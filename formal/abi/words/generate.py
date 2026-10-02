#!/usr/bin/env python3
"""Extract wordRule/checkRule from solc AST and emit exhaustive SMT obligations."""
import argparse
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

import z3 as z
from yul import Interpreter, bv

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]


def name_byte(x):
    return z.Or(z.And(z.UGE(x, 48), z.ULE(x, 57)), z.And(z.UGE(x, 97), z.ULE(x, 122)))


def rules():
    return ([(f'uint{b}', 1, b) for b in range(8, 249, 8)] +
            [(f'int{b}', 2, b) for b in range(8, 249, 8)] +
            [(f'bytes{b}', 3, b*8) for b in range(1, 32)] +
            [('address', 1, 160), ('bool', 1, 1), ('function', 3, 192)])


def compile_ast(source, solc):
    version = subprocess.check_output([str(solc), '--version'], text=True)
    assert '0.8.36+commit.8a079791' in version
    request = {'language': 'Solidity', 'sources': {'AbiCodec.sol': {'content': source}},
               'settings': {'evmVersion': 'cancun', 'outputSelection': {'*': {'': ['ast']}}}}
    result = subprocess.run([str(solc), '--standard-json'], input=json.dumps(request), text=True, capture_output=True, check=True)
    output = json.loads(result.stdout)
    assert not any(e['severity'] == 'error' for e in output.get('errors', [])), output.get('errors')
    library = next(n for n in output['sources']['AbiCodec.sol']['ast']['nodes'] if n['nodeType'] == 'ContractDefinition')
    functions = {n['name']: n for n in library['nodes'] if n['nodeType'] == 'FunctionDefinition'}
    return request, output, functions


def tree(node):
    """Structural Yul form, excluding source positions and compiler node ids."""
    kind = node['nodeType']
    if kind == 'YulIdentifier':
        return node['name']
    if kind == 'YulLiteral':
        assert node['kind'] == 'number'
        return int(node['value'], 16 if node['value'].startswith('0x') else 10)
    if kind == 'YulFunctionCall':
        return [node['functionName']['name'], *map(tree, node['arguments'])]
    if kind == 'YulBlock':
        return list(map(tree, node['statements']))
    if kind in ('YulAssignment', 'YulVariableDeclaration'):
        names = node['variableNames'] if kind == 'YulAssignment' else node['variables']
        assert len(names) == 1
        return ['set' if kind == 'YulAssignment' else 'let', names[0]['name'], tree(node['value']) if node.get('value') else 0]
    if kind == 'YulForLoop':
        return ['for', tree(node['pre']), tree(node['condition']), tree(node['post']), tree(node['body'])]
    if kind == 'YulIf':
        return ['if', tree(node['condition']), tree(node['body'])]
    if kind == 'YulSwitch':
        return ['switch', tree(node['expression']), [[tree(c['value']) if c['value'] != 'default' else 'default', tree(c['body'])] for c in node['cases']]]
    if kind == 'YulBreak':
        return ['break']
    raise ValueError(('unsupported Yul skeleton', kind))


