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
    values = {'end':736,'start':352,'body':384,'headend':480,'slot':416,'dstslot':768,'arrayptr':736,'position':64,'offset':448,'kind':0,'relative':64,'length':32,'source':576,'free':832}
    params = ', '.join(name + ': Word' for name in values) + ', prefix: seq<Word>, mem: seq<Byte>'
    args = ','.join(values) + ',prefix,mem'
    def evalword(expr):return eval(expr.replace('S.Round32(length)','((length+31)//32)*32'),{},values)
    stack = [E(values[n],n) if n!='0' else E(0) for n in ['end','start','0','body','headend','slot','dstslot','arrayptr']]
    pc, memory = 19590, 'mem'
    history = []
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
                node['guide'] += [f'    L.Mask({b.text});', f'    HH.Commute(G.Modulus()-32,{b.text});', f'    assert ({b.text})/32*32 == ({b.text})/32*32;']
                word='S.Round32(length)' if pc==18422 else 'S.Round32(length)+32'
                node['guide'] += [f'    assert ({b.text})/32*32 == {word};']
                stack.append(E(a.value & b.value,word))
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
                node['guide'].append('    D.DecoderLimit();')
            canonical = {19621:'offset',18309:'free+64',19652:'offset+32',19668:'offset+64',19693:'offset+relative',19694:'offset+relative+32',19702:'offset+relative+63',18418:'length+31',18425:'S.Round32(length)+32',18349:'S.Round32(length)+63',18355:'free+96+S.Round32(length)',19734:'offset+relative+32+length',19735:'source+length',19750:'source',19754:'free+96',19761:'free+96',19762:'free+96+length',19768:'free+32',19780:'dstslot+32',19786:'slot+32'}
            if a.constant and b.constant:
                stack.append(E(value))
            elif pc in canonical:
                word = canonical[pc]
                node['guide'].append(f'    assert {expr} == {word};')
                stack.append(E(value,word))
            else:
                stack.append(E(value,expr))
        elif op == 81:
            address = stack.pop()
            name, value = {19600:('position',64),18306:('free',832),19653:('kind',0),19669:('relative',64),19713:('length',32),18345:('free+64',896)}[pc]
            for before,pos,priorword in history:
                node['guide'].append(f'    R.StoredWord({before},{pos},{priorword});')
                if address.value+32 <= evalword(pos) or evalword(pos)+32 <= address.value:
                    node['guide'].append(f'    R.StoredFrame({before},{pos},{priorword},{address.text});')
            node['guide'] += [f'    assert S.Load({memory},{address.text}) == {name};', f'    assert S.Expand({memory},({address.text} as nat)+32) == {memory};']
            stack.append(E(value,name))
        elif op == 82:
            address, value = stack.pop(), stack.pop()
            positions={18339:('64','free+64'),19664:('free','kind'),18385:('64','free+96+S.Round32(length)'),19728:('free+64','length'),19763:('free+96+length','0'),19769:('free+32','free+64'),19774:('dstslot','free')}
            position, word=positions[pc]
            node['guide'] += [f'    assert {address.text} == {position} && {value.text} == {word};']
            for before,pos,priorword in history:
                if 'B.Memory' in before:
                    copied,dst,src,n=copy_parameters
                    node['guide'].append(f'    B.MemorySize({copied},{dst},{src},{n});')
                node['guide'].append(f'    R.StoredWord({before},{pos},{priorword});')
            if 'B.Memory' in memory:
                before,dst,src,n=copy_parameters
                node['guide'].append(f'    B.MemorySize({before},{dst},{src},{n});')
            node['guide'].append(f'    R.StoredWord({memory},{position},{word});')
            history.append((memory,position,word));memory=f'S.Store({memory},{position},{word})'
        elif op == 94:
            dst,src,n=stack.pop(),stack.pop(),stack.pop()
            node['guide'].append(f'    assert {dst.text} == free+96 && {src.text} == source && {n.text} == length;')
            copy_parameters=(memory,'free+96','source','length')
            memory=f'B.Memory({memory},free+96,source,length)'
        elif op in [86, 87]:
            target = stack.pop()
            take = op == 86 or stack.pop().value != 0
            assert target.constant and target.value in destinations
            targets.add(target.value)
            guards[target.value] = code[target.value]
            if take:
                nxt = target.value
        else:
            raise ValueError((pc, op))
        if nxt == 19590:
            guards[nxt] = code[nxt]
            assert [x.text for x in stack] == ['end','start','0','body','headend','slot+32','dstslot+32','arrayptr'],[x.text for x in stack]
            break
        pc = nxt
    guards_text = ' &&\n    '.join(f'code[{pc}] == {value}' for pc, value in sorted(guards.items()))
    good = '\n'.join('    ' + ('if' if n['id'] == 0 else 'else if') +
                     f' id == {n["id"]} then state == S.Running({n["pc"]},prefix+[{",".join(n["stack"])}],{n["memory"]})'
                     for n in states) + '\n    else false'
    text = f'''// SPDX-License-Identifier: MIT
// Complete successful in-memory decoder of an nonempty OR child-decoder iteration.
include "NonemptyMemory.dfy"
include "../../raw/Machine.dfy"
include "../../raw/Frame.dfy"
include "../../raw/Scalar.dfy"
include "../DecoderScalar.dfy"
include "../And.dfy"
include "../../../scans/Fetch.dfy"
module AssertionsConstraintOrNonemptyItem {{
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
  import W = AssertionsNavigationShift
  import N = AssertionsConstraintOrNonemptyMemory
  import B = BytecodeCopyMemory
  type Word = S.Word
  type Byte = S.Byte
  function Construct(mem: seq<Byte>, free: Word, kind: Word, source: Word, length: Word, slot: Word): seq<Byte>
    requires (free as nat)+128+S.Round32(length) < G.Modulus()
  {{ N.Construct(mem,free,kind,source,length,slot) }}
  predicate Admitted({params}) {{
    |prefix| <= 950 && |mem|%32 == 0 && 96 <= |mem| <= (free as nat)+32 &&
    free >= 128 && free%32 == 0 && (free as nat)+128+S.Round32(length) < 0x10000000000000000 &&
    96 <= slot && slot+32 <= headend <= end <= |mem| && end <= arrayptr <= free &&
    96 <= dstslot && dstslot+32 <= free && 96 <= body && offset == body+position &&
    offset+96 <= end && offset+relative+64+length <= end && source == offset+relative+64 &&
    kind <= 8 && S.Load(mem,64) == free && S.Load(mem,slot) == position &&
    S.Load(mem,offset+32) == kind && S.Load(mem,offset+64) == relative &&
    S.Load(mem,offset+relative+32) == length
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
        post = f'next == S.Running(19590,prefix+[end,start,0,body,headend,slot+32,dstslot+32,arrayptr],Construct(mem,free,kind,source,length,dstslot))' if i == len(states) - 1 else f'Good({i + 1},next,{args})'
        fetch = f'    F.Push{n["op"] - 95}(code,{n["pc"]});\n' if n['op'] in [96, 97] else ''
        guide = '\n'.join(n['guide'])
        attrs = ' {:isolate_assertions}' if n['op'] in [1,3,22,23,27,81,82,94] else ''
        text += f'''  lemma{attrs} Advance{i}(code: seq<Byte>, state: S.State, {params}, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted({args}) && Good({i},state,{args})
    ensures M.Step(code,Destinations(),state,value,data) != S.Bad
    ensures Q.Local(code,state) && Q.Local(code,M.Step(code,Destinations(),state,value,data))
    ensures var next := M.Step(code,Destinations(),state,value,data); {post}
  {{
    hide G.BitAnd();
    hide S.Load();
    hide S.Store();
    hide B.Memory();
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
      if id == {len(states) - 1} then next == S.Running(19590,prefix+[end,start,0,body,headend,slot+32,dstslot+32,arrayptr],Construct(mem,free,kind,source,length,dstslot)) else Good(id+1,next,{args})
  {{
{calls}
  }}
  ghost method Run(code: seq<Byte>, {params}, value: Word, data: seq<Byte>) returns (states: seq<S.State>)
    requires Matches(code) && Admitted({args})
    ensures M.Trace(code,Destinations(),value,data,states)
    ensures forall i {{:trigger states[i]}} :: 0 <= i < |states| ==> Q.Local(code,states[i])
    ensures states[0] == S.Running(19590,prefix+[end,start,0,body,headend,slot,dstslot,arrayptr],mem)
    ensures states[|states|-1] == S.Running(19590,prefix+[end,start,0,body,headend,slot+32,dstslot+32,arrayptr],Construct(mem,free,kind,source,length,dstslot))
  {{
    var state := S.Running(19590,prefix+[end,start,0,body,headend,slot,dstslot,arrayptr],mem);
    reveal Good(); reveal Matches();
    states := [state];
    var id: nat := 0;
    while id < {len(states)}
      invariant id <= {len(states)} && |states| == id+1
      invariant M.Trace(code,Destinations(),value,data,states)
      invariant forall i {{:trigger states[i]}} :: 0 <= i < |states| ==> Q.Local(code,states[i])
      invariant states[0] == S.Running(19590,prefix+[end,start,0,body,headend,slot,dstslot,arrayptr],mem) && states[|states|-1] == state
      invariant id < {len(states)} ==> Good(id,state,{args})
      invariant id == {len(states)} ==> state == S.Running(19590,prefix+[end,start,0,body,headend,slot+32,dstslot+32,arrayptr],Construct(mem,free,kind,source,length,dstslot))
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
    (out / 'NonemptyItem.generated.dfy').write_text(text)
    (out / 'NonemptyItem.mapping.json').write_text(json.dumps({'runtimeSha256': hashlib.sha256(code).hexdigest(),
          'states': states, 'requiredBytes': guards, 'scope': 'Exact successful in-memory decoder of an nonempty OR child-decoder iteration, arbitrary offset and frame.'}, indent=2) + '\n')
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
