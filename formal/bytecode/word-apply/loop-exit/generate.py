#!/usr/bin/env python3
"""Extract the actual complete nonempty loop exit, header shrink and wrapper cleanup."""
import argparse, hashlib, json, subprocess, sys
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
    artifact = json.loads((ROOT/'artifacts/contracts/Collections.sol/Collections.json').read_text())
    code = bytes.fromhex(artifact['deployedBytecode'][2:])
    digest = hashlib.sha256(code).hexdigest()
    pin = json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Collections']
    assert digest == pin['runtimeSha256']
    assert pin['methodIdentifiers']['mapWords(bytes,address,bytes,uint256[])'] == 'ed6dc3be'
    assert pin['methodIdentifiers']['filterWords(bytes,address,bytes,uint256[])'] == '7787eb48'
    instructions, pc = {}, 0
    while pc < len(code):
        op = code[pc]
        width = op-95 if 96 <= op <= 127 else 0
        instructions[pc] = (op, pc+1+width, int.from_bytes(code[pc+1:pc+1+width], 'big'))
        pc += 1+width
    destinations = {p for p, (op, _, _) in instructions.items() if op == 91}
    fields = ['sourceOffset','sourceLength','target','templateOffset','templateLength','arrayOffset','count']
    params = 'data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,n: Word,kept: Word,ptr: Word,value: Word'
    args = 'data,mem,prefix,'+','.join(fields)+',n,kept,ptr,value'
    for kind, mode, selector in [('Map',0,3983393726),('Filter',1,2005396296)]:
        names = [str(selector),'518']+fields+['96','5526']+fields+[str(mode),'128','n','kept','ptr','n']
        values = [selector,518,68,96,18176,228,64,324,0,96,5526,68,96,18176,228,64,324,0,mode,128,3,2 if mode else 3,256,3]
        stack = [Expr(v,t) for v,t in zip(values,names)]
        pc, mem, states, required, targets = 12391, 'mem', [], {518:code[518]}, {518}
        while pc != 518:
            assert len(states) < 80
            op, nxt, imm = instructions[pc]
            required.update({p:code[p] for p in range(pc,nxt)})
            states.append(dict(id=len(states),pc=pc,op=op,next=nxt,immediate=imm,stack=[x.text for x in stack],memory=mem))
            if op == 91: pass
            elif op == 95 or 96 <= op <= 127: stack.append(Expr(imm))
            elif 128 <= op <= 143: stack.append(stack[-(op-127)])
            elif 144 <= op <= 159:
                k = op-143
                stack[-1],stack[-1-k] = stack[-1-k],stack[-1]
            elif op == 80: stack.pop()
            elif op == 16:
                a,b = stack.pop(),stack.pop()
                assert a.text == b.text == 'n'
                stack.append(Expr(0))
            elif op == 21:
                a = stack.pop()
                assert a.constant()
                stack.append(Expr(int(a.value == 0)))
            elif op == 2:
                a,b = stack.pop(),stack.pop()
                assert {a.text,b.text} == {'kept','32'}
                stack.append(Expr((a.value*b.value)%MOD,'kept*32'))
            elif op == 82:
                address, datum = stack.pop(),stack.pop()
                assert mode and address.text == '128' and datum.text == 'kept*32'
                mem = 'Store(mem,128,kept*32)'
            elif op in (86,87):
                target = stack.pop()
                assert target.constant() and target.value in destinations
                targets.add(target.value)
                required[target.value] = code[target.value]
                if op == 86 or stack.pop().value: nxt = target.value
            else: raise ValueError((kind,pc,hex(op)))
            pc = nxt
        assert [x.text for x in stack] == [str(selector),'128']
        cap = max(len(s['stack']) for s in states)
        literal = lambda s: f"Running({s['pc']},prefix+[{','.join(s['stack'])}],{s['memory']})"
        initial = literal(states[0])
        final = f'Running(518,prefix+[{selector},128],{mem})'
        good = '\n'.join('    '+('if' if s['id'] == 0 else 'else if')+f" id == {s['id']} then state == {literal(s)}" for s in states)+'\n    else false'
        matches = ' &&\n    '.join(f'code[{p}] == {v}' for p,v in sorted(required.items()))
        text = f'''// SPDX-License-Identifier: MIT
// Generated exact completed {kind.lower()} loop exit and wrapper cleanup to serializer PC518.
include "../../scans/Execution.dfy"
module BytecodeApplyLoopExit{kind} {{
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  predicate Admitted({params}) {{ 0 < n < 0x800000000000000 && kept <= n && {'true' if mode else 'kept == n'} && |prefix| <= {1024-cap} }}
  opaque predicate Matches(code: seq<Byte>) {{ |code| == {len(code)} && {matches} }}
  function Destinations(): set<nat> {{ {{{','.join(map(str,sorted(targets)))}}} }}
  opaque predicate Good(id: nat,state: State,{params}) {{ Admitted({args}) && (
{good}) }}
'''
        for s in states:
            i = s['id']
            post = f'next == {final}' if i == len(states)-1 else f'Good({i+1},next,{args})'
            fetch = f"    F.Push{s['op']-95}(code,{s['pc']});\n" if s['op'] in (96,97) else ''
            text += f'''  lemma Advance{i}(code: seq<Byte>,state: State,{params})
    requires Matches(code) && Admitted({args}) && Good({i},state,{args})
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); {post}
  {{ hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == {literal(s)};
{fetch}    assert Fetch(code,{s['pc']}) == Op({s['op']},{s['next']},{s['immediate']});
  }}
'''
        joins = []
        for start in range(0,len(states),20):
            end = min(start+20,len(states))
            block = start//20
            post = f'state == {final}' if end == len(states) else f'Good({end},state,{args})'
            calls = '\n'.join(f'    Advance{i}(code,state,{args});\n    var next{i} := Step(code,Destinations(),state,value,data);\n    E.Extend(code,Destinations(),value,data,trace,next{i});trace := trace+[next{i}];state := next{i};' for i in range(start,end))
            text += f'''  ghost method Block{block}(code: seq<Byte>,initial: State,{params}) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted({args}) && Good({start},initial,{args})
    ensures {post} && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == {end-start+1} && trace[0] == initial && trace[|trace|-1] == state
  {{ state := initial;trace := [state];
{calls}
  }}
'''
            joins.append(f'    state,part := Block{block}(code,state,{args});\n    E.Join(code,Destinations(),value,data,trace,part);trace := trace+part[1..];')
        text += f'''  ghost method Run(code: seq<Byte>,{params}) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted({args})
    ensures state == {final} && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == {len(states)+1} && trace[0] == {initial} && trace[|trace|-1] == state
  {{ state := {initial};trace := [state];reveal Good();var part: seq<State>;
'''+ '\n'.join(joins)+'\n  }\n}\n'
        out.mkdir(parents=True,exist_ok=True)
        (out/(kind+'.generated.dfy')).write_text(text)
        (out/(kind+'.mapping.json')).write_text(json.dumps(dict(runtimeSha256=digest,states=states,requiredBytes=required,destinations=sorted(targets),scope='Exact completed loop exit and canonical output length header shrink. Serializer, full raw entry and fresh retained evidence still open.'),indent=2)+'\n')
        print(kind,len(states),'actual exit/cleanup instructions')


if __name__ == '__main__':
    p = argparse.ArgumentParser()
    p.add_argument('--output',type=Path,required=True)
    a = p.parse_args()
    generate(a.output)
    subprocess.run([sys.executable,'-B',HERE.parent/'map-prefix/format-generated.py','--output',a.output,'--include-root',HERE],check=True)
