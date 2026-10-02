#!/usr/bin/env python3
"""Exact compiled checked signed-multiply helper, parameterized caller prefix.

This generator is a certificate extractor; generated controls require native
verification. Both actual signed-power continuations are compiler-bound.
"""
import argparse, hashlib, json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
MOD = 1 << 256
CASES = {
    'Fit': (456, 1, '-Modulus()/2<=Signed(a)*Signed(b)<Modulus()/2'),
    'Overflow': (MOD//2, 2, '!(Signed(b)<0 && a==Modulus()/2) && !( -Modulus()/2<=Signed(a)*Signed(b)<Modulus()/2 )'),
    'Minimum': (MOD//2, MOD-1, 'Signed(b)<0 && a==Modulus()/2'),
}

def signed(n):
    return n if n < MOD//2 else n-MOD

def generate(out):
    artifact = json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text())
    code = bytes.fromhex(artifact['deployedBytecode'][2:])
    inv = json.loads((HERE.parent/'inventory.json').read_text())
    assert hashlib.sha256(code).hexdigest() == inv['runtimeSha256']
    ins = {}
    pc = 0
    while pc < len(code):
        op = code[pc]
        width = op-95 if 96 <= op <= 127 else 0
        ins[pc] = (op, pc+width+1, int.from_bytes(code[pc+1:pc+width+1], 'big'))
        pc += width+1
    assert ins[20145][0] == ins[3275][0] == ins[3301][0] == 0x5b
    out.mkdir(parents=True, exist_ok=True)
    for label, (left, right, guard) in CASES.items():
        pc = 20145
        stack, expr = [3275,left,right], ['returnPc','a','b']
        memory = 'Store([],64,128)'
        nodes, needed, destinations, seen = [], {3275:code[3275],3301:code[3301]}, {3275,3301}, set()
        def pop():
            return stack.pop(), expr.pop()
        def push(value, text=None):
            stack.append(value)
            expr.append(str(value) if text is None else text)
        while True:
            assert (pc,tuple(stack)) not in seen
            seen.add((pc,tuple(stack)))
            op,nxt,imm = ins[pc]
            assert nxt <= len(code)
            needed.update({i:code[i] for i in range(pc,nxt)})
            node = dict(id=len(nodes),pc=pc,opcode=op,next=nxt,immediate=imm,stack=expr.copy(),memory=memory)
            nodes.append(node)
            if op == 0x5f or 96 <= op <= 99:
                push(imm)
            elif 128 <= op <= 143:
                k=op-127
                assert k<=len(stack), 'Caller prefix must never be read'
                push(stack[-k],expr[-k])
            elif 144 <= op <= 159:
                k=op-143
                assert k<len(stack), 'Caller prefix must never be permuted'
                stack[-1],stack[-1-k]=stack[-1-k],stack[-1]
                expr[-1],expr[-1-k]=expr[-1-k],expr[-1]
            elif op == 0x50:
                pop()
            elif op == 0x15:
                value,text=pop()
                push(int(value==0),f'(if {text}==0 then 1 else 0)')
            elif op in [0x02,0x05,0x12,0x14,0x16,0x17,0x1b]:
                a,ae=pop();b,be=pop()
                values={0x02:lambda:(a*b)%MOD,0x05:lambda:0 if b==0 else ((-1 if (signed(a)<0)!=(signed(b)<0) else 1)*(abs(signed(a))//abs(signed(b))))%MOD,0x12:lambda:int(signed(a)<signed(b)),0x14:lambda:int(a==b),0x16:lambda:a&b,0x17:lambda:a|b,0x1b:lambda:0 if a>=256 else (b<<a)%MOD}
                texts={0x02:f'Product({ae},{be})',0x05:f'SignedQuotient({ae},{be})',0x12:f'(if Signed({ae})<Signed({be}) then 1 else 0)',0x14:f'(if {ae}=={be} then 1 else 0)',0x16:f'BitAnd({ae},{be})',0x17:f'BitOr({ae},{be})',0x1b:f'Shift({be},{ae})'}
                push(values[op](),texts[op])
            elif op == 0x52:
                at,ate=pop();value,ve=pop()
                assert at in [0,4]
                memory=f'Store({memory},{ate},{ve})'
            elif op == 0x5b:
                pass
            elif op in [0x56,0x57]:
                target,te=pop()
                take=op==0x56 or pop()[0]!=0
                assert ins[target][0]==0x5b
                if te=='returnPc':
                    assert op==0x56 and label=='Fit' and len(stack)==1
                    node['return']=True
                    break
                needed[target]=code[target];destinations.add(target);node['jump']=target
                if take:nxt=target
            elif op == 0xfd:
                at,ate=pop();count,ce=pop()
                assert (at,count)==(0,36) and label!='Fit'
                node['revert']=True
                break
            else:
                raise ValueError((pc,hex(op)))
            pc=nxt
        module='OperationsPowerSignedMultiply'+label
        params='code:seq<Byte>,destinations:set<nat>,state:State,prefix:seq<Word>,returnPc:Word,a:Word,b:Word,value:Word,size:Word,word:Word,headA:Word,headB:Word'
        passed='code,destinations,state,prefix,returnPc,a,b,value,size,word,headA,headB'
        good='\n'.join(('    if' if i==0 else '    else if')+f' id=={i} then state==Running({n["pc"]},prefix+[{",".join(n["stack"])}],{n["memory"]})' for i,n in enumerate(nodes))+'\n    else false'
        constraints=' &&\n    '.join(f'code[{i}]=={v}' for i,v in sorted(needed.items()))
        text=f'''// SPDX-License-Identifier: MIT
// Generated exact helper certificate. Never edit directly.
include "../power-opcode-kernel/Execution.dfy"
module {module} {{
  import opened OperationsSignedMultiplyMachine
  import E = OperationsPowerExecution
  predicate Admitted(prefix:seq<Word>,returnPc:Word,a:Word,b:Word) {{
    |prefix|<=1000 && returnPc in {{3275,3301}} && ({guard})
  }}
  opaque predicate Matches(code:seq<Byte>) {{ |code|=={len(code)} &&
    {constraints}
  }}
  function Destinations():set<nat> {{ {{{','.join(map(str,sorted(destinations)))}}} }}
  opaque predicate Good(id:nat,state:State,prefix:seq<Word>,returnPc:Word,a:Word,b:Word) {{
{good}
  }}
'''
        for n in nodes:
            i=n['id']
            post=f'Good({i+1},next,prefix,returnPc,a,b)'
            if n.get('return'):post='next==Running(returnPc,prefix+[SignedProduct(a,b)],Store([],64,128))'
            if n.get('revert'):post='next==Reverted(Panic(17))'
            guide=f'    reveal Matches(); reveal Good();\n    assert state==Running({n["pc"]},prefix+[{",".join(n["stack"])}],{n["memory"]});\n    assert Fetch(code,{n["pc"]})==Op({n["opcode"]},{n["next"]},{n["immediate"]});\n    E.Ordinary(code,destinations,state,value,size,word,headA,headB); reveal Step();\n'
            if n['opcode'] in [0x16,0x17,0x57]:guide+='    SignedProductCheck(b,a);\n'
            if n['opcode']==0x02:guide+='    ProductSymmetric(a,b); SignedProductProjection(a,b);\n'
            if n['opcode']==0x1b:guide+=('    MinimumShift();\n' if n['stack'][-2:]==['1','255'] else '    PanicShift();\n')
            if n.get('return'):guide+='    assert returnPc in Destinations() && returnPc<|code| && code[returnPc]==0x5b;\n    ProductSymmetric(a,b); SignedProductProjection(a,b);\n'
            if n.get('revert'):guide+='    PanicStores(Store([],64,128),17);\n'
            if n.get('jump'):guide+=f'    assert {n["jump"]} in Destinations() && code[{n["jump"]}]==0x5b;\n'
            text+=f'''  lemma Advance{i}({params})
    requires Matches(code) && Destinations()<=destinations && Admitted(prefix,returnPc,a,b) && Good({i},state,prefix,returnPc,a,b)
    ensures state.Running? && |state.stack|<=1024
    ensures var next:=E.Execute(code,destinations,state,value,size,word,headA,headB); {post}
  {{
{guide}  }}
'''
        outcome='Running(returnPc,prefix+[SignedProduct(a,b)],Store([],64,128))' if label=='Fit' else 'Reverted(Panic(17))'
        text+='''  lemma Extend(code:seq<Byte>,destinations:set<nat>,trace:seq<State>,state:State,value:Word,size:Word,word:Word,headA:Word,headB:Word)
    requires |trace|>0 && trace[|trace|-1]==state
    requires forall j:nat :: j+1<|trace| ==> trace[j+1]==E.Execute(code,destinations,trace[j],value,size,word,headA,headB)
    ensures forall j:nat :: j+1<|trace+[E.Execute(code,destinations,state,value,size,word,headA,headB)]| ==>
      (trace+[E.Execute(code,destinations,state,value,size,word,headA,headB)])[j+1]==E.Execute(code,destinations,(trace+[E.Execute(code,destinations,state,value,size,word,headA,headB)])[j],value,size,word,headA,headB)
  {
    forall j:nat | j+1<|trace+[E.Execute(code,destinations,state,value,size,word,headA,headB)]|
      ensures (trace+[E.Execute(code,destinations,state,value,size,word,headA,headB)])[j+1]==E.Execute(code,destinations,(trace+[E.Execute(code,destinations,state,value,size,word,headA,headB)])[j],value,size,word,headA,headB)
    { if j+1<|trace| {} else { assert j+1==|trace|; assert trace[j]==state; } }
  }
'''
        text+=f'''  ghost method Run({params.replace('state:State,','')}) returns(state:State,trace:seq<State>)
    requires Matches(code) && Destinations()<=destinations && Admitted(prefix,returnPc,a,b)
    ensures state=={outcome}
    ensures |trace|=={len(nodes)+1} && trace[0]==Running(20145,prefix+[returnPc,a,b],Store([],64,128)) && trace[|trace|-1]==state
    ensures forall j:nat :: j+1<|trace| ==> trace[j+1]==E.Execute(code,destinations,trace[j],value,size,word,headA,headB)
  {{
    reveal Good(); state:=Running(20145,prefix+[returnPc,a,b],Store([],64,128));trace:=[state];
    assert Good(0,state,prefix,returnPc,a,b);
'''
        for i in range(len(nodes)):
            text+=f'    Advance{i}({passed});Extend(code,destinations,trace,state,value,size,word,headA,headB);state:=E.Execute(code,destinations,state,value,size,word,headA,headB);trace:=trace+[state];assert |trace|=={i+2};assert trace[0]==Running(20145,prefix+[returnPc,a,b],Store([],64,128));assert trace[|trace|-1]==state;\n'
        text+='  }\n}\n'
        (out/(label+'.generated.dfy')).write_text(text)
        (out/(label+'.mapping.json')).write_text(json.dumps(dict(label=label,runtimeSha256=hashlib.sha256(code).hexdigest(),startPc=20145,continuations=[3275,3301],states=nodes,requiredBytes=needed,scope='Unverified helper certificate; exact reached caller frames and complete public paths remain open'),indent=2)+'\n')
        print(label,len(nodes),'actual instructions')

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();generate(a.output)
