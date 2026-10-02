#!/usr/bin/env python3
"""Recheck retained uniqueWords evidence against the complete current input graph."""
import importlib.util
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
path = ROOT / 'formal/bytecode/word-unique-entry/check-evidence.py'
spec = importlib.util.spec_from_file_location('unique_words_evidence_checker', path)
checker = importlib.util.module_from_spec(spec)
spec.loader.exec_module(checker)
checker.check('unique-words-bytecode.json')
