#!/usr/bin/env python

import sentencepiece as spm
import os
import argparse

def sp_tokenization(infile, outfile, spmodel):
    with open(infile, 'r', encoding='utf-8') as in_file:
        with open(outfile, 'w', encoding='utf-8') as out_file:
            for line in in_file:
                new_line = spmodel.encode_as_pieces(line)
                out_file.write(' '.join(new_line) + '\n')
                
def main(args):
    sp = spm.SentencePieceProcessor()
    sp.load(args.spmodel)
    
    dir_path = args.datadir
    dest_path = args.destdir

    path_exists = os.path.exists(dest_path)

    if not path_exists:
        os.makedirs(dest_path)
        
    for file in os.listdir(dir_path):
        filename = os.path.basename(file)
        dest_file = os.path.join(dest_path, filename)
        sp_tokenization(os.path.join(dir_path, file), dest_file, sp)
    
    
if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('-d', '--datadir', help='directory with files with source and target languages as extensions', required=True)
    parser.add_argument('-m', '--spmodel', help='sentencepiece model path', required=True)
    parser.add_argument('-t', '--destdir', help='destination directory for tokenized files', required=True) 

    args = parser.parse_args()
    main(args)