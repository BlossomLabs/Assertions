#!/usr/bin/env python3
"""Derive checked cursor kernels from selected aggregate-branch solc AST nodes.

Descriptor parsing, loop control and recursive/static child validation are not
translated here. Their interfaces are explicit in Refinement.dfy and README.md.
"""
import argparse
import gzip
import importlib.util
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
spec = importlib.util.spec_from_file_location('bytes_generator', HERE.parent/'source/generate.py')
base = importlib.util.module_from_spec(spec)
spec.loader.exec_module(base)


class CursorLower(base.Lower):
    def checked(self, a, op, b):
        if op == '/':
            self.emit(f'if {b} == 0 {{ r := Panic(18); return; }}')
            self.emit(f'DivisionShrinks({a},{b});')
        return super().checked(a, op, b)

    def expression(self, node):
        n = base.unwrap(node)
        if n['nodeType'] == 'MemberAccess' and base.ident(n['expression'], 'x'):
            assert n['memberName'] in ('base', 'tail', 'count', 'words')
            return n['memberName']
        if n['nodeType'] == 'Identifier' and n['name'] in ('w', 'base', 'count', 'words', 'position'):
            return n['name']
        if n['nodeType'] == 'FunctionCall' and base.ident(n['expression'], 'body'):
            assert self.mode in ('advance', 'advance_tuple') and n['expression']['referencedDeclaration'] == self.functions['body']['id']
            args = n['arguments']
            assert len(args) == 6 and base.ident(args[0], 't')
            descriptor = args[2] if self.mode == 'advance' else args[1]
            assert descriptor['nodeType'] == 'MemberAccess' and descriptor['memberName'] == 'j' and base.ident(descriptor['expression'], 'x')
            assert base.ident(args[1], 's') if self.mode == 'advance' else base.ident(args[2], 'next')
            assert base.ident(args[3], 'v') and base.ident(args[5], 'context')
            # Execute actual checked address arithmetic. Child extent is an
            # explicit interface input, justified by the recursive proof.
            position = self.expression(args[4])
            self.emit(f'assert {position}+used <= |v|;')
            return 'used'
        return super().expression(node)

    def statement(self, node):
        if node['nodeType'] == 'ExpressionStatement' and node['expression']['nodeType'] == 'Assignment':
            self.origin(node)
            n = node['expression']
            assert n['leftHandSide']['nodeType'] == 'MemberAccess' and base.ident(n['leftHandSide']['expression'], 'x')
            assert n['leftHandSide']['memberName'] == 'tail' and n['operator'] in ('=', '+=')
            value = self.expression(n['rightHandSide'])
            if n['operator'] == '+=':
                value = self.checked('tail', '+', value)
            self.emit(f'tail := {value};')
        elif node['nodeType'] == 'VariableDeclarationStatement' and node['declarations'][0]['name'] == 'position':
            self.origin(node)
            assert len(node['declarations']) == 1 and node['declarations'][0]['typeDescriptions']['typeString'] == 'uint256'
            value = self.expression(node['initialValue'])
            self.emit(f'var position := {value};')
        else:
            super().statement(node)


