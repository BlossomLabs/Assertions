#!/usr/bin/env python3
"""Extract actual sortWords merge segments; native proofs check every reached step."""
import argparse,hashlib,json,subprocess,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];MOD=1<<256
class E:
 def __init__(self,v,t=None):self.v=v;self.t=str(v) if t is None else t
 def constant(self):return self.t.isdecimal()
def generate(out):
 code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Collections.sol/Collections.json').read_text())['deployedBytecode'][2:]);digest=hashlib.sha256(code).hexdigest();inv=json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text());assert digest==inv['Collections']['runtimeSha256'] and inv['Collections']['methodIdentifiers']['sortWords(bytes)']=='2ed74f49'
 ins={};p=0
 while p<len(code):
  op=code[p];w=op-95 if 96<=op<=127 else 0;ins[p]=(op,p+1+w,int.from_bytes(code[p+1:p+1+w].ljust(w,b'\0'),'big'));p+=1+w
 dests={p for p,(op,_,_) in ins.items() if op==91}
 defaults=dict(offset=100,n=4,out=128,scratch=288,width=1,start=0,middle=1,end=2,a=0,b=1,dest=0,lword=7,rword=11,take=1)
 params=', '.join(k+': Word' for k in defaults);actual=','.join(defaults)
 base='n < 0x800000000000000 && offset < 0x10000000000000000 && out < 0x20000000000000000 && scratch < 0x20000000000000000 && 0 < width <= 2*n+1 && start <= 3*n'
 specs=[]
 def expr(t,d):
  if isinstance(t,int):return E(t)
  return E(eval(t,{},d),t)
 outer=['785862473',518,'offset','n*32','out','n','scratch','width'];block=outer+['start'];inner=block+['middle','end','a','b','dest']
 def add(name,entry,end,terms,pre,changes=None):
  d=defaults| (changes or {});ranges=' && start <= a <= middle <= b <= end <= n && dest <= end && take <= 1' if name.startswith(('Inner','Decision','Take','AfterLeft','AfterRight')) else '';specs.append((name,entry,end,[expr(t,d) for t in terms],base+ranges+' && '+pre,d))
 add('PassEnter',3612,3622,outer,'width < n')
 add('SortExit',3612,518,outer,'width >= n',{'n':0})
 add('BlockPrepare',3622,23604,block,'start < n')
 # Actual helper returns to the exact continuation stack.
 add('MiddleClamp',3642,3666,block+[0,'n','start+width'],'start < n && start+width >= n',{'width':4})
 add('MiddleRecompute',3642,23604,block+[0,'n','start+width'],'start < n && start+width < n')
 add('MiddleComputed',3663,3666,block+[0,'start+width'],'start < n && start+width < n')
 add('EndPrepare',3666,23581,block+['middle'],'start < n')
 add('EndAfterMul',3678,23604,block+['middle',0,'n','width*2'],'start < n')
 add('EndClamp',3688,3720,block+['middle',0,'n','start+width*2'],'start < n && start+width*2 >= n',{'width':2})
 add('EndRecompute',3688,23581,block+['middle',0,'n','start+width*2'],'start < n && start+width*2 < n')
 add('EndSecondMul',3710,23604,block+['middle',0,'width*2'],'start < n')
 add('RangeStart',3720,3726,block+['middle',0,'end'],'start <= middle <= end')
 add('InnerContinue',3726,3735,inner,'dest < end')
 add('InnerExit',3726,23581,inner,'dest == end',{'a':1,'b':2,'dest':2})
 add('DecisionLeft',3735,3789,inner,'dest < end && a < middle && b < end && lword <= rword')
 add('DecisionRight',3735,3789,inner,'dest < end && a < middle && b < end && lword > rword',{'lword':11,'rword':7})
 add('DecisionLeftExhausted',3735,3789,inner,'dest < end && a == middle && b < end',{'a':1,'dest':1})
 add('DecisionRightExhausted',3735,3789,inner,'dest < end && a < middle && b == end',{'b':2,'dest':1})
 add('TakeLeftPrepare',3789,23760,inner+['take'],'dest < end && take == 1 && a < middle')
 add('TakeRightPrepare',3789,23760,inner+['take'],'dest < end && take == 0 && b < end',{'take':0})
 add('AfterLeftInc',3830,3833,inner+['take',3860,'scratch','dest',3847,'out','a','a+1'],'dest < end && take == 1 && a < middle')
 add('AfterRightInc',3813,3833,inner+['take',3860,'scratch','dest',3847,'out','b','b+1'],'dest < end && take == 0 && b < end',{'take':0})
 add('InnerTail',3860,3726,inner+['take'],'dest < end')
 add('BlockAfterMul',3887,23604,block+['width*2'],'start < n')
 add('BlockAfterAdd',3897,3622,block+['start+width*2'],'start < n')
 add('PassFinish',3622,23581,block,'start >= n',{'start':4,'a':4,'middle':4,'b':4,'end':4,'dest':4})
 add('PassAfterMul',3919,3612,outer+['width*2'],'width < n')
 for name,entry,end,initial,pre,d in specs:
  s=initial.copy();pc=entry;states=[];required={};targets=set();seen=set();loads=[]
  def pop():return s.pop()
  def push(x):s.append(x)
  while pc!=end:
   assert pc not in seen,(name,pc);seen.add(pc);op,nxt,imm=ins[pc]
   for p in range(pc,nxt):required[p]=code[p]
   states.append(dict(id=len(states),pc=pc,stack=[x.t for x in s],op=op,next=nxt,immediate=imm))
   if op==0x5b:pass
   elif op==0x5f or 96<=op<=127:push(E(imm))
   elif 0x80<=op<=0x8f:push(s[-(op-0x7f)])
   elif 0x90<=op<=0x9f:k=op-0x8f;s[-1],s[-1-k]=s[-1-k],s[-1]
   elif op==0x50:pop()
   elif op in [1,2,3]:
    a,b=pop(),pop();v=(a.v+b.v if op==1 else a.v*b.v if op==2 else a.v-b.v)%MOD;t=f'(({a.t} as nat)+({b.t} as nat))%G.Modulus()' if op==1 else f'(({a.t} as nat)*({b.t} as nat))%G.Modulus()' if op==2 else f'(({a.t} as nat)+G.Modulus()-({b.t} as nat))%G.Modulus()';push(E(v) if a.constant() and b.constant() else E(v,t))
   elif op in [0x10,0x11,0x14]:
    a,b=pop(),pop();push(E(int(a.v<b.v if op==0x10 else a.v>b.v if op==0x11 else a.v==b.v)))
   elif op==0x15:push(E(int(pop().v==0)))
   elif op==0x51:
    address=pop();which='rword' if not loads else 'lword';idx='b' if not loads else 'a';assert address.v==d['out']+32+d[idx]*32;(loads.append((idx,which)));push(E(d[which],which))
   elif op==0x57:
    dst,truth=pop(),pop();assert dst.constant() and dst.v in dests;targets.add(dst.v);required[dst.v]=code[dst.v]
    if truth.v:nxt=dst.v
   elif op==0x56:
    dst=pop();assert dst.constant() and dst.v in dests;targets.add(dst.v);required[dst.v]=code[dst.v];nxt=dst.v
   else:raise ValueError((name,pc,op))
   pc=nxt
  matches=' &&\n    '.join(f'code[{p}] == {v}' for p,v in sorted(required.items()))
  final=','.join(x.t for x in s);first=','.join(x.t for x in initial)
  good='\n'.join('    '+('if' if st['id']==0 else 'else if')+f" id == {st['id']} then state == Running({st['pc']},[{','.join(st['stack'])}],mem)" for st in states)+'\n    else false'
  mempre=' && '.join(f'out+32+{idx}*32+32 <= |mem| && Load(mem,out+32+{idx}*32) == {word}' for idx,word in loads) or 'true'
  if loads:mempre+=' && |mem| < G.Modulus() && Round32(|mem|) == |mem|'
  text=f'''// SPDX-License-Identifier: MIT
// Generated compiler-bound sortWords segment; each actual reached opcode is checked.
include "../../scans/Execution.dfy"
include "../../copy/Memory.dfy"
include "Scalar.dfy"
module BytecodeSortSegment{name} {{
  import opened BytecodeScanMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import G = BytecodeGetterMachine
  import C = BytecodeCopyMemory
  import SC = BytecodeSortMergeScalar
  predicate Admitted({params}) {{ {pre} }}
  predicate MemoryAdmitted(mem: seq<Byte>, {params}) {{ Admitted({actual}) && {mempre} }}
  opaque predicate Matches(code: seq<Byte>) {{ |code| == {len(code)} && {matches} }}
  function Destinations(): set<nat> {{ {{{','.join(map(str,sorted(targets)))}}} }}
  opaque predicate Good(id: nat, state: State, {params}, mem: seq<Byte>) {{ Admitted({actual}) && MemoryAdmitted(mem,{actual}) && (
{good}) }}
'''
  for st in states:
   i=st['id'];post=f'next == Running({end},[{final}],mem)' if i==len(states)-1 else f'Good({i+1},next,{actual},mem)';fetch=f"    F.Push{st['op']-95}(code,{st['pc']});\n" if st['op'] in [96,97] else ''
   if st['op']==0x51:
    idx='b' if st['pc']==3765 else 'a';fetch+=f'    SC.Address(out,{idx});\n    C.RoundedMonotone(out+32+{idx}*32+32,|mem|);\n    assert Expand(mem,out+32+{idx}*32+32) == mem;\n'
   if st['pc']==3782:fetch+='    SC.Difference(a,middle);\n'
   text+=f'''  lemma Advance{i}(code: seq<Byte>, state: State, {params}, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted({actual}) && MemoryAdmitted(mem,{actual}) && Good({i},state,{actual},mem)
    ensures state.Running? && |state.stack| <= 30 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); {post}
  {{
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running({st['pc']},[{','.join(st['stack'])}],mem);
{fetch}    assert Fetch(code,{st['pc']}) == Op({st['op']},{st['next']},{st['immediate']});
  }}
'''
  calls='\n'.join(f'    Advance{i}(code,state,{actual},mem,value,data);\n    var next{i} := Step(code,Destinations(),state,value,data);\n    E.Extend(code,Destinations(),value,data,trace,next{i});\n    trace := trace+[next{i}];\n    state := next{i};' for i in range(len(states)))
  text+=f'''  lemma Start({params}, mem: seq<Byte>)
    requires Admitted({actual}) && MemoryAdmitted(mem,{actual})
    ensures Good(0,Running({entry},[{first}],mem),{actual},mem)
  {{ reveal Good(); }}
  ghost method Run(code: seq<Byte>, {params}, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted({actual}) && MemoryAdmitted(mem,{actual})
    ensures state == Running({end},[{final}],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == {len(states)+1} && trace[0] == Running({entry},[{first}],mem) && trace[|trace|-1] == state
  {{
    Start({actual},mem);state := Running({entry},[{first}],mem);trace := [state];
{calls}
  }}
}}
'''
  out.mkdir(parents=True,exist_ok=True);(out/(name+'.generated.dfy')).write_text(text);(out/(name+'.mapping.json')).write_text(json.dumps(dict(runtimeSha256=digest,states=states,requiredBytes=required,destinations=sorted(targets),initialStack=first,finalStack=final,loads=loads,scope='Actual fitting merge segment only; complete unbounded merge/public entry retained evidence open'),indent=2)+'\n');print(name,len(states),first,'->',final,flush=True)
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();generate(a.output)
 subprocess.run([sys.executable,'-B',HERE/'format-generated.py','--output',a.output,'--include-root',HERE],check=True)
