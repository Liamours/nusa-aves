#!/usr/bin/env python
"""Usage: python cli.py <audio_file> [--top-k N]"""
import argparse
import json

from model import Classifier


def main():
    parser = argparse.ArgumentParser(description="Identify a bird species from an audio clip.")
    parser.add_argument("audio_file")
    parser.add_argument("--top-k", type=int, default=5)
    args = parser.parse_args()

    predictions = Classifier().predict_file(args.audio_file, top_k=args.top_k)
    print(json.dumps(predictions, indent=2))


if __name__ == "__main__":
    main()
