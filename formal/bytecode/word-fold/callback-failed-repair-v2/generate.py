#!/usr/bin/env python3
"""Extract three complete physical CallbackFailed serializer segments."""
import argparse,hashlib,json,subprocess,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[3]
MOD=1<<256

class Expr:
    def __init__(self,atom=None,constant=0,terms=None):
        self.terms=dict(terms or ({atom:1} if atom else {}));self.constant=constant
    def add(self,other,sign=1):
        terms=self.terms.copy()
        for k,v in other.terms.items():terms[k]=terms.get(k,0)+sign*v
        return Expr(constant=self.constant+sign*other.constant,terms={k:v for k,v in terms.items() if v})
    @property
    def text(self):
        if not self.terms:return str(self.constant%MOD)
        if self.terms=={'free':1,'roundedPayload':1} and self.constant==228:return 'H.ReasonDst(free,payload)'
        if self.terms=={'free':1,'roundedPayload':1,'roundedReason':1} and self.constant==260:return 'H.End(free,payload,reason)'
        if self.terms=={'roundedPayload':1} and self.constant==224:return 'H.ReasonOffset(payload)'
        assert all(v==1 for v in self.terms.values()),(self.terms,self.constant)
        names={'operation':'CL.Operation(domain)','dataWord':'DataWord(data,0)','roundedPayload':'S.Round32(|payload|)','roundedReason':'S.Round32(|reason|)'}
        parts=[names.get(k,k) for k in sorted(self.terms)]
        if self.constant:parts.append(str(self.constant))
        return '+'.join(parts)

def extract(code):
    stack=[Expr(constant=16553),Expr('target'),Expr('ptr'),Expr('index'),Expr(),Expr('gasBefore'),Expr(),Expr('receipt')]
    pc,stage=17017,0;parts=[[]];required=[{}];targets=[set()]
    while True:
        op=code[pc];width=op-95 if 96<=op<=127 else 0;nxt=pc+1+width;imm=int.from_bytes(code[pc+1:nxt],'big')
        required[-1].update({p:code[p] for p in range(pc,nxt)})
        parts[-1].append(dict(id=len(parts[-1]),pc=pc,op=op,next=nxt,immediate=imm,stack=[x.text for x in stack],stage=stage))
        assert sum(map(len,parts))<200
        if op==91:pass
        elif op==95 or 96<=op<=127:stack.append(Expr(constant=imm))
        elif 128<=op<=143:stack.append(stack[-(op-127)])
        elif 144<=op<=159:
            k=op-143;stack[-1],stack[-1-k]=stack[-1-k],stack[-1]
        elif op==80:stack.pop()
        elif op==53:
            assert stack.pop().text=='0';stack.append(Expr('dataWord'))
        elif op==81:
            assert stack.pop().text=='64';stack.append(Expr('free'))
        elif op==27:
            amount,value=stack.pop(),stack.pop();assert not amount.terms and not value.terms
            stack.append(Expr(constant=(value.constant<<amount.constant)%MOD))
        elif op==25:
            value=stack.pop();assert not value.terms;stack.append(Expr(constant=MOD-1-value.constant))
        elif op==22:
            a,b=stack.pop(),stack.pop()
            if a.text==str(MOD-(1<<224)) and b.text=='DataWord(data,0)':stack.append(Expr('operation'))
            elif b.text==str(MOD-(1<<224)) and a.text=='CL.Operation(domain)':stack.append(Expr('operation'))
            else:
                assert (a.text,b.text)==('target',str((1<<160)-1)),(pc,a.text,b.text)
                stack.append(Expr('target'))
        elif op in (1,3):
            a,b=stack.pop(),stack.pop();stack.append(a.add(b,1 if op==1 else -1))
        elif op==82:
            offset,value=stack.pop(),stack.pop()
            expected=[('free',str(0x117cf6f6<<224)),('free+4','CL.Operation(domain)'),('free+36','index'),('free+68','0'),('free+100','target'),('free+132','192')]
            if stage<6:assert (offset.text,value.text)==expected[stage],(pc,stage,offset.text,value.text)
            else:assert stage==7 and (offset.text,value.text)==('free+164','H.ReasonOffset(payload)'),(pc,stage,offset.text,value.text)
            stage+=1
        elif op==86:
            target=stack.pop();assert not target.terms and code[target.constant]==91;targets[-1].add(target.constant);required[-1][target.constant]=91;nxt=target.constant
            if nxt==20951:
                ret,dst,src=stack[-3:]
                assert not ret.terms
                if len(parts)==1:
                    assert stage==6 and ret.constant==24352 and (dst.text,src.text)==('free+196','ptr')
                    result=Expr('free',228,{'free':1,'roundedPayload':1});stage=7
                else:
                    assert len(parts)==2 and stage==8 and ret.constant==24370 and (dst.text,src.text)==('H.ReasonDst(free,payload)','receipt')
                    result=Expr(constant=260,terms={'free':1,'roundedPayload':1,'roundedReason':1});stage=9
                parts[-1][-1]['finalStack']=[x.text for x in stack]
                stack=stack[:-3]+[result];nxt=ret.constant;parts.append([]);required.append({});targets.append(set())
        elif op==253:
            offset,size=stack.pop(),stack.pop();assert stage==9 and offset.text=='free' and size.text=='S.Round32(|payload|)+S.Round32(|reason|)+260',(offset.text,size.text);break
        else:raise ValueError((pc,op))
        pc=nxt
    return parts,required,targets

