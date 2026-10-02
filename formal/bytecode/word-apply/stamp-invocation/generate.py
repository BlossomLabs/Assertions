#!/usr/bin/env python3
"""Extract exact word-apply stamp helper invocation and zero loop index."""
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
    fields = ['returnPc','sourceOffset','sourceLength','target','templateOffset','templateLength','arrayOffset','count','mode','out','n','kept','callPtr','index']
    default = [5526,164,64,18176,260,32,324,1,0,128,2,0,224,1]
    cases = [('Invoke',12458,16850,False,0,'true')]
    for name, entryPc, stopPc, indexed, indexValue, admission in cases:
        pc,stack = entryPc,[Expr(v,f) for v,f in zip(default,fields)]+[Expr(0),Expr(99,'word')]
        if indexed:stack.append(Expr(indexValue,'index'))
        initialStack = [x.text for x in stack]
        states,required,targets,seen = [],{12235:code[12235]},{12235},set()
        while not states or pc != stopPc:
            key = pc,tuple(x.text for x in stack);assert key not in seen and len(states)<220;seen.add(key)
            op,next_pc,immediate = instructions[pc]
            required.update({p:code[p] for p in range(pc,next_pc)})
            states.append(dict(id=len(states),pc=pc,stack=[x.text for x in stack],op=op,next=next_pc,immediate=immediate))
            if op == 0x5b:pass
            elif op == 0x5f or 96 <= op <= 127:stack.append(Expr(immediate))
            elif 0x80 <= op <= 0x8f:stack.append(stack[-(op-0x7f)])
            elif 0x90 <= op <= 0x9f:
                depth=op-0x8f;stack[-1],stack[-1-depth]=stack[-1-depth],stack[-1]
            elif op == 0x50:stack.pop()
            elif op in (1,2,3,4):
                a,b=stack.pop(),stack.pop();value=(a.value+b.value if op==1 else a.value*b.value if op==2 else a.value-b.value if op==3 else a.value//b.value)%MOD
                if a.constant() and b.constant():text=str(value)
                elif op==2 and {a.text,b.text} == {'index','32'}:text='index*32'
                elif op==4 and a.text=='index*32' and b.text=='32':text='index'
                elif op==1 and {a.text,b.text} == {'index*32','32'}:text='index*32+32'
                elif op==1 and {a.text,b.text} == {'sourceOffset','index*32'}:text='sourceOffset+index*32'
                elif op==3 and a.text=='index*32+32' and b.text=='index*32':text='32'
                else:raise ValueError((name,pc,a.text,b.text))
                stack.append(Expr(value,text))
            elif op in (0x10,0x11,0x14):
                a,b=stack.pop(),stack.pop();stack.append(Expr(int(a.value<b.value if op==0x10 else a.value>b.value if op==0x11 else a.value==b.value)))
            elif op==0x17:
                a,b=stack.pop(),stack.pop();assert a.constant() and b.constant();stack.append(Expr(a.value|b.value))
            elif op==0x15:stack.append(Expr(int(stack.pop().value==0)))
            elif op==0x35:
                position=stack.pop();assert position.text=='sourceOffset+index*32', (name,pc,position.text)
                stack.append(Expr(99,'DataWord(data,sourceOffset+index*32)'))
            elif op in (0x56,0x57):
                dest=stack.pop();assert dest.value in destinations and (dest.constant() or dest.text=='returnPc')
                targets.add(dest.value);required[dest.value]=code[dest.value]
                if op==0x56 or stack.pop().value:next_pc=dest.value
            else:raise ValueError((name,pc,hex(op)))
            pc=next_pc
        expected = fields+['word','12472','callPtr','arrayOffset','count','word','0']
        assert [x.text for x in stack]==expected,(name,[x.text for x in stack])
        initial=f"Running({entryPc},prefix+[{','.join(initialStack)}],mem)"
        terminal=f"Running({stopPc},prefix+[{','.join(expected)}],mem)"
        cap = max(max(len(n['stack']) for n in states),len(expected))
        literal_state = lambda n: f"Running({n['pc']},prefix+[{','.join(n['stack'])}],mem)"
        good = '\n'.join('    '+('if' if n['id'] == 0 else 'else if')+f" id == {n['id']} then state == {literal_state(n)}" for n in states)+'\n    else false'
        matches = ' &&\n    '.join(f'code[{p}] == {v}' for p, v in sorted(required.items()))
        text = f'''// SPDX-License-Identifier: MIT
// Generated complete actual stamp helper invocation; arbitrary word/pointers and lower stack/memory preserved.
include "../../scans/Execution.dfy"
module BytecodeApplyStamp{name} {{
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  predicate Admitted(data: seq<Byte>,sourceOffset: Word,sourceLength: Word,n: Word,index: Word) {{ {admission} }}
  opaque predicate Matches(code: seq<Byte>) {{ |code| == {len(code)} &&
    {matches}
  }}
  function Destinations(): set<nat> {{ {{{','.join(map(str,sorted(targets)))}}} }}
  opaque predicate Good(id: nat, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, out: Word, n: Word, kept: Word, callPtr: Word, index: Word, word: Word) {{ Admitted(data,sourceOffset,sourceLength,n,index) && (
{good}) }}
'''
        for n in states:
            i = n['id']
            post = f'next == {terminal}' if i == len(states)-1 else f'Good({i+1},next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word)'
            facts = f"    F.Push{n['op']-95}(code,{n['pc']});\n" if n['op'] in (96, 97) else ''
            if name=='Iteration' and (n['op'] in (1,2,0x35)):
                facts += '    W.Index(templateLength,arrayOffset,count,data,index);\n'
            text += f'''  lemma Advance{i}(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, out: Word, n: Word, kept: Word, callPtr: Word, index: Word, word: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceOffset,sourceLength,n,index) && Good({i},state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word) && |prefix| <= {1024-cap}
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); {post}
  {{
    reveal Matches(); reveal Good(); reveal Step();
    assert state == {literal_state(n)};
{facts}    assert Fetch(code,{n['pc']}) == Op({n['op']},{n['next']},{n['immediate']});
  }}
'''
        text += f'''  lemma Start(data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, out: Word, n: Word, kept: Word, callPtr: Word, index: Word, word: Word)
    requires Admitted(data,sourceOffset,sourceLength,n,index)
    ensures Good(0,{initial},data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word)
  {{ reveal Good(); }}
'''
        joins = []
        for start in range(0, len(states), 20):
            end, block = min(start+20, len(states)), start//20
            block_post = f'state == {terminal}' if end == len(states) else f'Good({end},state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word)'
            calls = '\n'.join(f'    Advance{i}(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word,value);\n    var next{i} := Step(code,Destinations(),state,value,data);\n    E.Extend(code,Destinations(),value,data,trace,next{i});\n    trace := trace+[next{i}]; state := next{i};' for i in range(start, end))
            text += f'''  ghost method Block{block}(code: seq<Byte>, initial: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, out: Word, n: Word, kept: Word, callPtr: Word, index: Word, word: Word, value: Word) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(data,sourceOffset,sourceLength,n,index) && Good({start},initial,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word) && |prefix| <= {1024-cap}
    ensures {block_post} && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == {end-start+1} && trace[0] == initial && trace[|trace|-1] == state
  {{
    state := initial; trace := [state];
{calls}
  }}
'''
            joins.append(f'    state,part := Block{block}(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word,value);\n    E.Join(code,Destinations(),value,data,trace,part); trace := trace+part[1..];')
        joined = '\n'.join(joins)
        text += f'''  ghost method Run(code: seq<Byte>, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, out: Word, n: Word, kept: Word, callPtr: Word, index: Word, word: Word, value: Word) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(data,sourceOffset,sourceLength,n,index) && |prefix| <= {1024-cap}
    ensures state == {terminal} && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == {len(states)+1} && trace[0] == {initial} && trace[|trace|-1] == state
  {{
    Start(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word);
    state := {initial}; trace := [state];
    var part: seq<State>;
{joined}
  }}
}}
'''
        out.mkdir(parents=True, exist_ok=True)
        (out / (name+'.generated.dfy')).write_text(text)
        (out / (name+'.mapping.json')).write_text(json.dumps(dict(runtimeSha256=digest, states=states, requiredBytes=required, destinations=sorted(targets), scope='Exact physical stamp helper invocation; finite stamp loop/callback/output/full public evidence open',entryPc=entryPc,terminal=terminal), indent=2)+'\n')
        print(name, len(states), 'actual decoder states')


if __name__ == '__main__':
    p = argparse.ArgumentParser()
    p.add_argument('--output', type=Path, required=True)
    a = p.parse_args()
    generate(a.output)
    subprocess.run([sys.executable, '-B', HERE.parent/'map-prefix/format-generated.py', '--output', a.output, '--include-root', HERE], check=True)
