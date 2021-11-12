from sentencepiece.sentencepiece_model_pb2 import ModelProto
from typing import Iterable
import argparse


def add_missing_characters(input: str, output_prefix: str, required_vocab: Iterable[str]):
    model = ModelProto()

    with open(input, 'rb') as f:
        model.ParseFromString(f.read())

    score = min(p.score for p in model.pieces)

    vocab = {p.piece for p in model.pieces}

    for c in required_vocab:
        if c not in vocab:
            score -= 1
            model.pieces.append(ModelProto.SentencePiece(piece=c, score=score))

    with open(output_prefix + ".model", 'wb') as f:
        f.write(model.SerializeToString())

    with open(output_prefix + ".vocab", 'w', encoding="utf-8") as f:
        for p in model.pieces:
            f.write(f"{p.piece}\t{int(p.score)}\n")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--input', type=str, required=True)
    parser.add_argument('--output-prefix', type=str, required=True)
    parser.add_argument('--required-characters', type=str, required=True)
    args = parser.parse_args()
    add_missing_characters(args.input, args.output_prefix, args.required_characters)


if __name__ == "__main__":
    main()
