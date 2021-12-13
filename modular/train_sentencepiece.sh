#!/bin/bash

# path to input data
in_path=$1

# where sp will write temporary files
tmp_path=$2

# path where sentencepiece models and vocabularies will be saved
out_path=$3

# langpairs used
# when the data is symmetric use only half of the language pairs to avoid duplicate data
# e.g. for en-et, et-en, de-et, et-de use en-et, de-et
lang_pairs=$4

vocabulary_size=${5:-"24000"}

character_coverage=${6:-"0.9999"}

required_symbols=${7:-$(<top500.txt)}

mkdir -p ${tmp_path} ${out_path}

# append all sentences for a language into a single file
for lang_pair in ${lang_pairs//,/ }; do
  lang1=$(echo $lang_pair | cut -d'-' -f1)
  lang2=$(echo $lang_pair | cut -d'-' -f2)

  cat ${in_path}/train.${lang_pair}.${lang1} >>${tmp_path}/data.${lang1}
  cat ${in_path}/train.${lang_pair}.${lang2} >>${tmp_path}/data.${lang2}
done

# seed for repeatable experiments
get_seeded_random() {
  seed="$1"
  openssl enc -aes-256-ctr -pass pass:"$seed" -nosalt \
    </dev/zero 2>/dev/null
}

langs=$(echo ${lang_pairs} | tr '-' '\n' | tr ',' '\n' | sort | uniq | paste -sd "," -)

pids=""

for lang in ${langs//,/ }; do
  echo "training ${lang} sp model"

  # select 10,000,000 sentences from each language for training
  cat ${tmp_path}/data.${lang} | shuf --random-source=<(get_seeded_random 42) | head -n10000000 >${tmp_path}/train.${lang}
  rm ${tmp_path}/data.${lang}

  spm_train --input=${tmp_path}/train.${lang} --model_prefix=${out_path}/sp-model.${lang} --control_symbols="<bt>,<ft>" \
    --vocab_size=${vocabulary_size} --character_coverage=${character_coverage} --model_type=bpe &
  pids="${pids} $!"
done

wait ${pids}

script_path=$(dirname "$0")

for lang in ${langs//,/ }; do
  rm ${tmp_path}/train.${lang}
  python ${script_path}/add_missing_characters.py --input ${out_path}/sp-model.${lang}.model --output-prefix ${out_path}/sp-model.${lang} --required-characters ${required_symbols}
  tail -n +4 ${out_path}/sp-model.${lang}.vocab | cut -f1 | sed 's/$/ 100/g' >${out_path}/dict.${lang}.txt
done
