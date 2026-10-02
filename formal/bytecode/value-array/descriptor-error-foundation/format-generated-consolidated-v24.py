#!/usr/bin/env python3
"""Format exact generated syntax with resolved includes, restoring relative paths."""
import argparse,re,subprocess,tempfile
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);p.add_argument('--include-root',type=Path,required=True);a=p.parse_args()
for file in sorted(a.output.glob('*.generated.dfy')):
 text=file.read_text();includes=re.findall(r'^include "([^"]+)"$',text,re.M);replacements={name:str((a.include_root/name).resolve()) for name in includes}
 absolute=re.sub(r'^include "([^"]+)"$',lambda m:'include "'+replacements[m[1]]+'"',text,flags=re.M)
 with tempfile.TemporaryDirectory(prefix='dafny-generator-format-') as folder:
  temp=Path(folder)/file.name;temp.write_text(absolute)
  formatted=subprocess.run(['/home/sem/assertions/proof-tools/assertions-proof-tools/dafny/dafny','format','--print',temp],capture_output=True,text=True,check=True).stdout
 for old,new in replacements.items():formatted=formatted.replace('include "'+new+'"','include "'+old+'"')
 assert re.findall(r'^include "([^"]+)"$',formatted,re.M)==includes
 assert formatted.startswith('// SPDX-License-Identifier: MIT')
 file.write_text(formatted)
