#!/usr/bin/env python3
"""Inventory the prospective included graph. No proof/public evidence or snapshot."""
import argparse,hashlib,json,re
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[3]
parser=argparse.ArgumentParser();parser.add_argument('--output',type=Path,required=True);args=parser.parse_args()
spec=json.loads((HERE/'proof-spec.json').read_text());closed=set()
def visit(path):
 path=path.resolve();assert path.is_relative_to(ROOT) and path.is_file()
 if path in closed:return
 closed.add(path)
 for include in re.findall(r'^include "([^"]+)"',path.read_text(),re.M):visit(path.parent/include)
for path in spec['rootProofs']:visit(ROOT/path)
modules=[];forwarding=[]
for p in sorted(closed):
 s=p.read_text();name=re.search(r'^module (\w+)',s,re.M)
 if not name:forwarding.append(str(p.relative_to(ROOT)));continue
 modules.append({'module':name[1],'source':str(p.relative_to(ROOT)),'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'declarations':len(re.findall(r'^\s*(?:ghost\s+)?(?:opaque\s+)?(?:lemma|method|function|predicate)\s+\w+',s,re.M))})
assert len(modules)==len({m['module'] for m in modules}),'Duplicate qualified module owners'
record={'status':'prospective-graph-only-not-retained-proof','rootProofs':spec['rootProofs'],'moduleCount':len(modules),'includeOnlyCount':len(forwarding),'modules':modules,'includeOnlyFiles':forwarding,'scope':'Exact current transitive include inventory only. No declarations are credited by this inventory; every module requires complete same-input native provenance and the full retained gates.'}
args.output.parent.mkdir(parents=True,exist_ok=True);args.output.write_text(json.dumps(record,indent=2)+'\n');print(json.dumps({'modules':len(modules),'includeOnly':len(forwarding),'rootProofs':spec['rootProofs'],'status':record['status']}))
