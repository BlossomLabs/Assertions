#!/usr/bin/env python3
"""Reached-opcode certificate for the empty in-memory OR array decoder."""
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


def signed(value):
    return value if value < MOD // 2 else value - MOD


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
    values = {'end': 384, 'start': 320, 'relative': 32, 'free': 384}
    params = ', '.join(name + ': Word' for name in values) + ', prefix: seq<Word>, mem: seq<Byte>'
    args = ','.join(values) + ',prefix,mem'
    stack = [E(7777), E(384, 'end'), E(320, 'start')]
    pc, memory = 19462, 'mem'
    states, guards, targets, seen = [], {}, set(), set()
    while True:
        key = (pc, tuple(x.text for x in stack), memory)
        assert key not in seen, ('Unexpected cycle', pc)
        seen.add(key)
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
        elif op == 25:
            a = stack.pop()
            assert a.constant and a.value == 31
            node['guide'].append('    H.Complement31();')
            stack.append(E(MOD - 32))
        elif op in [22, 23]:
            a, b = stack.pop(), stack.pop()
            if op == 22:
                assert a.constant and b.constant
                node['guide'] += ['    L.Mask(63);', '    HH.Commute(G.Modulus()-32,63);']
                stack.append(E(a.value & b.value))
            else:
                assert a.value == b.value == 0
                node['guide'] += [f'    assert {a.text} == 0 && {b.text} == 0;', '    H.BoolOr(0,0);']
                stack.append(E(a.value | b.value))
        elif op in [1, 3, 16, 17, 18, 19, 27]:
            a, b = stack.pop(), stack.pop()
            if op == 1:
                value, expr = (a.value + b.value) % MOD, f'(({a.text} as nat)+({b.text} as nat))%G.Modulus()'
            elif op == 3:
                value, expr = (a.value - b.value) % MOD, f'(({a.text} as nat)+G.Modulus()-({b.text} as nat))%G.Modulus()'
            elif op in [16, 17, 18, 19]:
                av, bv = (signed(a.value), signed(b.value)) if op in [18, 19] else (a.value, b.value)
                relation = '<' if op in [16, 18] else '>'
                value = int(av < bv) if relation == '<' else int(av > bv)
                left, right = (f'G.Signed({a.text})', f'G.Signed({b.text})') if op in [18, 19] else (a.text, b.text)
                expr = f'(if {left} {relation} {right} then 1 else 0)'
            else:
                value = (b.value << a.value) % MOD if a.value < 256 else 0
                expr = f'S.ShiftLeft({b.text},{a.text})'
                node['guide'].append('    D.DecoderLimit();' if b.value == 1 else '    Z.ZeroShift();')
            if a.constant and b.constant:
                stack.append(E(value))
            elif pc in [19501, 19564]:
                node['guide'].append(f'    assert {expr} == start+relative;')
                stack.append(E(value, 'start+relative'))
            elif pc in [18355, 19570]:
                node['guide'].append(f'    assert {expr} == free+32;')
                stack.append(E(value, 'free+32'))
            elif pc in [19566, 19587]:
                node['guide'].append(f'    assert {expr} == start+relative+32;')
                stack.append(E(value, 'start+relative+32'))
            else:
                stack.append(E(value, expr))
        elif op == 81:
            address = stack.pop()
            name, value = {19480: ('relative', 32), 19517: ('0', 0), 18345: ('free', 384)}[pc]
            node['guide'] += [f'    assert S.Load({memory},{address.text}) == {name};',
                              f'    assert S.Expand({memory},({address.text} as nat)+32) == {memory};']
            stack.append(E(value) if name == '0' else E(value, name))
        elif op == 82:
            address, value = stack.pop(), stack.pop()
            position, word = {18385: ('64', 'free+32'), 19559: ('free', '0')}[pc]
            node['guide'] += [f'    assert {address.text} == {position} && {value.text} == {word};',
                              f'    R.StoredWord({memory},{position},{word});']
            memory = f'S.Store({memory},{position},{word})'
        elif op in [86, 87]:
            target = stack.pop()
            take = op == 86 or stack.pop().value != 0
            assert target.constant and target.value in destinations
            targets.add(target.value)
            guards[target.value] = code[target.value]
            if op == 86 and target.value == 7777:
                assert [x.text for x in stack] == ['free']
                assert memory == 'S.Store(S.Store(mem,64,free+32),free,0)'
                break
            if take:
                nxt = target.value
        else:
            raise ValueError((pc, op))
        pc = nxt
    guards_text = ' &&\n    '.join(f'code[{pc}] == {value}' for pc, value in sorted(guards.items()))
    good = '\n'.join('    ' + ('if' if n['id'] == 0 else 'else if') +
                     f' id == {n["id"]} then state == S.Running({n["pc"]},prefix+[{",".join(n["stack"])}],{n["memory"]})'
                     for n in states) + '\n    else false'
    text = f'''// SPDX-License-Identifier: MIT
// Complete successful in-memory decoder of an empty OR alternative array.
include "../../raw/Machine.dfy"
include "../../raw/Frame.dfy"
include "../../raw/Scalar.dfy"
include "../DecoderScalar.dfy"
include "../And.dfy"
include "../../../scans/Fetch.dfy"
module AssertionsConstraintOrEmptyDecoder {{
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import M = AssertionsRawResolveMachine
  import C = BytecodeCopyMachine
  import A = AssertionsSignedMachine
  import Q = AssertionsRawResolveFrame
  import R = BytecodeScanRepresentation
  import F = BytecodeScanFetch
  import D = BytecodeScanDecoderScalar
  import H = AssertionsConstraintDecoderScalar
  import L = AssertionsPrimitiveLowMask
  import HH = AssertionsConstraintAnd
  import Z = AssertionsRawResolveScalar
  type Word = S.Word
  type Byte = S.Byte
  function Construct(mem: seq<Byte>, free: Word): seq<Byte>
    requires (free as nat)+32 < G.Modulus()
  {{ S.Store(S.Store(mem,64,free+32),free,0) }}
  predicate Admitted({params}) {{
    |prefix| <= 990 && |mem|%32 == 0 && 96 <= |mem| <= (free as nat)+32 &&
    free >= 128 && free%32 == 0 && (free as nat)+64 < 0x10000000000000000 &&
    start >= 96 && (start as nat)+32 <= end <= |mem| && end <= free &&
    (start as nat)+relative+32 <= end && S.Load(mem,start) == relative &&
    S.Load(mem,start+relative) == 0 && S.Load(mem,64) == free
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
        post = f'next == S.Running(7777,prefix+[free],Construct(mem,free))' if i == len(states) - 1 else f'Good({i + 1},next,{args})'
        fetch = f'    F.Push{n["op"] - 95}(code,{n["pc"]});\n' if n['op'] in [96, 97] else ''
        guide = '\n'.join(n['guide'])
        attrs = ' {:isolate_assertions}' if n['op'] in [22, 23, 81, 82] else ''
        text += f'''  lemma{attrs} Advance{i}(code: seq<Byte>, state: S.State, {params}, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted({args}) && Good({i},state,{args})
    ensures M.Step(code,Destinations(),state,value,data) != S.Bad
    ensures Q.Local(code,state) && Q.Local(code,M.Step(code,Destinations(),state,value,data))
    ensures var next := M.Step(code,Destinations(),state,value,data); {post}
  {{
    hide G.BitAnd();
    reveal Matches(); reveal Good(); reveal M.Step(); reveal C.Step(); reveal A.Step(); reveal S.Step();
{fetch}    assert S.Fetch(code,{n['pc']}) == S.Op({n['op']},{n['next']},{n['immediate']});
{guide}
  }}
'''
    calls = '\n'.join(f'    {"if" if i == 0 else "else if"} id == {i} {{ Advance{i}(code,state,{args},value,data); }}' for i in range(len(states)))
    text += f'''  lemma Advance(id: nat, code: seq<Byte>, state: S.State, {params}, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted({args}) && Good(id,state,{args}) && id < {len(states)}
    ensures M.Step(code,Destinations(),state,value,data) != S.Bad
    ensures Q.Local(code,state) && Q.Local(code,M.Step(code,Destinations(),state,value,data))
    ensures var next := M.Step(code,Destinations(),state,value,data);
      if id == {len(states) - 1} then next == S.Running(7777,prefix+[free],Construct(mem,free)) else Good(id+1,next,{args})
  {{
{calls}
  }}
  ghost method Run(code: seq<Byte>, {params}, value: Word, data: seq<Byte>) returns (states: seq<S.State>)
    requires Matches(code) && Admitted({args})
    ensures M.Trace(code,Destinations(),value,data,states)
    ensures forall i {{:trigger states[i]}} :: 0 <= i < |states| ==> Q.Local(code,states[i])
    ensures states[0] == S.Running(19462,prefix+[7777,end,start],mem)
    ensures states[|states|-1] == S.Running(7777,prefix+[free],Construct(mem,free))
  {{
    var state := S.Running(19462,prefix+[7777,end,start],mem);
    reveal Good(); reveal Matches();
    states := [state];
    var id: nat := 0;
    while id < {len(states)}
      invariant id <= {len(states)} && |states| == id+1
      invariant M.Trace(code,Destinations(),value,data,states)
      invariant forall i {{:trigger states[i]}} :: 0 <= i < |states| ==> Q.Local(code,states[i])
      invariant states[0] == S.Running(19462,prefix+[7777,end,start],mem) && states[|states|-1] == state
      invariant id < {len(states)} ==> Good(id,state,{args})
      invariant id == {len(states)} ==> state == S.Running(7777,prefix+[free],Construct(mem,free))
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
    (out / 'EmptyDecoder.generated.dfy').write_text(text)
    (out / 'EmptyDecoder.mapping.json').write_text(json.dumps({'runtimeSha256': hashlib.sha256(code).hexdigest(),
          'states': states, 'requiredBytes': guards, 'scope': 'Exact successful in-memory decoder of an empty OR alternative array, arbitrary offset and frame.'}, indent=2) + '\n')
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
