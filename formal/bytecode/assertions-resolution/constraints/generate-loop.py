#!/usr/bin/env python3
"""Exact physical validator loop orchestration segments, unbounded symbolic inputs."""
import argparse,hashlib,json,os,subprocess,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];MOD=1<<256
class E:
 def __init__(self,v,t=None):self.v=v;self.t=str(v) if t is None else t;self.constant=t is None
def signed(v):return v if v<MOD//2 else v-MOD
def generate(out):
 code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Assertions.sol/Assertions.json').read_text())['deployedBytecode'][2:]);digest=hashlib.sha256(code).hexdigest();ins={};p=0
 while p<len(code):
  op=code[p];w=op-95 if 96<=op<=127 else 0;ins[p]=(op,p+1+w,int.from_bytes(code[p+1:p+1+w].ljust(w,b'\0'),'big'));p+=1+w
 dests={p for p,(op,_,_) in ins.items() if op==91}
 variables={'ret':3967,'constraints':260,'count':1,'ptr':160,'length':32,'assertion':128,'entry':0,'param':0,'index':0,'actual':7,'relative':32,'record':224,'kind':7}
 base=['ret','constraints','count','ptr','assertion','entry','param'];loop=base+['count','length/32','index'];params=', '.join(k+': Word' for k in variables)+', prefix: seq<Word>, mem: seq<Byte>, data: seq<Byte>';args=','.join(variables)+',prefix,mem,data'
 seeds=[('Init',7580,7660,base),('Prepare',7660,19377,loop),('Dispatch',7723,10646,loop+['actual','0','record']),('Increment',8035,7660,loop+['actual','record','0','1']),('Exit',7660,None,base+['count','length/32','count']),('Empty',7580,None,base)]
 independent={'Init':base+['count','length/32','0'],'Prepare':loop+['actual','0','7723','constraints+relative'],'Dispatch':loop+['actual','record','0','8035','actual','record','entry','param','index'],'Increment':base+['count','length/32','index+1'],'Exit':[],'Empty':[]}
 for name,pc,stop,seed in seeds:
  if name=='Empty':variables['count']=0
  def evalsym(expr):return variables[expr] if expr in variables else 1 if expr=='length/32' else int(expr)
  s=[E(evalsym(t),t) if not t.isdigit() else E(int(t)) for t in seed];states=[];required={};targets={'ret'};seen=set()
  def pop():return s.pop()
  def push(x):s.append(x)
  while True:
   key=(pc,tuple(x.t for x in s));assert pc in ins and key not in seen;seen.add(key);op,nxt,imm=ins[pc]
   for q in range(pc,nxt):required[q]=code[q]
   node={'id':len(states),'pc':pc,'op':op,'next':nxt,'immediate':imm,'stack':[x.t for x in s],'memory':'mem','guide':[]};states.append(node)
   if op==91:pass
   elif op==95 or 96<=op<=127:push(E(imm))
   elif 128<=op<=143:push(s[-(op-127)])
   elif 144<=op<=159:k=op-143;s[-1],s[-1-k]=s[-1-k],s[-1]
   elif op==80:pop()
   elif op==21:
    a=pop();push(E(int(a.v==0)) if a.constant else E(int(a.v==0),f'(if {a.t} == 0 then 1 else 0)'))
   elif op==25:
    a=pop();assert a.v in [31,62];push(E(MOD-1-a.v));node['guide'].append('    H.Complement'+str(a.v)+'();')
   elif op in [1,2,3,4,16,17,18,20]:
    a,b=pop(),pop()
    if op==1:v=(a.v+b.v)%MOD;t=f'(({a.t} as nat)+({b.t} as nat))%G.Modulus()'
    elif op==2:v=(a.v*b.v)%MOD;t=f'(({a.t} as nat)*({b.t} as nat))%G.Modulus()'
    elif op==3:v=(a.v-b.v)%MOD;t=f'(({a.t} as nat)+G.Modulus()-({b.t} as nat))%G.Modulus()'
    elif op==4:v=0 if b.v==0 else a.v//b.v;t=f'(if {b.t} == 0 then 0 else ({a.t} as nat)/({b.t} as nat))'
    else:
     pred={16:f'{a.t} < {b.t}',17:f'{a.t} > {b.t}',18:f'G.Signed({a.t}) < G.Signed({b.t})',20:f'{a.t} == {b.t}'}[op]
     v=int({16:a.v<b.v,17:a.v>b.v,18:signed(a.v)<signed(b.v),20:a.v==b.v}[op]);t=f'(if {pred} then 1 else 0)'
    push(E(v) if a.constant and b.constant else E(v,t))
   elif op==54:push(E(388,'|data|'))
   elif op==53:
    a=pop();assert name=='Prepare' and a.v==260;push(E(32,'relative'));node['guide'] += [f'    assert {a.t} == constraints+index*32;',f'    assert S.DataWord(data,{a.t}) == relative;']
   elif op==81:
    a=pop();value='length' if name=='Init' else 'actual' if name=='Prepare' else 'kind';position='ptr' if name=='Init' else 'ptr+32+index*32' if name=='Prepare' else 'record'
    push(E(variables[value],value));node['guide'] += [f'    assert {a.t} == {position};',f'    assert S.Load(mem,{a.t}) == {value};',f'    assert S.Expand(mem,({a.t} as nat)+32) == mem;']
   elif op in [86,87]:
    target=pop();take=op==86 or pop().v!=0
    if not target.constant:
     assert name in ['Exit','Empty'] and target.t=='ret' and op==86;break
    assert target.v in dests;required[target.v]=code[target.v];targets.add(str(target.v))
    if take:nxt=target.v
   else:raise ValueError((name,pc,op))
   if stop is not None and nxt==stop:break
   pc=nxt
  finalpc='ret' if name in ['Exit','Empty'] else str(stop);finalstack=','.join(independent[name]);initialpc=states[0]['pc'];initialstack=','.join(seed)
  if finalstack:node['guide'].append(f'    assert [{",".join(x.t for x in s)}] == [{finalstack}];')
  admitted=f"""|prefix| <= 950 && |mem|%32 == 0 && 96 <= |mem| < 0x10000000000000000 &&
    |data| < 0x10000000000000000 && 0 < count <= length/32 && ptr >= 96 &&
    (ptr as nat)+32+length <= |mem| && S.Load(mem,ptr) == length &&
    (constraints as nat)+count*32 <= |data| &&
    {'index == count' if name=='Exit' else 'index < count'}"""
  if name=='Prepare':admitted += """ &&
    (constraints as nat)+relative+64 <= |data| && S.DataWord(data,constraints+index*32) == relative &&
    S.Load(mem,ptr+32+index*32) == actual"""
  if name=='Dispatch':admitted += """ &&
    kind <= 8 && kind != 6 && (record as nat)+64 <= |mem| && S.Load(mem,record) == kind"""
  if stop is not None:required[stop]=code[stop];targets.add(str(stop))
  if name=='Empty':admitted='|prefix| <= 950 && count == 0'
  constraints=' &&\n    '.join(f'code[{p}] == {v}' for p,v in sorted(required.items()))
  good='\n'.join('    '+('if' if n['id']==0 else 'else if')+f' id == {n["id"]} then state == S.Running({n["pc"]},prefix+[{",".join(n["stack"])}],{n["memory"]})' for n in states)+'\n    else false'
  targetlist=','.join(sorted(targets,key=lambda t:(t=='ret',int(t) if t!='ret' else 0)))
  text=f'''// SPDX-License-Identifier: MIT
 // Exact validator {name} orchestration; arbitrary admitted count and index.
 include "../raw/Machine.dfy"
 include "../raw/Frame.dfy"
 include "LoopScalar.dfy"
 include "And.dfy"
 include "Addresses.dfy"
 include "../../scans/Fetch.dfy"
 module AssertionsConstraint{name} {{
   import S = BytecodeScanMachine
   import G = BytecodeGetterMachine
   import C = BytecodeCopyMachine
   import B = BytecodeCopyMemory
   import A = AssertionsSignedMachine
   import M = AssertionsRawResolveMachine
   import R = BytecodeScanRepresentation
    import F = BytecodeScanFetch
   import D = BytecodeScanDecoderScalar
   import H = AssertionsConstraintLoopScalar
   import L = AssertionsPrimitiveLowMask
   import HH = AssertionsConstraintAnd
   import V = AssertionsConstraintAddresses
   import Q = AssertionsRawResolveFrame
   type Word = S.Word
   type Byte = S.Byte
   predicate Admitted({params}) {{ {admitted} }}
   function Expected({params}): S.State requires Admitted({args}) {{ S.Running({finalpc},prefix+[{finalstack}],mem) }}
   opaque predicate Matches(code: seq<Byte>, ret: Word) {{
     |code| == {len(code)} && ret < |code| && code[ret] == 91 &&
     {constraints}
   }}
   function Destinations(ret: Word): set<nat> {{ {{{targetlist}}} }}
   opaque predicate Good(id: nat, state: S.State, {params}) {{
     Admitted({args}) && (
 {good})
   }}
 '''
  for n in states:
   i=n['id'];post=f'next == Expected({args})' if i==len(states)-1 else f'Good({i+1},next,{args})'
   fetch=f'    F.Push{n["op"]-95}(code,{n["pc"]});\n' if n['op'] in [96,97] else ''
   guide='\n'.join(n['guide'])
   attrs=' {:isolate_assertions}' if n['op'] in [22,55,82] or n['pc']==18184 else ''
   before=''
   text+=f'''  lemma{attrs} Advance{i}(code: seq<Byte>, state: S.State, {params}, value: Word)
     requires Matches(code,ret) && Admitted({args}) && Good({i},state,{args})
     ensures M.Step(code,Destinations(ret),state,value,data) != S.Bad
     ensures Q.Local(code,state) && Q.Local(code,M.Step(code,Destinations(ret),state,value,data))
     ensures var next := M.Step(code,Destinations(ret),state,value,data); {post}
   {{
     hide G.BitAnd();
 {before}
     reveal Matches(); reveal Good(); reveal M.Step(); reveal C.Step(); reveal A.Step(); reveal S.Step();
 {fetch}    assert S.Fetch(code,{n['pc']}) == S.Op({n['op']},{n['next']},{n['immediate']});
 {guide}
   }}
 '''
  calls='\n'.join(f'    {"if" if i==0 else "else if"} id == {i} {{ Advance{i}(code,state,{args},value); }}' for i in range(len(states)))
  text+=f'''  lemma Start(code: seq<Byte>, {params})
     requires Admitted({args}) && Matches(code,ret)
     ensures Good(0,S.Running({initialpc},prefix+[{initialstack}],mem),{args})
     ensures Q.Local(code,S.Running({initialpc},prefix+[{initialstack}],mem))
   {{ reveal Good(); reveal Matches(); }}
   lemma Advance(id: nat, code: seq<Byte>, state: S.State, {params}, value: Word)
     requires Matches(code,ret) && Admitted({args}) && Good(id,state,{args}) && id < {len(states)}
     ensures M.Step(code,Destinations(ret),state,value,data) != S.Bad
     ensures Q.Local(code,state) && Q.Local(code,M.Step(code,Destinations(ret),state,value,data))
     ensures var next := M.Step(code,Destinations(ret),state,value,data);
       if id == {len(states)-1} then next == Expected({args}) else Good(id+1,next,{args})
   {{
 {calls}
   }}
   ghost method Run(code: seq<Byte>, {params}, value: Word) returns (state: S.State, trace: seq<S.State>)
     requires Matches(code,ret) && Admitted({args})
     ensures state == Expected({args})
     ensures M.Trace(code,Destinations(ret),value,data,trace)
     ensures forall i {{:trigger trace[i]}} :: 0 <= i < |trace| ==> Q.Local(code,trace[i])
     ensures trace[0] == S.Running({initialpc},prefix+[{initialstack}],mem) && trace[|trace|-1] == state

   {{
     state := S.Running({initialpc},prefix+[{initialstack}],mem);
     Start(code,{args}); trace := [state];
     var id: nat := 0;
     while id < {len(states)}
       invariant id <= {len(states)} && |trace| == id+1
       invariant M.Trace(code,Destinations(ret),value,data,trace)
       invariant forall i {{:trigger trace[i]}} :: 0 <= i < |trace| ==> Q.Local(code,trace[i])
       invariant trace[0] == S.Running({initialpc},prefix+[{initialstack}],mem) && trace[|trace|-1] == state
       invariant id < {len(states)} ==> Good(id,state,{args})
       invariant id == {len(states)} ==> state == Expected({args})
       decreases {len(states)}-id
     {{
       Advance(id,code,state,{args},value);
       var next := M.Step(code,Destinations(ret),state,value,data);
       M.Extend(code,Destinations(ret),value,data,trace,next);
       trace := trace+[next];state := next;id := id+1;
     }}
   }}
 }}
 '''
  text=text.replace('\n ','\n')
  out.mkdir(parents=True,exist_ok=True);(out/(name+'.generated.dfy')).write_text(text);(out/(name+'.mapping.json')).write_text(json.dumps({'runtimeSha256':digest,'states':states,'requiredBytes':required,'scope':'complete internal validator '+name+' orchestration segment; symbolic count/index, exact physical read/control/stack, no decoder/leaf/whole-loop completion claim'},indent=2)+'\n');print(name,len(states))
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);p.add_argument('--dafny',type=Path);a=p.parse_args();generate(a.output)
 if a.dafny:subprocess.run([sys.executable,'-B',ROOT/'formal/bytecode/format-generated.py','--output',a.output,'--include-root',HERE],env=dict(os.environ,DAFNY=str(a.dafny.resolve())),check=True)
