#!/usr/bin/env python3
"""Complete exact _navWord helper paths, arbitrary fitting buffers and offsets."""
import argparse
from dataclasses import dataclass
import hashlib
import json
import re
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
MOD = 1 << 256


@dataclass
class Value:
    number: int
    term: str

    def constant(self):
        return self.term.isdecimal()


def signed(value):
    return value if value < MOD // 2 else value - MOD


def generate(out):
    code = bytes.fromhex(json.loads((ROOT / 'artifacts/contracts/Assertions.sol/Assertions.json').read_text())['deployedBytecode'][2:])
    digest = hashlib.sha256(code).hexdigest()
    assert digest == json.loads((ROOT / 'formal/bytecode/dispatch/inventory.json').read_text())['Assertions']['runtimeSha256']
    instructions = {}
    pc = 0
    while pc < len(code):
        op = code[pc]
        width = op - 95 if 96 <= op <= 127 else 0
        instructions[pc] = (op, pc + 1 + width, int.from_bytes(code[pc+1:pc+1+width], 'big'))
        pc += 1 + width
    destinations = {p for p, (op, _, _) in instructions.items() if op == 0x5b}
    params = 'ptr: Word, length: Word, pos: Word, word: Word, free: Word, ret: Word, prefix: seq<Word>, mem: seq<Byte>'
    actuals = 'ptr,length,pos,word,free,ret,prefix,mem'
    cases = [('WordSuccess', 32, True), ('WordPast', 97, False), ('WordShort', 80, False)]
    for name, sample, valid in cases:
        stack = [Value(600, 'ret'), Value(128, 'ptr'), Value(sample, 'pos')]
        pc, memory, states, required, targets, stores = 8130, 'mem', [], {}, set(), []
        seen = set()
        while True:
            key = (pc, tuple(v.term for v in stack), memory)
            assert key not in seen, 'Unexpected repeated complete helper state'
            seen.add(key)
            op, nxt, immediate = instructions[pc]
            required.update({p: code[p] for p in range(pc, nxt)})
            node = {'pc': pc, 'op': op, 'next': nxt, 'immediate': immediate,
                    'stack': [x.term for x in stack], 'memory': memory}
            states.append(node)
            def push(number, term=None):
                stack.append(Value(number, str(number) if term is None else term))
            def pop():
                return stack.pop()
            if op == 0x5b:
                pass
            elif op == 0x5f or 96 <= op <= 127:
                push(immediate)
            elif 0x80 <= op <= 0x8f:
                stack.append(stack[-(op-0x7f)])
            elif 0x90 <= op <= 0x9f:
                k = op-0x8f
                stack[-1], stack[-1-k] = stack[-1-k], stack[-1]
            elif op == 0x50:
                pop()
            elif op in [1, 3]:
                a, b = pop(), pop()
                number = (a.number + b.number if op == 1 else a.number-b.number) % MOD
                term = str(number) if a.constant() and b.constant() else (
                    f'(({a.term} as nat)+({b.term} as nat))%G.Modulus()' if op == 1 else
                    f'(({a.term} as nat)+G.Modulus()-({b.term} as nat))%G.Modulus()')
                if op == 1:
                    for base, constant in [(a,b),(b,a)]:
                        match = re.fullmatch(r'free(?:\+(\d+))?',base.term)
                        if match and constant.constant():
                            offset = int(match.group(1) or 0)+constant.number
                            if offset <= 96: term = 'free' if offset == 0 else f'free+{offset}'
                push(number, term)
            elif op in [0x10, 0x11, 0x12]:
                a, b = pop(), pop()
                truth = {0x10: a.number < b.number, 0x11: a.number > b.number,
                         0x12: signed(a.number) < signed(b.number)}[op]
                condition = f'G.Signed({a.term}) < G.Signed({b.term})' if op == 0x12 else f'{a.term} {"<" if op == 0x10 else ">"} {b.term}'
                push(int(truth), f'(if {condition} then 1 else 0)')
            elif op == 0x15:
                a = pop()
                push(int(a.number == 0), f'(if {a.term} == 0 then 1 else 0)')
            elif op == 0x04:
                a, b = pop(), pop()
                assert b.constant() and b.number == 32
                push(a.number//32, f'({a.term} as nat)/32')
            elif op == 0x1b:
                a, b = pop(), pop()
                assert a.constant() and b.constant()
                push((b.number << a.number) % MOD)
            elif op == 0x51:
                a = pop()
                node['loadOffset'] = a.term
                if a.number == 64:
                    push(1024, 'free')
                elif a.number == 128 and memory == 'mem':
                    push(96, 'length')
                elif a.number == 128+32+sample and memory == 'mem':
                    push(7, 'word')
                else:
                    raise ValueError(('Unexpected memory load', name, pc, a))
            elif op == 0x52:
                offset, value = pop(), pop()
                before = memory
                memory = f'Memory{len(stores)+1}({actuals})'
                stores.append((memory, before, offset.term, value.term))
            elif op in [0x56, 0x57]:
                destination = pop()
                if op == 0x56 and destination.term == 'ret':
                    break
                assert destination.constant() and destination.number in destinations
                targets.add(destination.number)
                required[destination.number] = code[destination.number]
                take = op == 0x56 or pop().number != 0
                if take:
                    nxt = destination.number
            elif op == 0xfd:
                offset, length = pop(), pop()
                assert offset.term == 'free' and length.number == 68
                break
            else:
                raise ValueError((name, pc, hex(op)))
            pc = nxt
        guard = 'pos <= length && 32 <= length-pos && Load(mem,ptr+32+pos) == word' if valid else 'pos > length' if name == 'WordPast' else 'pos <= length && length-pos < 32'
        pre = ('|mem|%32 == 0 && 96 <= |mem| < G.Modulus() && Load(mem,64) == free && '
               '128 <= free && (free as nat)+96 < G.Modulus() && '
               '(ptr as nat)+32+(length as nat) <= |mem| && Load(mem,ptr) == length && '
               'ret < |code| && code[ret] == 0x5b && ValidReturn(ret) && |prefix| <= 980 && '+guard)
        terminal = 'Running(ret,prefix+[word],mem)' if valid else 'Reverted(G.Encode(3586884662,4)+G.Encode(pos/32,32)+G.Encode(length,32))'
        byte_facts = ' &&\n    '.join(f'code[{p}] == {v}' for p, v in sorted(required.items()))
        good = '\n'.join('    '+('if' if i == 0 else 'else if')+f' id == {i} then state == Running({n["pc"]},prefix+[{",".join(n["stack"])}],{n["memory"]})' for i, n in enumerate(states))+'\n    else false'
        destination_list = sorted(destinations)
        destination_chunks = [destination_list[j:j+32] for j in range(0,len(destination_list),32)]
        destination_definitions = '\n'.join(f'  function DestinationChunk{j}(): set<nat> {{ {{{",".join(map(str,chunk))}}} }}' for j,chunk in enumerate(destination_chunks))
        destination_union = '+'.join(f'DestinationChunk{j}()' for j in range(len(destination_chunks)))
        text = f'''// SPDX-License-Identifier: MIT
// Generated exact Assertions memory-word helper certificate; never edit directly.
include "Index.dfy"
include "Word.dfy"
include "../scans/Execution.dfy"
include "../scans/Push.dfy"
module AssertionsNavigation{name} {{
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import Q = AssertionsNavigationIndex
  import W = AssertionsNavigationWord
  import F = BytecodeScanFetch
  import P = BytecodeScanPush
  import E = BytecodeScanExecution
  import R = BytecodeScanRepresentation
  opaque predicate ValidReturn(ret: Word) {{ ret in Destinations(ret) }}
  predicate Admitted(code: seq<Byte>, {params}) {{ {pre} }}
  opaque predicate Matches(code: seq<Byte>) {{ |code| == {len(code)} &&
    {byte_facts}
  }}
{destination_definitions}
  opaque function Destinations(ret: Word): set<nat> {{ {destination_union} }}
'''
        for call, before, offset, value in stores:
            text += f'  function {call.split("(")[0]}({params}): seq<Byte> requires (free as nat)+96 < G.Modulus() {{ Store({before},{offset},{value}) }}\n'
        text += f'''  opaque predicate Good(id: nat, state: State, code: seq<Byte>, {params}) {{ Admitted(code,{actuals}) && (
{good}) }}
'''
        for i, node in enumerate(states):
            post = f'next == {terminal}' if i == len(states)-1 else f'Good({i+1},next,code,{actuals})'
            next_state = terminal if i == len(states)-1 else f'Running({states[i+1]["pc"]},prefix+[{",".join(states[i+1]["stack"])}],{states[i+1]["memory"]})'
            extras = ''
            if 96 <= node['op'] <= 127:
                width = node['op']-95
                if width <= 2:
                    extras += f'    F.Push{width}(code,{node["pc"]});\n'
                elif width == 4:
                    extras += f'    P.Push4(code,{node["pc"]});\n'
                else:
                    raise ValueError(('Unproved PUSH width', width))
            if node['op'] == 0x56 and i == len(states)-1:
                extras += '    reveal ValidReturn();\n    assert ret in Destinations(ret);\n'
            if node['op'] in {0x56,0x57} and i+1 < len(states) and states[i+1]['pc'] != node['next']:
                target = states[i+1]['pc']
                extras += f'    assert {target} in Destinations(ret) by {{ reveal Destinations(); }}\n    assert code[{target}] == 0x5b;\n'
            if node['op'] == 0x51:
                extras += f'    Q.ExpansionIdentity({node["memory"]},({node["loadOffset"]} as nat)+32);\n'
                if node['memory'] != 'mem':
                    for call, before, offset, value in stores:
                        if int(call.split('(')[0][6:]) <= int(node['memory'].split('(')[0][6:]):
                            extras += f'    R.StoredWord({before},{offset},{value});\n    R.StoredFrame({before},{offset},{value},64);\n'
            if node['op'] == 0x1b:
                extras += '    assert ShiftLeft(1793442331,225) == 96702219188740649122977945812953308556173801082689626505169824435738867924992 by { reveal ShiftLeft(); }\n'
            if node['op'] == 0xfd:
                extras += '    W.ErrorBytes(mem,free,pos/32,length);\n'
                extras += f'    assert {node["memory"]} == W.ErrorMemory(mem,free,pos/32,length);\n'
                extras += f'    Q.ExpansionIdentity({node["memory"]},free+68);\n'
            text += f'''  lemma Advance{i}(code: seq<Byte>, state: State, {params}, value: Word, data: seq<Byte>)
    requires Matches(code) && Good({i},state,code,{actuals})
    ensures state.Running? && |state.stack| <= 1000
    ensures Step(code,Destinations(ret),state,value,data) != Bad
    ensures var next := Step(code,Destinations(ret),state,value,data); {post}
  {{
    reveal Matches(); reveal Good(); reveal Step();
{extras}    assert state == Running({node['pc']},prefix+[{','.join(node['stack'])}],{node['memory']});
    assert Fetch(code,{node['pc']}) == Op({node['op']},{node['next']},{node['immediate']});
    assert Step(code,Destinations(ret),state,value,data) == {next_state};
  }}
'''
        branches = '\n'.join('    '+('if' if i == 0 else 'else if')+f' id == {i} {{ Advance{i}(code,state,{actuals},value,data); }}' for i in range(len(states)))
        text += f'''  lemma Advance(id: nat, code: seq<Byte>, state: State, {params}, value: Word, data: seq<Byte>)
    requires Matches(code) && id < {len(states)} && Good(id,state,code,{actuals})
    ensures state.Running? && Step(code,Destinations(ret),state,value,data) != Bad
    ensures id < {len(states)-1} ==> Good(id+1,Step(code,Destinations(ret),state,value,data),code,{actuals})
    ensures id == {len(states)-1} ==> Step(code,Destinations(ret),state,value,data) == {terminal}
  {{
    reveal Good();
{branches}
  }}
  ghost method Run(code: seq<Byte>, {params}, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(code,{actuals})
    ensures state == {terminal}
    ensures E.Trace(code,Destinations(ret),value,data,trace)
    ensures trace[0] == Running(8130,prefix+[ret,ptr,pos],mem) && trace[|trace|-1] == state
    ensures |trace| == {len(states)+1}
  {{
    reveal Good();
    state := Running(8130,prefix+[ret,ptr,pos],mem);
    trace := [state];
    var id: nat := 0;
    while id < {len(states)}
      invariant id <= {len(states)} && |trace| == id+1
      invariant E.Trace(code,Destinations(ret),value,data,trace)
      invariant trace[0] == Running(8130,prefix+[ret,ptr,pos],mem) && trace[|trace|-1] == state
      invariant id < {len(states)} ==> Good(id,state,code,{actuals})
      invariant id == {len(states)} ==> state == {terminal}
      decreases {len(states)}-id
    {{
      Advance(id,code,state,{actuals},value,data);
      var next := Step(code,Destinations(ret),state,value,data);
      E.Extend(code,Destinations(ret),value,data,trace,next);
      trace := trace+[next];
      state := next;
      id := id+1;
    }}
  }}
}}
'''
        out.mkdir(parents=True, exist_ok=True)
        if out.resolve() != HERE.resolve():
            text = text.replace('include "Index.dfy"', f'include "{HERE / "Index.dfy"}"')
            text = text.replace('include "Word.dfy"', f'include "{HERE / "Word.dfy"}"')
            for name_part in ['Execution.dfy', 'Push.dfy']:
                text = text.replace(f'include "../scans/{name_part}"', f'include "{HERE.parent / "scans" / name_part}"')
        (out / (name+'.generated.dfy')).write_text(text)
        (out / (name+'.mapping.json')).write_text(json.dumps({'runtimeSha256': digest,
            'entry': 8130, 'states': states, 'requiredBytes': required, 'destinations': sorted(targets),
            'scope': 'Complete _navWord path only. Navigation public entry and raw ABI/body composition remain open.'}, indent=2)+'\n')
        print(name, len(states), 'reached instruction states')


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--output', type=Path, default=HERE)
    args = parser.parse_args()
    generate(args.output)
