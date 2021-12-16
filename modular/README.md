# Modular model training

## Environment

Install SentencePiece and portobuf for modifying SentecePiece models:
```
conda install -c conda-forge sentencepiece
pip install protobuf 
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
switching et-ru. When training the model, all directions must still be explicitly stated in the parameters.

When back translated data is used, the data is likely not symmetric and all directions must be present in the training data.
If you are not sure if the data is symmetric, preprocess so that all directions are present in the training data.


After combining various datasets (different domains for example) the data should be shuffled. (see `shuffle_data.sh`)

For training, the data needs to have a train (prefix *train* in the data) and validation (prefix *valid* for the data) data.
The validation data is used for tracking training progress and early stopping.

## Sentencepiece

### Training
Training the Sentencepiece model is done in `train_sentencepiece.sh`.

The script trains a separate Sentencepiece (SP) model for each language. All the parallel training data from a language is combined and shuffled.
Then the first 10,000,000 sentences are taken for training the SP model. To avoid duplicate training data with symmetric dataset
 use half of the language pairs as explained in Input files section.
 
Example:
```
bash train_sentencepiece.sh ${data_dir} ${tmp_dir} ${sp_model_out_dir} et-en,et-de,et-ru
```
 
### Segmenting

Segmenting files is done in `preprocess-sp.sh` (file input format "*{split}.{lang-pair}.{lang}*", same output format)

Example:
```
bash preprocess-sp.sh ${data_dir} ${sp_model_dir} ${sp_out_dir} et-en,et-de,et-ru,en-et,de-et,ru-et
```

## Binarizing
Binarizing files is done in `preprocess-fs.sh` (file input format "*{split}.{lang-pair}.{lang}*", same output format)

```
bash preprocess-fs.sh ${sp_data_dir} ${sp_model_dir} ${bin_out_dir} et-en,et-de,et-ru,en-et,de-et,ru-et
```

*Note: After binarizing, the SentencePiece segmented files can be deleted, since they will not be used for training.*

## Training the MT model
When training the model, the update-frequency has to be chosen so that n-gpus*update-frequency=24.
The product can likely be higher, but lowering it could hurt translation quality. 
You can choose the max-tokens according to your GPU memory. It is recommended that you choose the largest possible 
max-tokens as fits in you GPU memory for efficient training.

Example:
```
bash train_modular.sh ${bin_dir} checkpoints modular_baseline de-et,en-et,et-ru,et-de,et-en,ru-et
```

### Fine-tuning
Fine-tuning can be carried out by either continuing the training with new training data
or restarting the training (`finetune_modular.sh` or `finetune_modular_restart.sh` respectively).

Example:
```
bash finetune_modular.sh ${domain_bin_dir} checkpoints modular_domain_ft de-et,en-et,et-ru,et-de,et-en,ru-et checkpoints/modular_baseline/checkpoint_best.pt
```
or
```
bash finetune_modular_restart.sh ${domain_bin_dir} checkpoints modular_domain_ft de-et,en-et,et-ru,et-de,et-en,ru-et checkpoints/modular_baseline/checkpoint_best.pt
```

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

## Translating
To translate with a trained model use `translate.sh`.

Example:
```
bash translate.sh checkpoints/model/checkpoint_best.pt de-et,en-et,et-ru,et-de,et-en,ru-et sp-models/sp-model.et.model sp-models test.et hyp.test.en et en
```

## Ensembling

We use averaging checkpoint weights as the ensembling method.

Download the ensembling script:
```
wget https://raw.githubusercontent.com/pytorch/fairseq/ee833ed49d79da00faa396bd0509782841d3d688/scripts/average_checkpoints.py
```

An example of how ensembled checkpoint can be created:
```
python average_checkpoints.py --inputs checkpoints/checkpoint60.pt checkpoints/checkpoint61.pt checkpoints/checkpoint62.pt --output checkpoints/checkpoint_average.pt
```

As the input, provide the checkpoints you wish to ensemble.

## Examples of workflow

For training general-purpose model, you might want to use data of all domians during training. In
this case they should be combined into the general data

### Workflow with parallel data

For training with parallel data, an example of the workflow is in `workflow.sh`.

### Workflow with back translated data
Without tags:
1. train the sentencepiece model with parallel data (`train_sentencepiece.sh`)
1. combine back translated and parallel training data (use validation data from parallel data)
1. preprocess machine translated data and parallel data separately (`preprocess-sp.sh`)
1. binarize training and validation data (`preprocess-fs.sh`)
1. train models (`train_modular.sh`)

With tags (optional):
1. train the sentencepiece model with parallel data (`train_sentencepiece.sh`)
1. preprocess machine translated data and parallel data separately (`preprocess-sp.sh`)
1. add tags to preprocessed back translation data 
1. combine parallel and back translated data (use validation data from parallel data)
1. binarize training and validation data (`preprocess-fs.sh`)
1. train models (`train_modular.sh`)

### Workflow for fine-tuning
The steps of preprocessing training fine-tuning model are:
1. preprocess domain data (train and validation sets) 
with the sentencepiece model that was used to preprocess the data the model was trained with (`preprocess-sp.sh`)
1. binarize data (`preprocess-fs.sh`)
1. fine-tune models (`finetune_modular.sh` or `finetune_modular_restart.sh`)

## Held-out test set automatic evaluation scores

We evaluate the translation quality of the models on 3 metrics: BLEU, chrF, and COMET.

Models:
* public model - model trained with public data, including back-translated data.
* public, ft + bt - same as public, but additionally includes forward-translated data.
* private model - model trained with public and proprietary data.
* domain ft - models fine-tuned with domain data.


### BLEU

#### General
| direction | public | public, ft + bt | private |
| --------- | ------ | --------------- | ------- |
| et-en     | 38.9   | 39.2            | 38.4    |
| et-de     | 29.1   | 29.2            | 29.3    |
| et-ru     | 29     | 30              | 28.7    |
| en-et     | 31.4   | 30.6            | 30.7    |
| de-et     | 27.5   | 26.9            | 28.2    |
| ru-et     | 28.1   | 27.6            | 27.8    |
| AVG       | 30.67  | 30.58           | 30.52   |

#### Legal
| direction | public | public, ft + bt | public, domain ft | private | private, domain ft |
| --------- | ------ | --------------- | ----------------- | ------- | ------------------ |
| et-en     | 53.5   | 53.5            | 56.2              | 54      | 54.7               |
| et-de     | 41.2   | 40.9            | 43.5              | 42.9    | 42.9               |
| et-ru     | 45.4   | 50.7            | 56.9              | 47.1    | 53.3               |
| en-et     | 45.7   | 44.2            | 47.1              | 45.6    | 46.2               |
| de-et     | 39.1   | 38.2            | 40.8              | 40.1    | 40.1               |
| ru-et     | 53.0   | 52.7            | 60.8              | 50.4    | 53.7               |
| AVG       | 46.31  | 46.70           | 50.89             | 46.68   | 48.48              |

#### Crisis
| direction | public | public, ft + bt | public, domain ft | private | private, domain ft |
| --------- | ------ | --------------- | ----------------- | ------- | ------------------ |
| et-en     | 36.4   | 37.2            | 38.8              | 34.4    | 39.9               |
| et-de     | 25.2   | 25.8            | 24.1              | 26.2    | 25.8               |
| et-ru     | 32.5   | 33.4            | 34.6              | 31.6    | 34.8               |
| en-et     | 30.2   | 30.4            | 31.1              | 28.8    | 31.9               |
| de-et     | 22.4   | 22.6            | 20.6              | 22.8    | 21.9               |
| ru-et     | 30.6   | 29.1            | 31.6              | 29.9    | 31.1               |
| AVG       | 29.55  | 29.75           | 30.14             | 28.95   | 30.90              |

#### Military
| direction | public | public, ft + bt | public, domain ft | private | private, domain ft |
| --------- | ------ | --------------- | ----------------- | ------- | ------------------ |
| et-en     | 40.5   | 41              | 43                | 40.4    | 42.6               |
| et-de     | 28.9   | 28.9            | 30.5              | 29      | 30.9               |
| et-ru     | 24.8   | 24.7            | 26.4              | 24.4    | 27.1               |
| en-et     | 31.7   | 31.4            | 34                | 29.8    | 33.1               |
| de-et     | 25.2   | 25              | 27.4              | 24.9    | 28.1               |
| ru-et     | 22.8   | 21.7            | 24.7              | 21.9    | 25                 |
| AVG       | 28.98  | 28.78           | 31.00             | 28.40   | 31.13              |


### chrF

#### General
| direction | public | public, ft + bt | private |
| --------- | ------ | --------------- | ------- |
| et-en     | 64.15  | 64.23           | 63.3    |
| et-de     | 58.68  | 58.57           | 59.2    |
| et-ru     | 57.48  | 58.3            | 57.2    |
| en-et     | 64.26  | 63.71           | 63      |
| de-et     | 60.7   | 60.09           | 60.7    |
| ru-et     | 61.63  | 61.07           | 61.6    |
| AVG       | 61.15  | 61.00           | 60.83   |

#### Legal

| direction | public | public, ft + bt | public, domain ft | private | private, domain ft |
| --------- | ------ | --------------- | ----------------- | ------- | ------------------ |
| et-en     | 74.1   | 73.9            | 75.7              | 63.3    | 74.8               |
| et-de     | 66.7   | 66.5            | 68.3              | 59.2    | 68.2               |
| et-ru     | 73.0   | 76.6            | 80.0              | 56.6    | 78.1               |
| en-et     | 74.9   | 73.9            | 75.9              | 63      | 75.3               |
| de-et     | 68.3   | 68.0            | 69.6              | 60.7    | 69.3               |
| ru-et     | 81.7   | 81.6            | 85.0              | 59.2    | 82                 |
| AVG       | 73.10  | 73.41           | 75.74             | 60.33   | 74.62              |

#### Crisis

| direction | public | public, ft + bt | public, domain ft | private | private, domain ft |
| --------- | ------ | --------------- | ----------------- | ------- | ------------------ |
| et-en     | 62.7   | 62.9            | 63.9              | 60.7    | 64.6               |
| et-de     | 55.7   | 56              | 55.1              | 56.3    | 56.2               |
| et-ru     | 59.2   | 59.6            | 60.9              | 58.5    | 61.2               |
| en-et     | 63.4   | 63.6            | 64.1              | 62.2    | 64.3               |
| de-et     | 58.8   | 58.7            | 57.1              | 58.8    | 57.9               |
| ru-et     | 62.6   | 61.3            | 63.4              | 62.3    | 63                 |
| AVG       | 60.40  | 60.35           | 60.75             | 59.80   | 61.20              |

#### Military

| direction | public | public, ft + bt | public, domain ft | private | private, domain ft |
| --------- | ------ | --------------- | ----------------- | ------- | ------------------ |
| et-en     | 65.86  | 65.89           | 67.16             | 65.5    | 66.9               |
| et-de     | 58.83  | 59.01           | 59.71             | 59.2    | 60.2               |
| et-ru     | 52.57  | 52.55           | 53.4              | 51.9    | 53.9               |
| en-et     | 65     | 64.6            | 66.54             | 64.4    | 66.1               |
| de-et     | 58.51  | 58.25           | 59.74             | 58.6    | 60.5               |
| ru-et     | 54.89  | 54.28           | 56.12             | 54.4    | 56.1               |
| AVG       | 59.28  | 59.10           | 60.45             | 59.00   | 60.62              |

### COMET

#### General

| direction | public | private |
| --------- | ------ | ------- |
| et-en     | 0.7442 | 0.7273  |
| et-de     | 0.7158 | 0.7210  |
| et-ru     | 0.8448 | 0.8414  |
| en-et     | 1.1036 | 1.1126  |
| de-et     | 1.0766 | 1.0861  |
| ru-et     | 1.0451 | 1.0472  |
| AVG       | 0.9217 | 0.92260 |

#### Legal

| direction | public | public domain ft | private |
| --------- | ------ | ---------------- | ------- |
| et-en     | 0.7569 | 0.7736           | 0.7612  |
| et-de     | 0.7185 | 0.7263           | 0.7288  |
| et-ru     | 0.9581 | 1.0239           | 1.0037  |
| en-et     | 1.2155 | 1.2282           | 1.2228  |
| de-et     | 1.1569 | 1.1747           | 1.1736  |
| ru-et     | 1.2203 | 1.2460           | 1.2314  |
| AVG       | 1.0044 | 1.02878          | 1.0203  |

#### Crisis

| direction | public | public domain ft | private |
| --------- | ------ | ---------------- | ------- |
| et-en     | 0.7659 | 0.7756           | 0.7772  |
| et-de     | 0.7020 | 0.6872           | 0.7031  |
| et-ru     | 0.8778 | 0.90140          | 0.8947  |
| en-et     | 1.1574 | 1.16070          | 1.1740  |
| de-et     | 1.1125 | 1.07410          | 1.0871  |
| ru-et     | 1.1124 | 1.12990          | 1.1204  |
| AVG       | 0.9547 | 0.95482          | 0.9594  |

#### Military

| direction | public | public domain ft | private |
| --------- | ------ | ---------------- | ------- |
| et-en     | 0.5351 | 0.5605           | 0.5643  |
| et-de     | 0.4403 | 0.4491           | 0.4557  |
| et-ru     | 0.3312 | 0.3249           | 0.3406  |
| en-et     | 0.8429 | 0.8757           | 0.876   |
| de-et     | 0.728  | 0.7612           | 0.7673  |
| ru-et     | 0.4432 | 0.4569           | 0.4728  |
| AVG       | 0.5535 | 0.57138          | 0.5795  |