#!/bin/bash

input_dir=
combined_dir=combined
shuffled_dir=${combined_dir}/shuffled
tmp_dir=tmp
sp_model_dir=sp-model
sp_out_dir=sp
bin_dir=bin
checkpoint_dir=checkpoints

lang_pairs=de-et,en-et,et-ru

bash combine_data.sh ${input_dir} ${combined_dir} ${lang_pairs}

bash shuffle_data.sh ${combined_dir} ${shuffled_dir} ${lang_pairs}

bash train_sentencepiece.sh ${shuffled_dir} ${tmp_dir} ${sp_model_dir} ${lang_pairs}

bash preprocess-sp.sh ${shuffled_dir} ${sp_model_dir} ${sp_out_dir} ${lang_pairs}

bash preprocess-fs.sh ${sp_out_dir} ${sp_model_dir} ${bin_dir} ${lang_pairs}

bash train_modular.sh ${bin_dir} ${checkpoint_dir} modular_baseline ${lang_pairs}