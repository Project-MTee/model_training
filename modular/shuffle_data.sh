#!/bin/bash

# Expects the input data to be in formar {split}.{lang-pair}.{lang} in {data_dir}
# Writes the output in the same format into {out_dir}

# directory of the data
data_dir=$1

# output directory where shuffled files will be written
out_dir=$2

# comma separated list of language pairs. e.g. et-en,en-et,et-de,de-et
lang_pairs=$3

sets=${4:-"train,valid"}

mkdir -p ${out_dir}


get_seeded_random()
{
  seed="$1"
  openssl enc -aes-256-ctr -pass pass:"$seed" -nosalt \
    </dev/zero 2>/dev/null
}

for lang_pair in ${lang_pairs//,/ }; do
  src=$(echo $lang_pair | cut -d'-' -f1)
  tgt=$(echo $lang_pair | cut -d'-' -f2)

  for set in ${sets//,/ }; do
    echo "shuffling ${set}.${lang_pair}"
    file_prefix=${data_dir}/${set}.${lang_pair}
    out_prefix=${out_dir}/${set}.${lang_pair}
    cat ${file_prefix}.${src} | shuf --random-source=<(get_seeded_random 42) > ${out_prefix}.${src}
    cat ${file_prefix}.${tgt} | shuf --random-source=<(get_seeded_random 42) > ${out_prefix}.${tgt}
  done
done


