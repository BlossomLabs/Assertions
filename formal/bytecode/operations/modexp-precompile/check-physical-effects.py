#!/usr/bin/env python3
"""Independent finite actual call/packet/output/gate replay; no universal proof credit."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
def memory(state):return b''.join(int(word,16).to_bytes(32,'big') for word in state['memory'])
def stack(state):return [int(word,16) for word in state['stack']]
def main():
 a=argparse.ArgumentParser();a.add_argument('receipts',type=Path);a.add_argument('--output',type=Path,required=True);args=a.parse_args()
 runtime=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text())['deployedBytecode'][2:]);site=json.loads((HERE/'site.mapping.json').read_text());assert hashlib.sha256(runtime).hexdigest()==site['runtimeSha256'];assert runtime[site['pc']]==site['opcode']==250
 mapping=json.loads((HERE.parent/'modexp-reply-controls/reply.mapping.json').read_text());assert mapping['runtimeSha256']==site['runtimeSha256'];path=next(p for p in mapping['paths'] if p['name']=='Exact');observed=[];allreceipts=0
 for f in sorted(args.receipts.glob('*.json')):
  d=json.loads(f.read_text())
  if 'trace' not in d:continue
  allreceipts+=1;logs=d['trace']['structLogs'];assert d['runtimeSha256']==site['runtimeSha256']
  for i,state in enumerate(logs):
   if state['pc']!=9331:continue
   assert state['op']=='STATICCALL' and i+1<len(logs);s=stack(state);mem=memory(state);size,out,sizein,at,target,gas=s[-6:];assert (size,sizein,target)==(32,192,5) and out==at and at>=96 and at%32==0 and at+192<=len(mem)
   packet=mem[at:at+192];words=[int.from_bytes(packet[k:k+32],'big') for k in range(0,192,32)];assert words[:3]==[32,32,32];base,exponent,modulus=words[3:];assert modulus>0
   after=logs[i+1];post=memory(after);ss=stack(after);assert after['pc']==9332 and ss==s[:-6]+[1];expected=pow(base,exponent,modulus).to_bytes(32,'big');assert len(post)==len(mem) and post[at:at+32]==expected and post[:at]==mem[:at] and post[at+32:]==mem[at+32:]
   assert len(logs)>i+len(path['nodes'])+1
   for j,n in enumerate(path['nodes']):
    step=logs[i+1+j];assert step['pc']==n['pc'];pc=n['pc'];op=runtime[pc];width=op-95 if 96<=op<=127 else 0;assert (op,pc+1+width,int.from_bytes(runtime[pc+1:pc+1+width],'big'))==(n['opcode'],n['next'],n['immediate'])
    if step['op']=='RETURNDATASIZE':assert stack(logs[i+2+j])[-1]==32
   end=logs[i+1+len(path['nodes'])];assert end['pc']==9354;assert stack(end)==s[:-9]+[int.from_bytes(expected,'big'),1];assert memory(end)==post
   observed.append({'receipt':f.name,'receiptSha256':hashlib.sha256(f.read_bytes()).hexdigest(),'pc':9331,'heap':at,'requestedGas':gas,'packetHex':packet.hex(),'resultHex':expected.hex(),'postGateInstructions':len(path['nodes'])})
 assert allreceipts==122 and len(observed)==16
 result={'status':'finite-physical-effects-passed-no-public-credit','runtimeSha256':site['runtimeSha256'],'receipts':allreceipts,'successfulExactReplyCases':len(observed),'failureWrongSizeFiniteCases':0,'explicitPremise':'Exact32-byte successful MODEXP observation mathematically faithful; actual engine implementation not proved. Native universal complementary gates remain open.','observed':observed};args.output.write_text(json.dumps(result,indent=2)+'\n');print('PASS122 receipts/16 complete physical MODEXP packets, replies and exact result gates; native open')
if __name__=='__main__':main()
