checkpoint_file=$1 # path to the model checkpoint file
lang_pairs=$2 # model lang pairs
src_sp_model=$3 # path to the sp model of the src language
bin_dir=$4 # path to the directory with the dict.${lang}.txt files

in_file=$5 # path to the file to be translated
out_file=$6 # path to the output file

src_lang=$7
tgt_lang=$8

max_tokens=${9:-"50000"}
buffer_size=${10:-"5000"}


cat ${in_file} | fairseq-interactive ${bin_dir} \
  --task multilingual_translation_sampled \
  --source-lang ${src_lang} \
  --target-lang ${tgt_lang} \
  --bpe sentencepiece \
  --max-tokens ${max_tokens} \
  --buffer-size ${buffer_size} \
  --remove-bpe \
  --sentencepiece-model ${src_sp_model} \
  --lang-pairs ${lang_pairs} \
  --path ${checkpoint_file} \
  2>&1 | tee ${out_file}.log | grep -P "D-[0-9]+" | cut -f3 >${out_file}