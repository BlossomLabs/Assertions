#!/usr/bin/env python3
"""Regenerate both exact fold target observation leaves without changing shared supports."""
import argparse,subprocess,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent
parser=argparse.ArgumentParser();parser.add_argument('--output',type=Path,required=True);args=parser.parse_args()
for name in ['generate-code.py','generate-rejected.py']:
 subprocess.run([sys.executable,'-B',HERE/name,'--output',args.output],check=True)
