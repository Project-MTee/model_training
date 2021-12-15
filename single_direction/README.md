# Single-directional model training

## Setup and description of training process

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

## Results on held-out test data

*N\A - no model trained, because of lack of data*

*\* - de encoder-decoder not finetuned*
<br>
<br>
<br>
**BLEU**
<br>
| general test set         |             |             |             |                                     |
| ------------------------ | ----------- | ----------- | ----------- | ----------------------------------- |
|                          | BASELINE    |             | MODULAR     |                                     |
| ET-RU                    | 28.82       |             | 29.81       |                                     |
| RU-ET                    | 25.7        |             | 27.06       |                                     |
| ET-EN                    | 40.65       |             | 40.37       |                                     |
| EN-ET                    | 31.44       |             | 31.49       |                                     |
| ET-DE                    | 31.85       |             | 30.75       |                                     |
| DE-ET                    | 28.59       |             | 27.65       |                                     |
| AVERAGE                  | 31.175      |             | 31.18833333 |                                     |
|                          |             |             |             |                                     |
| **legal test set**       |             |             |             |                                     |
|                          | BASELINE    | BASELINE FT | MODULAR     | MODULAR FT                          |
| ET-RU                    | 50.31       | 53.65       | 50.87       | 55.95                               |
| RU-ET                    | 47.87       | 52.66       | 51          | 57.5                                |
| ET-EN                    | 57.39       | 57.91       | 56.63       | 57.11                               |
| EN-ET                    | 47.82       | 48.01       | 47.1        | 47.62                               |
| ET-DE                    | 44.59       | 44.79       | 44.82       | 44.71                               |
| DE-ET                    | 41.27       | 41.09       | 41.71       | 41.48                               |
| AVERAGE                  | 48.20833333 | 47.95       | 48.68833333 | 50.72833333                         |
|                          |             |             |             |                                     |
| **crisis test set**      |             |             |             |                                     |
|                          | BASELINE    | BASELINE FT | MODULAR     | MODULAR FT                          |
| ET-RU                    | 29.82       | 32.01       | 31.76       | 35.46                               |
| RU-ET                    | 25.97       | 26.89       | 27.36       | 29.79                               |
| ET-EN                    | 35.64       | 40.43       | 36.57       | 41.41                               |
| EN-ET                    | 28.2        | 31.9        | 28.81       | 33.26                               |
| ET-DE                    | 24.96       | N\A         | 25.79       | 25.66\*                             |
| DE-ET                    | 21.19       | N\A         | 21.76       | 22.91\*                             |
| AVERAGE                  | 27.63       | 32.8075     | 28.675      | 34.98                               |
|                          |             |             |             |                                     |
| **military test set**    |             |             |             |                                     |
|                          | BASELINE    | BASELINE FT | MODULAR     | MODULAR FT                          |
| ET-RU                    | 23.44       | 23.44       | 24.17       | 23.57                               |
| RU-ET                    | 19.71       | 20.34       | 20.34       | 22.26                               |
| ET-EN                    | 42.68       | 44.35       | 42.1        | 44.33                               |
| EN-ET                    | 32.42       | 33.52       | 31.57       | 33.34                               |
| ET-DE                    | 31.55       | 31.8        | 30.62       | 31.96                               |
| DE-ET                    | 26.39       | 27.69       | 26.67       | 28.53                               |
| AVERAGE                  | 29.365      | 30.19       | 29.245      | 30.665                              |

<br>
<br>

**CHRF**