def scanners(functions, source_hash):
    """AST-checked loop certificates; two predicates normalized by SMT queries.

    This intentionally accepts just these complete loop skeletons. A change to
    control flow fails generation rather than silently reusing a certificate.
    The normalization and memory representation are trusted boundaries.
    """
    scan = functions['scanName']['body']['statements']
    assert len(scan) == 1
    scan_tree = tree(scan[0]['AST'])
    scan_tree[1][4][1][1] = '$name-predicate'
    assert scan_tree == [
        ['set', 'q', 'p'],
        ['for', [], ['lt', 'q', 'limit'], [], [
            ['let', 'c', ['byte', 0, ['calldataload', ['add', 't.offset', 'q']]]],
            ['if', '$name-predicate', [['break']]], ['set', 'q', ['add', 'q', 1]]]]]
    check = functions['checkRule']['body']['statements']
    assert len(check) == 3 and check[0]['initialValue']['name'] == 'n'
    assert [d['name'] for d in check[0]['declarations']] == ['bad']
    check_tree = tree(check[1]['AST'])
    check_tree[1][4][2] = '$word-predicate'
    assert check_tree == [
        ['let', 'src', ['add', ['add', 'v', 32], 'p']],
        ['for', [['let', 'i', 0]], ['lt', 'i', 'n'], [['set', 'i', ['add', 'i', 1]]], [
            ['let', 'x', ['mload', ['add', 'src', ['shl', 5, 'i']]]],
            ['let', 'ok', 0], '$word-predicate', ['if', ['iszero', 'ok'], [['set', 'bad', 'i'], ['break']]]]]]
    call = check[2]['expression']
    assert call['expression']['name'] == 'requireValue' and len(call['arguments']) == 3
    a, b, c = call['arguments']
    assert a['operator'] == '==' and a['leftExpression']['name'] == 'bad' and a['rightExpression']['name'] == 'n'
    assert b['operator'] == '+' and b['leftExpression']['name'] == 'p'
    product = b['rightExpression']
    assert product['operator'] == '*' and product['leftExpression']['name'] == 'bad' and product['rightExpression']['value'] == '32'
    assert c['name'] == 'context'
    return '''// SPDX-License-Identifier: MIT
// Generated from pinned solc AST by words/generate.py. Do not edit.
// Source SHA256: '''+source_hash+'''
// Loop skeletons checked exactly; predicates normalized by retained SMT proofs.
include "Semantics.dfy"

module AbiWordSource {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiValidation
  import opened AbiByteSemantics
  import opened AbiWordSemantics

  ghost method ScanName(t: seq<Byte>, p: nat, limit: nat) returns (q: nat)
    requires p <= limit <= |t| && Uint(|t|)
    ensures q == NameEnd(t,p,limit)
    ensures p <= q <= limit
  {
    q := p;
    while q < limit
      invariant p <= q <= limit
      invariant NameEnd(t,p,limit) == NameEnd(t,q,limit)
      decreases limit-q
    {
      var c := t[q];
      if !NameByte(c) { break; }
      assert Uint(q+1);
      q := q+1;
    }
  }

  ghost method CheckRule(rule: WordRule, v: seq<Byte>, p: nat, n: nat) returns (r: Outcome)
    requires ClassifiedRule(rule) && !rule.Opaque?
    requires p+32*n <= |v| && Uint(|v|)
    ensures r == (if FirstBad(rule,v,p,n,0) == n then Ok(0) else Invalid(p+32*FirstBad(rule,v,p,n,0)))
  {
    var bad := n;
    var i: nat := 0;
    while i < n
      invariant 0 <= i <= n && bad == n
      invariant FirstBad(rule,v,p,n,0) == FirstBad(rule,v,p,n,i)
      decreases n-i
    {
      assert Uint(p+32*i) && Uint(32*i);
      var x := ReadNat(v[p+32*i..p+32*i+32]);
      BytesNatRoundTrip(v[p+32*i..p+32*i+32]);
      var ok := CanonicalWord(rule,x);
      if !ok { bad := i; break; }
      assert Uint(i+1);
      i := i+1;
    }
    assert bad == FirstBad(rule,v,p,n,0);
    assert Uint(p+bad*32);
    if bad != n { r := Invalid(p+bad*32); return; }
    r := Ok(0);
  }
}
'''


