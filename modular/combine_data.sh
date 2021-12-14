#!/bin/bash

# combines all domains

# expects the data to be {data_dir}/{lang_pair}/{domain}/{split}.{lang}
# modify file_prefix to change that
data_dir=$1

# outputs the data in format {out_dir}/{split}.{lang-pair}.{lang}
out_dir=$2

# comma separated list of language pairs. e.g. et-en,en-et,et-de,de-et
lang_pairs=$3

sets=${4:-"train,valid"}

domains=${5:-"general,legal,crisis,military"}

mkdir -p ${out_dir}

for lang_pair in ${lang_pairs//,/ }; do
  src=$(echo $lang_pair | cut -d'-' -f1)
  tgt=$(echo $lang_pair | cut -d'-' -f2)

  for set in ${sets//,/ }; do
    for domain in ${domains//,/ }; do
      file_prefix=${data_dir}/${lang_pair}/${domain}/${set}
      out_prefix=${out_dir}/${set}.${lang_pair}

      echo "${file_prefix} to ${out_prefix}"

      cat ${file_prefix}.${src} >> ${out_prefix}.${src}
      cat ${file_prefix}.${tgt} >> ${out_prefix}.${tgt}
    done
  done
done