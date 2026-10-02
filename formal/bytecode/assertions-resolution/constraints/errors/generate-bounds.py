#!/usr/bin/env python3
"""Exact validator word-count precheck through physical ReturnDataOutOfBounds."""
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
        self.value = value
        self.text = str(value) if text is None else text
        self.constant = text is None


def generate(out):
    code = bytes.fromhex(json.loads((ROOT / 'artifacts/contracts/Assertions.sol/Assertions.json').read_text())['deployedBytecode'][2:])
    instructions = {}
    pc = 0
    while pc < len(code):
        op = code[pc]
        width = op - 95 if 96 <= op <= 127 else 0
        instructions[pc] = (op, pc + 1 + width, int.from_bytes(code[pc + 1:pc + 1 + width], 'big'))
        pc += 1 + width
    destinations = {pc for pc, (op, _, _) in instructions.items() if op == 91}
    variables = {'ret': 3967, 'constraints': 260, 'count': 2, 'ptr': 160, 'assertion': 128,
                 'entry': 0, 'param': 0, 'length': 33, 'free': 256}
    params = ', '.join(name + ': Word' for name in variables) + ', prefix: seq<Word>, mem: seq<Byte>'
    args = ','.join(variables) + ',prefix,mem'
    stack = [E(variables[name], name) for name in ['ret', 'constraints', 'count', 'ptr', 'assertion', 'entry', 'param']]
    initial = ','.join(x.text for x in stack)
    pc, memory = 7580, 'mem'
    states, guards, targets, stores, visited = [], {}, set(), [], set()
    while True:
        assert pc not in visited, ('Unexpected cycle', pc)
        visited.add(pc)
        op, nxt, immediate = instructions[pc]
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
        elif op == 21:
            a = stack.pop()
            stack.append(E(int(a.value == 0)) if a.constant else E(int(a.value == 0), f'(if {a.text} == 0 then 1 else 0)'))
        elif op in [1, 3, 4, 16, 17, 27]:
            a, b = stack.pop(), stack.pop()
            if op == 1:
                value, text = (a.value + b.value) % MOD, f'(({a.text} as nat)+({b.text} as nat))%G.Modulus()'
            elif op == 3:
                value, text = (a.value - b.value) % MOD, f'(({a.text} as nat)+G.Modulus()-({b.text} as nat))%G.Modulus()'
            elif op == 4:
                value, text = a.value // b.value if b.value else 0, f'(if {b.text} == 0 then 0 else ({a.text} as nat)/({b.text} as nat))'
            elif op in [16, 17]:
                value = int(a.value < b.value) if op == 16 else int(a.value > b.value)
                text = f'(if {a.text} {"<" if op == 16 else ">"} {b.text} then 1 else 0)'
            else:
                value, text = (b.value << a.value) % MOD if a.value < 256 else 0, f'S.ShiftLeft({b.text},{a.text})'
                node['guide'].append('    H.Selectors();')
            stack.append(E(value) if a.constant and b.constant else E(value, text))
        elif op == 81:
            address = stack.pop()
            if address.value == 160:
                name, value = 'length', 33
            else:
                assert address.value == 64
                name, value = 'free', 256
            for before, position, word in stores:
                node['guide'].append(f'    R.StoredFrame({before},{position},{word},64);')
            node['guide'] += [f'    assert S.Load({memory},{address.text}) == {name};',
                              f'    assert S.Expand({memory},({address.text} as nat)+32) == {memory};']
            stack.append(E(value, name))
        elif op == 82:
            address, value = stack.pop(), stack.pop()
            offset = address.value - variables['free']
            assert offset in [0, 4, 36]
            canonical = 'free' if offset == 0 else 'free+' + str(offset)
            node['guide'] += [f'    assert {address.text} == {canonical};',
                              f'    R.StoredWord({memory},{canonical},{value.text});']
            stores.append((memory, canonical, value.text))
            memory = f'S.Store({memory},{canonical},{value.text})'
        elif op in [86, 87]:
            target = stack.pop()
            take = op == 86 or stack.pop().value != 0
            assert target.constant and target.value in destinations
            targets.add(target.value)
            guards[target.value] = code[target.value]
            if take:
                nxt = target.value
        elif op == 253:
            offset, size = stack.pop(), stack.pop()
            node['guide'] += [f'    assert {offset.text} == free && {size.text} == 68;',
                              f'    assert {memory} == Image(mem,free,length);',
                              '    H.TwoWordError(mem,free,0xd5cb8436,Header(),length/32,length);',
                              f'    assert G.Grow({memory},(free as nat)+68) == {memory};']
            break
        else:
            raise ValueError((pc, op))
        pc = nxt
    guards_text = ' &&\n    '.join(f'code[{pc}] == {value}' for pc, value in sorted(guards.items()))
    good = '\n'.join('    ' + ('if' if n['id'] == 0 else 'else if') +
                     f' id == {n["id"]} then state == S.Running({n["pc"]},prefix+[{",".join(n["stack"])}],{n["memory"]})'
                     for n in states) + '\n    else false'
    text = f'''// SPDX-License-Identifier: MIT
// Exact arbitrary word-count rejection before any constraint predicate is evaluated.
include "../../raw/Machine.dfy"
include "../../raw/Frame.dfy"
include "../../../assertions-primitives/Scalar.dfy"
include "../../Fetch.dfy"
module AssertionsConstraintWordBounds {{
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import M = AssertionsRawResolveMachine
  import C = BytecodeCopyMachine
  import A = AssertionsSignedMachine
  import Q = AssertionsRawResolveFrame
  import R = BytecodeScanRepresentation
  import F = BytecodeScanFetch
  import J = AssertionsConstraintFetch
  import H = AssertionsPrimitiveScalar
  type Word = S.Word
  type Byte = S.Byte
  function Header(): Word {{ 0xd5cb843600000000000000000000000000000000000000000000000000000000 }}
  function Error(length: Word): seq<Byte> {{ G.Encode(0xd5cb8436,4)+G.Encode(length/32,32)+G.Encode(length,32) }}
  function Image(mem: seq<Byte>, free: Word, length: Word): seq<Byte>
    requires (free as nat)+68 < G.Modulus()
  {{ S.Store(S.Store(S.Store(mem,free,Header()),free+4,length/32),free+36,length) }}
  predicate Admitted({params}) {{
    |prefix| <= 1000 && |mem|%32 == 0 && 96 <= |mem| <= (free as nat)+32 && free >= 128 &&
    (free as nat)+100 < 0x10000000000000000 && ptr >= 96 &&
    (ptr as nat)+32 <= |mem| && S.Load(mem,ptr) == length && S.Load(mem,64) == free &&
    count > length/32
  }}
  opaque predicate Matches(code: seq<Byte>) {{ |code| == {len(code)} &&
    {guards_text}
  }}
  function Destinations(): set<nat> {{ {{{','.join(map(str, sorted(targets)))}}} }}
  opaque predicate Good(id: nat, state: S.State, {params}) {{ Admitted({args}) && (
{good}) }}
'''
    for n in states:
        i = n['id']
        post = f'next == S.Reverted(Error(length))' if i == len(states) - 1 else f'Good({i + 1},next,{args})'
        fetch = f'    F.Push{n["op"] - 95}(code,{n["pc"]});\n' if n['op'] in [96, 97] else ''
        if n['op'] == 99:
            fetch += f'    J.Push4(code,{n["pc"]});\n'
        guide = '\n'.join(n['guide'])
        attrs = ' {:isolate_assertions}' if n['op'] in [82, 253] else ''
        next_local = '' if i == len(states)-1 else ' && Q.Local(code,M.Step(code,Destinations(),state,value,data))'
        text += f'''  lemma{attrs} Advance{i}(code: seq<Byte>, state: S.State, {params}, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted({args}) && Good({i},state,{args})
    ensures M.Step(code,Destinations(),state,value,data) != S.Bad
    ensures Q.Local(code,state){next_local}
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
      if id == {len(states) - 1} then next == S.Reverted(Error(length)) else Good(id+1,next,{args})
  {{
{calls}
  }}
  ghost method Run(code: seq<Byte>, {params}, value: Word, data: seq<Byte>) returns (states: seq<S.State>)
    requires Matches(code) && Admitted({args})
    ensures M.Trace(code,Destinations(),value,data,states)
    ensures forall i {{:trigger states[i]}} :: 0 <= i < |states|-1 ==> Q.Local(code,states[i])
    ensures states[0] == S.Running(7580,prefix+[{initial}],mem)
    ensures states[|states|-1] == S.Reverted(Error(length))
  {{
    var state := S.Running(7580,prefix+[{initial}],mem);
    reveal Good(); reveal Matches();
    states := [state];
    var id: nat := 0;
    while id < {len(states)}
      invariant id <= {len(states)} && |states| == id+1
      invariant M.Trace(code,Destinations(),value,data,states)
      invariant forall i {{:trigger states[i]}} :: 0 <= i < |states|-1 ==> Q.Local(code,states[i])
      invariant states[0] == S.Running(7580,prefix+[{initial}],mem) && states[|states|-1] == state
      invariant id < {len(states)} ==> Good(id,state,{args})
      invariant id == {len(states)} ==> state == S.Reverted(Error(length))
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
    (out / 'WordBounds.generated.dfy').write_text(text)
    (out / 'WordBounds.mapping.json').write_text(json.dumps({'runtimeSha256': hashlib.sha256(code).hexdigest(),
          'states': states, 'requiredBytes': guards, 'scope': 'Complete validator word-count precheck to independent exact physical ReturnDataOutOfBounds REVERT.'}, indent=2) + '\n')
    print(len(states), 'physical instructions')


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--dafny', type=Path)
    args = parser.parse_args()
    generate(args.output)
    if args.dafny:
        subprocess.run([sys.executable, '-B', ROOT / 'formal/bytecode/format-generated.py', '--output', args.output,
                        '--include-root', HERE], env=dict(os.environ, DAFNY=str(args.dafny.resolve())), check=True)
