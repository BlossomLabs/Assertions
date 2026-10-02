#!/usr/bin/env python3
"""Check the retained sumWords raw-entry bytecode closure."""
import runpy
from pathlib import Path
runpy.run_path(str(Path(__file__).with_name('check-word-entry-bytecode-evidence.py')))['check']('word-sum-bytecode.json')
