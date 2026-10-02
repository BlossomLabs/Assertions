#!/usr/bin/env python3
"""Full physical replay of the nonempty OR decoder start, every child, and exit."""
import argparse,hashlib,json,runpy
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[4]
model=runpy.run_path(str(HERE.parent.parent/'constrained-raw/public/check-false-replay-consolidated-v1.py'));step,stack,memory=model['step'],model['stack'],model['memory']
def main():
 p=argparse.ArgumentParser();p.add_argument('--receipts',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();code=bytes.fromhex(json.load(open(ROOT/'artifacts/contracts/Assertions.sol/Assertions.json'))['deployedBytecode'][2:]);digest=hashlib.sha256(code).hexdigest();maps={name:json.load(open(HERE/f'Nonempty{name}.mapping.json')) for name in ['Start','Item','Exit']}
 for m in maps.values():
  assert m['runtimeSha256']==digest
  for pos,value in m['requiredBytes'].items():assert code[int(pos)]==value
 checks=[];instructions=0;coverage=set()
 for path in sorted(a.receipts.glob('or-*.json')):
  if path.name.endswith('-boundaries.json'):continue
  j=json.load(open(path));assert j['runtimeSha256']==digest;logs=[r for r in j['trace']['structLogs'] if r['depth']==1];begin=next(i for i,r in enumerate(logs) if r['pc']==19462);at=begin;segments=[]
  while True:
   if logs[at]['pc']==19462:name='Start'
   else:
    assert logs[at]['pc']==19590;s=stack(logs[at]);name='Exit' if s[-3]>=s[-4] else 'Item'
   states=maps[name]['states'];assert [r['pc'] for r in logs[at:at+len(states)]]==[r['pc'] for r in states],(path.name,name)
   for i,m in enumerate(states):
    row=logs[at+i];assert code[row['pc']]==m['op'];nxt,s,mem,terminal=step(code,row,bytes.fromhex(j['data'][2:]));following=logs[at+i+1];assert terminal is None and (nxt,s,mem)==(following['pc'],stack(following),memory(following)),(path.name,name,i,row['pc'])
   segments.append({'segment':name,'instructionCount':len(states),'fullStackMemoryReplay':True});coverage.add(name);instructions+=len(states);at+=len(states)
   if name=='Exit':break
  assert logs[at]['pc']==7777;checks.append({'fixture':path.name,'fromPC':19462,'toPC':7777,'instructionCount':at-begin,'segments':segments,'fullStackMemoryReplay':True})
 assert len(checks)==8 and coverage==set(maps);result={'status':'passed','scope':'Full concrete nonempty child-array decoder replay; universal child-fill induction, structural/verdict and public composition remain separate obligations.','runtimeSha256':digest,'instructionCount':instructions,'checks':checks,'mappingSha256':{name:hashlib.sha256((HERE/f'Nonempty{name}.mapping.json').read_bytes()).hexdigest() for name in maps}};a.output.write_text(json.dumps(result,indent=2)+'\n');print('PASS',instructions,'instructions',len(checks),'complete decoder executions')
if __name__=='__main__':main()
