**generating human faces with a generative adversarial network**

i used a generative adversarial network (GAN) to generate novel faces. 

the gan is built in pure tensorflow and has two parts, the descirminator and the generator. the discriminator tries to tell if an input you give it is a human face or not. the generator tries to generate an image of a human face of sufficient quality such that the disciminator thinks this generated face has the characteristics of a real human face.

both networks are concolutional networks built in tensorflow. the generator can be thought of a deconvolutional net (using transpose convolutions) and the discriminator as a normal convolutional net.

first i trained my model on the small mnist numbers dataset to see that the generator is capable of learning hwo to make numbers. then i trained it on the celebrity faces dataset to get a generator capable fo generating a realistic human face.

the faces ended up pretty good, but more hyper parameter tweaking is probably necessary to get them to look as realistic as possible.

trained on a k80 GPU.