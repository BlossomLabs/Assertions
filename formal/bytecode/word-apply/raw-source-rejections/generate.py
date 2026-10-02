#!/usr/bin/env python3
"""Extract the five ordered source-tail failures of the shared four-head decoder."""
import argparse, hashlib, json, subprocess, sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
MOD, U64 = 1 << 256, 1 << 64


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
    assert pin['methodIdentifiers']['mapWords(bytes,address,bytes,uint256[])'] == 'ed6dc3be'
    assert pin['methodIdentifiers']['filterWords(bytes,address,bytes,uint256[])'] == '7787eb48'
    instructions, pc = {}, 0
    while pc < len(code):
        op = code[pc]
        width = op - 95 if 96 <= op <= 127 else 0
        instructions[pc] = (op, pc + 1 + width, int.from_bytes(code[pc+1:pc+1+width], 'big'))
        pc += 1 + width
    destinations = {p for p, (op, _, _) in instructions.items() if op == 0x5b}
    cases = [
        ('HeadShort', 100, 128, 0, '|data| < 132'),
        ('SourceOffsetLarge', 164, U64, 0, '132 <= |data| && Head(data) >= 0x10000000000000000'),
        ('SourceHeaderShort', 132, 128, 0, '132 <= |data| && Head(data) < 0x10000000000000000 && (Head(data) as nat)+36 > |data|'),
        ('SourceLengthLarge', 164, 128, U64, '132 <= |data| && Head(data) < 0x10000000000000000 && (Head(data) as nat)+36 <= |data| && Length(data) >= 0x10000000000000000'),
        ('SourceTailShort', 164, 128, 32, '132 <= |data| && Head(data) < 0x10000000000000000 && (Head(data) as nat)+36 <= |data| && Length(data) < 0x10000000000000000 && (Head(data) as nat)+36+(Length(data) as nat) > |data|'),
    ]
    for name, size, head, length, admission in cases:
        pc, stack = 22579, [Expr(1050, 'returnPc'), Expr(size, '|data|'), Expr(4)]
        states, required, targets, seen = [], {}, set(), set()
        while True:
            key = pc, tuple(x.text for x in stack)
            assert key not in seen and len(states) < 500
            seen.add(key)
            op, next_pc, immediate = instructions[pc]
            required.update({p: code[p] for p in range(pc, next_pc)})
            states.append(dict(id=len(states), pc=pc, stack=[x.text for x in stack], op=op, next=next_pc, immediate=immediate))
            if op == 0x5b:
                pass
            elif op == 0x5f or 96 <= op <= 127:
                stack.append(Expr(immediate))
            elif op == 0x36:
                stack.append(Expr(size, '|data|'))
            elif 0x80 <= op <= 0x8f:
                stack.append(stack[-(op-0x7f)])
            elif 0x90 <= op <= 0x9f:
                depth = op-0x8f
                stack[-1], stack[-1-depth] = stack[-1-depth], stack[-1]
            elif op == 0x50:
                stack.pop()
            elif op in (1, 3):
                a, b = stack.pop(), stack.pop()
                value = (a.value+b.value if op == 1 else a.value-b.value) % MOD
                operands = {a.text, b.text}
                if a.constant() and b.constant():
                    text = str(value)
                elif op == 1 and operands == {'4', 'Head(data)'}:
                    text = 'Header(data)'
                elif op == 1 and operands == {'32', 'Header(data)'}:
                    text = 'Offset(data)'
                else:
                    text = f'(({a.text} as nat)+({b.text} as nat))%G.Modulus()' if op == 1 else f'(({a.text} as nat)+G.Modulus()-({b.text} as nat))%G.Modulus()'
                stack.append(Expr(value, text))
            elif op == 0x1b:
                amount, a = stack.pop(), stack.pop()
                assert amount.constant() and a.constant()
                stack.append(Expr((a.value << amount.value) % MOD))
            elif op == 0x15:
                stack.append(Expr(int(stack.pop().value == 0)))
            elif op in (0x11, 0x12):
                a, b = stack.pop(), stack.pop()
                signed = lambda x: x if x < MOD//2 else x-MOD
                stack.append(Expr(int(a.value > b.value if op == 0x11 else signed(a.value) < signed(b.value))))
            elif op == 0x35:
                position = stack.pop()
                if position.text == 'Header(data)':
                    stack.append(Expr(length, 'Length(data)'))
                elif position.value == 4:
                    stack.append(Expr(head, 'Head(data)'))
                else:
                    raise ValueError((name, pc, position.text))
            elif op in (0x56, 0x57):
                dest = stack.pop()
                assert dest.constant() and dest.value in destinations
                targets.add(dest.value)
                required[dest.value] = code[dest.value]
                if op == 0x56 or stack.pop().value:
                    next_pc = dest.value
            elif op == 0xfd:
                assert stack.pop().value == stack.pop().value == 0
                break
            else:
                raise ValueError((name, pc, hex(op)))
            pc = next_pc
        cap = max(len(n['stack']) for n in states)
        literal_state = lambda n: f"Running({n['pc']},prefix+[{','.join(n['stack'])}],mem)"
        good = '\n'.join('    '+('if' if n['id'] == 0 else 'else if')+f" id == {n['id']} then state == {literal_state(n)}" for n in states)+'\n    else false'
        matches = ' &&\n    '.join(f'code[{p}] == {v}' for p, v in sorted(required.items()))
        text = f'''// SPDX-License-Identifier: MIT
// Generated ordered raw four-head decoder source rejection; arbitrary prefix preserved until REVERT.
include "../../scans/Execution.dfy"
include "../../scans/DecoderScalar.dfy"
module BytecodeApplyRaw{name} {{
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import DS = BytecodeScanDecoderScalar
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  function Head(data: seq<Byte>): Word {{ DataWord(data,4) }}
  function Header(data: seq<Byte>): Word {{ ((Head(data) as nat)+4)%G.Modulus() }}
  function Length(data: seq<Byte>): Word {{ DataWord(data,Header(data)) }}
  function Offset(data: seq<Byte>): Word {{ ((Head(data) as nat)+36)%G.Modulus() }}
  predicate Admitted(data: seq<Byte>) {{ 4 <= |data| < 0x10000000000000000 && {admission} }}
  opaque predicate Matches(code: seq<Byte>) {{ |code| == {len(code)} &&
    {matches}
  }}
  function Destinations(): set<nat> {{ {{{','.join(map(str,sorted(targets)))}}} }}
  opaque predicate Good(id: nat, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word) {{ Admitted(data) && (
{good}) }}
'''
        for n in states:
            i = n['id']
            post = 'next == Reverted([])' if i == len(states)-1 else f'Good({i+1},next,data,mem,prefix,returnPc)'
            facts = f"    F.Push{n['op']-95}(code,{n['pc']});\n" if n['op'] in (96, 97) else ''
            if n['op'] == 0x1b:
                facts += '    DS.DecoderLimit();\n'
            if n['op'] == 1 and set(n['stack'][-2:]) == {'32', 'Header(data)'}:
                facts += '    assert Head(data) < 0x10000000000000000;\n    assert Header(data) == (Head(data) as nat)+4;\n    assert Offset(data) == (Head(data) as nat)+36;\n    assert (Header(data) as nat)+32 == Offset(data);\n'
            text += f'''  lemma Advance{i}(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good({i},state,data,mem,prefix,returnPc) && |prefix| <= {1024-cap}
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); {post}
  {{
    reveal Matches(); reveal Good(); reveal Step();
    assert state == {literal_state(n)};
{facts}    assert Fetch(code,{n['pc']}) == Op({n['op']},{n['next']},{n['immediate']});
  }}
'''
        text += f'''  lemma Start(data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word)
    requires Admitted(data)
    ensures Good(0,Running(22579,prefix+[returnPc,|data|,4],mem),data,mem,prefix,returnPc)
  {{ reveal Good(); }}
'''
        joins = []
        for start in range(0, len(states), 20):
            end, block = min(start+20, len(states)), start//20
            terminal = 'state == Reverted([])' if end == len(states) else f'Good({end},state,data,mem,prefix,returnPc)'
            calls = '\n'.join(f'    Advance{i}(code,state,data,mem,prefix,returnPc,value);\n    var next{i} := Step(code,Destinations(),state,value,data);\n    E.Extend(code,Destinations(),value,data,trace,next{i});\n    trace := trace+[next{i}]; state := next{i};' for i in range(start, end))
            text += f'''  ghost method Block{block}(code: seq<Byte>, initial: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(data) && Good({start},initial,data,mem,prefix,returnPc) && |prefix| <= {1024-cap}
    ensures {terminal} && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == {end-start+1} && trace[0] == initial && trace[|trace|-1] == state
  {{
    state := initial; trace := [state];
{calls}
  }}
'''
            joins.append(f'    state,part := Block{block}(code,state,data,mem,prefix,returnPc,value);\n    E.Join(code,Destinations(),value,data,trace,part); trace := trace+part[1..];')
        joined = '\n'.join(joins)
        text += f'''  ghost method Run(code: seq<Byte>, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(data) && |prefix| <= {1024-cap}
    ensures state == Reverted([]) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == {len(states)+1} && trace[0] == Running(22579,prefix+[returnPc,|data|,4],mem) && trace[|trace|-1] == state
  {{
    Start(data,mem,prefix,returnPc);
    state := Running(22579,prefix+[returnPc,|data|,4],mem); trace := [state];
    var part: seq<State>;
{joined}
  }}
}}
'''
        out.mkdir(parents=True, exist_ok=True)
        (out / (name+'.generated.dfy')).write_text(text)
        (out / (name+'.mapping.json')).write_text(json.dumps(dict(runtimeSha256=digest, states=states, requiredBytes=required, destinations=sorted(targets), scope='Five early source rejection classes of shared decoder only; no public coverage'), indent=2)+'\n')
        print(name, len(states), 'actual decoder states')


if __name__ == '__main__':
    p = argparse.ArgumentParser()
    p.add_argument('--output', type=Path, required=True)
    a = p.parse_args()
    generate(a.output)
    subprocess.run([sys.executable, '-B', HERE.parent/'map-prefix/format-generated.py', '--output', a.output, '--include-root', HERE], check=True)
