#!/usr/bin/env python3
"""Extract complete reached fold-result cleanup and physical scalar RETURN."""
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
    assert pin['methodIdentifiers']['foldRange(uint256,address,bytes,uint256,uint256[],bytes32,uint8)'] == 'f1d88dc8'
    assert pin['selectorToDeclaredEntryPc']['4057501128'] == 1055
    assert pin['methodIdentifiers']['foldBytes(bytes,address,bytes,uint256,uint256[],bytes32,uint8)'] == '6d24e79c'
    assert pin['selectorToDeclaredEntryPc']['1831135132'] == 713
    assert pin['methodIdentifiers']['foldWords(bytes,address,bytes,uint256,uint256[],bytes32,uint8)'] == '6de60cb0'
    assert pin['selectorToDeclaredEntryPc']['1843793072'] == 732
    instructions, pc = {}, 0
    while pc < len(code):
        op = code[pc]
        width = op - 95 if 96 <= op <= 127 else 0
        instructions[pc] = (op, pc + 1 + width, int.from_bytes(code[pc+1:pc+1+width], 'big'))
        pc += 1 + width
    destinations = {p for p, (op, _, _) in instructions.items() if op == 0x5b}
    cases = [('Range',True,388,'I.Fits(data,true)'),('Bytes',False,452,'I.Fits(data,false)'),('Words',False,452,'I.Fits(data,false)')]
    for name, rangeCase, size, admission in cases:
        rangeMode = 'true' if rangeCase else 'false'
        entryPc = 12157
        returnExample = 604
        fields = dict(SourceHead=224,SourceLength=32,RangeCount=1,Target=0,
                      TemplateHead=224 if rangeCase else 288,TemplateLength=64,
                      AccOffset=0,ArrayHead=320 if rangeCase else 384,Count=1,Initial=17,Exit=0)
        decoded = ([Expr(fields['RangeCount'],'I.RangeCount(data)')] if rangeCase else [Expr(fields['SourceHead']+36,'I.Offset(I.SourceHead(data))'),Expr(fields['SourceLength'],'I.SourceLength(data)')])+[Expr(fields['Target'],'I.Target(data)'),Expr(fields['TemplateHead']+36,'I.Offset(I.TemplateHead(data))'),Expr(fields['TemplateLength'],'I.TemplateLength(data)'),Expr(fields['AccOffset'],'I.AccOffset(data)'),Expr(fields['ArrayHead']+36,'I.Offset(I.ArrayHead(data))'),Expr(fields['Count'],'I.Count(data)'),Expr(fields['Initial'],'I.Initial(data)'),Expr(fields['Exit'],'I.Exit(data)')]
        decodedText = ','.join(x.text for x in decoded)
        countText = 'I.RangeCount(data)' if rangeCase else 'I.SourceLength(data)' if name == 'Bytes' else '(I.SourceLength(data) as nat)/32'
        argumentTexts = [str({'Range':0,'Bytes':1,'Words':2}[name]),countText,'0' if rangeCase else 'I.Offset(I.SourceHead(data))','0' if rangeCase else 'I.SourceLength(data)']+[x.text for x in decoded[-8:]]
        assert len(argumentTexts) == 12
        argumentText = ','.join(argumentTexts)
        windowTexts = ['I.Offset(I.TemplateHead(data))','I.TemplateLength(data)','I.AccOffset(data)','I.Offset(I.ArrayHead(data))','I.Count(data)']
        windowText = ','.join(windowTexts)
        wrapperReturn = 8778 if rangeCase else 5094
        known = {x.text:x.value for x in decoded}
        known[countText] = fields['RangeCount'] if rangeCase else fields['SourceLength'] if name == 'Bytes' else fields['SourceLength']//32
        arguments = [Expr(int(text)) if text.isdecimal() else Expr(known[text],text) for text in argumentTexts]
        pc,stack = entryPc,[Expr(returnExample,'returnPc')]+decoded+[Expr(0),Expr(wrapperReturn)]+arguments+[Expr(0),Expr(128),Expr(17,'word')]
        initialStack = ','.join(x.text for x in stack)
        memory = 'mem'
        states, required, targets, seen = [], {}, set(), set()
        required.update({p: code[p] for p in targets})
        terminal = None
        while True:
            key = pc, tuple(x.text for x in stack)
            assert key not in seen and len(states) < 500
            seen.add(key)
            op, next_pc, immediate = instructions[pc]
            required.update({p: code[p] for p in range(pc, next_pc)})
            states.append(dict(id=len(states), pc=pc, stack=[x.text for x in stack], op=op, next=next_pc, immediate=immediate,memory=memory))
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
                text = None
                if a.constant() and b.constant():
                    text = str(value)
                elif op == 1:
                    for field in ('SourceHead','TemplateHead','ArrayHead'):
                        head = f'I.{field}(data)'
                        header, offset = f'I.Header({head})', f'I.Offset({head})'
                        if operands == {'4',head}: text = header
                        if operands == {'32',header}: text = offset
                if text is None:
                    text = f'(({a.text} as nat)+({b.text} as nat))%G.Modulus()' if op == 1 else f'(({a.text} as nat)+G.Modulus()-({b.text} as nat))%G.Modulus()'
                stack.append(Expr(value, text))
            elif op in (4,6):
                a,b = stack.pop(),stack.pop()
                assert b.constant() and b.value == 32 and a.text == 'I.SourceLength(data)'
                result = a.value//b.value if op == 4 else a.value%b.value
                text = '(I.SourceLength(data) as nat)/32' if op == 4 else '0'
                stack.append(Expr(result,text))
            elif op == 0x1b:
                amount, a = stack.pop(), stack.pop()
                assert amount.constant()
                value = (a.value << amount.value) % MOD
                if a.constant():
                    text = str(value)
                else:
                    assert amount.value == 5 and a.text == 'I.Count(data)'
                    text = 'I.Span(data)'
                stack.append(Expr(value,text))
            elif op == 0x16:
                a, b = stack.pop(), stack.pop()
                assert pc == 22108 and a.text == 'I.Target(data)' and b.value == (1 << 160)-1
                stack.append(Expr(a.value & b.value, 'I.MaskedTarget(data)' if name == 'BadAddress' else 'I.Target(data)'))
            elif op == 0x15:
                stack.append(Expr(int(stack.pop().value == 0)))
            elif op in (0x10,0x11,0x12,0x14):
                a, b = stack.pop(), stack.pop()
                signed = lambda x: x if x < MOD//2 else x-MOD
                value = a.value < b.value if op == 0x10 else a.value > b.value if op == 0x11 else signed(a.value) < signed(b.value) if op == 0x12 else a.value == b.value
                stack.append(Expr(int(value)))
            elif op == 0x35:
                position = stack.pop()
                result = None
                for field, offset in [('RangeCount' if rangeCase else 'SourceHead',4),('Target',36),('TemplateHead',68),('AccOffset',100),('ArrayHead',132),('Initial',164),('Exit',196)]:
                    if position.constant() and position.value == offset: result = Expr(fields[field],f'I.{field}(data)')
                for head, length in [('SourceHead','SourceLength'),('TemplateHead','TemplateLength'),('ArrayHead','Count')]:
                    if position.text == f'I.Header(I.{head}(data))': result = Expr(fields[length],f'I.{length}(data)')
                assert result is not None, (name,pc,position.text)
                stack.append(result)
            elif op in (0x56,0x57):
                dest = stack.pop()
                assert (dest.constant() or dest.text == 'returnPc') and dest.value in destinations
                targets.add(dest.value)
                required[dest.value] = code[dest.value]
                if op == 0x56 or stack.pop().value:
                    next_pc = dest.value
            elif op == 0x51:
                assert stack.pop().value == 64
                stack.append(Expr(512,'free'))
            elif op == 0x52:
                offset,word = stack.pop(),stack.pop()
                assert offset.text == 'free' and word.text == 'word'
                memory = f'Store({memory},free,word)'
            elif op == 0xf3:
                offset,size = stack.pop(),stack.pop()
                assert offset.text == 'free' and size.value == 32
                assert memory == 'Store(mem,free,word)'
                terminal = 'Returned(G.Encode(word,32))'
                break
            elif op == 0xfd:
                raise ValueError('Successful candidate unexpectedly reached REVERT')
            else:
                raise ValueError((name,pc,hex(op)))
            pc = next_pc
        assert terminal is not None
        print(name,'terminal',terminal)
        cap = max(len(n['stack']) for n in states)
        literal_state = lambda n: f"Running({n['pc']},prefix+[{','.join(n['stack'])}],{n['memory']})"
        good = '\n'.join('    '+('if' if n['id'] == 0 else 'else if')+f" id == {n['id']} then state == {literal_state(n)}" for n in states)+'\n    else false'
        matches = ' &&\n    '.join(f'code[{p}] == {v}' for p, v in sorted(required.items()))
        text = f'''// SPDX-License-Identifier: MIT
// Generated reached full-word fold result through all shared/wrapper cleanup and physical scalar RETURN.
include "../raw-inputs/Inputs.dfy"
include "../raw-inputs/Scalar.dfy"
include "../../scans/DecoderScalar.dfy"
include "../../scans/Representation.dfy"
module BytecodeFoldScalarReturn{name} {{
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import DS = BytecodeScanDecoderScalar
  import A = BytecodeApplyAddressMask
  import R = BytecodeFoldRawScalar
  import AS = BytecodeApplyArrayStride
  import I = BytecodeFoldRawInputs
  import MR = BytecodeScanRepresentation
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  function Decoded(data: seq<Byte>): seq<Word> {{ [{decodedText}] }}
  function Arguments(data: seq<Byte>): seq<Word> {{ [{argumentText}] }}
  function Windows(data: seq<Byte>): seq<Word> {{ [{windowText}] }}
  opaque predicate Admitted(data: seq<Byte>)
    ensures Admitted(data) ==> 4 <= |data| < I.U64()
    ensures Admitted(data) ==> {admission}
  {{ 4 <= |data| < I.U64() && {admission} }}
  opaque predicate Matches(code: seq<Byte>) {{ |code| == {len(code)} &&
    {matches}
  }}
  function Destinations(): set<nat> {{ {{{','.join(map(str,sorted(targets)))}}} }}
  opaque predicate Good(id: nat, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, word: Word, free: Word) {{ Admitted(data) && (
{good}) }}
'''
        for n in states:
            i = n['id']
            post = f'next == {terminal}' if i == len(states)-1 else f'Good({i+1},next,data,mem,prefix,returnPc,word,free)'
            facts = f"    F.Push{n['op']-95}(code,{n['pc']});\n" if n['op'] in (96, 97) else ''
            if n['op'] == 0x1b:
                if n['stack'][-1] == '64': facts += '    DS.DecoderLimit();\n'
                elif n['stack'][-1] == '160': facts += '    A.Limit();\n'
                else:
                    assert n['stack'][-1] == '5'
                    facts += '    AS.Scalar(I.Count(data));\n    I.ArrayArithmetic(data);\n'
            if n['op'] == 0x16 or (n['op'] == 0x14 and name == 'BadAddress'):
                facts += '    R.Address(I.Target(data));\n'
                if name == 'BadAddress': facts += '    I.MaskDefinition(data);\n'
            if n['op'] == 1:
                for field in ('SourceHead','TemplateHead','ArrayHead'):
                    if set(n['stack'][-2:]) == {'32',f'I.Header(I.{field}(data))'}:
                        facts += f'    I.Pointer(I.{field}(data));\n'
                if 'I.Span(data)' in n['stack'][-2:]: facts += '    I.ArrayArithmetic(data);\n'
            if n['op'] in (0x51,0x52,0xf3):
                facts += '    MR.StoredWord(mem,free,word);\n    MR.StoredFrame(mem,free,word,64);\n'
                if n['op'] == 0xf3:
                    facts += '    assert |Store(mem,free,word)| >= free+32;\n    assert G.Grow(Store(mem,free,word),free+32) == Store(mem,free,word);\n'
            text += f'''  lemma Advance{i}(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, word: Word, free: Word, value: Word)
    requires returnPc == 604 && |mem|%32 == 0 && 96 <= |mem| < G.Modulus() && Load(mem,64) == free && 320 <= free && (free as nat)+64 < G.Modulus() && Matches(code) && Admitted(data) && Good({i},state,data,mem,prefix,returnPc,word,free) && |prefix| <= {1024-cap}
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); {post}
  {{
    hide G.BitAnd(); hide G.Shift();
    reveal Matches(); reveal Good(); reveal Step();
    assert state == {literal_state(n)};
{facts}    assert Fetch(code,{n['pc']}) == Op({n['op']},{n['next']},{n['immediate']});
  }}
'''
        text += f'''  lemma Start(data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, word: Word, free: Word)
    requires returnPc == 604 && |mem|%32 == 0 && 96 <= |mem| < G.Modulus() && Load(mem,64) == free && 320 <= free && (free as nat)+64 < G.Modulus() && Admitted(data)
    ensures Good(0,Running({entryPc},prefix+[{initialStack}],mem),data,mem,prefix,returnPc,word,free)
  {{ reveal Good(); }}
'''
        joins = []
        for start in range(0, len(states), 20):
            end, block = min(start+20, len(states)), start//20
            block_post = f'state == {terminal}' if end == len(states) else f'Good({end},state,data,mem,prefix,returnPc,word,free)'
            calls = '\n'.join(f'    Advance{i}(code,state,data,mem,prefix,returnPc,word,free,value);\n    var next{i} := Step(code,Destinations(),state,value,data);\n    E.Extend(code,Destinations(),value,data,trace,next{i});\n    trace := trace+[next{i}]; state := next{i};' for i in range(start, end))
            text += f'''  ghost method Block{block}(code: seq<Byte>, initial: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, word: Word, free: Word, value: Word) returns (state: State, trace: seq<State>)
    requires returnPc == 604 && |mem|%32 == 0 && 96 <= |mem| < G.Modulus() && Load(mem,64) == free && 320 <= free && (free as nat)+64 < G.Modulus() && Matches(code) && Admitted(data) && Good({start},initial,data,mem,prefix,returnPc,word,free) && |prefix| <= {1024-cap}
    ensures {block_post} && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == {end-start+1} && trace[0] == initial && trace[|trace|-1] == state
  {{
    state := initial; trace := [state];
{calls}
  }}
'''
            joins.append(f'    state,part := Block{block}(code,state,data,mem,prefix,returnPc,word,free,value);\n    E.Join(code,Destinations(),value,data,trace,part); trace := trace+part[1..];')
        joined = '\n'.join(joins)
        text += f'''  ghost method Run(code: seq<Byte>, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, word: Word, free: Word, value: Word) returns (state: State, trace: seq<State>)
    requires returnPc == 604 && |mem|%32 == 0 && 96 <= |mem| < G.Modulus() && Load(mem,64) == free && 320 <= free && (free as nat)+64 < G.Modulus() && Matches(code) && Admitted(data) && |prefix| <= {1024-cap}
    ensures state == {terminal} && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == {len(states)+1} && trace[0] == Running({entryPc},prefix+[{initialStack}],mem) && trace[|trace|-1] == state
  {{
    Start(data,mem,prefix,returnPc,word,free);
    state := Running({entryPc},prefix+[{initialStack}],mem); trace := [state];
    var part: seq<State>;
{joined}
  }}
}}
'''
        out.mkdir(parents=True, exist_ok=True)
        (out / (name+'.generated.dfy')).write_text(text)
        (out / (name+'.mapping.json')).write_text(json.dumps(dict(runtimeSha256=digest, states=states, requiredBytes=required, destinations=sorted(targets), scope='Complete reached12157 scalar result cleanup through exact32-byte public RETURN; original raw decoder/body/loop/callback/resource/failure and retained gates remain mandatory',initialStack=initialStack,mode=name,foldArguments=argumentTexts,windowArguments=windowTexts,wrapperReturnPc=wrapperReturn,terminal=terminal), indent=2)+'\n')
        print(name, len(states), 'actual scalar-result cleanup instructions')


if __name__ == '__main__':
    p = argparse.ArgumentParser()
    p.add_argument('--output', type=Path, required=True)
    a = p.parse_args()
    generate(a.output)
    subprocess.run([sys.executable, '-B', HERE/'format-generated.py', '--output', a.output, '--include-root', HERE], check=True)
