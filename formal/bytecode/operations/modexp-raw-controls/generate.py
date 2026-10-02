#!/usr/bin/env python3
"""Generate complete complementary raw gates and four modular-power accepted prefixes."""
import argparse,hashlib,json,importlib.util,subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];MOD=1<<256
SIGNATURES={'UU':0x44852766,'US':0xdec28c5b,'SU':0x640c3e5a,'SS':0x08198add}
FRONTIERS={'UU':4610,'US':8791,'SU':5210,'SS':2990}
CASES={family+case:(value,size,sig) for family,sig in SIGNATURES.items() for case,value,size in [('Nonzero',1,0),('Short',0,0),('Args',0,4),('Accepted',0,100)]}
GUARDS={name:('value!=0' if name.endswith('Nonzero') else 'value==0 && |data|<4' if name.endswith('Short') else f'value==0 && 4<=|data|<100 && S.ShiftRight(S.DataWord(data,0),224)=={sig}' if name.endswith('Args') else f'value==0 && 100<=|data|<0x10000000000000000 && S.ShiftRight(S.DataWord(data,0),224)=={sig}') for name,(_,_,sig) in CASES.items()}
def generate(out):
 spec=importlib.util.spec_from_file_location('modexp_source_gate',HERE.parent/'modexp-entry-preparation/generate-source-gate.py');gate=importlib.util.module_from_spec(spec);spec.loader.exec_module(gate);gate.generate(out)
 assert (out/'source-gate.json').read_bytes()==(HERE.parent/'modexp-entry-preparation/source-gate.json').read_bytes(),'Complete current powMod/helper AST gate changed'
 out.mkdir(parents=True,exist_ok=True);raw=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text())['deployedBytecode'][2:]);inv=json.loads((HERE.parent/'inventory.json').read_text());assert hashlib.sha256(raw).hexdigest()==inv['runtimeSha256'];assert all(int(inv['compilerIdentity']['methodIdentifiers'][sig],16)==SIGNATURES[k] for k,sig in {'UU':'powMod(uint256,uint256,uint256)','US':'powMod(uint256,int256,uint256)','SU':'powMod(int256,uint256,int256)','SS':'powMod(int256,int256,int256)'}.items())
 ins={};pc=0
 while pc<len(raw):
  op=raw[pc];width=op-95 if 96<=op<=127 else 0;nxt=pc+1+width;ins[pc]=(op,nxt,int.from_bytes(raw[pc+1:nxt],'big'));pc=nxt
 mappings=[]
 for name,(value,size,SIG) in CASES.items():
  stack=[];expr=[];memory='[]';nodes=[];dests=set();pc=0;seen=set()
  def push(v,e=None):stack.append(v);expr.append(str(v) if e is None else e)
  def pop():return stack.pop(),expr.pop()
  while True:
   if name.endswith('Accepted') and pc==FRONTIERS[name[:2]]:break
   assert (pc,tuple(stack),tuple(expr)) not in seen;seen.add((pc,tuple(stack),tuple(expr)))
   op,nxt,imm=ins[pc];before=expr[:];mem=memory;guide=''
   if op==0x5b:pass
   elif op==0x5f or 96<=op<=127:push(imm)
   elif op==0x34:push(value,'value')
   elif op==0x36:push(size,'|data|')
   elif op==0x35:
    at,_=pop();assert at in [0,4,36,68];push(SIG<<224 if at==0 else 0,f'S.DataWord(data,{at})')
   elif 128<=op<=143:k=op-127;push(stack[-k],expr[-k])
   elif 144<=op<=159:k=op-143;stack[-1],stack[-1-k]=stack[-1-k],stack[-1];expr[-1],expr[-1-k]=expr[-1-k],expr[-1]
   elif op==0x50:pop()
   elif op==0x15:
    v,e=pop();push(int(v==0),f'Bool(({e})==0)' if any(t in e for t in ['data','value']) else None)
   elif op in [1,3,16,17,18,20,28]:
    a,ae=pop();b,be=pop();actual={1:(a+b)%MOD,3:(a-b)%MOD,16:int(a<b),17:int(a>b),18:int((a if a<MOD//2 else a-MOD)<(b if b<MOD//2 else b-MOD)),20:int(a==b),28:(b>>a if a<256 else 0)}[op]
    symbolic=any(t in ae+be for t in ['data','value']);ex={1:f'((({ae}) as nat)+(({be}) as nat))%G.Modulus()',3:f'((({ae}) as nat)+G.Modulus()-(({be}) as nat))%G.Modulus()',16:f'Bool(({ae})<({be}))',17:f'Bool(({ae})>({be}))',18:f'Bool(G.Signed({ae})<G.Signed({be}))',20:f'Bool(({ae})==({be}))',28:f'S.ShiftRight({be},{ae})'}[op]
    if op==28:assert (ae,be)==('224','S.DataWord(data,0)');ex=str(SIG);guide=f'assert S.ShiftRight(S.DataWord(data,0),224)=={SIG};'
    push(actual,ex if symbolic else None)
   elif op==0x52:
    at,_=pop();v,e=pop();assert (at,v)==(64,128);memory='S.Store([],64,128)'
   elif op in [0x56,0x57]:
    dest,_=pop();take=op==0x56 or pop()[0]!=0;assert ins[dest][0]==0x5b;dests.add(dest)
    if take:nxt=dest
   elif op==0xfd:assert(pop()[0],pop()[0])==(0,0)
   else:raise AssertionError((name,pc,hex(op)))
   nodes.append(dict(pc=pc,opcode=op,next=ins[pc][1],immediate=imm,actualNext=nxt,stack=before,memory=mem,guide=guide));pc=nxt
   if op==0xfd:break
   assert len(nodes)<200
  terminal='S.Reverted([])' if not name.endswith('Accepted') else f'S.Running({pc},['+','.join(expr)+f'],{memory})'
  module='OperationsModularPowerRaw'+name
  params='self:S.Word,value:S.Word,data:seq<S.Byte>,observations:seq<E.Observation>'
  args='self,value,data,observations'
  step='E.Execute(code,destinations,frame,self,value,data,observations)'
  text=f'''// SPDX-License-Identifier: MIT
// Generated exact raw powMod gate/prefix. Never edit directly.
include "../modexp-execution/Execution.dfy"
module {module} {{
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import C = BytecodeCopyMachine
  import M = BytecodeExternalMachine
  import E = OperationsModularPowerExecution
  function Bool(value:bool):S.Word {{ if value then 1 else 0 }}
  predicate Admitted({params}) {{ |data|<0x10000000000000000 && {GUARDS[name]} }}
  predicate Matches(code:seq<S.Byte>) {{
'''
  text+='    '+' &&\n    '.join(f'{n["pc"]}<|code| && S.Fetch(code,{n["pc"]})==S.Op({n["opcode"]},{n["next"]},{n["immediate"]})' for n in nodes)
  text+=' &&\n    '+' &&\n    '.join(f'{d}<|code| && code[{d}]==0x5b' for d in sorted(dests))
  text+='\n  }\n  opaque predicate Good(id:nat,frame:E.Frame,'+params+')\n    requires Admitted('+args+')\n  {\n'
  for i,n in enumerate(nodes):text+=f'    {"if" if i==0 else "else if"} id=={i} then frame==M.Frame(S.Running({n["pc"]},['+','.join(n['stack'])+f'],{n["memory"]}),[],0)\n'
  text+=f'    else if id=={len(nodes)} then frame==M.Frame({terminal},[],0)\n    else false\n  }}\n'
  ds='{'+','.join(map(str,sorted(dests)))+'}'
  for i,n in enumerate(nodes):text+=f'''  lemma Advance{i}(code:seq<S.Byte>,destinations:set<nat>,frame:E.Frame,{params})
    requires Matches(code) && {ds}<=destinations && Admitted({args}) && Good({i},frame,{args})
    ensures Good({i+1},{step},{args})
  {{ {n['guide']} reveal Good(); reveal E.Execute(); reveal M.Step(); reveal C.Step(); reveal S.Step(); reveal G.Step(); }}
'''
  text+=f'''  lemma Start({params})
    requires Admitted({args})
    ensures Good(0,M.Frame(S.Running(0,[],[]),[],0),{args})
  {{ reveal Good(); }}
  ghost method Run(code:seq<S.Byte>,destinations:set<nat>,{params}) returns(frame:E.Frame,trace:seq<E.Frame>)
    requires Matches(code) && {ds}<=destinations && Admitted({args})
    ensures frame==M.Frame({terminal},[],0)
    ensures |trace|=={len(nodes)+1} && trace[0]==M.Frame(S.Running(0,[],[]),[],0) && trace[|trace|-1]==frame
    ensures E.Trace(code,destinations,self,value,data,observations,trace)
  {{
    frame:=M.Frame(S.Running(0,[],[]),[],0);trace:=[frame];Start({args});
'''
  for i,n in enumerate(nodes):
   text+=f'    Advance{i}(code,destinations,frame,{args});\n'
   text+=f'    reveal Good(); assert {step}.state!=S.Bad; E.Extend(code,destinations,self,value,data,observations,trace,{step}); frame:={step};trace:=trace+[frame];assert |trace|=={i+2};assert trace[0]==M.Frame(S.Running(0,[],[]),[],0);assert trace[|trace|-1]==frame;\n'
  text+='    reveal Good();\n  }\n}\n'
  (out/(name+'.generated.dfy')).write_text(text)
  mappings.append({'name':name,'selector':hex(SIG),'start':0,'states':nodes,'terminal':terminal,'destinations':sorted(dests)})
 (out/'raw.mapping.json').write_text(json.dumps({'runtimeSha256':hashlib.sha256(raw).hexdigest(),'selectors':SIGNATURES,'bodyFrontiers':FRONTIERS,'paths':mappings},indent=2)+'\n')
 for p in sorted(out.glob('*.generated.dfy')):
  r=subprocess.run(['/tmp/assertions-dafny-4.11.0/dafny/dafny','format','--stdin','--print'],input=p.read_text().replace('include \"','//FORMAT_INCLUDE \"'),capture_output=True,text=True);assert r.returncode==0,(p,r.stderr);p.write_text(r.stdout.replace('//FORMAT_INCLUDE \"','include \"'))
 print('Generated16 complete powMod raw gates/prefixes',sum(len(x['states']) for x in mappings),'actual instruction occurrences')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();generate(a.output)
