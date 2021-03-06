#!/bin/bash

# input dir
in_dir=$1

# model directory, expects the model name to be sp-model.{lang}.model
sp_model_dir=$2

# output dir for sp segmented files
sp_out_dir=$3

# comma separated list of language pairs. e.g. et-en,en-et,et-de,de-et
lang_pairs=$4

mkdir -p ${sp_out_dir}

pids=""
for lang_pair in ${lang_pairs//,/ }; do
  echo "segmenting $lang_pair"
  lang1=$(echo $lang_pair | cut -d'-' -f1)
  lang2=$(echo $lang_pair | cut -d'-' -f2)

  for split in train valid; do
    spm_encode --model=${sp_model_dir}/sp-model.${lang1}.model < ${in_dir}/${split}.${lang_pair}.${lang1} > ${sp_out_dir}/${split}.${lang_pair}.${lang1} &
    pids="${pids} $!"
    spm_encode --model=${sp_model_dir}/sp-model.${lang2}.model < ${in_dir}/${split}.${lang_pair}.${lang2} > ${sp_out_dir}/${split}.${lang_pair}.${lang2} &
    pids="${pids} $!"
  done

done

wait ${pids}

