#!/usr/bin/env python3
"""Independent full-frame replay of nonempty OR allocation prefix."""
import argparse,hashlib,json,runpy
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[4]
interpreter=runpy.run_path(str(HERE.parent.parent/'constrained-raw/public/check-false-replay-consolidated-v1.py'))
step,stack,memory=interpreter['step'],interpreter['stack'],interpreter['memory']
def main():
 p=argparse.ArgumentParser();p.add_argument('--receipts',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
 code=bytes.fromhex(json.load(open(ROOT/'artifacts/contracts/Assertions.sol/Assertions.json'))['deployedBytecode'][2:]);digest=hashlib.sha256(code).hexdigest();mapping=json.load(open(HERE/'NonemptyStart.mapping.json'));assert mapping['runtimeSha256']==digest
 for pos,value in mapping['requiredBytes'].items():assert code[int(pos)]==value
 checks=[]
 for path in sorted(a.receipts.glob('or-*.json')):
  fixture=json.load(open(path));assert fixture['runtimeSha256']==digest;logs=[r for r in fixture['trace']['structLogs'] if r['depth']==1];at=next(i for i,r in enumerate(logs) if r['pc']==19462);schedule=mapping['states'];assert [r['pc'] for r in logs[at:at+len(schedule)]]==[r['pc'] for r in schedule]
  for i,node in enumerate(schedule):
   row=logs[at+i];nxt,s,m,terminal=step(code,row,bytes.fromhex(fixture['data'][2:]));following=logs[at+i+1];assert terminal is None and (nxt,s,m)==(following['pc'],stack(following),memory(following)),(path.name,i,row['pc'])
  assert logs[at+len(schedule)]['pc']==19590
  checks.append({'fixture':path.name,'instructionCount':len(schedule),'fullStackMemoryReplay':True})
 assert len(checks)==3
 result={'status':'passed','scope':'Concrete nonempty OR decoder allocation prefix only; no child decoding or public completion credit.','runtimeSha256':digest,'instructionCount':sum(r['instructionCount'] for r in checks),'checks':checks,'mappingSha256':hashlib.sha256((HERE/'NonemptyStart.mapping.json').read_bytes()).hexdigest()};a.output.write_text(json.dumps(result,indent=2)+'\n');print('PASS',result['instructionCount'],'instructions',len(checks),'fixtures')
if __name__=='__main__':main()
