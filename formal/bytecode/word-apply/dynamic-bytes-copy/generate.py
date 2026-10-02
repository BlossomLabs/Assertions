#!/usr/bin/env python3
"""Extract every instruction of shared ABI bytes copy at20951 for any fitting length."""
import argparse, hashlib, json, subprocess, sys
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[3]
MOD=1<<256


class Expr:
    def __init__(self,key=None,constant=0,terms=None):
        self.terms = dict(terms or ({key:1} if key else {}))
        self.constant = constant

    def add(self,other):
        terms=self.terms.copy()
        for k,v in other.terms.items():terms[k]=terms.get(k,0)+v
        return Expr(constant=self.constant+other.constant,terms=terms)

    @property
    def text(self):
        if not self.terms:return str(self.constant)
        if self.terms=={'dst':1,'round':1} and self.constant==32:return 'H.End(dst,length)'
        if self.terms=={'dst':1,'length':1} and self.constant==32:return 'dst+32+length'
        if self.terms=={'dst':1,'length':1} and self.constant==0:return 'dst+length'
        if self.terms=={'dst':1,'round':1} and self.constant==0:return 'dst+S.Round32(length)'
        assert len(self.terms)==1 and next(iter(self.terms.values()))==1,(self.terms,self.constant)
        key=next(iter(self.terms))
        atom='S.Round32(length)' if key=='round' else key
        return atom+(f'+{self.constant}' if self.constant else '')


