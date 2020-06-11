**language translation from english to french**

i used a sequence to sequence (seq2seq) model to translate a small subset of phrases from english to french.

the model uses an encoder and a decoder to accomplish its task. the english words are encoded into a latent space (determined by the encoder's embedding size). the encoder is essentially trained to find an efficient representation in the latent space for a sequence of english words only. then the output of the encoder is passed to a decoder which is trained to take efficient representations of sequences of english words and convert them into the appropriate french counterpart sequences. implementation details can be seen by looking in the [dlnd_language_translation.ipynb](https://github.com/yvan/language-translation/blob/master/dlnd_language_translation.ipynb) file.

my model achieved a validation accuracy of 0.973 or 97.3%

here is an example translation:

```

Input
  English Words: ['france', 'is', 'never', 'cold', 'during', 'september', ',', 'and', 'it', 'is', 'snowy', 'in', 'october', '.']

Prediction
  French Words: ['france', 'ne', 'fait', 'jamais', 'froid', 'en', 'septembre', ',', 'et', 'il', 'est', 'neigeux', 'en', 'octobre', '.']
```

it's acutally pretty good and even got the grammar right.

i trained the model using a k80 GPU.