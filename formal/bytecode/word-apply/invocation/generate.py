#!/usr/bin/env python3
"""Extract both actual decoded-wrapper calls into the shared map/filter engine."""
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
    fields = ['sourceOffset','sourceLength','target','templateOffset','templateLength','arrayOffset','count']
    cases = [('Map',1050,0),('Filter',784,1)]
    for name, entryPc, mode in cases:
        pc, stack = entryPc, [Expr(i+10,field) for i,field in enumerate(fields)]
        states, required, targets, seen = [], {12177:code[12177]}, {12177}, set()
        while pc != 12177:
            key = pc,tuple(x.text for x in stack)
            assert key not in seen and len(states) < 50
            seen.add(key)
            op,next_pc,immediate = instructions[pc]
            required.update({p:code[p] for p in range(pc,next_pc)})
            states.append(dict(id=len(states),pc=pc,stack=[x.text for x in stack],op=op,next=next_pc,immediate=immediate))
            if op == 0x5b: pass
            elif op == 0x5f or 96 <= op <= 127: stack.append(Expr(immediate))
            elif 0x80 <= op <= 0x8f: stack.append(stack[-(op-0x7f)])
            elif op == 0x56:
                dest = stack.pop(); assert dest.constant() and dest.value in destinations
                targets.add(dest.value);required[dest.value]=code[dest.value];next_pc=dest.value
            else: raise ValueError((name,pc,op))
            pc=next_pc
        expected = fields+['96','5526']+fields+[str(mode)]
        assert [x.text for x in stack] == expected,(name,[x.text for x in stack])
        initial = f"Running({entryPc},prefix+[{','.join(fields)}],mem)"
        terminal = f"Running(12177,prefix+[{','.join(expected)}],mem)"
        cap = max(len(n['stack']) for n in states)
        literal_state = lambda n: f"Running({n['pc']},prefix+[{','.join(n['stack'])}],mem)"
        good = '\n'.join('    '+('if' if n['id'] == 0 else 'else if')+f" id == {n['id']} then state == {literal_state(n)}" for n in states)+'\n    else false'
        matches = ' &&\n    '.join(f'code[{p}] == {v}' for p, v in sorted(required.items()))
        text = f'''// SPDX-License-Identifier: MIT
// Generated actual wrapper call into the shared map/filter body; arbitrary lower prefix and memory preserved.
include "../../scans/Execution.dfy"
module BytecodeApplyInvoke{name} {{
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  predicate Admitted(data: seq<Byte>) {{ true }}
  opaque predicate Matches(code: seq<Byte>) {{ |code| == {len(code)} &&
    {matches}
  }}
  function Destinations(): set<nat> {{ {{{','.join(map(str,sorted(targets)))}}} }}
  opaque predicate Good(id: nat, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word) {{ Admitted(data) && (
{good}) }}
'''
        for n in states:
            i = n['id']
            post = f'next == {terminal}' if i == len(states)-1 else f'Good({i+1},next,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count)'
            facts = f"    F.Push{n['op']-95}(code,{n['pc']});\n" if n['op'] in (96, 97) else ''
            text += f'''  lemma Advance{i}(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good({i},state,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count) && |prefix| <= {1024-cap}
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); {post}
  {{
    reveal Matches(); reveal Good(); reveal Step();
    assert state == {literal_state(n)};
{facts}    assert Fetch(code,{n['pc']}) == Op({n['op']},{n['next']},{n['immediate']});
  }}
'''
        text += f'''  lemma Start(data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word)
    requires Admitted(data)
    ensures Good(0,{initial},data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count)
  {{ reveal Good(); }}
'''
        joins = []
        for start in range(0, len(states), 20):
            end, block = min(start+20, len(states)), start//20
            block_post = f'state == {terminal}' if end == len(states) else f'Good({end},state,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count)'
            calls = '\n'.join(f'    Advance{i}(code,state,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,value);\n    var next{i} := Step(code,Destinations(),state,value,data);\n    E.Extend(code,Destinations(),value,data,trace,next{i});\n    trace := trace+[next{i}]; state := next{i};' for i in range(start, end))
            text += f'''  ghost method Block{block}(code: seq<Byte>, initial: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, value: Word) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(data) && Good({start},initial,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count) && |prefix| <= {1024-cap}
    ensures {block_post} && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == {end-start+1} && trace[0] == initial && trace[|trace|-1] == state
  {{
    state := initial; trace := [state];
{calls}
  }}
'''
            joins.append(f'    state,part := Block{block}(code,state,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,value);\n    E.Join(code,Destinations(),value,data,trace,part); trace := trace+part[1..];')
        joined = '\n'.join(joins)
        text += f'''  ghost method Run(code: seq<Byte>, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, value: Word) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(data) && |prefix| <= {1024-cap}
    ensures state == {terminal} && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == {len(states)+1} && trace[0] == {initial} && trace[|trace|-1] == state
  {{
    Start(data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count);
    state := {initial}; trace := [state];
    var part: seq<State>;
{joined}
  }}
}}
'''
        out.mkdir(parents=True, exist_ok=True)
        (out / (name+'.generated.dfy')).write_text(text)
        (out / (name+'.mapping.json')).write_text(json.dumps(dict(runtimeSha256=digest, states=states, requiredBytes=required, destinations=sorted(targets), scope='Both actual decoded wrappers into the shared engine only; no complete entry/body/public coverage',entryPc=entryPc,terminal=terminal), indent=2)+'\n')
        print(name, len(states), 'actual decoder states')


if __name__ == '__main__':
    p = argparse.ArgumentParser()
    p.add_argument('--output', type=Path, required=True)
    a = p.parse_args()
    generate(a.output)
    subprocess.run([sys.executable, '-B', HERE.parent/'map-prefix/format-generated.py', '--output', a.output, '--include-root', HERE], check=True)
