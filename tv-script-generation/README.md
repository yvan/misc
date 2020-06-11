**generating a simpson's like tv-script**

i used a recurrent nerual net (rnn) model to generate a simpson's like tv script. 

first i created word embeddings (weight lookups) for all the words (the corpus) in my simpson's dataset. then i trained a recurrent neural net on these word embeddings. the model tries to predict the next word in a sequence of words. i used common tensorflow rnn tools to construct the network.

here is an example script:

```
moe_szyslak:(snaps fingers, inspired) hey, how about uncle moe's family feedbag?
homer_simpson: i want you to meet the springfield.
homer_simpson: hey, i created this.
barney_gumble: drinks all around!
homer_simpson: what's with the crazy getup!
moe_szyslak: wait a minute...(to moe) pardon me? i'm all alone!
lenny_leonard: it's too late to turn back, moe. we've exchanged for the first time with the world of my life. bart's, why don't you slap him some payback?
homer_simpson: revenge? on mr. x were here.
moe_szyslak: here you go, homer. a hundred bucks says".
moe_szyslak:(furious) you callin' my one of my?
barney_gumble: you know, i heard of a new reality show where they...(sobs)
lisa_simpson:(bursts in) moe, my family's gone, my dog hates me, and i can't stand do better.
moe_szyslak:(annoyed) hey, come on, there's your picture on the front of my youth
```

while nonsensical this script seems to have captured some of the spirit of the simpsons.

i trained this model on a k80 GPU.