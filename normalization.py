#!/usr/bin/env python
# adapted from moses punctuation normalization script
import re
import argparse


def normalize_data(filepath, lang):
    with open(filepath, 'r', encoding='utf-8') as in_file:
        lines = in_file.readlines()

    # define and compile all the patterns

    regex_1 = re.compile(r'\r')
    regex_2 = re.compile(r'\(')

    # remove extra spaces
    regex_3 = re.compile(r'\(')
    regex_4 = re.compile(r'\)')
    regex_5 = re.compile(r' +')
    regex_6 = re.compile(r'\) ([.!:?;,])')
    regex_7 = re.compile(r'\( ')
    regex_8 = re.compile(r' \)')
    regex_9 = re.compile(r'(\d) %')
    regex_10 = re.compile(r' :')
    regex_11 = re.compile(r' ;')
    # normalize unicode punctuation
    regex_12 = re.compile(r'`')
    regex_13 = re.compile(r"''")

    regex_14 = re.compile(r'„')
    regex_15 = re.compile(r'“')
    regex_16 = re.compile(r'”')
    regex_17 = re.compile(r'–')
    regex_18 = re.compile(r'—')
    regex_19 = re.compile(r' +')
    regex_20 = re.compile(r'´')
    regex_21 = re.compile(r'([a-z])‘([a-z])', flags=re.IGNORECASE)
    regex_22 = re.compile(r'([a-z])’([a-z])', flags=re.IGNORECASE)
    regex_23 = re.compile(r'‘')
    regex_24 = re.compile(r'‚')
    regex_25 = re.compile(r'’')
    regex_26 = re.compile(r"''")
    regex_27 = re.compile(r'´´')
    regex_28 = re.compile(r'…')
    # French quotes
    regex_29 = re.compile(r' « ')
    regex_30 = re.compile(r'« ')
    regex_31 = re.compile(r'«')
    regex_32 = re.compile(r' » ')
    regex_33 = re.compile(r' »')
    regex_34 = re.compile(r'»')
    # handle pseudo-spaces
    regex_35 = re.compile(r' %')
    regex_36 = re.compile(r'nº ')
    regex_37 = re.compile(r' :')
    regex_38 = re.compile(r' ºC')
    regex_39 = re.compile(r' cm')
    regex_40 = re.compile(r' \?')
    regex_41 = re.compile(r' !')
    regex_42 = re.compile(r' ;')
    regex_43 = re.compile(r', ')
    regex_44 = re.compile(r' +')

    regex_45 = re.compile(r'"([,.]+)')

    regex_46 = re.compile(r',"')
    regex_47 = re.compile(r'(\.+)"(\s*[^<])')

    regex_48 = re.compile(r'(\d) (\d)')
    regex_49 = re.compile(r'(\d) (\d)')

    # start normalizing
    new_lines = []

    for sentence in lines:
        sentence = sentence.strip()
        sentence = regex_1.sub(r'', sentence)
        sentence = regex_2.sub(r' (', sentence)

        # remove extra spaces
        sentence = regex_3.sub(r' (', sentence)
        sentence = regex_4.sub(r') ', sentence)
        sentence = regex_5.sub(r' ', sentence)
        sentence = regex_6.sub(r')\1', sentence)
        sentence = regex_7.sub(r'(', sentence)
        sentence = regex_8.sub(r')', sentence)
        sentence = regex_9.sub(r'\1%', sentence)
        sentence = regex_10.sub(r':', sentence)
        sentence = regex_11.sub(r';', sentence)
        # normalize unicode punctuation
        sentence = regex_12.sub(r"'", sentence)
        sentence = regex_13.sub(r' " ', sentence)

        sentence = regex_14.sub(r'"', sentence)
        sentence = regex_15.sub(r'"', sentence)
        sentence = regex_16.sub(r'"', sentence)
        sentence = regex_17.sub(r'-', sentence)
        sentence = regex_18.sub(r' - ', sentence)
        sentence = regex_19.sub(r' ', sentence)
        sentence = regex_20.sub(r"'", sentence)
        sentence = regex_21.sub(r"\1'\2", sentence)
        sentence = regex_22.sub(r"\1'\2", sentence)
        sentence = regex_23.sub(r"'", sentence)
        sentence = regex_24.sub(r"'", sentence)
        sentence = regex_25.sub(r"'", sentence)
        sentence = regex_26.sub(r'"', sentence)
        sentence = regex_27.sub(r'"', sentence)
        sentence = regex_28.sub(r'...', sentence)
        # French quotes
        sentence = regex_29.sub(r' "', sentence)
        sentence = regex_30.sub(r'"', sentence)
        sentence = regex_31.sub(r'"', sentence)
        sentence = regex_32.sub(r'" ', sentence)
        sentence = regex_33.sub(r'"', sentence)
        sentence = regex_34.sub(r'"', sentence)
        # handle pseudo-spaces
        sentence = regex_35.sub(r'%', sentence)
        sentence = regex_36.sub(r'nº ', sentence)
        sentence = regex_37.sub(r':', sentence)
        sentence = regex_38.sub(r' ºC', sentence)
        sentence = regex_39.sub(r' cm', sentence)
        sentence = regex_40.sub(r'?', sentence)
        sentence = regex_41.sub(r'!', sentence)
        sentence = regex_42.sub(r';', sentence)
        sentence = regex_43.sub(r', ', sentence)
        sentence = regex_44.sub(r' ', sentence)

        # English "quotation," followed by comma, style
        if lang == "en":
            sentence = regex_45.sub(r'\1"', sentence)
        # German', 'Spanish', 'French "quotation", followed by comma, style
        else:
            sentence = regex_46.sub(r'",', sentence)
            sentence = regex_47.sub(r'"\1\2', sentence)  # don't fix period at end of sentence

        if lang in ["de", "es", "cz", "cs", "fr"]:
            sentence = regex_48.sub(r'\1,\2', sentence)
        else:
            sentence = regex_49.sub(r'\1.\2', sentence)

        new_lines.append(sentence)

    with open(filepath + '.normalized', 'w', encoding='utf-8') as out_file:
        for line in new_lines:
            out_file.write(line + '\n')

def main(args):
    normalize_data(args.filepath, args.lang)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('-f', '--filepath', help='filepath', required=True)
    parser.add_argument('-l', '--lang', help='language', required=True)

    args = parser.parse_args()
    main(args)