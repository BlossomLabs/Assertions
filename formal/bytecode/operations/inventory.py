#!/usr/bin/env python3
"""Compiler-bound Operations ABI and exact instruction boundary inventory."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
def generate(identity_folder,out):
 identity=json.loads((identity_folder/'identity.json').read_text())[0]
 assert identity['contract']=='Operations' and identity['identicalRuntime']
 code=(identity_folder/'Operations.runtime.bin').read_bytes()
 assert hashlib.sha256(code).hexdigest()==identity['runtimeSha256']
 ins={};pc=0
 while pc<len(code):
  op=code[pc];width=op-95 if 96<=op<=127 else 0
  ins[pc]=(op,pc+1+width,int.from_bytes(code[pc+1:pc+1+width].ljust(width,b'\0'),'big'));pc+=width+1
 entries={}
 for pc,(op,nxt,imm) in ins.items():
  if not 0x60<=op<=0x63 or f'{imm:08x}' not in identity['methodIdentifiers'].values():continue
  eq=ins.get(nxt);push=ins.get(eq[1]) if eq else None;jump=ins.get(push[1]) if push else None
  if eq and eq[0]==0x14 and push and push[0]==0x61 and jump and jump[0]==0x57:
   assert imm not in entries;entries[imm]=push[2]
 assert len(entries)==len(identity['methodIdentifiers'])==92
 assert all(ins[p][0]==0x5b for p in entries.values())
 source=json.loads((ROOT/'formal/operations/verification-plan.json').read_text())
 source_entries={x['signature']:x for x in source['publicEntries']}
 assert set(source_entries)==set(identity['methodIdentifiers'])
 result={'schemaVersion':1,'contract':'Operations','runtimeBytes':len(code),'runtimeSha256':identity['runtimeSha256'],'compilerIdentity':identity,'instructionBoundaries':sorted(ins),'selectorToDeclaredEntryPc':{str(k):v for k,v in sorted(entries.items())},'publicEntries':[{'signature':k,'selector':v,'entryPc':entries[int(v,16)],'stateMutability':source_entries[k]['stateMutability'],'sourceLedger':source_entries[k]['ledger'],'bytecodeStatus':'open'} for k,v in sorted(identity['methodIdentifiers'].items())],'scope':'Exact compiler-bound inventory only. No opcode, ABI body, success or rejection proof is inferred.'}
 out.write_text(json.dumps(result,indent=2)+'\n');print('PASS: 92 compiler-bound public entries and complete instruction boundary scan')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--identity',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();generate(a.identity,a.output)
