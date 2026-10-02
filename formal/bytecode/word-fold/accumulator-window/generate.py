#!/usr/bin/env python3
"""Extract every reached fold accumulator check, physical error and outer cleanup opcode."""
import argparse
import hashlib
import json
import subprocess
import sys
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
    artifact = json.loads((ROOT / 'artifacts/contracts/Collections.sol/Collections.json').read_text())
    code = bytes.fromhex(artifact['deployedBytecode'][2:])
    digest = hashlib.sha256(code).hexdigest()
    pin = json.loads((ROOT / 'formal/bytecode/dispatch/inventory.json').read_text())['Collections']
    assert digest == pin['runtimeSha256']
    for signature, selector in [
        ('foldRange(uint256,address,bytes,uint256,uint256[],bytes32,uint8)', 'f1d88dc8'),
        ('foldBytes(bytes,address,bytes,uint256,uint256[],bytes32,uint8)', '6d24e79c'),
        ('foldWords(bytes,address,bytes,uint256,uint256[],bytes32,uint8)', '6de60cb0'),
    ]:
        assert pin['methodIdentifiers'][signature] == selector
    instructions, pc = {}, 0
    while pc < len(code):
        op = code[pc]
        width = op - 95 if 96 <= op <= 127 else 0
        instructions[pc] = (op, pc + 1 + width, int.from_bytes(code[pc+1:pc+1+width], 'big'))
        pc += 1 + width
    destinations = {pc for pc, (op, _, _) in instructions.items() if op == 0x5b}
    fields = ['returnPc', 'templateOffset', 'templateLength', 'accOffset', 'arrayOffset', 'count']
    params = 'data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, accOffset: Word, arrayOffset: Word, count: Word, value: Word'
    args = 'data,mem,prefix,returnPc,templateOffset,templateLength,accOffset,arrayOffset,count,value'
    cases = [
        ('Gate', 16343, 16683, 64, 16, 'templateLength >= 32 && accOffset <= templateLength-32', False),
        ('Short', 16343, None, 0, 9, 'templateLength < 32', True),
        ('Invalid', 16343, None, 64, 33, 'templateLength >= 32 && accOffset > templateLength-32', True),
        ('Exit', 16419, 12029, 64, 16, 'true', False),
    ]
    for name, entry, stop, length, acc, admission, failure in cases:
        values = [12029, 196, length, acc, 260, 2]
        stack = [Expr(v, f) for v, f in zip(values, fields)]
        initial_stack = [x.text for x in stack]
        pc, memory, states, required, targets, seen = entry, 'mem', [], {}, set(), set()
        if stop is not None:
            targets.add(stop)
            required[stop] = code[stop]
        while not states or pc != stop:
            key = pc, tuple(x.text for x in stack)
            assert key not in seen and len(states) < 150, (name, key)
            seen.add(key)
            op, nxt, imm = instructions[pc]
            required.update({p: code[p] for p in range(pc, nxt)})
            states.append(dict(id=len(states), pc=pc, op=op, next=nxt, immediate=imm,
                               stack=[x.text for x in stack], memory=memory))
            if op == 0x5b:
                pass
            elif op == 0x5f or 96 <= op <= 127:
                stack.append(Expr(imm))
            elif 0x80 <= op <= 0x8f:
                stack.append(stack[-(op-127)])
            elif 0x90 <= op <= 0x9f:
                depth = op-143
                stack[-1], stack[-1-depth] = stack[-1-depth], stack[-1]
            elif op == 0x50:
                stack.pop()
            elif op in (1, 3):
                a, b = stack.pop(), stack.pop()
                value = (a.value+b.value if op == 1 else a.value-b.value) % MOD
                if a.constant() and b.constant():
                    text = str(value)
                elif op == 3 and a.text == 'templateLength' and b.value == 32:
                    text = 'templateLength-32'
                else:
                    raise ValueError((name, pc, a.text, b.text))
                stack.append(Expr(value, text))
            elif op in (0x10, 0x11):
                a, b = stack.pop(), stack.pop()
                stack.append(Expr(int(a.value < b.value if op == 0x10 else a.value > b.value)))
            elif op == 0x15:
                stack.append(Expr(int(stack.pop().value == 0)))
            elif op == 0x1b:
                a, b = stack.pop(), stack.pop()
                assert a.constant() and b.constant()
                stack.append(Expr((b.value << a.value) % MOD))
            elif op == 0x51:
                assert stack.pop().value == 64 and failure
                stack.append(Expr(128))
            elif op == 0x52:
                offset, datum = stack.pop(), stack.pop()
                assert offset.constant() and failure
                memory = f'Store({memory},{offset.text},{datum.text})'
            elif op in (0x56, 0x57):
                dest = stack.pop()
                assert dest.value in destinations and (dest.constant() or dest.text == 'returnPc')
                targets.add(dest.value)
                required[dest.value] = code[dest.value]
                if op == 0x56 or stack.pop().value:
                    nxt = dest.value
            elif op == 0xfd:
                offset, size = stack.pop(), stack.pop()
                assert failure and offset.value == 128 and size.value == 68
                break
            else:
                raise ValueError((name, pc, hex(op)))
            pc = nxt
        expected = fields + ['16419', 'templateOffset', 'templateLength', 'arrayOffset', 'count'] if name == 'Gate' else []
        if not failure:
            assert [x.text for x in stack] == expected, (name, [x.text for x in stack])
        cap = max(len(s['stack']) for s in states)
        admission += f' && returnPc == 12029 && |prefix| <= {1024-cap}'
        if failure:
            admission += ' && mem == Store([],64,128)'
        literal = lambda s: f"Running({s['pc']},prefix+[{','.join(s['stack'])}],{s['memory']})"
        initial = f"Running({entry},prefix+[{','.join(initial_stack)}],mem)"
        terminal = 'Reverted(G.Encode(0x1a0d83de,4)+G.Encode(accOffset,32)+G.Encode(templateLength,32))' if failure else f"Running({stop},prefix+[{','.join(expected)}],mem)"
        matches = ' &&\n    '.join(f'code[{p}] == {v}' for p, v in sorted(required.items()))
        good = '\n'.join('    '+('if' if s['id'] == 0 else 'else if')+f" id == {s['id']} then state == {literal(s)}" for s in states)+'\n    else false'
        text = f'''// SPDX-License-Identifier: MIT
// Generated fold accumulator-window control, including checked subtraction and physical error serialization.
include "../element-windows/Inputs.dfy"
include "../../scans/Push.dfy"
include "../../word-apply/window-errors/Memory.dfy"
include "../../word-apply/window-errors/Scalar.dfy"
module BytecodeFoldAccumulatorWindow{name} {{
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import P = BytecodeScanPush
  import H = BytecodeApplyWindowErrorMemory
  import SC = BytecodeApplyWindowErrorScalar
  import E = BytecodeScanExecution
  predicate Admitted({params}) {{ {admission} }}
  opaque predicate Matches(code: seq<Byte>) {{ |code| == {len(code)} &&
    {matches}
  }}
  function Destinations(): set<nat> {{ {{{','.join(map(str, sorted(targets)))}}} }}
  opaque predicate Good(id: nat,state: State,{params}) {{ Admitted({args}) && (
{good}) }}
'''
        for s in states:
            i = s['id']
            post = f'next == {terminal}' if i == len(states)-1 else f'Good({i+1},next,{args})'
            facts = f"    F.Push{s['op']-95}(code,{s['pc']});\n" if s['op'] in (96, 97) else f"    P.Push4(code,{s['pc']});\n" if s['op'] == 99 else ''
            if failure:
                facts += '    H.Layout(accOffset,templateLength);\n'
            if s['op'] == 0x1b:
                facts += '    SC.Selector();\n'
            if s['op'] == 0xfd:
                facts += '    H.Error(mem,accOffset,templateLength);\n'
            memory_bound = ' && |state.memory| <= 224' if failure else ''
            text += f'''  lemma Advance{i}(code: seq<Byte>,state: State,{params})
    requires Matches(code) && Admitted({args}) && Good({i},state,{args})
    ensures state.Running? && |state.stack| <= 1024{memory_bound}
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); {post}
  {{
    reveal Matches(); reveal Good(); reveal Step();
{facts}    assert state == {literal(s)};
    assert Fetch(code,{s['pc']}) == Op({s['op']},{s['next']},{s['immediate']});
  }}
'''
        joins = []
        for start in range(0, len(states), 20):
            end, block = min(start+20, len(states)), start//20
            post = f'state == {terminal}' if end == len(states) else f'Good({end},state,{args})'
            calls = '\n'.join(f'    Advance{i}(code,state,{args});\n    var next{i} := Step(code,Destinations(),state,value,data);\n    E.Extend(code,Destinations(),value,data,trace,next{i}); trace := trace+[next{i}]; state := next{i};' for i in range(start, end))
            text += f'''  ghost method Block{block}(code: seq<Byte>,initial: State,{params}) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted({args}) && Good({start},initial,{args})
    ensures {post} && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == {end-start+1} && trace[0] == initial && trace[|trace|-1] == state
  {{ state := initial; trace := [state];
{calls}
  }}
'''
            joins.append(f'    state,part := Block{block}(code,state,{args});\n    E.Join(code,Destinations(),value,data,trace,part); trace := trace+part[1..];')
        text += f'''  ghost method Run(code: seq<Byte>,{params}) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted({args})
    ensures state == {terminal} && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == {len(states)+1} && trace[0] == {initial} && trace[|trace|-1] == state
  {{ state := {initial}; trace := [state]; reveal Good();
    var part: seq<State>;
''' + '\n'.join(joins) + '\n  }\n}\n'
        out.mkdir(parents=True, exist_ok=True)
        (out / (name+'.generated.dfy')).write_text(text)
        (out / (name+'.mapping.json')).write_text(json.dumps(dict(runtimeSha256=digest, states=states,
            requiredBytes=required, destinations=sorted(targets), entryPc=entry, terminal=terminal,
            scope='Exact fold accumulator check and outer cleanup only; selected imports assumed; full public retention open.'), indent=2)+'\n')
        print(name, len(states), 'actual accumulator-window instructions')


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    generate(args.output)
    subprocess.run([sys.executable, '-B', HERE / 'format-generated.py', '--output', args.output,
                    '--include-root', HERE], check=True)
