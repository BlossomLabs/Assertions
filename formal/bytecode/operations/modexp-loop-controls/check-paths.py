#!/usr/bin/env python3
"""Independent complete finite compiled one-iteration replay against independent binary-power residue update."""
import argparse,json,hashlib
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
def main():
 parser=argparse.ArgumentParser();parser.add_argument('receipts',type=Path);parser.add_argument('--output',type=Path,required=True);args=parser.parse_args()
 mapping=json.loads((HERE/'loop.mapping.json').read_text());runtime=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text())['deployedBytecode'][2:]);assert hashlib.sha256(runtime).hexdigest()==mapping['runtimeSha256'];paths={p['name']:p for p in mapping['paths']};observed=[];count=0
 for f in sorted(args.receipts.glob('*.json')):
  d=json.loads(f.read_text())
  if 'trace' not in d:continue
  count+=1;assert d['runtimeSha256']==mapping['runtimeSha256'];logs=d['trace']['structLogs']
  for i,s in enumerate(logs):
   if s['pc']!=9367:continue
   stack=[int(x,16) for x in s['stack']];ret,base,exponent,modulus,result=stack[-5:];assert modulus>0 and base<modulus and result<modulus
   path=paths['Zero' if exponent==0 else 'Final' if exponent==1 else 'Odd' if exponent%2==1 else 'Even'];assert i+len(path['nodes'])<len(logs)
   for j,n in enumerate(path['nodes']):
    step=logs[i+j];assert step['pc']==n['pc'];pc=n['pc'];op=runtime[pc];width=op-95 if 96<=op<=127 else 0;assert (op,pc+1+width,int.from_bytes(runtime[pc+1:pc+1+width],'big'))==(n['opcode'],n['next'],n['immediate']);assert step['memory']==s['memory']
   end=logs[i+len(path['nodes'])];assert end['pc']==(3085 if exponent==0 else 9367);assert [int(x,16) for x in end['stack']]==stack[:-5]+[ret,base if exponent<=1 else (base*base)%modulus,exponent if exponent==0 else exponent//2,modulus,(result*base)%modulus if exponent%2 else result];assert end['memory']==s['memory'];observed.append({'receipt':f.name,'receiptSha256':hashlib.sha256(f.read_bytes()).hexdigest(),'path':path['name'],'instructions':len(path['nodes']),'base':str(base),'exponent':str(exponent),'modulus':str(modulus)})
 assert count==122 and len(observed)>0
 args.output.write_text(json.dumps({'status':'finite-loop-paths-passed-no-public-credit','runtimeSha256':mapping['runtimeSha256'],'receipts':count,'completeObservedLoopPaths':len(observed),'partitionCounts':{name:sum(x['path']==name for x in observed) for name in paths},'universalNativePassed':False,'observed':observed},indent=2)+'\n');print('PASS122 receipts/'+str(len(observed))+' complete binary-loop paths against independent quotient/parity/residue update; native open')
if __name__=='__main__':main()
