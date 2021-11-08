#!/usr/bin/env python
# adapted from moses punctuation normalization script
import re
import argparse


def normalize_data(sentence, lang):
    sentence = re.sub(r'\r', r'', sentence)
    sentence = re.sub(r'\(', r' (', sentence)

    # remove extra spaces
    sentence = re.sub(r'\(', r' (', sentence)
    sentence = re.sub(r'\)', r') ', sentence)
    sentence = re.sub(r' +', r' ', sentence)
    sentence = re.sub(r'\) ([.!:?;,])', r')\1', sentence)
    sentence = re.sub(r'\( ', r'(', sentence)
    sentence = re.sub(r' \)', r')', sentence)
    sentence = re.sub(r'(\d) %', r'\1%', sentence)
    sentence = re.sub(r' :', r':', sentence)
    sentence = re.sub(r' ;', r';', sentence)
    # normalize unicode punctuation
    sentence = re.sub(r'`', '\'', sentence)
    sentence = re.sub(r'\'\'', r' " ', sentence)

    sentence = re.sub(r'„', r'"', sentence)
    sentence = re.sub(r'“', r'"', sentence)
    sentence = re.sub(r'”', r'"', sentence)
    sentence = re.sub(r'–', r'-', sentence)
    sentence = re.sub(r'—', r' - ', sentence)
    sentence = re.sub(r' +', r' ', sentence)
    sentence = re.sub(r'´', '\'', sentence)
    sentence = re.sub(r'([a-z])‘([a-z])', r'\1\'\2', sentence, flags=re.IGNORECASE)
    sentence = re.sub(r'([a-z])’([a-z])', r'\1\'\2', sentence, flags=re.IGNORECASE)
    sentence = re.sub(r'‘', '\'', sentence)
    sentence = re.sub(r'‚', '\'', sentence)
    sentence = re.sub(r'’', '\'', sentence)
    sentence = re.sub(r'\'\'', r'"', sentence)
    sentence = re.sub(r'´´', r'"', sentence)
    sentence = re.sub(r'…', r'...', sentence)
    # French quotes
    sentence = re.sub(r' « ', r' "', sentence)
    sentence = re.sub(r'« ', r'"', sentence)
    sentence = re.sub(r'«', r'"', sentence)
    sentence = re.sub(r' » ', r'" ', sentence)
    sentence = re.sub(r' »', r'"', sentence)
    sentence = re.sub(r'»', r'"', sentence)
    # handle pseudo-spaces
    sentence = re.sub(r' %', r'%', sentence)
    sentence = re.sub(r'nº ', r'nº ', sentence)
    sentence = re.sub(r' :', r':', sentence)
    sentence = re.sub(r' ºC', r' ºC', sentence)
    sentence = re.sub(r' cm', r' cm', sentence)
    sentence = re.sub(r' \?', r'?', sentence)
    sentence = re.sub(r' !', r'!', sentence)
    sentence = re.sub(r' ;', r';', sentence)
    sentence = re.sub(r', ', r', ', sentence)
    sentence = re.sub(r' +', r' ', sentence)

    # English "quotation," followed by comma, style
    if lang == "en":
        sentence = re.sub(r'"([,.]+)', r'\1"', sentence)
    # German', 'Spanish', 'French "quotation", followed by comma, style
    else:
        sentence = re.sub(r',"', r'",', sentence)
        sentence = re.sub(r'(\.+)\"(\s*[^<])', r'"\1\2', sentence)  # don't fix period at end of sentence

    if lang in ["de", "es", "cz", "cs", "fr"]:
        sentence = re.sub(r'(\d) (\d)', r'\1,\2', sentence)
    else:
        sentence = re.sub(r'(\d) (\d)', r'\1.\2', sentence)

    return sentence

def main(args):
    normalize_data(args.sentence, args.lang)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('-s', '-sentence', help='sentence', required=True)
    parser.add_argument('-l', '-lang', help='language', required=True)

    args = parser.parse_args()
    main(args)