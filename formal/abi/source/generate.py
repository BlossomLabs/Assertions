#!/usr/bin/env python3
"""Lower the pinned solc AST bytes/string slice to a checked Dafny program.

This small, deliberately restricted translator is part of the trusted computing
base. Unknown syntax/types/callees fail closed. It never parses executable
Solidity with regex, copies a handwritten implementation, or inserts assumptions.
"""
import argparse
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

if not __debug__:
    raise RuntimeError('Run without Python -O: translator validation uses assertions')

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
SOLC_VERSION = '0.8.36+commit.8a079791'


def sha(data):
    return hashlib.sha256(data).hexdigest()


def unwrap(n):
    while n['nodeType'] == 'TupleExpression':
        assert len(n['components']) == 1 and not n['isInlineArray']
        n = n['components'][0]
    return n


def ident(n, name):
    return n['nodeType'] == 'Identifier' and n['name'] == name


def const(n, env):
    """Evaluate only the two descriptor branch predicates at literal types."""
    n = unwrap(n)
    k = n['nodeType']
    if k == 'Identifier':
        return env[n['name']]
    if k == 'Literal':
        return int(n['value']) if n['kind'] == 'number' else bytes.fromhex(n['hexValue'])[0]
    if k == 'IndexAccess':
        return const(n['baseExpression'], env)[const(n['indexExpression'], env)]
    if k == 'BinaryOperation':
        a, b = const(n['leftExpression'], env), const(n['rightExpression'], env)
        if n['operator'] == '-':
            assert 0 <= a-b < 2**256
            return a-b
        if n['operator'] == '==':
            return a == b
    raise ValueError(('unsupported constant branch', k))


def yul(n):
    k = n['nodeType']
    if k == 'YulIdentifier':
        return n['name']
    if k == 'YulLiteral':
        assert n['kind'] == 'number'
        return int(n['value'])
    if k == 'YulFunctionCall':
        return [n['functionName']['name'], *map(yul,n['arguments'])]
    raise ValueError(('unsupported Yul', k))


