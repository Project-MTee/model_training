#!/bin/bash
# directory with the binarized files (from fairseq-preprocess)
bin_dir=$1

# directory for the checkpoints
checkpoint_dir=$2

# name for the model
model_name=$3

# all lang-pairs that the model will support
lang_pairs=$4

# the model to fine-tune from
finetune_model_path=$5

# n_gpus * --update-freq = 24


fairseq-train ${bin_dir}/ \
  --task multilingual_translation_sampled --arch multilingual_transformer \
  --max-epoch 200 \
  --patience 5 \
  --seed 1 \
  --finetune-from-model ${finetune_model_path} \
  --tensorboard-logdir tensorboard_logs/${model_name} --save-dir ${checkpoint_dir}/${model_name} \
  --lang-pairs ${lang_pairs} \
  --sampling-method concat \
  --max-tokens 15000 --update-freq 24 \
  --share-decoder-input-output-embed --share-language-specific-embeddings \
  --encoder-embed-dim 512 --decoder-embed-dim 512 \
  --encoder-ffn-embed-dim 2048 --decoder-ffn-embed-dim 2048 \
  --attention-dropout 0.1 --activation-dropout 0.1 --dropout 0.1 \
  --lr 0.0002 --lr-scheduler inverse_sqrt --optimizer adam --adam-betas '(0.9, 0.98)' \
  --warmup-updates 4000 --warmup-init-lr '1e-07' --label-smoothing 0.1 --criterion label_smoothed_cross_entropy \
  --ddp-backend=no_c10d --fp16 --num-workers 0

