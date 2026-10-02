#!/usr/bin/env python3
"""Exact false non-OR caller preparation PC8035 to serializer PC19793."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
MOD = 1 << 256


class E:
    def __init__(self, value, text=None):
        self.value, self.text = value, str(value) if text is None else text
        self.constant = text is None


def generate(out):
    code = bytes.fromhex(json.loads((ROOT / 'artifacts/contracts/Assertions.sol/Assertions.json').read_text())['deployedBytecode'][2:])
    ins, pc = {}, 0
    while pc < len(code):
        op = code[pc]
        width = op - 95 if 96 <= op <= 127 else 0
        ins[pc] = op, pc + 1 + width, int.from_bytes(code[pc + 1:pc + 1 + width], 'big')
        pc += 1 + width
    destinations = {pc for pc, (op, _, _) in ins.items() if op == 91}
    values = {'ret':3967,'constraints':260,'count':1,'ptr':160,'assertion':128,'entry':0,'param':0,
              'words':1,'index':0,'actual':7,'record':224,'kind':0,'reference':288,'free':352,
              'assertionLength':0,'referenceLength':32}
    params = ', '.join(n + ': Word' for n in values) + ', prefix: seq<Word>, mem: seq<Byte>'
    args = ','.join(values) + ',prefix,mem'
    base = ['ret','constraints','count','ptr','assertion','entry','param','count','words','index','actual','record']
    for name, first, seed, stop in [('Caller',8035,base+['0','0'],19793)]:
        def expression(text):
            if text in values:return E(values[text],text)
            return E(int(text))
        stack = [expression(t) for t in seed]
        pc, memory, states, guards, targets, seen = first, 'mem', [], {}, set(), set()
        while True:
            key = (pc, tuple(x.text for x in stack))
            assert key not in seen
            seen.add(key)
            op, nxt, immediate = ins[pc]
            guards.update({i: code[i] for i in range(pc, nxt)})
            node = {'id': len(states), 'pc': pc, 'op': op, 'next': nxt, 'immediate': immediate,
                    'stack': [x.text for x in stack], 'memory': memory, 'guide': []}
            states.append(node)
            if op == 91:
                pass
            elif op == 95 or 96 <= op <= 127:
                stack.append(E(immediate))
            elif 128 <= op <= 143:
                stack.append(stack[-(op - 127)])
            elif 144 <= op <= 159:
                k = op - 143
                stack[-1], stack[-1 - k] = stack[-1 - k], stack[-1]
            elif op == 80:
                stack.pop()
            elif op in [1, 3, 16]:
                a, b = stack.pop(), stack.pop()
                if op == 1:
                    value, text = (a.value + b.value) % MOD, f'(({a.text} as nat)+({b.text} as nat))%G.Modulus()'
                elif op == 3:
                    value, text = (a.value - b.value) % MOD, f'(({a.text} as nat)+G.Modulus()-({b.text} as nat))%G.Modulus()'
                else:
                    value, text = int(a.value < b.value), f'(if {a.text} < {b.text} then 1 else 0)'
                if pc == 8083:
                    node['guide'].append(f'    assert {text} == free+4;')
                    stack.append(E(value,'free+4'))
                elif a.constant and b.constant:
                    stack.append(E(value))
                elif pc == 19805:
                    node['guide'].append(f'    assert {text} == free+228;')
                    stack.append(E(value, 'free+228'))
                elif pc == 19851:
                    node['guide'].append(f'    assert {text} == 256+S.Round32(assertionLength);')
                    stack.append(E(value, '256+S.Round32(assertionLength)'))
                else:
                    stack.append(E(value, text))
            elif op == 81:
                address = stack.pop()
                item = {8045:'kind',8050:'reference',8053:'free'}[pc]
                node['guide'] += [f'    assert S.Load(mem,{address.text}) == {item};', f'    assert S.Expand(mem,({address.text} as nat)+32) == mem;']
                stack.append(E(values[item],item))
            elif op == 27:
                shift, word = stack.pop(),stack.pop()
                assert shift.constant and word.constant
                node['guide'].append('    V.Selector();')
                stack.append(E((word.value << shift.value)%MOD))
            elif op == 82:
                address, word = stack.pop(),stack.pop()
                assert pc==8063 and word.constant
                node['guide'].append(f'    assert {address.text} == free;')
                memory=f'S.Store(mem,free,{word.value})'
            elif op in [86, 87]:
                target = stack.pop()
                take = op == 86 or stack.pop().value != 0
                assert target.value in destinations
                assert target.constant or target.text == 'ret'
                targets.add(target.value)
                guards[target.value] = code[target.value]
                if take:
                    nxt = target.value
                if nxt == stop:
                    break
            elif op == 253:
                address, size = stack.pop(), stack.pop()
                assert name == 'End'
                node['guide'] += [f'    assert {address.text} == free;',
                                  f'    assert {size.text} == 292+S.Round32(assertionLength)+S.Round32(referenceLength);',
                                  f'    assert G.Grow(mem,free+4) == mem;']
                break
            else:
                raise ValueError((name, pc, op))
            pc = nxt
        final_stack = base+['0','1423','assertion','entry','param','index','kind','actual','reference','free+4']
        states[-1]['guide'].append(f'    assert [{",".join(x.text for x in stack)}] == [{",".join(final_stack)}];')
        guards_text = ' &&\n    '.join(f'code[{pc}] == {value}' for pc, value in sorted(guards.items()))
        good = '\n'.join('    ' + ('if' if n['id'] == 0 else 'else if') +
                         f' id == {n["id"]} then state == S.Running({n["pc"]},prefix+[{",".join(n["stack"])}],{n["memory"]})'
                         for n in states) + '\n    else false'
        image = memory
        expected = f'S.Running(19793,prefix+[{",".join(final_stack)}],Image(mem,free))'
        text = f'''// SPDX-License-Identifier: MIT
// Exact ConstraintFailed serializer {name} segment; arbitrary ABI head words and lengths.
include "../../raw/Machine.dfy"
include "../../raw/Frame.dfy"
include "../../../scans/Fetch.dfy"
include "../../Fetch.dfy"
include "Heap.dfy"
include "SelectorScalar.dfy"
module AssertionsConstraintFailed{name} {{
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import M = AssertionsRawResolveMachine
  import C = BytecodeCopyMachine
  import A = AssertionsSignedMachine
  import Q = AssertionsRawResolveFrame
  import F = BytecodeScanFetch
  import J = AssertionsConstraintFetch
  import T = AssertionsConstraintFailedHeap
  import V = AssertionsConstraintFailedSelectorScalar
  type Word = S.Word
  type Byte = S.Byte
  function Image(mem: seq<Byte>, free: Word): seq<Byte> {{ {image} }}
  predicate Admitted({params}) {{
    |prefix| <= 927 && kind <= 8 && record+64 <= |mem| && record+64 <= free &&
    S.Load(mem,record) == kind && S.Load(mem,record+32) == reference &&
    T.Heap(mem,free,assertion,assertionLength,reference,referenceLength)
  }}
  opaque predicate Matches(code: seq<Byte>) {{ |code| == {len(code)} &&
    {guards_text}
  }}
  function Destinations(): set<nat> {{ {{{','.join(map(str, sorted(targets)))}}} }}
  function Expected({params}): S.State requires Admitted({args}) {{ {expected} }}
  opaque predicate Good(id: nat, state: S.State, {params}) {{ Admitted({args}) && (
{good}) }}
'''
        for n in states:
            i = n['id']
            post = f'next == Expected({args})' if i == len(states) - 1 else f'Good({i + 1},next,{args})'
            fetch = f'    F.Push{n["op"] - 95}(code,{n["pc"]});\n' if n['op'] in [96, 97] else f'    J.Push4(code,{n["pc"]});\n' if n['op']==99 else ''
            guide = '\n'.join(n['guide'])
            attrs = ' {:isolate_assertions}' if n['op'] in [82, 253] else ''
            local = '' if n['op'] == 253 else ' && Q.Local(code,M.Step(code,Destinations(),state,value,data))'
            text += f'''  lemma{attrs} Advance{i}(code: seq<Byte>, state: S.State, {params}, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted({args}) && Good({i},state,{args})
    ensures M.Step(code,Destinations(),state,value,data) != S.Bad
    ensures Q.Local(code,state){local}
    ensures var next := M.Step(code,Destinations(),state,value,data); {post}
  {{
    reveal Matches(); reveal Good(); reveal M.Step(); reveal C.Step(); reveal A.Step(); reveal S.Step();
{fetch}    assert S.Fetch(code,{n['pc']}) == S.Op({n['op']},{n['next']},{n['immediate']});
{guide}
  }}
'''
        calls = '\n'.join(f'    {"if" if i == 0 else "else if"} id == {i} {{ Advance{i}(code,state,{args},value,data); }}' for i in range(len(states)))
        text += f'''  lemma Advance(id: nat, code: seq<Byte>, state: S.State, {params}, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted({args}) && Good(id,state,{args}) && id < {len(states)}
    ensures M.Step(code,Destinations(),state,value,data) != S.Bad
    ensures Q.Local(code,state)
    ensures id < {len(states)-1} ==> Q.Local(code,M.Step(code,Destinations(),state,value,data))
    ensures var next := M.Step(code,Destinations(),state,value,data);
      if id == {len(states) - 1} then next == Expected({args}) else Good(id+1,next,{args})
  {{
{calls}
  }}
  ghost method Run(code: seq<Byte>, {params}, value: Word, data: seq<Byte>) returns (states: seq<S.State>)
    requires Matches(code) && Admitted({args})
    ensures M.Trace(code,Destinations(),value,data,states)
    ensures forall i {{:trigger states[i]}} :: 0 <= i < |states|-1 ==> Q.Local(code,states[i])
    ensures states[0] == S.Running({first},prefix+[{','.join(seed)}],mem)
    ensures states[|states|-1] == Expected({args})
  {{
    var state := S.Running({first},prefix+[{','.join(seed)}],mem);
    reveal Good(); reveal Matches();
    states := [state]; var id: nat := 0;
    while id < {len(states)}
      invariant id <= {len(states)} && |states| == id+1
      invariant M.Trace(code,Destinations(),value,data,states)
      invariant forall i {{:trigger states[i]}} :: 0 <= i < |states|-1 ==> Q.Local(code,states[i])
      invariant states[0] == S.Running({first},prefix+[{','.join(seed)}],mem) && states[|states|-1] == state
      invariant id < {len(states)} ==> Good(id,state,{args})
      invariant id == {len(states)} ==> state == Expected({args})
      decreases {len(states)}-id
    {{
      Advance(id,code,state,{args},value,data);
      var next := M.Step(code,Destinations(),state,value,data);
      M.Extend(code,Destinations(),value,data,states,next);
      states := states+[next]; state := next; id := id+1;
    }}
  }}
}}
'''
        out.mkdir(parents=True, exist_ok=True)
        (out / (name + '.generated.dfy')).write_text(text)
        (out / (name + '.mapping.json')).write_text(json.dumps({'runtimeSha256': hashlib.sha256(code).hexdigest(),
              'states': states, 'requiredBytes': guards, 'scope': 'Exact physical ConstraintFailed ' + name + ' orchestration; blob helper and independent canonical ABI connection are separate.'}, indent=2) + '\n')
        print(name, len(states), 'physical instructions')


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--dafny', type=Path)
    args = parser.parse_args()
    generate(args.output)
    if args.dafny:
        subprocess.run([sys.executable, '-B', ROOT / 'formal/bytecode/format-generated.py', '--output', args.output,
                        '--include-root', HERE], env=dict(os.environ, DAFNY=str(args.dafny.resolve())), check=True)