| general test set     |             |             |             |             |
| -------------------- | ----------- | ----------- | ----------- | ----------- |
|                      | BASELINE    |             | MODULAR     |             |
| ET-RU                | 57.26       |             | 57.87       |             |
| RU-ET                | 59.29       |             | 60.91       |             |
| ET-EN                | 65.05       |             | 65.04       |             |
| EN-ET                | 64.45       |             | 64.38       |             |
| ET-DE                | 60.31       |             | 60.06       |             |
| DE-ET                | 61.01       |             | 60.91       |             |
| AVERAGE              | 61.22833333 |             | 61.52833333 |             |
|                      |             |             |             |             |
| **legal test set**   |             |             |             |             |
|                      | BASELINE    | BASELINE FT | MODULAR     | MODULAR FT  |
| ET-RU                | 76.37       | 78.56       | 76.75       | 79.68       |
| RU-ET                | 79.54       | 81.75       | 80.62       | 83.63       |
| ET-EN                | 76.51       | 76.42       | 75.94       | 76.3        |
| EN-ET                | 76.33       | 75.94       | 75.82       | 76.04       |
| ET-DE                | 69.26       | 68.78       | 69.05       | 69.12       |
| DE-ET                | 69.81       | 69.51       | 70.2        | 70.11       |
| AVERAGE              | 74.63666667 | 75.16       | 74.73       | 75.81333333 |
|                      |             |             |             |             |
| **crisis test set**  |             |             |             |             |
|                      | BASELINE    | BASELINE FT | MODULAR     | MODULAR FT  |
| ET-RU                | 57.09       | 58.88       | 58.43       | 61.65       |
| RU-ET                | 58.5        | 59.64       | 59.59       | 62.3        |
| ET-EN                | 62.11       | 65.34       | 62.54       | 65.69       |
| EN-ET                | 62.29       | 64.74       | 62.21       | 65.46       |
| ET-DE                | 55.65       | N\A         | 55.89       | 56.2\*      |
| DE-ET                | 57.61       | N\A         | 58.29       | 58.81\*     |
| AVERAGE              | 58.875      | 62.15       | 59.49166667 | 63.775      |

<br>  
<br> 

**COMET**

| general test set     |              |             |              |            |
| -------------------- | ------------ | ----------- | ------------ | ---------- |
|                      | BASELINE     |             | MODULAR      |            |
| ET-RU                | 0.8113       |             | 0.8324       |            |
| RU-ET                | 0.9626       |             | 1.0208       |            |
| ET-EN                | 0.7438       |             | 0.757        |            |
| EN-ET                | 1.0691       |             | 1.0938       |            |
| ET-DE                | 0.6945       |             | 0.7196       |            |
| DE-ET                | 1.0325       |             | 1.065        |            |
| AVERAGE              | 0.8856333333 |             | 0.9147666667 |            |
|                      |              |             |              |            |
| **legal test set**   |              |             |              |            |
|                      | BASELINE     | BASELINE FT | MODULAR      | MODULAR FT |
| ET-RU                | 0.9711       | 0.9932      | 0.9827       | 1.0154     |
| RU-ET                | 1.1578       | 1.1813      | 1.2123       | 1.2387     |
| ET-EN                | 0.7722       | 0.7726      | 0.7776       | 0.7794     |
| EN-ET                | 1.2061       | 1.2031      | 1.2122       | 1.2254     |
| ET-DE                | 0.7308       | 0.7246      | 0.7368       | 0.7409     |
| DE-ET                | 1.1393       | 1.1378      | 1.1721       | 1.1703     |
| AVERAGE              | 0.9962166667 | 1.0021      | 1.015616667  | 1.02835    |
|                      |              |             |              |            |
| **crisis test set**  |              |             |              |            |
|                      | BASELINE     | BASELINE FT | MODULAR      | MODULAR FT |
| ET-RU                | 0.8038       | 0.8366      | 0.852        | 0.8999     |
| RU-ET                | 1.0221       | 1.0431      | 1.0638       | 1.1032     |
| ET-EN                | 0.7563       | 0.7799      | 0.7586       | 0.7914     |
| EN-ET                | 1.1207       | 1.1597      | 1.1384       | 1.1772     |
| ET-DE                | 0.6689       | \-          | 0.7058       | 0.7113\*   |
| DE-ET                | 1.0739       | \-          | 1.1018       | 1.1017\*   |
| AVERAGE              | 0.9076166667 | 0.954825    | 0.9367333333 | 0.992925   |
<br>
