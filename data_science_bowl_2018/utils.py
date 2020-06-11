import torch
import torch.nn.functional as F
from torch.nn import BCELoss as bce
from torch.nn.modules.loss import _Loss
from torch.autograd import Variable, Function

import os
import glob
import shutil
import numpy as np
import pandas as pd
from PIL import Image
from skimage.morphology import label
from sklearn.model_selection import train_test_split

def prob_to_rles(x, cutoff=0.5):
    lab_img = label(x > cutoff)
    for i in range(1, lab_img.max() + 1):
        yield rle_encode(lab_img == i)
        
# https://www.kaggle.com/paulorzp/run-length-encode-and-decode
def rle_encode(img):
    '''
    img: numpy array, 1 - mask, 0 - background
    Returns run length as string formated
    '''
    # if you dont transpose it scores 0!
    # this is bceause its top to bottomr first
    # then left to right so you gotta trnaspose.
    pixels = img.T.flatten()
    pixels[0] = 0
    pixels[-1] = 0
    runs = np.where(pixels[1:] != pixels[:-1])[0] + 2
    runs[1::2] = runs[1::2] - runs[:-1:2]
    return ' '.join(str(x) for x in runs)
 
def rle_decode(mask_rle, shape):
    '''
    mask_rle: run-length as string formated (start length)
    shape: (height,width) of array to return 
    Returns numpy array, 1 - mask, 0 - background

    '''
    s = mask_rle.split()
    starts, lengths = [np.asarray(x, dtype=int) for x in (s[0:][::2], s[1:][::2])]
    starts -= 1
    ends = starts + lengths
    img = np.zeros(shape[0]*shape[1], dtype=np.uint8)
    for lo, hi in zip(starts, ends):
        img[lo:hi] = 1
    return img.reshape(shape)

def weights_init(m):
    if type(m) == nn.Conv2d or type(m) == nn.ConvTranspose2d:
        nn.init.xavier_uniform(m.weight, gain=np.sqrt(2))
        nn.init.constant(m.bias,0.0)
    elif type(m) == nn.BatchNorm2d:
        m.weight.data.uniform_(1.0,0.02)
        m.bias.data.zero_()
        
def unfreeze_model(model):
    for p in model.parameters():
            p.requires_grad = True

def freeze_model(model):
    for p in model.parameters():
            p.requires_grad = False

def rle_encoding(x):
    '''
    x: numpy array of shape (height, width), 1 - mask, 0 - background
    Returns run length as list
    '''
    dots = np.where(x.T.flatten()==1)[0] # .T sets Fortran order down-then-right
    run_lengths = []
    prev = -2
    for b in dots:
        if (b > prev+1): run_lengths.extend((b+1, 0))
        run_lengths[-1] += 1
        prev = b
    return run_lengths

def rescale(X,xmin,xmax):
    _std = (X - X.min()) / (X.max() - X.min())
    return _std * (xmax - xmin) + xmin

def show_one(file):
    image = Image.open(file, 'r')
    plt.imshow(np.asarray(image))
    plt.axis('off')
    
def show_n(img_files, n=6):
    _, ax = plt.subplots(1, n, sharex='col', sharey='row', figsize=(24,6))
    
    for i, img_file in enumerate(img_files):
        ax[i].imshow(img_file)
        ax[i].axis('off')

def chunker(seq, size):
    return (seq[pos:pos + size] for pos in range(0, len(seq), size))


def check_param_sum(model):
    return sum([torch.sum(param).data[0] for param in model.parameters()])

def to_variable(x):
    if torch.cuda.is_available():
        x = x.cuda()
    return Variable(x)

class DiceCoeff(Function):
    def forward(self, input, target):
        self.save_for_backward(input, target)
        self.inter = torch.dot(input, target) + 0.0001
        self.union = torch.sum(input) + torch.sum(target) +0.0001
        
        t = 2*self.inter.float()/self.union.float()
        return t
    
    def backward(self, grad_output):
        input,target = self.saved_variables
        grad_input = grad_target = None
        if self.needs_input_grad[0]:
            grad_input = grad_output *2* (target * self.union + self.inter) / self.union*self.union
            
        if self.needs_input_grad[1]:
            grad_target = None
        return grad_input, grad_target
    
