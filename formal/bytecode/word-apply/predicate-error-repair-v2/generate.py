#!/usr/bin/env python3
"""Extract complete noncanonical filter predicate rejection through exact REVERT."""
import argparse, hashlib, json, subprocess, sys
from pathlib import Path
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
MOD = 1 << 256


class Expr:
    def __init__(self,value,text=None):
        self.value = value
        self.text = str(value) if text is None else text

    def constant(self):
        return self.text.isdecimal()


def generate(out):
    code = bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Collections.sol/Collections.json').read_text())['deployedBytecode'][2:])
    digest = hashlib.sha256(code).hexdigest()
    pin = json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Collections']
    assert digest == pin['runtimeSha256'] and pin['methodIdentifiers']['filterWords(bytes,address,bytes,uint256[])'] == '7787eb48'
    ins, pc = {}, 0
    while pc < len(code):
        op = code[pc]
        w = op-95 if 96 <= op <= 127 else 0
        ins[pc] = (op,pc+1+w,int.from_bytes(code[pc+1:pc+1+w],'big'))
        pc += 1+w
    dests = {p for p,(op,_,_) in ins.items() if op == 91}
    names = ['returnPc','sourceOffset','sourceLength','target','templateOffset','templateLength','arrayOffset','count','1','out','n','kept','ptr','index','word','0','result']
    values = [5526,68,96,18182,228,64,324,0,1,128,3,1,256,1,7,0,2]
    stack = [Expr(v,t) for v,t in zip(values,names)]
    pc, stage, states, required, targets = 12484, 0, [], {}, set()
    operation = 2005396296 << 224
    while True:
        op,nxt,imm = ins[pc]
        required.update({p:code[p] for p in range(pc,nxt)})
        states.append(dict(id=len(states),pc=pc,op=op,next=nxt,immediate=imm,stack=[x.text for x in stack],stage=stage))
        assert len(states) < 120
        if op == 91: pass
        elif op == 95 or 96 <= op <= 127: stack.append(Expr(imm))
        elif 128 <= op <= 143: stack.append(stack[-(op-127)])
        elif 144 <= op <= 159:
            k = op-143
            stack[-1],stack[-1-k] = stack[-1-k],stack[-1]
        elif op == 80: stack.pop()
        elif op == 17:
            a,b = stack.pop(),stack.pop()
            assert a.text == 'result' and b.text == '1'
            stack.append(Expr(1))
        elif op == 21:
            a = stack.pop()
            assert a.constant()
            stack.append(Expr(int(a.value == 0)))
        elif op == 53:
            assert stack.pop().text == '0'
            stack.append(Expr(operation+123,'DataWord(data,0)'))
        elif op == 27:
            a,b = stack.pop(),stack.pop()
            assert a.constant() and b.constant()
            stack.append(Expr((b.value << a.value)%MOD))
        elif op == 25:
            a = stack.pop()
            assert a.constant()
            stack.append(Expr(MOD-1-a.value))
        elif op == 22:
            a,b = stack.pop(),stack.pop()
            if a.constant() and b.text in ['DataWord(data,0)','SC.Operation()']:
                assert a.value == MOD-(1 << 224)
                stack.append(Expr(operation,'SC.Operation()'))
            else:
                assert a.constant() and a.value == (1 << 160)-1 and b.text == 'target'
                stack.append(Expr(b.value,'target'))
        elif op in (1,3):
            a,b = stack.pop(),stack.pop()
            v = (a.value+b.value if op == 1 else a.value-b.value)%MOD
            if a.constant() and b.constant(): t = str(v)
            elif op == 1:
                if a.constant() and b.text.startswith('free'):
                    delta = int(b.text[5:]) if b.text.startswith('free+') else 0
                    t = 'free+'+str(delta+a.value)
                elif b.constant() and a.text.startswith('free'):
                    delta = int(a.text[5:]) if a.text.startswith('free+') else 0
                    t = 'free+'+str(delta+b.value)
                else: raise ValueError((pc,a.text,b.text))
            else:
                assert (a.text,b.text) == ('free+132','free')
                t = '132'
            stack.append(Expr(v,t))
        elif op == 81:
            assert stack.pop().text == '64'
            stack.append(Expr(512,'free'))
        elif op == 82:
            off,datum = stack.pop(),stack.pop()
            expected = [('free',str(0x24448a11 << 224)),('free+4','SC.Operation()'),('free+36','index'),('free+68','0'),('free+100','target')]
            assert (off.text,datum.text) == expected[stage],(pc,stage,off.text,datum.text)
            stage += 1
        elif op in (86,87):
            target = stack.pop()
            assert target.constant() and target.value in dests
            targets.add(target.value)
            required[target.value] = code[target.value]
            if op == 86 or stack.pop().value: nxt = target.value
        elif op == 253:
            off,size = stack.pop(),stack.pop()
            assert stage == 5 and (off.text,size.text) == ('free','132')
            break
        else: raise ValueError((pc,hex(op)))
        pc = nxt
    fields = 'returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,free: Word,value: Word'
    params = 'data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,'+fields
    args = 'data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,free,value'
    heap = lambda k: f'H.Stage(mem,free,SC.Operation(),index,target,{k})'
    literal = lambda s: f"Running({s['pc']},prefix+[{','.join(s['stack'])}],{heap(s['stage'])})"
    final = 'Reverted(H.Packet(SC.Operation(),index,target))'
    cap = max(len(s['stack']) for s in states)
    good = '\n'.join('    '+('if' if s['id'] == 0 else 'else if')+f" id == {s['id']} then state == {literal(s)}" for s in states)+'\n    else false'
    matches = ' &&\n    '.join(f'code[{p}] == {v}' for p,v in sorted(required.items()))
    text = f'''// SPDX-License-Identifier: MIT
// Generated complete actual noncanonical filter predicate branch through exact132-byte REVERT.
include "../callback-result-error/Scalar.dfy"
include "../../scans/Execution.dfy"
include "../../scans/Push.dfy"
module BytecodeApplyPredicateError {{
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import P = BytecodeScanPush
  import E = BytecodeScanExecution
  import H = BytecodeApplyWrongCallbackMemory
  import SC = BytecodeApplyWrongCallbackScalar
  import A = BytecodeApplyAddressMask
  opaque predicate Admitted({params}) {{ H.Fits(mem,free) && result > 1 && target < A.Bound() && ShiftRight(DataWord(data,0),224) == 2005396296 && |prefix| <= {1024-cap} }}
  lemma Admission({params})
    requires Admitted({args})
    ensures H.Fits(mem,free) && free+160 < 0x10000000000000000000000000000000000000000000000000000000000000000
    ensures result > 1 && target < A.Bound() && ShiftRight(DataWord(data,0),224) == 2005396296 && |prefix| <= {1024-cap}
  {{ hide DataWord(); hide ShiftRight(); reveal Admitted(); }}
  opaque predicate Matches(code: seq<Byte>) {{ |code| == {len(code)} && {matches} }}
  function Destinations(): set<nat> {{ {{{','.join(map(str,sorted(targets)))}}} }}
  opaque predicate Good(id: nat,state: State,{params}) {{ Admitted({args}) && H.Fits(mem,free) && free+160 < 0x10000000000000000000000000000000000000000000000000000000000000000 && (
{good}) }}
'''
    text += f'''  lemma StageNext({params},k: nat)
    requires H.Fits(mem,free) && k < 5
    ensures H.Stage(mem,free,SC.Operation(),index,target,k+1) == Store(H.Stage(mem,free,SC.Operation(),index,target,k),if k == 0 then free else free+4+32*(k-1),if k == 0 then H.Header() else if k == 1 then SC.Operation() else if k == 2 then index else if k == 3 then 0 else target)
  {{ reveal H.Stage(); }}
'''
    for s in states:
        i = s['id']
        post = f'next == {final}' if i == len(states)-1 else f'Good({i+1},next,{args})'
        fetch = f"    F.Push{s['op']-95}(code,{s['pc']});\n" if s['op'] in (96,97) else f"    P.Push4(code,{s['pc']});\n" if s['op'] == 99 else ''
        facts = f'    Admission({args});\n'
        if s['op'] in (27,25): facts += '    SC.Literals();\n'
        if s['op'] == 22: facts += '    SC.OperationMask(data); A.Canonical(target);\n'
        if s['op'] == 82: facts += f'    StageNext({args},{s["stage"]});\n'
        if s['op'] == 253:
            facts += '    H.Bytes(mem,free,SC.Operation(),index,target);\n    assert G.Grow('+heap(5)+',free+132) == '+heap(5)+';\n'
        text += f'''  lemma Advance{i}(code: seq<Byte>,state: State,{params})
    requires Matches(code) && Admitted({args}) && Good({i},state,{args})
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); {post}
  {{ hide G.BitAnd(); hide H.Stage(); hide DataWord(); hide ShiftRight(); reveal Matches(); reveal Good(); reveal Step();
    H.Layout(mem,free,SC.Operation(),index,target,{s['stage']});
{facts}    assert state == {literal(s)};
{fetch}    assert Fetch(code,{s['pc']}) == Op({s['op']},{s['next']},{s['immediate']});
  }}
'''
    joins = []
    for start in range(0,len(states),20):
        end = min(start+20,len(states))
        block = start//20
        post = f'state == {final}' if end == len(states) else f'Good({end},state,{args})'
        calls = '\n'.join(f'    Advance{i}(code,state,{args});\n    var next{i} := Step(code,Destinations(),state,value,data);\n    E.Extend(code,Destinations(),value,data,trace,next{i});trace := trace+[next{i}];state := next{i};' for i in range(start,end))
        text += f'''  ghost method Block{block}(code: seq<Byte>,initial: State,{params}) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted({args}) && Good({start},initial,{args})
    ensures {post} && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == {end-start+1} && trace[0] == initial && trace[|trace|-1] == state
  {{ hide E.Trace(); state := initial;trace := [state];
{calls}
  }}
'''
        joins.append(f'    state,part := Block{block}(code,state,{args});\n    E.Join(code,Destinations(),value,data,trace,part);trace := trace+part[1..];')
    text += f'''  ghost method Run(code: seq<Byte>,{params}) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted({args})
    ensures state == {final} && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == {len(states)+1} && trace[0] == {literal(states[0])} && trace[|trace|-1] == state
  {{ hide E.Trace(); Admission({args}); state := {literal(states[0])};trace := [state];reveal Good();var part: seq<State>;
'''+ '\n'.join(joins)+'\n  }\n}\n'
    out.mkdir(parents=True,exist_ok=True)
    (out/'Predicate.generated.dfy').write_text(text)
    (out/'Predicate.mapping.json').write_text(json.dumps(dict(runtimeSha256=digest,states=states,requiredBytes=required,destinations=sorted(targets),scope='Complete local noncanonical filter predicate rejection, actual operation/index/zero/target packet. Callback/raw loop composition and fresh retained public graph remain open.'),indent=2)+'\n')
    print(len(states),'actual noncanonical predicate instructions')


if __name__ == '__main__':
    p = argparse.ArgumentParser()
    p.add_argument('--output',type=Path,required=True)
    a = p.parse_args()
    generate(a.output)
    subprocess.run([sys.executable,'-B',HERE.parent/'map-prefix/format-generated.py','--output',a.output,'--include-root',HERE],check=True)
