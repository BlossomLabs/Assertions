#!/usr/bin/env python3
"""Actual zipWords alignment and count admission instruction segments."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];MOD=1<<256
class E:
 def __init__(self,v,t=None):self.v=v;self.t=str(v) if t is None else t
 def constant(self):return self.t.isdecimal()
def generate(out):
 code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Collections.sol/Collections.json').read_text())['deployedBytecode'][2:]);digest=hashlib.sha256(code).hexdigest();assert digest==json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Collections']['runtimeSha256']; assert json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Collections']['methodIdentifiers']['zipWords(bytes,bytes)']=='1008e959'
 ins={};p=0
 while p<len(code):
  op=code[p];w=op-95 if 96<=op<=127 else 0;ins[p]=(op,p+1+w,int.from_bytes(code[p+1:p+1+w].ljust(w,b'\0'),'big'));p+=1+w
 dests={p for p,(op,_,_) in ins.items() if op==91}
 A=E(100,'a');B=E(228,'b');LA=E(96,'lengthA');LB=E(96,'lengthB');C=E(3,'lengthA/32')
 frame=[E(269019481),E(518),A,LA,B,LB]
 base='lengthA < 0x10000000000000000 && lengthB < 0x10000000000000000'
 aligned=base+' && lengthA%32 == 0 && lengthB%32 == 0 && lengthA == lengthB'
 f='269019481,518,a,lengthA,b,lengthB'
 specs=[
 ('BodyStart',1846,23523,frame,base,f+',96,1859,32,lengthA'),
 ('FirstAligned',1859,23523,frame+[E(96),E(0,'lengthA%32')],base+' && lengthA%32 == 0',f+',96,1903,32,lengthB'),
 ('BothAlignedEqual',1903,1999,frame+[E(96),E(0,'lengthB%32')],aligned,f+',96'),
 ('DivideCount',1999,23562,frame+[E(96)],aligned,f+',96,0,2011,32,lengthA'),
 ('Multiply',2011,23581,frame+[E(96),E(0),C],aligned,f+',96,lengthA/32,2024,lengthA,2'),
 ('AllocationGuard',2024,2047,frame+[E(96),C,E(192,'lengthA*2')],aligned+' && lengthA < 0x8000000000000000',f+',96,lengthA/32,lengthA*2'),
 ('LargeOutputGuard',2024,23354,[E(269019481),E(518),A,E(1<<63,'lengthA'),B,E(1<<63,'lengthB'),E(96),E(1<<58,'lengthA/32'),E(1<<64,'lengthA*2')],aligned+' && lengthA >= 0x8000000000000000',f+',96,lengthA/32,lengthA*2,2047'),
 ('MismatchFirstDivide',1936,23562,[E(269019481),E(518),A,LA,B,E(32,'lengthB'),E(96)],base+' && lengthA%32 == 0 && lengthB%32 == 0 && lengthA != lengthB',f+',96,1954,32,lengthA'),
 ('MismatchSecondDivide',1954,23562,[E(269019481),E(518),A,LA,B,E(32,'lengthB'),E(96),C],base+' && lengthA%32 == 0 && lengthB%32 == 0 && lengthA != lengthB',f+',96,lengthA/32,1965,32,lengthB')]


 for name,entry,end,initial,pre,final in specs:
  s=initial.copy();pc=entry;states=[];required={};targets=set();seen=set()
  def pop():return s.pop()
  def push(x):s.append(x)
  while pc!=end:
   assert pc not in seen;seen.add(pc);op,nxt,imm=ins[pc]
   for p in range(pc,nxt):required[p]=code[p]
   states.append({'id':len(states),'pc':pc,'stack':[x.t for x in s],'op':op,'next':nxt,'immediate':imm})
   if op==0x5b:pass
   elif op==0x5f or 96<=op<=127:push(E(imm))
   elif 0x80<=op<=0x8f:push(s[-(op-0x7f)])
   elif 0x90<=op<=0x9f:k=op-0x8f;s[-1],s[-1-k]=s[-1-k],s[-1]
   elif op==0x50:pop()
   elif op in [0x01,0x03]:
    a,b=pop(),pop();v=(a.v+b.v)%MOD if op==1 else (a.v-b.v)%MOD;t=f'(({a.t} as nat)+({b.t} as nat))%G.Modulus()' if op==1 else f'(({a.t} as nat)+G.Modulus()-({b.t} as nat))%G.Modulus()';push(E(v) if a.constant() and b.constant() else E(v,t))
   elif op in [0x10,0x11,0x14]:a,b=pop(),pop();push(E(int(a.v<b.v if op==0x10 else a.v>b.v if op==0x11 else a.v==b.v)))
   elif op==0x1b:a,b=pop(),pop();assert a.constant() and b.constant();push(E((b.v<<a.v)%MOD))
   elif op==0x15:push(E(int(pop().v==0)))
   elif op==0x57:
    dest,truth=pop(),pop();assert dest.constant() and dest.v in dests;targets.add(dest.v);required[dest.v]=code[dest.v]
    if truth.v:nxt=dest.v
   elif op==0x56:
    dest=pop();assert dest.constant() and dest.v in dests;targets.add(dest.v);required[dest.v]=code[dest.v];nxt=dest.v
   else:raise ValueError((name,pc,op))
   pc=nxt
  matches=' &&\n    '.join(f'code[{p}] == {v}' for p,v in sorted(required.items()))
  good='\n'.join('    '+('if' if n['id']==0 else 'else if')+f" id == {n['id']} then state == Running({n['pc']},[{','.join(n['stack'])}],mem)" for n in states)+'\n    else false'
  params='a: Word, lengthA: Word, b: Word, lengthB: Word';actual='a,lengthA,b,lengthB'
  text=f'''// SPDX-License-Identifier: MIT
// Generated pinned zipWords admission instructions between actual helper boundaries.
include "../../scans/Execution.dfy"
include "../../scans/DecoderScalar.dfy"
module BytecodeZipAdmission{name} {{
  import opened BytecodeScanMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import G = BytecodeGetterMachine
  import SC = BytecodeScanDecoderScalar
  predicate Admitted({params}) {{ {pre} }}
  opaque predicate Matches(code: seq<Byte>) {{ |code| == {len(code)} &&
    {matches}
  }}
  function Destinations(): set<nat> {{ {{{','.join(map(str,sorted(targets)))}}} }}
  opaque predicate Good(id: nat, state: State, {params}, mem: seq<Byte>) {{ Admitted({actual}) && (
{good}) }}
'''
  for n in states:
   i=n['id'];post=f'next == Running({end},[{final}],mem)' if i==len(states)-1 else f'Good({i+1},next,{actual},mem)';fetch=f"    F.Push{n['op']-95}(code,{n['pc']});\n" if n['op'] in [96,97] else ''
   if n['op']==0x1b:fetch+='    SC.DecoderLimit();\n'
   text+=f'''  lemma Advance{i}(code: seq<Byte>, state: State, {params}, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted({actual}) && Good({i},state,{actual},mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); {post}
  {{
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running({n['pc']},[{','.join(n['stack'])}],mem);
{fetch}    assert Fetch(code,{n['pc']}) == Op({n['op']},{n['next']},{n['immediate']});
  }}
'''
  first=','.join(x.t for x in initial);calls='\n'.join(f'    Advance{i}(code,state,{actual},mem,value,data);\n    var next{i} := Step(code,Destinations(),state,value,data);\n    E.Extend(code,Destinations(),value,data,trace,next{i});\n    trace := trace+[next{i}];\n    assert trace[0] == Running({entry},[{first}],mem);\n    state := next{i};' for i in range(len(states)))
  text+=f'''  lemma Start({params}, mem: seq<Byte>)
    requires Admitted({actual})
    ensures Good(0,Running({entry},[{first}],mem),{actual},mem)
  {{ reveal Good(); }}
  ghost method Run(code: seq<Byte>, {params}, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted({actual})
    ensures state == Running({end},[{final}],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == {len(states)+1} && trace[0] == Running({entry},[{first}],mem) && trace[|trace|-1] == state
  {{
    Start({actual},mem);
    state := Running({entry},[{first}],mem);
    trace := [state];
{calls}
  }}
}}
'''
  out.mkdir(parents=True,exist_ok=True);(out/(name+'.generated.dfy')).write_text(text);(out/(name+'.mapping.json')).write_text(json.dumps({'runtimeSha256':digest,'states':states,'requiredBytes':required,'destinations':sorted(targets),'expectedFinalStack':final,'scope':'development admitted actual loop segment only; unbounded loop/public entry and retained evidence remain open'},indent=2)+'\n');print(name,len(states),'states')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();generate(a.output)
 import subprocess,sys
 subprocess.run([sys.executable,'-B',HERE/'format-generated.py','--output',a.output,'--include-root',HERE],check=True)
