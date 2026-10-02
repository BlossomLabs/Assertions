#!/usr/bin/env python3
"""Exact ConstraintFailed orchestration around the separately proved blob encoder."""
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
    values = {'ret': 1423, 'assertion': 128, 'entry': 0, 'param': 0, 'index': 0, 'kind': 0,
              'actual': 7, 'reference': 288, 'free': 352, 'assertionLength': 0, 'referenceLength': 32}
    params = ', '.join(n + ': Word' for n in values) + ', prefix: seq<Word>, mem: seq<Byte>'
    args = ','.join(values) + ',prefix,mem'
    end_as, end_ref = 'free+260+S.Round32(assertionLength)', 'free+292+S.Round32(assertionLength)+S.Round32(referenceLength)'
    base = ['ret', 'assertion', 'entry', 'param', 'index', 'kind', 'actual', 'reference', 'free+4']
    for name, first, seed, stop in [('Start', 19793, base, 17270),
                                    ('Heads', 19811, base + ['0', end_as], 17270),
                                    ('End', 19866, base + ['0', end_as, end_ref], None)]:
        def expression(text):
            if text in values:
                return E(values[text], text)
            if text.isdigit():
                return E(int(text))
            return E({'free+4': 356, end_as: 612, end_ref: 676}[text], text)
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
                if a.constant and b.constant:
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
                a = stack.pop()
                assert name == 'End' and a.value == 64
                node['guide'] += [f'    assert S.Load(mem,{a.text}) == free;', '    assert S.Expand(mem,96) == mem;']
                stack.append(E(352, 'free'))
            elif op == 82:
                address, word = stack.pop(), stack.pop()
                position, item = {19797: ('free+4', '224'), 19817: ('free+36', 'entry'),
                                  19823: ('free+68', 'param'), 19829: ('free+100', 'index'),
                                  18784: ('free+132', 'kind'), 19848: ('free+164', 'actual'),
                                  19856: ('free+196', '256+S.Round32(assertionLength)')}[pc]
                node['guide'].append(f'    assert {address.text} == {position} && {word.text} == {item};')
                memory = f'S.Store({memory},{position},{item})'
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
                                  f'    assert G.Grow(mem,{end_ref}) == mem;']
                break
            else:
                raise ValueError((name, pc, op))
            pc = nxt
        final_stack = base + ['0', '19811', 'free+228', 'assertion'] if name == 'Start' else base + ['0', end_as, '19866', end_as, 'reference']
        if name != 'End':
            states[-1]['guide'].append(f'    assert [{",".join(x.text for x in stack)}] == [{",".join(final_stack)}];')
        guards_text = ' &&\n    '.join(f'code[{pc}] == {value}' for pc, value in sorted(guards.items()))
        good = '\n'.join('    ' + ('if' if n['id'] == 0 else 'else if') +
                         f' id == {n["id"]} then state == S.Running({n["pc"]},prefix+[{",".join(n["stack"])}],{n["memory"]})'
                         for n in states) + '\n    else false'
        image = 'S.Store(mem,free+4,224)' if name == 'Start' else memory
        expected = f'S.Reverted(mem[free..{end_ref}])' if name == 'End' else f'S.Running(17270,prefix+[{",".join(final_stack)}],Image(mem,free,entry,param,index,kind,actual,assertionLength))'
        extra = f' && {end_ref} <= |mem| && S.Load(mem,64) == free' if name == 'End' else ''
        text = f'''// SPDX-License-Identifier: MIT
// Exact ConstraintFailed serializer {name} segment; arbitrary ABI head words and lengths.
include "../../raw/Machine.dfy"
include "../../raw/Frame.dfy"
include "../../../scans/Fetch.dfy"
module AssertionsConstraintFailed{name} {{
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import M = AssertionsRawResolveMachine
  import C = BytecodeCopyMachine
  import A = AssertionsSignedMachine
  import Q = AssertionsRawResolveFrame
  import F = BytecodeScanFetch
  type Word = S.Word
  type Byte = S.Byte
  function Image(mem: seq<Byte>, free: Word, entry: Word, param: Word, index: Word,
                 kind: Word, actual: Word, assertionLength: Word): seq<Byte>
    requires (free as nat)+356+S.Round32(assertionLength) < G.Modulus()
  {{ {image} }}
  predicate Admitted({params}) {{
    |prefix| <= 950 && |mem|%32 == 0 && 96 <= |mem| < 0x10000000000000000 && ret == 1423 && kind <= 8 &&
    free >= 128 && (free as nat)+356+S.Round32(assertionLength)+S.Round32(referenceLength) < 0x10000000000000000{extra}
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
            fetch = f'    F.Push{n["op"] - 95}(code,{n["pc"]});\n' if n['op'] in [96, 97] else ''
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
