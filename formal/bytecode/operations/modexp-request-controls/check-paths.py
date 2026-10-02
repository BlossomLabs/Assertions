#!/usr/bin/env python3
"""Independent finite replay of every actual packet-construction instruction and caller stack."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
def mem(s):return b''.join(int(x,16).to_bytes(32,'big') for x in s['memory'])
def main():
 parser=argparse.ArgumentParser();parser.add_argument('receipts',type=Path);parser.add_argument('--output',type=Path,required=True);args=parser.parse_args();mapping=json.loads((HERE/'request.mapping.json').read_text());path=mapping['paths'][0];code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text())['deployedBytecode'][2:]);assert hashlib.sha256(code).hexdigest()==mapping['runtimeSha256'];observed=[];count=0;initial=bytes(64)+(128).to_bytes(32,'big')
 for f in sorted(args.receipts.glob('*.json')):
  d=json.loads(f.read_text())
  if 'trace' not in d:continue
  count+=1;assert d['runtimeSha256']==mapping['runtimeSha256'];logs=d['trace']['structLogs']
  for i,state in enumerate(logs):
   if state['pc']!=9283:continue
   assert mem(state)==initial;ss=[int(x,16) for x in state['stack']];ret,base,exponent,modulus,result=ss[-5:];assert modulus>0 and exponent>=1<<32 and i+len(path['nodes'])<len(logs)
   for j,n in enumerate(path['nodes']):
    step=logs[i+j];assert step['pc']==n['pc'];pc=n['pc'];op=code[pc];width=op-95 if 96<=op<=127 else 0;assert (op,pc+1+width,int.from_bytes(code[pc+1:pc+1+width],'big'))==(n['opcode'],n['next'],n['immediate'])
   after=logs[i+len(path['nodes'])];assert after['pc']==9331;stack=[int(x,16) for x in after['stack']];gas=stack[-1];assert stack==ss[:-5]+[ret,base,exponent,modulus,result,0,128,32,128,192,128,5,gas];packet=b''.join(x.to_bytes(32,'big') for x in [32,32,32,base,exponent,modulus]);assert mem(after)==initial+bytes(32)+packet
   observed.append({'receipt':f.name,'receiptSha256':hashlib.sha256(f.read_bytes()).hexdigest(),'instructions':len(path['nodes']),'requestedGas':gas,'packetHex':packet.hex()})
 assert count==122 and len(observed)==16;args.output.write_text(json.dumps({'status':'finite-request-paths-passed-no-public-credit','runtimeSha256':mapping['runtimeSha256'],'receipts':count,'exactRequestPaths':len(observed),'universalNativePassed':False,'observed':observed},indent=2)+'\n');print('PASS122 receipts/16 complete37-instruction packet/GAS prefixes; native open')
if __name__=='__main__':main()
