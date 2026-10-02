#!/usr/bin/env python3
"""Extract every instruction of the physical four-byte exhaustion return."""
import argparse, hashlib, json, subprocess, sys
from pathlib import Path
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]


def generate(out):
    code = bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Collections.sol/Collections.json').read_text())['deployedBytecode'][2:])
    digest = hashlib.sha256(code).hexdigest()
    pin = json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Collections']
    assert digest == pin['runtimeSha256']
    stack, states, required, pc, stage = [], [], {}, 16171, 0
    while True:
        op = code[pc]
        width = op-95 if 96 <= op <= 127 else 0
        nxt = pc+1+width
        imm = int.from_bytes(code[pc+1:nxt],'big')
        required.update({p:code[p] for p in range(pc,nxt)})
        states.append(dict(id=len(states),pc=pc,op=op,next=nxt,immediate=imm,stack=stack.copy(),stage=stage))
        assert len(states) < 30
        if 96 <= op <= 127: stack.append(str(imm))
        elif op == 81:
            assert stack.pop() == '64'
            stack.append('free')
        elif op == 27:
            assert (stack.pop(),stack.pop()) == ('225',str(0x69388307))
            stack.append('M.Header()')
        elif op == 82:
            assert (stack.pop(),stack.pop()) == ('free','M.Header()') and stage == 0
            stage = 1
        elif 128 <= op <= 143: stack.append(stack[-(op-127)])
        elif 144 <= op <= 159:
            k = op-143
            stack[-1],stack[-1-k] = stack[-1-k],stack[-1]
        elif op == 1:
            assert (stack.pop(),stack.pop()) == ('4','free')
            stack.append('free+4')
        elif op == 3:
            assert (stack.pop(),stack.pop()) == ('free+4','free')
            stack.append('4')
        elif op == 253:
            assert (stack.pop(),stack.pop()) == ('free','4') and stage == 1
            break
        else: raise ValueError((pc,op,stack))
        pc = nxt
    params = 'mem: seq<Byte>,prefix: seq<Word>,free: Word,value: Word,data: seq<Byte>'
    args = 'mem,prefix,free,value,data'
    cap = 1024-max(len(s['stack']) for s in states)
    heap = lambda s: 'mem' if s['stage'] == 0 else 'M.Complete(mem,free)'
    literal = lambda s: f"Running({s['pc']},prefix+[{','.join(s['stack'])}],{heap(s)})"
    good = '\n'.join('    '+('if' if s['id'] == 0 else 'else if')+f" id == {s['id']} then state == {literal(s)}" for s in states)+'\n    else false'
    matches = ' &&\n    '.join(f'code[{p}] == {v}' for p,v in sorted(required.items()))
    text = f'''// SPDX-License-Identifier: MIT
// Generated actual local four-byte SubcallOutOfGas return.
include "Memory.dfy"
include "../../scans/Execution.dfy"
include "../../scans/Push.dfy"
module BytecodeApplyCallbackOutOfGasReturn {{
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import P = BytecodeScanPush
  import E = BytecodeScanExecution
  import H = BytecodeApplyWrongCallbackMemory
  import M = BytecodeApplyCallbackOutOfGasReturnMemory
  opaque predicate Matches(code: seq<Byte>) {{ |code| == {len(code)} && {matches} }}
  opaque predicate Admitted({params}) {{ H.Fits(mem,free) && |prefix| <= {cap} }}
  lemma Admission({params})
    requires Admitted({args})
    ensures H.Fits(mem,free) && free+160 < 0x10000000000000000000000000000000000000000000000000000000000000000 && |prefix| <= {cap}
  {{ reveal Admitted(); }}
  opaque predicate Good(id: nat,state: State,{params}) {{ Admitted({args}) && H.Fits(mem,free) && free+160 < 0x10000000000000000000000000000000000000000000000000000000000000000 && (
{good}) }}
'''
    for s in states:
        i = s['id']
        post = 'next == Reverted(M.Packet())' if i == len(states)-1 else f'Good({i+1},next,{args})'
        fetch = f"    F.Push1(code,{s['pc']});\n" if s['op'] == 96 else f"    P.Push4(code,{s['pc']});\n" if s['op'] == 99 else ''
        facts = '    M.Literal();\n' if s['op'] == 27 else ''
        if s['op'] == 253: facts += '    M.Bytes(mem,free);\n    assert G.Grow(M.Complete(mem,free),free+4) == M.Complete(mem,free);\n'
        text += f'''  lemma Advance{i}(code: seq<Byte>,state: State,{params})
    requires Matches(code) && Admitted({args}) && Good({i},state,{args})
    ensures Step(code,{{}},state,value,data) != Bad
    ensures var next := Step(code,{{}},state,value,data); {post}
  {{ hide M.Complete(); reveal Matches(); reveal Good(); reveal Step();
    Admission({args}); M.Layout(mem,free);
{facts}    assert state == {literal(s)};
{fetch}    assert Fetch(code,{s['pc']}) == Op({s['op']},{s['next']},{s['immediate']});
'''
        if s['op'] == 82: text += '    reveal M.Complete();\n'
        text += '  }\n'
    calls = '\n'.join(f'    Advance{i}(code,state,{args});\n    var next{i} := Step(code,{{}},state,value,data);\n    E.Extend(code,{{}},value,data,trace,next{i});trace := trace+[next{i}];state := next{i};' for i in range(len(states)))
    text += f'''  ghost method Run(code: seq<Byte>,{params}) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted({args})
    ensures state == Reverted(M.Packet()) && E.Trace(code,{{}},value,data,trace)
    ensures |trace| == {len(states)+1} && trace[0] == {literal(states[0])} && trace[|trace|-1] == state
  {{ hide E.Trace(); Admission({args}); state := {literal(states[0])};trace := [state];reveal Good();
{calls}
  }}
}}
'''
    out.mkdir(parents=True,exist_ok=True)
    (out/'Control.generated.dfy').write_text(text)
    (out/'Control.mapping.json').write_text(json.dumps(dict(runtimeSha256=digest,states=states,requiredBytes=required,scope='Complete local exact exhaustion signal return. Guard and full raw failure composition remain open.'),indent=2)+'\n')
    print(len(states),'actual exhaustion return instructions')


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--output',type=Path,required=True)
    args = parser.parse_args()
    generate(args.output)
    subprocess.run([sys.executable,'-B',HERE.parent/'map-prefix/format-generated.py','--output',args.output,'--include-root',HERE],check=True)