def queries(functions):
    mem = z.Array('calldata', z.BitVecSort(256), z.BitVecSort(8))
    limit = z.BitVec('limit', 256)
    env = {'t.offset': bv(0), 's': bv(0), 'limit': limit, 'end': bv(0), 'kind': bv(0), 'bits': bv(0)}
    body = functions['wordRule']['body']['statements']
    assert len(body) == 2 and body[0]['nodeType'] == 'InlineAssembly'
    fallback = body[1]
    assert fallback['nodeType'] == 'IfStatement' and fallback.get('falseBody') is None
    condition = fallback['condition']
    assert condition['operator'] == '==' and condition['leftExpression']['name'] == 'end' and condition['rightExpression']['name'] == 's'
    assignment = fallback['trueBody']['expression']
    assert assignment['nodeType'] == 'Assignment' and assignment['operator'] == '=' and assignment['leftHandSide']['name'] == 'end'
    call = assignment['rightHandSide']
    assert call['expression']['name'] == 'scanName' and [n['name'] for n in call['arguments']] == ['t', 's', 'limit']
    interpreter = Interpreter(mem)
    interpreter.block(body[0]['AST'], env, z.BoolVal(True))
    assert len(interpreter.completion) == 1
    yield 'width-loop-complete', [], interpreter.completion[0], {'scope': 'All calldata and all uint256 limits; no residual fifth visit'}
    for length in range(1, 9):
        chars = [z.Select(mem, bv(i)) for i in range(length)]
        assumptions = [z.UGE(limit, bv(length)), *[name_byte(c) for c in chars],
                       z.Implies(z.UGT(limit, bv(length)), z.Not(name_byte(z.Select(mem, bv(length)))))]
        expected_kind, expected_bits = bv(0), bv(0)
        for name, kind, bits in rules():
            if len(name) == length:
                match = z.And(*[chars[i] == ord(c) for i, c in enumerate(name)])
                expected_kind = z.If(match, bv(kind), expected_kind)
                expected_bits = z.If(match, bv(bits), expected_bits)
        good = z.And(env['kind'] == expected_kind,
                     z.Implies(expected_kind != 0, env['bits'] == expected_bits),
                     z.Or(env['end'] == 0, env['end'] == bv(length)))
        yield f'name-length-{length}', assumptions, z.Not(good), {'scope': f'Every maximal lowercase/digit name of length {length}; arbitrary surrounding bytes'}
    assumptions = [z.UGE(limit, bv(9)), *[name_byte(z.Select(mem, bv(i))) for i in range(9)]]
    yield 'names-at-least-nine', assumptions, z.Or(env['kind'] != 0, env['end'] != 0), {'scope': 'Every name of length >=9; arbitrary remaining bytes; scanName fallback'}
    # Interpret the actual word predicate; the loop is handled by induction in Dafny.
    check = functions['checkRule']['body']['statements']
    assert len(check) == 3 and check[1]['nodeType'] == 'InlineAssembly'
    loop = check[1]['AST']['statements'][1]
    assert loop['nodeType'] == 'YulForLoop'
    switch = loop['body']['statements'][2]
    assert switch['nodeType'] == 'YulSwitch'
    x = z.BitVec('word', 256)
    for name, kind, bits in rules():
        rule_env = {'kind': bv(kind), 'bits': bv(bits), 'x': x, 'ok': bv(0)}
        Interpreter().statement(switch, rule_env, z.BoolVal(True), False)
        actual = rule_env['ok'] != 0
        if kind == 1:
            expected = z.ULT(x, bv(2**bits))
        elif kind == 2:
            expected = z.Or(z.ULT(x, bv(2**(bits-1))), z.UGE(x, bv(2**256-2**(bits-1))))
        else:
            expected = z.URem(x, bv(2**(256-bits))) == 0
        yield 'canonical-'+name, [], actual != expected, {'scope': 'All 256-bit words', 'kind': kind, 'bits': bits}
    scan = functions['scanName']['body']['statements']
    assert len(scan) == 1 and scan[0]['nodeType'] == 'InlineAssembly'
    scan_loop = scan[0]['AST']['statements'][1]
    reject = scan_loop['body']['statements'][1]
    assert reject['nodeType'] == 'YulIf' and reject['body']['statements'][0]['nodeType'] == 'YulBreak'
    c = z.BitVec('character', 8)
    bad = Interpreter().expr(reject['condition'], {'c': z.ZeroExt(248, c)}) != 0
    yield 'scan-name-character', [], bad != z.Not(name_byte(c)), {'scope': 'All 256 byte values'}


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--solc', required=True, type=Path)
    p.add_argument('--source', type=Path, default=ROOT/'contracts/lib/AbiCodec.sol')
    p.add_argument('--output', required=True, type=Path)
    args = p.parse_args()
    args.output.mkdir(parents=True, exist_ok=False)
    source = args.source.read_text()
    request, output, functions = compile_ast(source, args.solc)
    source_hash = hashlib.sha256(source.encode()).hexdigest()
    (args.output/'Scanners.generated.dfy').write_text(scanners(functions, source_hash))
    (args.output/'solc-input.json').write_text(json.dumps(request, indent=2)+'\n')
    (args.output/'solc-output.json.gz').write_bytes(gzip.compress(json.dumps(output).encode(), mtime=0))
    inventory = []
    for name, assumptions, failure, metadata in queries(functions):
        solver = z.Solver()
        solver.add(*assumptions, failure)
        (args.output/(name+'.smt2')).write_text('(set-option :timeout 30000)\n'+solver.to_smt2())
        inventory.append(dict(name=name, **metadata, expected='unsat'))
    (args.output/'queries.json').write_text(json.dumps(inventory, indent=2)+'\n')
    (args.output/'mapping.json').write_text(json.dumps({
        'sourceSha256': source_hash,
        'expressionLibrary': z.get_version_string(),
        'sourceFunctions': {k: {'id': functions[k]['id'], 'src': functions[k]['src']} for k in ('wordRule', 'checkRule', 'scanName')},
        'widthLoopVisits': 4, 'loopCompletionProvedSeparately': True,
        'calldata': 'Unconstrained symbolic byte array; descriptor-relative s=t.offset=0; pointer relocation trusted',
    }, indent=2)+'\n')


if __name__ == '__main__':
    main()
