#!/usr/bin/env python3
"""Require semantic native and EVM rejection of physical error byte faults."""
import argparse,importlib.util,json,os,re,shutil,subprocess,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
def main():
 p=argparse.ArgumentParser();p.add_argument('--dafny',type=Path,required=True);p.add_argument('--node',type=Path,required=True);p.add_argument('--root',type=Path,default=ROOT);p.add_argument('--output',type=Path,required=True);a=p.parse_args();out=a.output.resolve();out.mkdir(parents=True,exist_ok=False);os.environ['DAFNY']=str(a.dafny)
 root=a.root.resolve();source=root/HERE.relative_to(ROOT);code=bytes.fromhex(json.loads((root/'artifacts/contracts/Assertions.sol/Assertions.json').read_text())['deployedBytecode'][2:]);results=[]
 for name,pc,expected,replacement,proof,case in [('bounds-selector',3995,194,195,'FirstWord','condition-first-word-31'),('address-error-index',4060,131,132,'AsAddress','dirty-address'),('pick-error-index',7539,134,132,'RawWord','signed-maximum')]:
  assert code[pc]==expected,(name,pc,code[pc]);folder=out/name;folder.mkdir();runtime=folder/'runtime.bin';candidate=bytearray(code);candidate[pc]=replacement;runtime.write_bytes(candidate)
  generated=folder/'generated';cmd=[sys.executable,'-B',source/'generate.py','--runtime',runtime,'--output',generated];g=subprocess.run(list(map(str,cmd)),text=True,capture_output=True);(folder/'generation.log').write_text(g.stdout+g.stderr)
  if g.returncode:raise RuntimeError('Candidate extraction failed '+name)
  # Preserve the independent specifications and semantics; only byte-extracted
  # candidate certificates change. Keep relative includes resolvable locally.
  for suffix in ['Scalar.dfy','Connection.dfy']:shutil.copy2(source/suffix,generated/suffix)
  shared=source.parent/'scans'
  for f in generated.glob('*.dfy'):
   text=f.read_text();text=re.sub(r'^include "../scans/([^\"]+)"',lambda m:'include "'+str(shared/m[1])+'"',text,flags=re.M);f.write_text(text)
  helper={'FirstWord':'FirstWordShort','AsAddress':'AsAddressDirty','RawWord':'RawWordPositiveOob'}[proof]
  certificate=(generated/(helper+'.generated.dfy')).read_text();header=int(re.search(r'function Memory1\([^\n]+?Store\(mem,free,(\d+)\)',certificate)[1]);actual='word' if proof=='AsAddress' else 'length/32'
  params='ptr: Word, length: Word, word: Word, index: Word, free: Word, ret: Word, prefix: seq<Word>, mem: seq<Byte>';args='ptr,length,word,index,free,ret,prefix,mem'
  goal=f'Load(H.Memory1({args}),free) == 0xd5cb843600000000000000000000000000000000000000000000000000000000' if proof=='FirstWord' else f'Load(H.Memory2({args}),free+4) == index'
  body=f'R.StoredWord(mem,free,{header});'
  if proof!='FirstWord':body+=f'\n    R.StoredWord(H.Memory1({args}),free+4,{actual});\n    assert Load(H.Memory2({args}),free+4) == {actual};'
  (generated/'Fault.dfy').write_text(f'''// SPDX-License-Identifier: MIT
include "{helper}.generated.dfy"
module AssertionsPrimitiveSemanticFault {{
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import R = BytecodeScanRepresentation
  import H = AssertionsPrimitive{helper}
  lemma CorrectErrorField({params})
    requires |mem|%32 == 0 && free+96 < G.Modulus()
    ensures {goal}
  {{
    {body}
  }}
}}
''')
  csv=folder/'proof.csv';cmd=[a.dafny,'verify',generated/'Fault.dfy','--filter-symbol','AssertionsPrimitiveSemanticFault','--manual-lemma-induction','--isolate-assertions','--cores','1','--verification-time-limit','30','--solver-path',a.dafny.parent/'z3/bin/z3-4.12.1','--log-format','csv;LogFileName='+str(csv)]
  formal_command=list(map(str,cmd));pr=subprocess.run(formal_command,text=True,capture_output=True,timeout=180);log=pr.stdout+pr.stderr;(folder/'proof.log').write_text(log)
  formal=pr.returncode==4 and 'a postcondition could not be proved' in log and not re.search(r'timed out|Resolution/type|Parse Error',log,re.I)
  cmd=[a.node,HERE/'evm-traces.mjs','--root',root,'--runtime',runtime,'--output',folder/'evm','--case',case];evm=subprocess.run(list(map(str,cmd)),text=True,capture_output=True,timeout=120);(folder/'evm.log').write_text(evm.stdout+evm.stderr)
  rows=json.loads((folder/'evm/results.json').read_text());concrete=evm.returncode==1 and len(rows)==1 and rows[0]['name']==case and not rows[0]['receiptPassed'];result={'name':name,'pc':pc,'before':expected,'after':replacement,'formalRejected':formal,'evmRejected':concrete,'passed':formal and concrete,'formalCommand':formal_command,'evmCommand':list(map(str,cmd)),'formalExitCode':pr.returncode,'evmExitCode':evm.returncode,'case':case};results.append(result);(out/'results.json').write_text(json.dumps(results,indent=2)+'\n');print(name,'killed' if result['passed'] else 'FAILED',flush=True)
 if not all(r['passed'] for r in results):raise SystemExit('Semantic bytecode fault escaped required native/EVM checks')
if __name__=='__main__':main()
