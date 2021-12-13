# Single-directional model training

**Requirements for environment:**
```
sentencepiece==0.1.96
fairseq==0.10.2
```

Before starting the training, the data can be normalized using the `normalization.py` script.

The `baseline_train_workflow.sh` script takes data folder (where the files are already divided into train-test-valid) as input and outputs a single-direction model trained on the input data.

**Steps of the script:**

1. The joint sentencepiece model is trained on input data from both languages (training data files).
2. Training data is then tokenized by the trained sentencepiece model.
3. Tokenized training data is input for `fairseq-preprocess` command which produces binarized data files into the specified binarized data folder.
4. The binarized data folder is input to `fairseq-train` command which produces the final single-direction model.

**Note:** the sentencepiece model is trained jointly over the two languages trained.

`baseline_train_workflow.sh` takes 12 arguments:

1. clean data folder (e.g. with files like train.et, train.en, test.et, test.en, valid.et, valid.et)
2. sentencepiece model directory path
3. tokenized data directory path (tokenized by trained sentencepiece model)
4. sentencepiece model prefix
5. source language (en/et/ru/de)
6. target language (en/et/ru/de)
7. binarized data directory path
8. model directory path
9. sentencepiece vocabulary size
10. train file name prefix
11. validation file name prefix
12. test file name prefix

**Running example:**

```
baseline_train_workflow.sh ../mt_project/clean_data/et_en/general ../mt_project/sp_models ../mt_project/tokenized_data_et_en_general SPM_et_en et en ../mt_project/data-bin_et_en_general ../mt_project/et_en_general_model 32000 train valid test
```

* `clean_data/et-en/general` folder consists of files `train.et, train.en, test.et, test.en, valid.et, valid.et`
* estonian is the source language and english is the target language
* tokenized data folder should be created for every language pair direction and domain separately, so to avoid overwriting other tokenized data

