#!/bin/bash

in_path=$1

tmp_path=$2

out_path=$3

lang_pairs=$4

vocabulary_size=24000


mkdir -p ${tmp_path} ${out_path}


# append all sentences for a language into a single file
for lang_pair in ${lang_pairs//,/ }; do
  lang1=$(echo $lang_pair | cut -d'-' -f1)
  lang2=$(echo $lang_pair | cut -d'-' -f2)

  cat ${in_path}/train.${lang_pair}.${lang1} >> ${tmp_path}/data.${lang1}
  cat ${in_path}/train.${lang_pair}.${lang2} >> ${tmp_path}/data.${lang2}
done

# seed for repeatable experiments
get_seeded_random()
{
  seed="$1"
  openssl enc -aes-256-ctr -pass pass:"$seed" -nosalt \
    </dev/zero 2>/dev/null
}

langs=$(echo ${lang_pairs} | tr '-' '\n' | tr ',' '\n' | sort | uniq | paste -sd "," -)

for lang in ${langs//,/ }; do
  echo "training ${lang} sp model"

  # select 10,000,000 sentences from each language for training
  cat ${tmp_path}/data.${lang} | shuf --random-source=<(get_seeded_random 42) | head -n10000000 > ${tmp_path}/train.${lang}
  rm ${tmp_path}/data.${lang}

  # train sp model
  if [ "$lang" = "en" ] || [ "$lang" = "de" ] || [ "$lang" = "ru" ]; then

      # Adding missing characters to en, de and ru
      spm_train --input=${tmp_path}/train.${lang} --model_prefix=${out_path}/sp-model.${lang} --user_defined_symbols=Õ,õ --vocab_size=${vocabulary_size} --character_coverage=1.0 --model_type=bpe

      # create fairseq vocabulary from sentencepiece
      tail -n +6 ${out_path}/sp-model.${lang}.vocab | cut -f1 | sed 's/$/ 100/g' > ${out_path}/fairseq.${lang}.vocab

      # sentencepiece puts the manually added characters to the beginning of the vocab,
      # but we are moving them to the end where other rare symbols are
      echo "õ 100" >> ${out_path}/fairseq.${lang}.vocab
      echo "Õ 100" >> ${out_path}/fairseq.${lang}.vocab
  else
      spm_train --input=${tmp_path}/train.${lang} --model_prefix=${out_path}/sp-model.${lang} --vocab_size=${vocabulary_size} --character_coverage=1.0 --model_type=bpe
      tail -n +4 ${out_path}/sp-model.${lang}.vocab | cut -f1 | sed 's/$/ 100/g' > ${out_path}/fairseq.${lang}.vocab
  fi

  rm ${tmp_path}/train.${lang}
done