def generate(out):
    code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Collections.sol/Collections.json').read_text())['deployedBytecode'][2:])
    digest=hashlib.sha256(code).hexdigest()
    assert digest==json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Collections']['runtimeSha256']
    stack=[Expr('returnPc'),Expr('dst'),Expr('src')]
    states,required,pc,stage=[],{},20951,0
    while True:
        op=code[pc];width=op-95 if 96<=op<=127 else 0;nxt=pc+1+width
        immediate=int.from_bytes(code[pc+1:nxt],'big')
        required.update({p:code[p] for p in range(pc,nxt)})
        states.append(dict(id=len(states),pc=pc,op=op,next=nxt,immediate=immediate,stack=[x.text for x in stack],stage=stage))
        assert len(states)<60
        if op==91:pass
        elif op==95 or 96<=op<=127:stack.append(Expr(constant=immediate))
        elif 128<=op<=143:stack.append(stack[-(op-127)])
        elif 144<=op<=159:
            k=op-143;stack[-1],stack[-1-k]=stack[-1-k],stack[-1]
        elif op==80:stack.pop()
        elif op==81:
            assert stack.pop().text=='src';stack.append(Expr('length'))
        elif op==1:stack.append(stack.pop().add(stack.pop()))
        elif op==25:
            assert stack.pop().text=='31';stack.append(Expr(constant=MOD-32))
        elif op==22:
            a,b=stack.pop(),stack.pop();assert (a.text,b.text)==('length+31',str(MOD-32));stack.append(Expr('round'))
        elif op==82:
            offset,value=stack.pop(),stack.pop()
            assert (offset.text,value.text,stage) in [('dst','length',0),('dst+32+length','0',2)],(pc,offset.text,value.text,stage)
            stage+=1
        elif op==94:
            dst,src,length=stack.pop(),stack.pop(),stack.pop()
            assert (dst.text,src.text,length.text,stage)==('dst+32','src+32','length',1)
            stage=2
        elif op==86:
            assert stack.pop().text=='returnPc' and stage==3
            assert [x.text for x in stack]==['H.End(dst,length)']
            break
        else:raise ValueError((pc,op,[x.text for x in stack]))
        pc=nxt
    params='mem: seq<Byte>,prefix: seq<Word>,src: Word,dst: Word,length: Word,payload: seq<Byte>,returnPc: Word,value: Word,data: seq<Byte>'
    args='mem,prefix,src,dst,length,payload,returnPc,value,data'
    capacity=1024-max(len(s['stack']) for s in states)
    matches=' &&\n    '.join(f'code[{p}] == {v}' for p,v in sorted(required.items()))
    literal=lambda s:f"Running({s['pc']},prefix+[{','.join(s['stack'])}],H.Stage(mem,src,dst,length,payload,{s['stage']}))"
    good='\n'.join('    '+('if' if s['id']==0 else 'else if')+f" id == {s['id']} then state == {literal(s)}" for s in states)+'\n    else false'
    text=f'''// SPDX-License-Identifier: MIT
// Generated complete physical shared bytes ABI copy; arbitrary fitting payload length.
include "Memory.dfy"
include "../callback-success/Scalar.dfy"
include "../../scans/Fetch.dfy"
module BytecodeApplyDynamicBytesCopyControl {{
  import opened BytecodeScanMachine
  import S = BytecodeScanMachine
  import M = BytecodeCopyMachine
  import E = BytecodeCopyExecution
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import H = BytecodeApplyDynamicBytesCopyMemory
  import CS = BytecodeApplyCallbackSuccessScalar
  opaque predicate Matches(code: seq<Byte>,returnPc: Word) {{ |code| == {len(code)} && returnPc < |code| && code[returnPc] == 0x5b && {matches} }}
  function Destinations(returnPc: Word): set<nat> {{ {{returnPc}} }}
  predicate Admitted({params}) {{ H.Fits(mem,src,dst,length,payload) && |prefix| <= {capacity} }}
  opaque predicate Good(id: nat,state: State,{params}) {{ Admitted({args}) && (
{good}) }}
'''
    for s in states:
        i=s['id'];op=s['op']
        final='Running(returnPc,prefix+[H.End(dst,length)],H.Stage(mem,src,dst,length,payload,3))'
        post=f'next == {final}' if i==len(states)-1 else f'Good({i+1},next,{args})'
        facts=''
        if op==25:facts+='    CS.Not31();\n'
        if op==22:facts+='    CS.Not31();H.Round(length);\n'
        fetch=f"    F.Push1(code,{s['pc']});\n" if op==96 else ''
        body='    M.Delegate(code,Destinations(returnPc),state,value,data);reveal S.Step();\n'
        if op==94:
            tail='['+','.join(s['stack'][:-3])+']'
            body=f'''    CS.Append(prefix,{tail},[length,src+32,dst+32]);
    M.MemoryStep(code,{s['pc']},prefix+{tail},H.Stage(mem,src,dst,length,payload,1),dst+32,src+32,length,value,data);
    E.WidenStep(code,{{}},Destinations(returnPc),state,value,data);
'''
        text+=f'''  lemma Advance{i}(code: seq<Byte>,state: State,{params})
    requires Matches(code,returnPc) && Admitted({args}) && Good({i},state,{args})
    ensures M.Step(code,Destinations(returnPc),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(returnPc),state,value,data); {post}
  {{ hide G.BitAnd();hide BitNot();hide H.Stage();reveal Matches();reveal Good();
    H.Sizes(mem,src,dst,length,payload,{s['stage']});H.Headers(mem,src,dst,length,payload,{s['stage']});
{facts}    assert state == {literal(s)};
{fetch}    assert Fetch(code,{s['pc']}) == Op({op},{s['next']},{s['immediate']});
{body}'''
        if op in [82,94]:text+='    reveal H.Stage();\n'
        text+='  }\n'
    joins=[]
    for start in range(0,len(states),20):
        end=min(start+20,len(states));block=start//20
        post=f'frame == {final}' if end==len(states) else f'Good({end},frame,{args})'
        calls='\n'.join(f'    Advance{i}(code,frame,{args});\n    var next{i} := M.Step(code,Destinations(returnPc),frame,value,data);\n    E.Extend(code,Destinations(returnPc),value,data,trace,next{i});trace := trace+[next{i}];frame := next{i};' for i in range(start,end))
        text+=f'''  ghost method Block{block}(code: seq<Byte>,initial: State,{params}) returns (frame: State,trace: seq<State>)
    requires Matches(code,returnPc) && Admitted({args}) && Good({start},initial,{args})
    ensures {post} && E.Trace(code,Destinations(returnPc),value,data,trace)
    ensures |trace| == {end-start+1} && trace[0] == initial && trace[|trace|-1] == frame
  {{ hide E.Trace();frame := initial;trace := [frame];
    assert E.Trace(code,Destinations(returnPc),value,data,trace) by {{ reveal E.Trace(); }}
{calls}
  }}
'''
        joins.append(f'    frame,part := Block{block}(code,frame,{args});\n    E.Join(code,Destinations(returnPc),value,data,trace,part);trace := trace+part[1..];')
    text+=f'''  ghost method Run(code: seq<Byte>,{params}) returns (frame: State,trace: seq<State>)
    requires Matches(code,returnPc) && Admitted({args})
    ensures frame == {final} && E.Trace(code,Destinations(returnPc),value,data,trace)
    ensures |trace| == {len(states)+1} && trace[0] == {literal(states[0])} && trace[|trace|-1] == frame
  {{ hide E.Trace();frame := {literal(states[0])};trace := [frame];reveal Good();
    var part: seq<State>;
    assert E.Trace(code,Destinations(returnPc),value,data,trace) by {{ reveal E.Trace(); }}
{chr(10).join(joins)}
  }}
}}
'''
    out.mkdir(parents=True,exist_ok=True)
    (out/'Control.generated.dfy').write_text(text)
    (out/'Control.mapping.json').write_text(json.dumps(dict(runtimeSha256=digest,states=states,requiredBytes=required,scope='Complete shared ABI bytes copy to supplied physical return jump. Full CallbackFailed composition and retention remain open.'),indent=2)+'\n')
    print(len(states),'actual generic ABI bytes-copy instructions')


if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();generate(a.output)
    subprocess.run([sys.executable,'-B',HERE.parent/'map-prefix/format-generated.py','--output',a.output,'--include-root',HERE],check=True)