class Lower:
    def __init__(self, source, functions):
        self.source, self.functions = source, functions
        self.lines, self.spans, self.masks = [], [], []
        self.level, self.counter, self.mode, self.in_loop = 1, 0, '', False

    def emit(self, line):
        self.lines.append('  '*self.level + line)

    def temp(self):
        self.counter += 1
        return 'tmp'+str(self.counter)

    def origin(self, node):
        self.spans.append({'nodeId': node['id'], 'kind': node['nodeType'], 'src': node['src']})
        self.emit('// solc AST '+str(node['id'])+' @ '+node['src'])

    def checked(self, a, op, b):
        if op in ('/', '%'):
            self.emit(f'if {b} == 0 {{ r := Panic(18); return; }}')
        name = self.temp()
        self.emit(f'var {name}: int := {a} {op} {b};')
        self.emit(f'if !Uint({name}) {{ r := Panic(17); return; }}')
        return name

    def expression(self, node):
        n = unwrap(node)
        k = n['nodeType']
        if k == 'Identifier':
            assert n['name'] in ('v','data','p','n','padded','padding','i','end')
            return 'v' if n['name'] == 'data' else n['name']
        if k == 'Literal':
            assert n['kind'] in ('number','bool')
            if n['kind'] == 'number':
                assert 0 <= int(n['value']) < 2**256
            return n['value']
        if k == 'MemberAccess':
            assert n['memberName'] == 'length' and (ident(n['expression'],'v') or ident(n['expression'],'data'))
            return '|v|'
        if k == 'IndexAccess':
            assert ident(n['baseExpression'],'v')
            i = self.expression(n['indexExpression'])
            self.emit(f'if {i} < 0 || {i} >= |v| {{ r := Panic(50); return; }}')
            return f'v[{i}]'
        if k == 'BinaryOperation':
            op = n['operator']
            assert n['commonType']['typeString'] in ('uint256','bool','bytes1')
            if op in ('&&','||'):
                left = self.expression(n['leftExpression'])
                tmp = self.temp()
                self.emit(f'var {tmp}: bool := {left};')
                self.emit(f'if {"" if op == "&&" else "!"}{tmp} {{')
                self.level += 1
                right = self.expression(n['rightExpression'])
                self.emit(f'{tmp} := {right};')
                self.level -= 1
                self.emit('}')
                return tmp
            if op == '&':
                return self.mask(n)
            a, b = self.expression(n['leftExpression']), self.expression(n['rightExpression'])
            if op in ('+','-','*','/','%'):
                return self.checked(a,op,b)
            assert op in ('==','!=','<','<=','>','>=')
            return f'({a} {op} {b})'
        if k == 'FunctionCall':
            assert n['kind'] == 'functionCall' and not n['names'] and not n['tryCall']
            callee = n['expression']
            assert callee['nodeType'] == 'Identifier'
            name = callee['name']
            assert callee['referencedDeclaration'] == self.functions[name]['id']
            args = n['arguments']
            if name == 'word':
                assert len(args) == 3 and self.expression(args[0]) == 'v' and ident(args[2],'context')
                p = self.expression(args[1])
                method = 'ReadWord'
            elif name == 'body':
                assert self.mode == 'validate' and len(args) == 6
                assert ident(args[0],'t') and args[1]['value'] == '0'
                assert args[2]['nodeType'] == 'MemberAccess' and args[2]['memberName'] == 'length' and ident(args[2]['expression'],'t')
                assert ident(args[3],'v') and ident(args[5],'context')
                p = self.expression(args[4])
                method = 'BytesBody'
            else:
                raise ValueError(('unsupported expression call', name))
            tmp = self.temp()
            self.emit(f'var {tmp} := {method}(v,{p});')
            self.emit(f'if !{tmp}.Ok? {{ r := {tmp}; return; }}')
            return tmp+'.used'
        raise ValueError(('unsupported expression', k))

    def mask(self, n):
        # Only this bitwise operation is normalized. Its actual AST expression
        # is proved equal to remainder modulo 256^padding by 32 QF_BV queries.
        right = unwrap(n['rightExpression'])
        assert right['nodeType'] == 'BinaryOperation' and right['operator'] == '>>'
        maximum = unwrap(right['leftExpression'])
        assert maximum['nodeType'] == 'MemberAccess' and maximum['memberName'] == 'max'
        call = maximum['expression']
        assert call['nodeType'] == 'FunctionCall' and ident(call['expression'],'type')
        assert len(call['arguments']) == 1 and call['arguments'][0]['typeName']['name'] == 'uint256'
        self.masks.append(n)
        left = self.expression(n['leftExpression'])
        # Evaluate all checked shift-count arithmetic even after normalization.
        self.expression(right['rightExpression'])
        self.emit('assert 0 <= padding < 32;')
        self.emit('PaddingMask(v,p,n,padded);')
        return f'({left} % Pow256(padding))'

    def statement(self, node):
        self.origin(node)
        k = node['nodeType']
        if k == 'Block':
            for child in node['statements']:
                self.statement(child)
        elif k == 'VariableDeclarationStatement':
            assert len(node['declarations']) == 1
            decl = node['declarations'][0]
            assert decl['typeDescriptions']['typeString'] == 'uint256'
            name = decl['name']
            assert name in ('n','padded','padding','i','end')
            value = self.expression(node['initialValue'])
            self.emit(f'var {name}: int := {value};')
            if name == 'n':
                self.emit('RoundedExtent(n);')
            if name == 'padded':
                self.emit('assert padded == n+Padding(n);')
        elif k == 'ExpressionStatement':
            call = node['expression']
            if call['nodeType'] == 'UnaryOperation':
                assert call['operator'] == '++' and ident(call['subExpression'],'i')
                value = self.checked('i','+','1')
                self.emit(f'i := {value};')
                return
            assert call['nodeType'] == 'FunctionCall' and ident(call['expression'],'requireValue')
            assert call['expression']['referencedDeclaration'] == self.functions['requireValue']['id']
            assert len(call['arguments']) == 3 and ident(call['arguments'][2],'context')
            valid = self.expression(call['arguments'][0])
            offset = self.expression(call['arguments'][1])
            self.emit(f'if !({valid}) {{')
            self.level += 1
            if self.in_loop:
                self.emit('FirstDirtyAt(v,p+32+n,p+32+padded,p+32+i);')
            self.emit(f'r := Invalid({offset}); return;')
            self.level -= 1
            self.emit('}')
        elif k == 'IfStatement':
            valid = self.expression(node['condition'])
            self.emit(f'if {valid} {{')
            self.level += 1
            self.statement(node['trueBody'])
            self.level -= 1
            if node.get('falseBody'):
                self.emit('} else {')
                self.level += 1
                self.statement(node['falseBody'])
                self.level -= 1
            self.emit('}')
        elif k == 'ForStatement':
            assert not self.in_loop
            self.statement(node['initializationExpression'])
            cond = node['condition']
            assert cond['nodeType'] == 'BinaryOperation' and cond['operator'] in ('<','<=')
            assert ident(cond['leftExpression'],'i') and ident(cond['rightExpression'],'padded')
            self.emit(f'while i {cond["operator"]} padded')
            self.emit('  invariant n <= i <= padded')
            self.emit('  invariant Uint(i)')
            self.emit('  invariant ZeroRegion(v,p+32+n,p+32+i)')
            self.emit('  decreases padded-i')
            self.emit('{')
            self.level += 1
            self.in_loop = True
            self.statement(node['body'])
            self.statement(node['loopExpression'])
            self.in_loop = False
            self.level -= 1
            self.emit('}')
        elif k == 'Return':
            assert node.get('expression') is not None
            value = self.expression(node['expression'])
            if self.mode == 'body':
                self.emit('FirstDirtyCharacterization(v,p+32+n,p+32+padded);')
            self.emit(f'r := Ok({value}); return;')
        elif k == 'InlineAssembly':
            assert self.mode == 'word' and node['flags'] == ['memory-safe']
            statements = node['AST']['statements']
            assert len(statements) == 1
            a = statements[0]
            assert a['nodeType'] == 'YulAssignment' and [x['name'] for x in a['variableNames']] == ['v']
            assert yul(a['value']) == ['mload',['add',['add','data',32],'p']]
            self.emit('assert p+32 <= |v|;')
            self.emit('BytesNatRoundTrip(v[p..p+32]);')
            self.emit('r := Ok(ReadNat(v[p..p+32])); return;')
        else:
            raise ValueError(('unsupported statement', k))

    def method(self, mode, nodes):
        self.mode = mode
        name, spec = {'word':('ReadWord','WordSpec(v,p)'), 'body':('BytesBody','BodySpec(v,p)'),
                      'validate':('ValidateBytes','ValidationSpec(v)')}[mode]
        self.emit(f'ghost method {name}(v: seq<Byte>'+(', p: nat' if mode != 'validate' else '')+') returns (r: Outcome)')
        self.emit('  requires Uint(|v|)'+(' && Uint(p)' if mode != 'validate' else ''))
        self.emit(f'  ensures r == {spec}')
        if mode == 'word':
            self.emit('  ensures r.Ok? ==> Uint(r.used)')
        if mode == 'body':
            self.emit('  ensures r.Ok? ==> p+r.used <= |v|')
        self.emit('{')
        self.level += 1
        for n in nodes:
            self.statement(n)
        if mode == 'validate':
            self.emit('r := Ok(0);')
        self.level -= 1
        self.emit('}')


