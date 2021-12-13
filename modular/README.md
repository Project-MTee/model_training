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

For tracking the experiments tensorboard should also be installed:
```
pip install tensorboard
```

WandB is also supported, see https://docs.wandb.ai/quickstart (installing) and https://fairseq.readthedocs.io/en/latest/command_line_tools.html (--wandb-project).


## Input files

The input files should be detokenized and normalized.

The expected file format in all further scripts is "*{train/valid}.{lang-pair}.{lang}*". 
The modular model assumes that each language-pair there is a separate training and validation data file. 


When training with data that is symmetric (i.e. the et-ru and ru-et datasets are the same), only one of the directions needs to be preprocessed (to save space and time).
For example, with en-et, et-en, de-et, et-de we can preprocess en-et, de-et.

When et-ru and ru-et are the language pairs of the model, but only et-ru is present, the model additionally assumes ru-et by automatically
swiching et-ru. When training the model, all directions must still be explicitly stated in the parameters.

When back translated data is used, the data is likely not symmetric and all directions must be present in the training data.
If you are not sure if the data is symmetric, preprocess so that all directions are present in the training data.


After combining various datasets (different domains for example) the data should be shuffled. (see *shuffle_data.sh*)

For training, the data needs to have a train (prefix *train* in the data) and validation (prefix *valid* for the data) data.
The validation data is used for tracking training progress and early stopping.

## Sentencepiece
Scripts: *train_sentencepiece.sh*, *preprocess-sp.sh*

Training the Sentencepiece model is done in *train_sentencepiece.sh*.

The script trains a separate Sentencepiece (SP) model for each language. All the parallel training data from a language is combined and shuffled.
Then the first 10,000,000 sentences are taken for training the SP model. To avoid duplicate training data with symmetric dataset
 use half of the language pairs as explained in Input files section.

Segmenting files is done in *preprocess-sp.sh* (file input format "*{split}.{lang-pair}.{lang}*", same output format)

## Binarizing
Script: *preprocess-fs.sh*

Binarizing files is done in *preprocess-fs.sh* (file input format "*{split}.{lang-pair}.{lang}*", same output format)

## Training the MT model
Script: *train_modular.sh*

When training the model, the update-frequency has to be chosen so that n-gpus*update-frequency=24.
The product can likely be higher, but lowering it could hurt translation quality. 
You can choose the max-tokens according to your GPU memory. It is recommended that you choose the largest possible 
max-tokens as fits in you GPU memory for efficient training.

### Fine-tuning
Fine-tuning can be carried out by either continuing the training with new training data
or restarting the training (*finetune_modular.sh* or *finetune_modular_restart.sh* respectively).

## Back translation data
The monolingual data translated in this porject is in format *train.{src}-{tgt}.{src/tgt}*. The source (*train.{src}-{tgt}.{src}*) is
the original text and the target (*train.{src}-{tgt}.{tgt}*) is the translation. 

To use it for back translation add *train.{src}-{tgt}.{tgt}* translation file to the *train.{tgt}-{src}.{tgt}* training data file and
*train.{src}-{tgt}.{src}* translation file to the *train.{tgt}-{src}.{src}* training file. This way the original sentence
is on the target side during the model training.


To use back translation tags, add them at the beginning of each line after preprocessing the data with SentencePiece:
```
cat ${in_file} | awk '{print "<bt> " $0}' >> ${out_file}
```
For forward translation tags:
```
cat ${in_file} | awk '{print "<ft> " $0}' >> ${out_file}
```

This is done after SentencePiece processing to keep SentencePiece from splitting the tags. The usage of the tags is optional,
since they might not provide any noticeable difference in the translation quality.


## Examples of workflow

For training general-purpose model, you might want to use data of all domians during training. In
this case they should be combined into the general data

### Workflow with parallel data

For training with parallel data, An example of the workflow is in *workflow.sh*.

### Workflow with back translated data
Without tags:
* train the sentencepiece model with parallel data (*train_sentencepiece.sh*)
* combine back translated and parallel training data (use validation data from parallel data)
* preprocess machine translated data and parallel data separately (*preprocess-sp.sh*)
* binarize training and validation data (*preprocess-fs.sh*)
* train models (*train_modular.sh*)

With tags (optional):
* train the sentencepiece model with parallel data (*train_sentencepiece.sh*)
* preprocess machine translated data and parallel data separately (*preprocess-sp.sh*)
* add tags to preprocessed back translation data 
* combine parallel and back translated data (use validation data from parallel data)
* binarize training and validation data (*preprocess-fs.sh*)
* train models (*train_modular.sh*)

### Workflow for fine-tuning
The steps of preprocessing training fine-tuning model are:
* preprocess domain data (train and validation sets) 
with the sentencepiece model that was used to preprocess the data the model was trained with (*preprocess-sp.sh*)
* binarize data (*preprocess-fs.sh*)
* fine-tune models (*finetune_modular.sh* or *finetune_modular_restart.sh*)

