**image classifier for the CIFAR-10 dataset**

i built an imgae classifier for the [cifar10 dataset](https://www.cs.toronto.edu/~kriz/cifar.html), a dataset with 10 different image classes, from birds to cars, planes. the classifier uses a convolutional net built with tensorflow.

the network takes in a 32x32 image with 3 color channels. passes it through 2 convolutions and then uses three dense layers to put it in one of 10 classes. i implemented the convolutional, dense, and output layers myself using only tensorflow core libraries. the predicted classes are one-hot encoded.

my model has a testing accuracy of: 0.6531648089171974 or 65.3%

i trained this on my computer and k80 GPUs.