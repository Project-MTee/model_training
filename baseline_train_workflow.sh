#!/bin/bash

#$1 = clean data folder (files like train.et, train.en, test.et, test.en, valid.et, valid.et)
#$2 = sentencepiece model path
#$3 = tokenized data folder path
#$4 = sentencepiece dictionary path
#$5 = source language (en/et/ru/de)
#$6 = target language (en/et/ru/de)
#$7 = binarized data directory path
#$8 = model directory path

python spm_tokenization.py --datadir $1 --spmodel $2 --destdir $3


# preprocessing 
DATA_FOLDER=$3
SPM_PATH=$4
SRC_LANG=$5
TGT_LANG=$6
DEST_DIR=$7
fairseq-preprocess \
    --srcdict $SPM_PATH \
    --tgtdict $SPM_PATH \
    --source-lang $SRC_LANG --target-lang $TGT_LANG \
    --trainpref $DATA_FOLDER/train \
    --validpref $DATA_FOLDER/valid \
    --testpref $DATA_FOLDER/test \
    --destdir $DEST_DIR --thresholdtgt 0 --thresholdsrc 0 \
    --workers 20
	
	
# baseline training
CHECKPOINT_DIR=$8
fairseq-train --fp16 \
   $DEST_DIR \
   --source-lang $SRC_LANG --target-lang $TGT_LANG \
   --arch transformer --share-all-embeddings \
   --optimizer adam --adam-betas '(0.9, 0.98)' --clip-norm 0.0 \
   --lr 0.001 --lr-scheduler inverse_sqrt --warmup-updates 4000 \
   --max-tokens 15000 --update-freq 8 \
   --save-interval-updates 5000 \
   --keep-interval-updates 32 \
   --save-dir $CHECKPOINT_DIR \
   --tensorboard-logdir $CHECKPOINT_DIR/log-tb
   
   
   
   



