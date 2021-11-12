#!/bin/bash

# path to the directory with sentencepiece processed files
in_dir=$1

# path to the directory containing the fairseq dictionary, filename format: fairseq.{lang}.vocab
sp_model_dir=$2

# output directory for the binarized files
bin_dir=$3

lang_pairs=$4

# number of workers to use for binarizing
workers=${5:-"8"}

mkdir -p ${bin_dir}


for lang_pair in ${lang_pairs//,/ }; do
  echo "preprocessing $lang_pair"
  lang1=$(echo $lang_pair | cut -d'-' -f1)
  lang2=$(echo $lang_pair | cut -d'-' -f2)

  fairseq-preprocess --source-lang ${lang1} --target-lang ${lang2} \
    --trainpref ${in_dir}/train.${lang_pair} \
    --validpref ${in_dir}/valid.${lang_pair} \
    --tgtdict ${sp_model_dir}/dict.${lang2}.txt \
    --srcdict ${sp_model_dir}/dict.${lang1}.txt \
    --destdir ${bin_dir} \
    --workers ${workers}

done

