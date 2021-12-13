# Modular model training

## Environment



Install SentencePiece with:

```
conda install -c conda-forge sentencepiece
```

The model training requires TartuNLP Fairseq fork which has the following requirements:
 (more details in https://github.com/TartuNLP/fairseq/tree/mtee):

* PyTorch version >= 1.5.0
* Python version >= 3.6

To install it run:

```
git clone https://github.com/TartuNLP/fairseq.git --branch mtee-0.1.0
cd fairseq
pip install ./
```

For more efficient training, installing NVIDIA Apex is recommended.

## Input files

The input files should be detokenized and normalized.

For the base model, all the domains need to be combined into a single directory. For example,
train.en-et.\* would contain all the domains. 
See *combine_data.sh*, expects input data in format *{lang_pair}/{domain}/{split}.{lang}* and outputs files in format *{split}.{lang-pair}.{lang}*.

The expected file format in further steps is "*{split}.{lang-pair}.{lang}*".

For example, in train split we would have files:
* train.et-ru.et
* train.et-ru.ru
* train.de-et.et
* train.de-et.de
* train.en-et.et
* train.en-et.en

The language pairs required are et-ru, en-et, de-et.
Note that only \*.et-en.\* is necessary, no need for duplicate \*.en-et.\* (same for other language pairs).
The other direction is assumed during the training. 

The data was also shuffled before the next steps. (see *shuffle_data.sh*)

## Sentencepiece

Training the Sentencepiece model is done in *train_sentencepiece.sh*.

This script trains each language a separate Sentencepiece (SP) model. All the train data from a language is combined and shuffled.
Then the first 10,000,000 sentences are taken for training the SP model.

Segmenting files is done in *preprocess-sp.sh* (file input format "*{split}.{lang-pair}.{lang}*", same output format)

## Binarizing

Binarizing files is done in *preprocess-fs.sh* (file input format "*{split}.{lang-pair}.{lang}*", same output format)

## Training the MT model


Script: *train_modular.sh*

When training the model, the update-frequency has to be chosen so that n-gpus*update-frequency=24 (used for training by UT).
The product can likely be higher, but lowering it could hurt translation quality.

## Full workflow

An example of the full workflow is in *workflow.sh*.

