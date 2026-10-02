#!/usr/bin/env python3
"""Extract the reached canonical target check with a positive code-size observation."""
import argparse, hashlib, json, subprocess, sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
MOD = 1 << 256

class Expr:
    def __init__(self, value, text=None):
        self.value = value
        self.text = str(value) if text is None else text
    def constant(self):
        return self.text.isdecimal()

def generate(out):
    obj = json.loads((ROOT/'artifacts/contracts/Collections.sol/Collections.json').read_text())
    code = bytes.fromhex(obj['deployedBytecode'][2:])
    digest = hashlib.sha256(code).hexdigest()
    pin = json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Collections']
    assert digest == pin['runtimeSha256']
    assert pin['methodIdentifiers']['mapWords(bytes,address,bytes,uint256[])'] == 'ed6dc3be'
    assert pin['methodIdentifiers']['filterWords(bytes,address,bytes,uint256[])'] == '7787eb48'
    instructions, pc = {}, 0
    while pc < len(code):
        op = code[pc]; width = op-95 if 96 <= op <= 127 else 0
        instructions[pc] = op, pc+1+width, int.from_bytes(code[pc+1:pc+1+width],'big')
        pc += 1+width
    destinations = {p for p,(op,_,_) in instructions.items() if op == 0x5b}
    pc, stack, consumed = 15859, [Expr(12334),Expr(18176,'target')], 0
    states, required, targets = [], {12334:code[12334]}, {12334}
    while pc != 12334:
        assert len(states) < 40
        op, next_pc, immediate = instructions[pc]
        required.update({p:code[p] for p in range(pc,next_pc)})
        states.append(dict(id=len(states),pc=pc,stack=[x.text for x in stack],consumed=consumed,op=op,next=next_pc,immediate=immediate))
        if op == 0x5b: pass
        elif op == 0x5f or 96 <= op <= 127: stack.append(Expr(immediate))
        elif 0x80 <= op <= 0x8f: stack.append(stack[-(op-127)])
        elif 0x90 <= op <= 0x9f:
            k=op-143;stack[-1],stack[-1-k]=stack[-1-k],stack[-1]
        elif op == 0x50: stack.pop()
        elif op == 0x1b:
            a,b=stack.pop(),stack.pop();assert a.constant() and b.constant()
            stack.append(Expr((b.value<<a.value)%MOD))
        elif op == 0x03:
            a,b=stack.pop(),stack.pop()
            if a.constant() and b.constant():stack.append(Expr((a.value-b.value)%MOD))
            else:
                assert a.value == 0 and b.text == 'codeSize'
                stack.append(Expr(MOD-b.value,'G.Modulus()-codeSize'))
        elif op == 0x16:
            a,b=stack.pop(),stack.pop();assert a.value == (1<<160)-1 and b.text == 'target'
            stack.append(Expr(b.value,'target'))
        elif op == 0x3b:
            assert stack.pop().text == 'target';stack.append(Expr(11,'codeSize'));consumed += 1
        elif op in (0x56,0x57):
            dest=stack.pop();assert dest.constant() and dest.value in destinations
            targets.add(dest.value);required[dest.value]=code[dest.value]
            if op == 0x56 or stack.pop().value:next_pc=dest.value
        else:raise ValueError((pc,op))
        pc=next_pc
    assert not stack and consumed == 1
    cap=max(len(s['stack']) for s in states)
    params='target: Word, codeSize: Word, prefix: seq<Word>, mem: seq<Byte>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>'
    args='target,codeSize,prefix,mem,returned,cursor,observations,self,value,data'
    admissible='Admitted('+args+')'
    literal=lambda n:f"X.Frame(Running({n['pc']},prefix+[{','.join(n['stack'])}],mem),returned,cursor+{n['consumed']})"
    final='X.Frame(Running(12334,prefix,mem),returned,cursor+1)'
    initial='X.Frame(Running(15859,prefix+[12334,target],mem),returned,cursor)'
    good='\n'.join('    '+('if' if n['id']==0 else 'else if')+f" id == {n['id']} then frame == {literal(n)}" for n in states)+'\n    else false'
    matches=' &&\n    '.join(f'code[{p}] == {v}' for p,v in sorted(required.items()))
    text=f'''// SPDX-License-Identifier: MIT
// Generated exact target admission with truthful EXTCODESIZE observation; arbitrary caller-local returndata preserved.
include "../../external-calls/Execution.dfy"
include "../address-kernel/Mask.dfy"
include "MaskOpcode.dfy"
include "Sequence.dfy"
module BytecodeApplyTargetCode {{
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import X = BytecodeExternalMachine
  import E = BytecodeExternalExecution
  import C = BytecodeCopyMachine
  import A = BytecodeApplyAddressMask
  import O = BytecodeApplyTargetMaskOpcode
  import Q = BytecodeApplyTargetSequence
  predicate Admitted({params}) {{ X.Context(self) && target < A.Bound() && 0 < codeSize && |prefix| <= {1024-cap} && cursor < |observations| && observations[cursor] == X.CodeSize(target,codeSize) }}
  opaque predicate Matches(code: seq<Byte>) {{ |code| == {len(code)} &&
    {matches}
  }}
  function Destinations(): set<nat> {{ {{{','.join(map(str,sorted(targets)))}}} }}
  opaque predicate Good(id: nat,frame: X.Frame,{params}) {{ {admissible} && (
{good}) }}
'''
    for n in states:
        i=n['id'];post=f'next == {final}' if i==len(states)-1 else f'Good({i+1},next,{args})'
        fetch=f"    F.Push{n['op']-95}(code,{n['pc']});\n" if n['op'] in (96,97) else ''
        facts=''
        if n['op'] == 0x3b:
            facts+='    Q.Append(prefix,12334,target,target);\n    Q.Append(prefix,12334,target,codeSize);\n    assert frame == X.Frame(Running(15870,(prefix+[12334,target])+[target],mem),returned,cursor);\n    assert X.Address(target) == target;\n    X.CodeSizeStep(code,15870,prefix+[12334,target],mem,self,target,codeSize,returned,cursor,observations,value,data);\n    assert X.Step(code,{},frame,self,value,data,observations) == X.Frame(Running(15871,prefix+[12334,target,codeSize],mem),returned,cursor+1);\n    E.WidenStep(code,{},Destinations(),frame,self,value,data,observations);\n'
        else:
            facts+='    X.Delegate(code,Destinations(),frame,self,value,data,observations);\n    C.Delegate(code,Destinations(),frame.state,value,data);\n'
            if n['op'] == 0x16:
                facts+='    assert frame.state == Running(15869,(prefix+[12334,target])+[target,0xffffffffffffffffffffffffffffffffffffffff],mem);\n    O.Step(code,Destinations(),prefix+[12334,target],mem,target,value,data);\n    assert Step(code,Destinations(),frame.state,value,data) == Running(15870,prefix+[12334,target,target],mem);\n'
            else:
                facts+='    reveal Step();\n'
                if n['op'] == 0x1b:facts+='    A.Limit();\n'
        text+=f'''  lemma Advance{i}(code: seq<Byte>,frame: X.Frame,{params})
    requires Matches(code) && Good({i},frame,{args})
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); {post}
  {{
    hide G.BitAnd();\n    reveal Matches(); reveal Good();
    assert frame == {literal(n)};
{fetch}    assert Fetch(code,{n['pc']}) == Op({n['op']},{n['next']},{n['immediate']});
{facts}  }}
'''
    calls='\n'.join(f'    Advance{i}(code,frame,{args});\n    var next{i} := X.Step(code,Destinations(),frame,self,value,data,observations);\n    E.Extend(code,Destinations(),self,value,data,observations,trace,next{i});\n    trace := trace+[next{i}]; frame := next{i};' for i in range(len(states)))
    text+=f'''  ghost method Run(code: seq<Byte>,{params}) returns (frame: X.Frame,trace: seq<X.Frame>)
    requires Matches(code) && {admissible}
    ensures frame == {final}
    ensures E.Trace(code,Destinations(),self,value,data,observations,trace)
    ensures |trace| == {len(states)+1} && trace[0] == {initial} && trace[|trace|-1] == frame
  {{
    frame := {initial}; trace := [frame];
    reveal Good();
{calls}
  }}
}}
'''
    out.mkdir(parents=True,exist_ok=True)
    (out/'Code.generated.dfy').write_text(text)
    (out/'Code.mapping.json').write_text(json.dumps(dict(runtimeSha256=digest,states=states,requiredBytes=required,destinations=sorted(targets),scope='Canonical target helper admitted by one truthful positive code-size observation; source loop, errors and retained public evidence remain open.'),indent=2)+'\n')
    print(len(states),'actual target-admission states')

if __name__ == '__main__':
    p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();generate(a.output)
    subprocess.run([sys.executable,'-B',HERE.parent/'map-prefix/format-generated.py','--output',a.output,'--include-root',HERE],check=True)