def dice_coeff(input, target):
    if input.is_cuda:
        s = Variable(torch.FloatTensor(1).cuda().zero_())
    else:
        s = Variable(torch.FloatTensor(1).zero_())
        
    for i,c in enumerate(zip(input, target)):
        s = s + DiceCoeff().forward(c[0], c[1])
        
    return s / (i+1)

class DiceLoss(_Loss):
    def forward(self, input, target):
        return 1 - dice_coeff(input, target)
    
class BCEDiceLoss(_Loss):
    def forward(self, input, target):
#         bce_ = bce()
        dl = DiceLoss()
        return dl(input, target)#bce_(input, target) + 

def convert_raw_train(data_dir='data', folder_name='stage1_train', new_train='train_img', new_labels='train_mask', valid_img='valid_img', valid_mask='valid_mask', make_valid=False, rand_state=100):
    labels = pd.read_csv(os.path.join(data_dir, 'stage1_train_labels.csv', 'stage1_train_labels.csv'))
    view_ids = list(labels['ImageId'].drop_duplicates())
    imgs = [glob.glob(os.path.join(data_dir, folder_name, f_id, 'images','*.png'))[0] for f_id in view_ids]
    mask_sets = [glob.glob(os.path.join(data_dir, folder_name, f_id, 'masks','*.png')) for f_id in view_ids]

    names = []
    images = []
    combined_masks = []
    for f_id in view_ids:
        image = glob.glob(os.path.join(data_dir, folder_name, f_id, 'images','*.png'))
        mask_sets = glob.glob(os.path.join(data_dir, folder_name, f_id, 'masks','*.png'))
        masks = [np.asarray(Image.open(img_file, 'r')) for img_file in mask_sets]
        if len(image) > 0 and len(masks) > 0:
            mask = Image.fromarray(sum(masks+[np.zeros(masks[0].shape)])).convert('RGB')
            pimg = Image.fromarray(np.asarray(Image.open(image[0], 'r'))).convert('RGB')
            names.append(f_id)
            combined_masks.append(mask)
            images.append(pimg)
            
    train_path, mask_path = os.path.join(data_dir,new_train,'all'), os.path.join(data_dir,new_labels,'all')
    valid_path, valid_mask = os.path.join(data_dir, valid_img, 'all'), os.path.join(data_dir, valid_mask, 'all')
    if os.path.exists(valid_path): shutil.rmtree(valid_path)
    if os.path.exists(valid_mask): shutil.rmtree(valid_mask)
    os.makedirs(valid_path) 
    os.makedirs(valid_mask)
    if os.path.exists(train_path): shutil.rmtree(train_path)
    if os.path.exists(mask_path): shutil.rmtree(mask_path)
    os.makedirs(train_path)
    os.makedirs(mask_path)
    
    i_m_n = [(image, mask, name) for image, mask, name in zip(images, combined_masks, names)]
    train_data = []
        
    if make_valid:
        train_data, valid_data = train_test_split(i_m_n, test_size=0.1, random_state=rand_state)

        for image, mask, name in valid_data:
            image.save(os.path.join(valid_path, name+'_img.jpg'))
            mask.save(os.path.join(valid_mask, name+'_mask.jpg'))
    else:
        train_data = i_m_n
            
    for image, mask, name in train_data:
        image.save(os.path.join(train_path, name+'_img.jpg'))
        mask.save(os.path.join(mask_path, name+'_mask.jpg'))
        
def convert_raw_test(data_dir='data', folder_name='stage1_test', folder_new='test_img'):
    img_paths = glob.glob(os.path.join(data_dir, folder_name, '*', 'images','*.png'))
    
    new_folder = os.path.join(data_dir,folder_new,'all')
    
    if os.path.exists(new_folder): shutil.rmtree(new_folder)
    os.makedirs(new_folder)    
    
    imgs = []
    for img_path in img_paths:
        img = Image.open(img_path, 'r').convert('RGB')
        bname = os.path.basename(img_path)
        path, _ = os.path.splitext(os.path.join(new_folder, bname))
        img.save(path+'_test.jpg')
    