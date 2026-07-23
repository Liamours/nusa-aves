#!/usr/bin/env python
"""Usage: python cli.py <audio_file> [--top-k N] [--version]

Logging goes to stderr; the JSON result is the only thing on stdout, so
output stays pipeable (e.g. `python cli.py clip.wav | jq .[0].species`).
Set NUSA_LOG_LEVEL=DEBUG for verbose logs.
"""
import argparse
import json
import logging
import sys

from config import LOG_LEVEL, VERSION
from model import Classifier

logger = logging.getLogger(__name__)


def main():
    logging.basicConfig(
        level=LOG_LEVEL,
        format="%(asctime)s %(levelname)s %(name)s: %(message)s",
        stream=sys.stderr,
    )

    parser = argparse.ArgumentParser(description="Identify a bird species from an audio clip.")
    parser.add_argument("audio_file")
    parser.add_argument("--top-k", type=int, default=5)
    parser.add_argument("--version", action="version", version=f"nusa-aves-cli {VERSION}")
    args = parser.parse_args()

    try:
        predictions = Classifier().predict_file(args.audio_file, top_k=args.top_k)
    except FileNotFoundError as e:
        logger.error("%s", e)
        sys.exit(1)
    except Exception:
        logger.exception("classification failed")
        sys.exit(1)

    print(json.dumps(predictions, indent=2))


if __name__ == "__main__":
    main()