def generate(out):
    code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Collections.sol/Collections.json').read_text())['deployedBytecode'][2:]);digest=hashlib.sha256(code).hexdigest()
    pin=json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Collections'];assert digest==pin['runtimeSha256'] and pin['methodIdentifiers']['foldRange(uint256,address,bytes,uint256,uint256[],bytes32,uint8)']=='f1d88dc8' and pin['methodIdentifiers']['foldBytes(bytes,address,bytes,uint256,uint256[],bytes32,uint8)']=='6d24e79c' and pin['methodIdentifiers']['foldWords(bytes,address,bytes,uint256,uint256[],bytes32,uint8)']=='6de60cb0'
    parts,requirements,targets=extract(code);names=['Before','Between','After'];out.mkdir(parents=True,exist_ok=True)
    params='data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,domain: nat,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word'
    args='data,mem,prefix,domain,target,ptr,index,gasBefore,receipt,free,payload,reason,value'
    heap=lambda k:f'M.Heap(mem,ptr,receipt,free,CL.Operation(domain),index,target,payload,reason,{k})'
    for name,states,required,dests in zip(names,parts,requirements,targets):
        cap=1024-max(len(s['stack']) for s in states)
        matches=' &&\n    '.join(f'code[{p}] == {v}' for p,v in sorted(required.items()))
        literal=lambda s:f"Running({s['pc']},prefix+[{','.join(s['stack'])}],{heap(s['stage'])})"
        final='Reverted(H.Packet(CL.Operation(domain),index,target,payload,reason))' if name=='After' else f"Running(20951,prefix+[{','.join(states[-1]['finalStack'])}],{heap(states[-1]['stage'])})"
        # Cache every distinct heap stage once in the predicate. This is a
        # definitional let substitution, not a changed state or admission domain.
        stages=sorted({s['stage'] for s in states})
        heap_bindings='\n'.join(f'    var heap{k} := {heap(k)};' for k in stages)
        good='\n'.join('    '+('if' if i==0 else 'else if')+f" id == {i} then state == {literal(s).replace(heap(s['stage']), 'heap'+str(s['stage']))}" for i,s in enumerate(states))+'\n    else false'
        text=f'''// SPDX-License-Identifier: MIT
// Generated complete physical CallbackFailed {name} segment.
include "Scalar.dfy"
include "../../scans/Execution.dfy"
include "../../scans/Push.dfy"
module BytecodeFoldCallbackFailed{name} {{
  import opened BytecodeScanMachine
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import P = BytecodeScanPush
  import E = BytecodeScanExecution
  import M = BytecodeApplyCallbackFailedControlMemory
  import H = BytecodeApplyCallbackFailedMemory
  import CL = BytecodeFoldCallbackLengthScalar
  import WC = BytecodeApplyWrongCallbackScalar
  import A = BytecodeApplyAddressMask
  import L = BytecodeFoldCallbackFailedControlScalar
  opaque predicate Matches(code: seq<Byte>) {{ |code| == {len(code)} && {matches} }}
  function Destinations(): set<nat> {{ {{{','.join(map(str,sorted(dests)))}}} }}
  opaque predicate Admitted({params})
    ensures Admitted({args}) ==> domain < 3 && free+|payload|+|reason|+512 < 0x400000000000000000 && H.Fits(mem,ptr,receipt,free,payload,reason) && target < A.Bound() && |prefix| <= {cap}
  {{ domain < 3 && free+|payload|+|reason|+512 < 0x400000000000000000 && H.Fits(mem,ptr,receipt,free,payload,reason) && target < A.Bound() && ShiftRight(DataWord(data,0),224) == CL.Selector(domain) && |prefix| <= {cap} }}
  lemma Admission({params})
    requires Admitted({args})
    ensures domain < 3 && free+|payload|+|reason|+512 < 0x400000000000000000 && H.Fits(mem,ptr,receipt,free,payload,reason) && target < A.Bound() && ShiftRight(DataWord(data,0),224) == CL.Selector(domain) && |prefix| <= {cap}
  {{ hide DataWord();hide ShiftRight();reveal Admitted(); }}
  lemma Admit({params})
    requires domain < 3 && free+|payload|+|reason|+512 < 0x400000000000000000 && H.Fits(mem,ptr,receipt,free,payload,reason) && target < A.Bound() && ShiftRight(DataWord(data,0),224) == CL.Selector(domain) && |prefix| <= {cap}
    ensures Admitted({args})
  {{ hide DataWord();hide ShiftRight();reveal Admitted(); }}
  opaque predicate Good(id: nat,state: State,{params}) {{ domain < 3 && free+|payload|+|reason|+512 < 0x400000000000000000 && Admitted({args}) && (
{heap_bindings}
{good}) }}
'''
        for i,s in enumerate(states):
            op=s['op'];post=f'next == {final}' if i==len(states)-1 else f'Good({i+1},next,{args})';facts=''
            if op==27:facts+='    WC.UnitLiteral();A.Limit();L.HeaderLiteral();\n'
            if op==25:facts+='    WC.NotLiteral();\n'
            if op==22:facts+='    L.OperationMask(domain,data);L.TargetMask(target);\n'
            if op==82:facts+=f"    M.NextStore(mem,ptr,receipt,free,CL.Operation(domain),index,target,payload,reason,{s['stage']});\n"
            if op==253:facts+=f'    M.HeapProjection(mem,ptr,receipt,free,CL.Operation(domain),index,target,payload,reason,9);\n    assert H.End(free,payload,reason) == free+S.Round32(|payload|)+S.Round32(|reason|)+260;\n    H.FinalBytes(mem,ptr,receipt,free,CL.Operation(domain),index,target,payload,reason);\n    assert G.Grow({heap(9)},H.End(free,payload,reason)) == {heap(9)};\n'
            fetch=f"    F.Push{op-95}(code,{s['pc']});\n" if op in [96,97] else f"    P.Push4(code,{s['pc']});\n" if op==99 else ''
            text+=f'''  lemma Advance{i}(code: seq<Byte>,state: State,{params})
    requires Matches(code) && Admitted({args}) && Good({i},state,{args})
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); {post}
  {{ hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();reveal Matches();reveal Good();reveal Step();
    Admission({args});
    M.Info(mem,ptr,receipt,free,CL.Operation(domain),index,target,payload,reason,{s['stage']});
{facts}    assert state == {literal(s)};
{fetch}    assert Fetch(code,{s['pc']}) == Op({op},{s['next']},{s['immediate']});
  }}
'''
        joins=[]
        for start in range(0,len(states),20):
            end=min(start+20,len(states));block=start//20;post=f'frame == {final}' if end==len(states) else f'Good({end},frame,{args})'
            calls='\n'.join(f'    Advance{i}(code,frame,{args});\n    var next{i} := Step(code,Destinations(),frame,value,data);\n    E.Extend(code,Destinations(),value,data,trace,next{i});trace := trace+[next{i}];frame := next{i};' for i in range(start,end))
            text+=f'''  ghost method Block{block}(code: seq<Byte>,initial: State,{params}) returns (frame: State,trace: seq<State>)
    requires Matches(code) && Admitted({args}) && Good({start},initial,{args})
    ensures {post} && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == {end-start+1} && trace[0] == initial && trace[|trace|-1] == frame
  {{ hide E.Trace();frame := initial;trace := [frame];
    assert E.Trace(code,Destinations(),value,data,trace) by {{ reveal E.Trace(); }}
{calls}
  }}
'''
            joins.append(f'    frame,part := Block{block}(code,frame,{args});\n    E.Join(code,Destinations(),value,data,trace,part);trace := trace+part[1..];')
        text+=f'''  lemma Initial({params})
    requires Admitted({args})
    ensures Good(0,{literal(states[0])},{args})
  {{ hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();hide DataWord();hide ShiftRight();
    Admission({args});
    M.Info(mem,ptr,receipt,free,CL.Operation(domain),index,target,payload,reason,{states[0]['stage']});
    reveal Good();
  }}
  ghost method Run(code: seq<Byte>,{params}) returns (frame: State,trace: seq<State>)
    requires Matches(code) && Admitted({args})
    ensures frame == {final} && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == {len(states)+1} && trace[0] == {literal(states[0])} && trace[|trace|-1] == frame
  {{ hide E.Trace();hide M.Heap();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide H.Packet();hide DataWord();hide ShiftRight();Admission({args});Initial({args});frame := {literal(states[0])};trace := [frame];var part: seq<State>;
    assert E.Trace(code,Destinations(),value,data,trace) by {{ reveal E.Trace(); }}
{chr(10).join(joins)}
  }}
}}
'''
        (out/(name+'.generated.dfy')).write_text(text)
        (out/(name+'.mapping.json')).write_text(json.dumps(dict(runtimeSha256=digest,states=states,requiredBytes=required,destinations=sorted(dests),prefixCapacity=cap,scope='Physical serializer segment; both shared helper copies and full caller/raw/retained composition remain separately required.'),indent=2)+'\n')
        print(name,len(states),'physical instructions, prefix capacity',cap)

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();generate(a.output)
    subprocess.run([sys.executable,'-B',HERE/'format-generated.py','--output',a.output,'--include-root',HERE],check=True)
