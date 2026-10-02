#!/usr/bin/env python3
"""Semantic byte mutations: independent operand/result fields and full EVM receipts."""
import argparse,csv,hashlib,json,os,re,subprocess,sys,time
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
def main():
 p=argparse.ArgumentParser();p.add_argument('--root',type=Path,default=ROOT);p.add_argument('--dafny',type=Path,required=True);p.add_argument('--node',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();root,dafny,node,out=[x.resolve() for x in (a.root,a.dafny,a.node,a.output)];out.mkdir(parents=True,exist_ok=False)
 runtime=bytes.fromhex(json.loads((root/'artifacts/contracts/Assertions.sol/Assertions.json').read_text())['deployedBytecode'][2:]);results=[]
 cases=[('gather-step',2561,1,2,'gather-2',2560,True),('probe-validity',3380,1,0,'isValid-false-value',3379,False),('fallback-index',1842,1,0,'orElse-fallback-constraint',1841,False)]
 for name,offset,old,new,fixture,pc,addition in cases:
  assert runtime[offset]==old and runtime[pc]==0x60
  folder=out/name;folder.mkdir();candidate=bytearray(runtime);candidate[offset]=new;code=folder/'runtime.bin';code.write_bytes(candidate)
  target=pc+3 if addition else pc+2
  result='((index as nat)+1)%G.Modulus()' if addition else '1'
  requires=f'code[{pc+2}] == 1 && index < 0x10000000000000000' if addition else 'true'
  calculation=f'var next := Step(code,{{}},first,value,data);\n    assert first == Running({pc+2},prefix+[index,{new}],mem);' if addition else 'var next := first;'
  initial='prefix+[index]' if addition else 'prefix'
  fault=f'''// SPDX-License-Identifier: MIT
// Mutated physical field is judged against independent canonical increment/index/boolean intent.
include "{root/'formal/bytecode/scans/Execution.dfy'}"
include "{root/'formal/bytecode/scans/Push.dfy'}"
module AssertionsPrimitiveControlMutation {{
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  lemma PhysicalField(code: seq<Byte>, prefix: seq<Word>, index: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires |code| == {len(runtime)} && code[{pc}] == 0x60 && code[{pc+1}] == {new} && {requires}
    requires |prefix| <= 980
    ensures var first := Step(code,{{}},Running({pc},{initial},mem),value,data);
            var next := {'Step(code,{},first,value,data)' if addition else 'first'};
            next == Running({target},prefix+[{result}],mem)
  {{
    reveal Step(); F.Push1(code,{pc});
    var first := Step(code,{{}},Running({pc},{initial},mem),value,data);
    {calculation}
  }}
}}
'''
  file=folder/'Fault.dfy';file.write_text(fault);csvfile=folder/'proof.csv';cmd=[str(dafny),'verify',str(file),'--manual-lemma-induction','--isolate-assertions','--cores','1','--verification-time-limit','30','--solver-path',str(dafny.parent/'z3/bin/z3-4.12.1'),'--filter-symbol','AssertionsPrimitiveControlMutation','--log-format','csv;LogFileName='+str(csvfile)];start=time.time()
  with (folder/'proof.log').open('w') as log:proof=subprocess.run(cmd,stdout=log,stderr=subprocess.STDOUT,timeout=180)
  rows=list(csv.DictReader(csvfile.open())) if csvfile.exists() else [];log=(folder/'proof.log').read_text();formal=proof.returncode==4 and bool(rows) and any(r['TestResult.Outcome']=='Failed' for r in rows) and 'could not be proved' in log and not any(x in log for x in ['timed out','parse errors','resolution/type errors'])
  evmdir=folder/'evm';cmd2=[str(node),str(HERE/'evm-traces.mjs'),'--root',str(root),'--runtime',str(code),'--case',fixture,'--output',str(evmdir)]
  with (folder/'evm.log').open('w') as log:evm=subprocess.run(cmd2,stdout=log,stderr=subprocess.STDOUT,timeout=300)
  evidence=json.loads((evmdir/'results.json').read_text()) if (evmdir/'results.json').exists() else [];receipt=evm.returncode==1 and len(evidence)==1 and not evidence[0]['receiptPassed']
  results.append({'name':name,'offset':offset,'originalByte':old,'mutatedByte':new,'candidateSha256':hashlib.sha256(candidate).hexdigest(),'formalCommand':cmd,'formalExitCode':proof.returncode,'formalSemanticFailure':formal,'nativeResults':rows,'evmCommand':cmd2,'evmExitCode':evm.returncode,'evmReceiptFailure':receipt,'seconds':round(time.time()-start,3),'passed':formal and receipt})
  print(name,'PASS' if results[-1]['passed'] else 'FAIL',flush=True)
 (out/'results.json').write_text(json.dumps(results,indent=2)+'\n');raise SystemExit(0 if len(results)==3 and all(x['passed'] for x in results) else 1)
if __name__=='__main__':main()