def mask_queries(node):
    def bv(n):
        n = unwrap(n)
        if n['nodeType'] == 'Literal' and n['kind'] == 'number':
            return f'(_ bv{int(n["value"])} 256)'
        if ident(n,'padding'):
            return 'padding'
        if n['nodeType'] == 'MemberAccess' and n['memberName'] == 'max':
            return f'(_ bv{2**256-1} 256)'
        if n['nodeType'] == 'BinaryOperation':
            op = {'+':'bvadd','-':'bvsub','*':'bvmul','>>':'bvlshr'}[n['operator']]
            return f'({op} {bv(n["leftExpression"])} {bv(n["rightExpression"])})'
        raise ValueError(('unsupported mask expression',n['nodeType']))
    formula = bv(node['rightExpression'])
    lines = ['(set-logic QF_BV)', '(declare-const w (_ BitVec 256))', '(declare-const padding (_ BitVec 256))']
    for count in range(32):
        lines += ['(push 1)',f'(assert (= padding (_ bv{count} 256)))',
                  f'(assert (not (= (bvand w {formula}) (bvurem w (_ bv{256**count} 256)))))',
                  '(check-sat)', '(pop 1)']
    return '\n'.join(lines)+'\n'


def generate(source, solc):
    version = subprocess.check_output([str(solc),'--version'],text=True)
    assert SOLC_VERSION in version
    request = {'language':'Solidity','sources':{'AbiCodec.sol':{'content':source}},
               'settings':{'evmVersion':'cancun','outputSelection':{'*':{'':['ast']}}}}
    proc = subprocess.run([str(solc),'--standard-json'],input=json.dumps(request),capture_output=True,text=True,check=True)
    output = json.loads(proc.stdout)
    assert not [e for e in output.get('errors',[]) if e['severity'] == 'error']
    contract = next(n for n in output['sources']['AbiCodec.sol']['ast']['nodes'] if n['nodeType']=='ContractDefinition' and n['name']=='AbiCodec')
    functions = {}
    for f in contract['nodes']:
        if f['nodeType']=='FunctionDefinition' and f['name'] in ('body','word','requireValue','validateDynamic'):
            if f['name']=='word' and len(f['parameters']['parameters'])!=3:
                continue
            assert f['stateMutability']=='pure' and not f['modifiers']
            functions[f['name']] = f
    assert set(functions) == {'body','word','requireValue','validateDynamic'}
    signatures = {
        'body': [('t','bytes'),('s','uint256'),('e','uint256'),('v','bytes'),('p','uint256'),('context','struct AbiCodec.Context')],
        'word': [('data','bytes'),('p','uint256'),('context','struct AbiCodec.Context')],
        'requireValue': [('valid','bool'),('offset','uint256'),('context','struct AbiCodec.Context')],
        'validateDynamic': [('t','bytes'),('v','bytes'),('context','struct AbiCodec.Context')],
    }
    for name,f in functions.items():
        assert [(p['name'],p['typeDescriptions']['typeString']) for p in f['parameters']['parameters']] == signatures[name]
        for p in f['parameters']['parameters']:
            assert p['storageLocation'] == ('calldata' if p['name'] == 't' else 'memory' if p['name'] in ('v','data','context') else 'default')
        assert [p['typeDescriptions']['typeString'] for p in f['returnParameters']['parameters']] == (['uint256'] if name in ('word','body') else [])
        assert not f['virtual'] and not f.get('overrides')
    assert functions['word']['returnParameters']['parameters'][0]['name'] == 'v'
    word_statements = functions['word']['body']['statements']
    assert word_statements[-1]['nodeType'] == 'InlineAssembly'
    assert all(n['nodeType'] != 'InlineAssembly' for n in word_statements[:-1])
    # Default ContextKind.Value only. Refuse changes to the helper until its
    # error-routing translation is reviewed; executable statements are pinned.
    req = functions['requireValue']
    begin, length, _ = map(int,req['src'].split(':'))
    expected = '''function requireValue(bool valid, uint256 offset, Context memory context) private pure {
        if (valid) return;
        if (context.kind == ContextKind.CallbackResult) {
            revert InvalidCallbackResult(context.operation, context.index, context.other, context.target);
        }
        if (context.kind == ContextKind.TupleComponent) revert InvalidComponentValue(context.index, offset);
        revert InvalidValue(offset);
    }'''
    assert source.encode()[begin:begin+length].decode() == expected, 'requireValue helper changed'
    body = functions['body']['body']['statements']
    assert body[1]['nodeType'] == body[2]['nodeType'] == 'IfStatement'
    for desc in (b'bytes',b'string'):
        env = {'t':desc,'s':0,'e':len(desc)}
        for branch in body[1:3]:
            assert not branch.get('falseBody') and const(branch['condition'],env) is False
    lower = Lower(source, functions)
    lower.method('word',functions['word']['body']['statements'])
    lower.method('body',[body[0],*body[3:]])
    lower.method('validate',functions['validateDynamic']['body']['statements'])
    assert len(lower.masks)==1
    text = ('// SPDX-License-Identifier: MIT\n// GENERATED by generate.py from solc '+SOLC_VERSION+' AST. Do not edit.\n'
            '// Source SHA-256: '+sha(source.encode())+'\ninclude "ByteSemantics.dfy"\n\nmodule AbiBytesSource {\n'
            '  import opened AbiFrames\n  import opened AbiEncoding\n  import opened AbiValidation\n  import opened AbiByteSemantics\n\n'
            +'\n'.join(lower.lines)+'\n}\n')
    correspondence = {'compiler':SOLC_VERSION,'sourceSha256':sha(source.encode()),
                      'scope':'body bytes/string branch at t=bytes|string, s=0, e=t.length; validateDynamic; word; ContextKind.Value',
                      'functions':{name:{'id':f['id'],'src':f['src']} for name,f in functions.items()},
                      'loweredNodes':lower.spans,'maskQueries':32,
                      'trustedBoundary':['solc typed AST and this restricted AST translator',
                         'Valid bytes-memory representation and in-bounds MLOAD big-endian semantics',
                         'Sufficient gas; no allocation, compiler-correctness or bytecode proof']}
    return text, mask_queries(lower.masks[0]), correspondence, request, output


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--solc',required=True,type=Path)
    p.add_argument('--source',type=Path,default=ROOT/'contracts/lib/AbiCodec.sol')
    p.add_argument('--output',required=True,type=Path)
    args=p.parse_args()
    args.output.mkdir(parents=True,exist_ok=False)
    text,smt,mapping,request,output = generate(args.source.read_text(),args.solc)
    (args.output/'BytesBody.generated.dfy').write_text(text)
    (args.output/'mask.smt2').write_text(smt)
    for name,value in [('correspondence.json',mapping),('solc-input.json',request)]:
        (args.output/name).write_text(json.dumps(value,indent=2)+'\n')
    (args.output/'solc-output.json.gz').write_bytes(gzip.compress(json.dumps(output).encode(), mtime=0))


if __name__=='__main__':
    main()