def generate(source, solc):
    bytecode, mask, mapping, request, output = base.generate(source, solc)
    contract = next(n for n in output['sources']['AbiCodec.sol']['ast']['nodes'] if n['nodeType'] == 'ContractDefinition')
    funcs = {n['name']: n for n in contract['nodes'] if n['nodeType'] == 'FunctionDefinition' and
             (n['name'] in ('body', 'requireValue') or n['name'] == 'word' and len(n['parameters']['parameters']) == 3)}
    body = funcs['body']['body']['statements']
    array = body[1]['trueBody']['statements']
    tup = body[2]['trueBody']['statements']
    assert len(array) == 10 and len(tup) == 6
    assert array[8]['nodeType'] == 'ForStatement' and tup[2]['nodeType'] == 'WhileStatement'
    loop = array[8]['body']['statements']
    head = tup[2]['body']['statements']
    assert len(loop) == 3 and len(head) == 4
    lower = CursorLower(source, funcs)
    def start(mode, declaration, contracts, hints):
        lower.mode = mode
        lower.emit(declaration)
        for line in contracts:
            lower.emit('  '+line)
        lower.emit('{')
        lower.level = 2
        for line in hints:
            lower.emit(line)
    def end(value):
        lower.emit(f'r := Ok({value});')
        lower.level = 1
        lower.emit('}')
    start('head', 'ghost method {:isolate_assertions} ArrayHead(v: seq<Byte>, base: nat, count: nat, words: nat) returns (r: Outcome)',
          ['requires Uint(|v|) && base <= |v| && Uint(count) && Uint(words) && words > 0',
           'ensures r == (if count*words*32 > |v|-base then Invalid(base) else Ok(count*words*32))'],
          ['DivisionBound(|v|-base,count,words);', 'var tail: int := 0;'])
    lower.statement(array[5])
    lower.emit('ProductFits(count,words,|v|-base);')
    lower.statement(array[6])
    end('tail')
    start('tuple', 'ghost method TupleHeadStep(v: seq<Byte>, p: nat, previous: nat, w: nat) returns (r: Outcome)',
          ['requires Uint(|v|) && p+previous <= |v| && Uint(w) && w > 0',
           'ensures r == (if w*32 > |v|-p-previous then Invalid(p) else Ok(previous+w*32))'],
          ['DivisionBound(|v|-p-previous,w,1);', 'var tail: int := previous;'])
    lower.statement(head[1])
    lower.statement(head[2])
    end('tail')
    start('position', 'ghost method ArrayPosition(v: seq<Byte>, base: nat, count: nat, words: nat, i: nat) returns (r: Outcome)',
          ['requires Uint(|v|) && words > 0 && i < count && base+count*words*32 <= |v|',
           'ensures r == Ok(base+i*words*32)', 'ensures r.used+32*words <= |v|'],
          ['PositionFits(base,count,words,i,|v|);'])
    lower.statement(loop[0])
    end('position')
    start('offset', 'ghost method ArrayOffset(v: seq<Byte>, position: nat, tail: nat) returns (r: Outcome)',
          ['requires Uint(|v|) && position+32 <= |v| && Uint(tail)',
           'ensures r == (if ReadNat(v[position..position+32]) == tail then Ok(0) else Invalid(position))'], [])
    lower.statement(loop[1])
    end('0')
    tuple_loop = tup[4]['body']['statements']
    assert tuple_loop[1]['nodeType'] == 'IfStatement'
    tuple_dynamic = tuple_loop[1]['trueBody']['statements']
    start('offset', 'ghost method TupleOffset(v: seq<Byte>, p: nat, base: nat, tail: nat) returns (r: Outcome)',
          ['requires Uint(|v|) && p+base+32 <= |v| && Uint(tail)',
           'ensures r == (if ReadNat(v[p+base..p+base+32]) == tail then Ok(0) else Invalid(p+base))'], [])
    lower.statement(tuple_dynamic[0])
    end('0')
    start('advance', 'ghost method ArrayTailAdvance(v: seq<Byte>, base: nat, previous: nat, used: nat) returns (r: Outcome)',
          ['requires Uint(|v|) && base+previous+used <= |v|',
           'ensures r == Ok(previous+used)'], ['var tail: int := previous;'])
    lower.statement(loop[2])
    end('tail')
    start('advance_tuple', 'ghost method TupleTailAdvance(v: seq<Byte>, p: nat, previous: nat, used: nat) returns (r: Outcome)',
          ['requires Uint(|v|) && p+previous+used <= |v|',
           'ensures r == Ok(previous+used)'], ['var tail: int := previous;'])
    lower.statement(tuple_dynamic[1])
    end('tail')
    text = ('// SPDX-License-Identifier: MIT\n// GENERATED by aggregate/generate.py; do not edit.\n'
            '// Source SHA-256: '+base.sha(source.encode())+'\ninclude "CursorSemantics.dfy"\n\nmodule AbiCursorSource {\n'
            '  import opened AbiFrames\n  import opened AbiEncoding\n  import opened AbiValidation\n'
            '  import opened AbiByteSemantics\n  import opened AbiBytesSource\n  import opened AbiCursorSemantics\n\n'+ '\n'.join(lower.lines)+'\n}\n')
    mapping['aggregateKernels'] = lower.spans
    mapping['aggregateBoundary'] = 'Selected arithmetic/guard/position/tail AST nodes only. Descriptor traversal and child validation are composed through explicit interfaces, not silently translated.'
    return text, bytecode, mask, mapping, request, output


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--solc', required=True, type=Path)
    parser.add_argument('--source', type=Path, default=ROOT/'contracts/lib/AbiCodec.sol')
    parser.add_argument('--output', required=True, type=Path)
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=False)
    text, bytecode, mask, mapping, request, output = generate(args.source.read_text(), args.solc)
    (args.output/'Cursors.generated.dfy').write_text(text)
    (args.output/'BytesBody.generated.dfy').write_text(bytecode)
    (args.output/'mask.smt2').write_text(mask)
    for name, value in [('correspondence.json', mapping), ('solc-input.json', request)]:
        (args.output/name).write_text(json.dumps(value, indent=2)+'\n')
    (args.output/'solc-output.json.gz').write_bytes(gzip.compress(json.dumps(output).encode(), mtime=0))


if __name__ == '__main__':
    main()
