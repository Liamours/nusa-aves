"""Runtime configuration, overridable via environment variables.

No separate debug/release build — same code, different env vars:
  NUSA_LOG_LEVEL=DEBUG docker run --rm nusa-aves samples/black_hornbill.wav
"""
import os

VERSION = "1.0.0"
LOG_LEVEL = os.environ.get("NUSA_LOG_LEVEL", "INFO")
MODEL_DIR = os.environ.get("NUSA_MODEL_DIR", "../model")
