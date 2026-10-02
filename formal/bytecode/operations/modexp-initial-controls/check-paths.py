#!/usr/bin/env python3
"""Independent complete finite compiled initialization replay against integer residue/threshold spec."""
import argparse,json,hashlib
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
def main():
 parser=argparse.ArgumentParser();parser.add_argument('receipts',type=Path);parser.add_argument('--output',type=Path,required=True);args=parser.parse_args()
 mapping=json.loads((HERE/'initial.mapping.json').read_text());runtime=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text())['deployedBytecode'][2:]);assert hashlib.sha256(runtime).hexdigest()==mapping['runtimeSha256'];paths={p['name']:p for p in mapping['paths']};observed=[];count=0
 for f in sorted(args.receipts.glob('*.json')):
  d=json.loads(f.read_text())
  if 'trace' not in d:continue
  count+=1;assert d['runtimeSha256']==mapping['runtimeSha256'];logs=d['trace']['structLogs']
  for i,s in enumerate(logs):
   if s['pc']!=9244:continue
   stack=[int(x,16) for x in s['stack']];ret,base,exponent,modulus=stack[-4:]
   if modulus==0:continue
   path=paths['Loop' if exponent<1<<32 else 'Precompile'];assert i+len(path['nodes'])<len(logs)
   for j,n in enumerate(path['nodes']):
    step=logs[i+j];assert step['pc']==n['pc'];pc=n['pc'];op=runtime[pc];width=op-95 if 96<=op<=127 else 0;assert (op,pc+1+width,int.from_bytes(runtime[pc+1:pc+1+width],'big'))==(n['opcode'],n['next'],n['immediate']);assert step['memory']==s['memory']
   end=logs[i+len(path['nodes'])];assert end['pc']==(9367 if exponent<1<<32 else 9283);assert [int(x,16) for x in end['stack']]==stack[:-4]+[ret,base%modulus,exponent,modulus,1%modulus];assert end['memory']==s['memory'];observed.append({'receipt':f.name,'receiptSha256':hashlib.sha256(f.read_bytes()).hexdigest(),'path':path['name'],'instructions':len(path['nodes']),'base':str(base),'exponent':str(exponent),'modulus':str(modulus)})
 assert count==122 and len(observed)==70
 args.output.write_text(json.dumps({'status':'finite-initialization-paths-passed-no-public-credit','runtimeSha256':mapping['runtimeSha256'],'receipts':count,'nonzeroModulusReachedInitializations':len(observed),'loopFrontiers':sum(x['path']=='Loop' for x in observed),'precompileFrontiers':sum(x['path']=='Precompile' for x in observed),'universalNativePassed':False,'observed':observed},indent=2)+'\n');print('PASS122 receipts/70 complete initialization paths against independent integer residues and exponent threshold; native open')
if __name__=='__main__':main()
