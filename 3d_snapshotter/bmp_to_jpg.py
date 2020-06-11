'''
@yvan

converts bitmap (.bmp) files output by the pygame generator
to jpeg (.jpg) files with no compress/data loss.

'''
import os
import glob
from PIL import Image

img_paths = glob.glob('imgs/*.bmp')
for img_path in img_paths:
    img = Image.open(img_path)
    path, basename = os.path.split(img_path)
    basename, _ = os.path.splitext(basename)
    img = img.resize((32,32))
    img.save(f'imgs_jpg/{basename}.jpg', format='JPEG', subsampling=0, quality=100)
