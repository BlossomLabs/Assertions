#!/usr/bin/env python3
"""Recheck retained zipWords evidence against the complete current input graph."""
import importlib.util
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
path = ROOT / 'formal/bytecode/word-zip-entry/check-evidence.py'
spec = importlib.util.spec_from_file_location('zip_words_evidence_checker', path)
checker = importlib.util.module_from_spec(spec)
spec.loader.exec_module(checker)
checker.check('zip-words-bytecode.json')
