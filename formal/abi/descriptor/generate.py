#!/usr/bin/env python3
"""Translate the validated static suffix loop, retaining modulo-256 arithmetic.

The complete loop skeleton is checked; arithmetic expressions are translated
from the typed AST. Ghost syntax witnesses and invariants do not decide results.
"""
import argparse
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]


def form(n):
    k = n['nodeType']
    if k == 'Identifier':
        return n['name']
    if k == 'Literal':
        assert n['kind'] == 'number'
        return int(n['value'], 0)
    if k == 'BinaryOperation':
        return [n['operator'], form(n['leftExpression']), form(n['rightExpression'])]
    if k == 'UnaryOperation':
        return [n['operator'], n['prefix'], form(n['subExpression'])]
    if k == 'FunctionCall':
        return ['call', form(n['expression']), *map(form, n['arguments'])]
    if k == 'TupleExpression':
        return ['tuple', *[form(c) if c else None for c in n['components']]]
    if k == 'Assignment':
        return [n['operator'], form(n['leftHandSide']), form(n['rightHandSide'])]
    if k == 'ExpressionStatement':
        return form(n['expression'])
    if k in ('Block', 'UncheckedBlock'):
        return [k, *map(form, n['statements'])]
    if k == 'WhileStatement':
        return ['while', form(n['condition']), form(n['body'])]
    if k == 'VariableDeclarationStatement':
        return ['var', [[d['name'], d['typeDescriptions']['typeString']] for d in n['declarations']],
                form(n['initialValue']) if n.get('initialValue') else None]
    if k == 'IfStatement':
        return ['if', form(n['condition']), form(n['trueBody']), form(n['falseBody']) if n.get('falseBody') else None]
    if k == 'Return':
        return ['return', form(n['expression'])]
    raise ValueError('Unsupported AST: '+k)


def expr(n):
    k = n['nodeType']
    if k == 'Identifier':
        assert n['name'] in ('k', 'end', 'product')
        return n['name']
    if k == 'Literal':
        assert n['kind'] == 'number'
        return str(int(n['value'], 0))
    if k == 'FunctionCall':
        assert form(n) == ['call', 'byteAt', 't', 'end']
        return 't[end]'
    if k == 'BinaryOperation':
        assert n['operator'] in ('+', '-', '*')
        assert n['commonType']['typeString'] == 'uint256'
        return f'(({expr(n["leftExpression"])} {n["operator"]} {expr(n["rightExpression"])}) % Limit())'
    raise ValueError('Unsupported arithmetic: '+k)


def generate(source, solc):
    assert '0.8.36+commit.8a079791' in subprocess.check_output([str(solc), '--version'], text=True)
    request = {'language': 'Solidity', 'sources': {'AbiCodec.sol': {'content': source}},
               'settings': {'evmVersion': 'cancun', 'outputSelection': {'*': {'': ['ast']}}}}
    proc = subprocess.run([str(solc), '--standard-json'], input=json.dumps(request), capture_output=True, text=True, check=True)
    output = json.loads(proc.stdout)
    assert not any(e['severity'] == 'error' for e in output.get('errors', []))
    contract = next(n for n in output['sources']['AbiCodec.sol']['ast']['nodes'] if n['nodeType'] == 'ContractDefinition')
    fs = {n['name']: n for n in contract['nodes'] if n['nodeType'] == 'FunctionDefinition'}
    const = {n['name']: form(n['value']) for n in contract['nodes'] if n['nodeType'] == 'VariableDeclaration' and n['name'] in ('LPAREN','LBRACKET','RBRACKET')}
    assert const == {'LPAREN':40, 'LBRACKET':91, 'RBRACKET':93}
    body = fs['suffixes']['body']
    assert [n['typeDescriptions']['typeString'] for n in fs['suffixes']['parameters']['parameters']] == ['bytes','uint256','uint256']
    nodes = body['statements']
    outer = nodes[1]['statements'][0]
    inner = outer['body']['statements'][1]
    update = inner['body']['statements'][0]['expression']
    initial = nodes[0]['expression']['rightHandSide']
    product = outer['body']['statements'][3]['expression']
    # Only arithmetic slots are variable. Every increment, guard, return and
    # unchecked-block boundary must have the expected full source structure.
    tree = form(body)
    tree[1][2] = '$initial'
    tree[2][1][2][2][2][1][2] = '$digit'
    tree[2][1][2][4] = '$product'
    assert tree == ['Block', ['=', 'product', '$initial'], ['UncheckedBlock',
        ['while', ['&&', ['<', 'end', 'limit'], ['==', ['call','byteAt','t','end'], 'LBRACKET']],
         ['Block', ['var', [['k','uint256']], None],
          ['while', ['!=', ['call','byteAt','t',['++',True,'end']], 'RBRACKET'],
           ['Block', ['=','k','$digit']]], ['++',False,'end'], '$product']]],
        ['return',['tuple','end','product']]]
    assert product['operator'] in ('*=', '+=') and form(product['leftHandSide']) == 'product'
    product_expr = f'((product {product["operator"][0]} {expr(product["rightHandSide"])}) % Limit())'
    # byteAt's actual body must remain the unchecked calldata-byte projection.
    a = fs['byteAt']['body']['statements']
    assert len(a) == 1 and a[0]['nodeType'] == 'InlineAssembly'
    y = a[0]['AST']['statements']
    def yform(n):
        if n['nodeType'] == 'YulIdentifier': return n['name']
        if n['nodeType'] == 'YulLiteral': return int(n['value'],0)
        if n['nodeType'] == 'YulFunctionCall': return [n['functionName']['name'], *map(yform,n['arguments'])]
        raise ValueError(n['nodeType'])
    assert len(y) == 1 and y[0]['nodeType'] == 'YulAssignment'
    assert [x['name'] for x in y[0]['variableNames']] == ['c']
    assert yform(y[0]['value']) == ['byte',0,['calldataload',['add','t.offset','i']]]
    assert len(fs['checkWords']['body']['statements']) == 1
    dispatch = fs['checkWords']['body']['statements'][0]
    assert form(dispatch['condition']) == ['==',['call','byteAt','t','s'],'LPAREN']
    word_branch = dispatch['falseBody']
    assert form(word_branch) == ['Block',
        ['var', [['kind','uint256']], None], ['var', [['bits','uint256']], None],
        ['=', ['tuple','end','kind','bits'], ['call','wordRule','t','s','limit']],
        ['=', 'words', 1],
        ['if', ['<','end','limit'], ['=', ['tuple','end','words'], ['call','suffixes','t','end','limit']], None],
        ['if', ['!=','kind',0], ['call','checkRule','kind','bits',['*','words','count'],'v','p','context'], None]]
    text = TEMPLATE.replace('$HASH', hashlib.sha256(source.encode()).hexdigest()).replace('$INITIAL',expr(initial)).replace('$DIGIT',expr(update['rightHandSide']).replace('t[end]','c')).replace('$PRODUCT',product_expr)
    mapping = {'sourceSha256':hashlib.sha256(source.encode()).hexdigest(),
               'functions': {n:{'id':fs[n]['id'],'src':fs[n]['src']} for n in ('suffixes','byteAt','checkWords')},
               'suffixSkeleton':form(body), 'arithmetic':'Each unchecked uint256 operation is reduced modulo 2^256; proof establishes no wrap on the syntax domain.',
               'boundary':'Valid static suffix syntax and product <2^32 are premises, not inferred from typeShape. Calldata projection/relocation and translator remain trusted.'}
    return text, mapping, request, output


TEMPLATE = '''// SPDX-License-Identifier: MIT
// Generated from the complete suffixes AST skeleton. Do not edit.
// Source SHA256: $HASH
include "Semantics.dfy"

module AbiSuffixSource {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiByteSemantics
  import opened AbiSuffixSemantics

  ghost method Digit(k: nat, c: Byte) returns (next: nat)
    requires k < 0x100000000 && 48 <= c <= 57
    ensures next == 10*k+c-48
  {
    DecimalMachineStep(k,c);
    next := $DIGIT;
    // A reachable nonzero prefix also gives a direct fault-sensitivity witness.
    if k == 1 && c == 48 { assert next == 10; }
  }

  ghost method ReadSuffix(t: seq<Byte>, start: nat, ds: seq<Byte>)
    returns (end: nat, k: nat)
    requires Uint(|t|) && Digits(ds) && Decimal(ds) < 0x100000000
    requires start+2+|ds| <= |t|
    requires t[start+1..start+1+|ds|] == ds && t[start+1+|ds|] == 93
    ensures end == start+2+|ds| && k == Decimal(ds)
  {
    end := start;
    k := 0;
    var i: nat := 0;
    while true
      invariant 0 <= i <= |ds| && end == start+i
      invariant k == Decimal(ds[..i])
      decreases |ds|-i
    {
      NoWrap(end+1);
      end := (end+1)%Limit();
      assert end == start+i+1;
      if t[end] == 93 {
        if i < |ds| { assert t[end] == ds[i]; }
        assert i == |ds| && ds[..i] == ds;
        break;
      }
      assert i < |ds| && t[end] == ds[i];
      DecimalStep(ds,i);
      DecimalPrefix(ds,i);
      k := Digit(k,t[end]);
      i := i+1;
    }
    NoWrap(end+1);
    end := (end+1)%Limit();
  }

  ghost method {:isolate_assertions} Suffixes(t: seq<Byte>, start: nat, limit: nat, ss: seq<seq<Byte>>)
    returns (end: nat, product: nat)
    requires Uint(|t|) && At(t,start,limit,ss)
    requires SuffixList(ss) && Product(ss) < 0x100000000
    ensures end == start+|Text(ss)| && product == Product(ss)
    ensures end <= limit && 0 < product < 0x100000000
  {
    assert Limit() > 0x100000000;
    end := start;
    product := $INITIAL;
    var remaining := ss;
    while end < limit && t[end] == 91
      invariant At(t,end,limit,remaining) && SuffixList(remaining)
      invariant end+|Text(remaining)| == start+|Text(ss)|
      invariant 0 < product && product*Product(remaining) == Product(ss)
      decreases |remaining|
    {
      assert |remaining| > 0;
      SuffixStep(t,end,limit,remaining);
      var opening := end;
      var ds := remaining[0];
      var k: nat;
      end, k := ReadSuffix(t,end,ds);
      assert Product(remaining) == k*Product(remaining[1..]);
      ExtendProduct(product,k,Product(remaining[1..]),Product(ss));
      var nextProduct := product*k;
      NoWrap(product*k);
      product := $PRODUCT;
      assert product == nextProduct;
      assert product*Product(remaining[1..]) == Product(ss);
      remaining := remaining[1..];
    }
    assert |remaining| == 0;
  }
}
'''


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--solc', required=True, type=Path)
    p.add_argument('--source', type=Path, default=ROOT/'contracts/lib/AbiCodec.sol')
    p.add_argument('--output', required=True, type=Path)
    a = p.parse_args()
    a.output.mkdir(parents=True,exist_ok=False)
    text,mapping,request,output = generate(a.source.read_text(),a.solc)
    (a.output/'Suffixes.generated.dfy').write_text(text)
    for name,data in [('mapping.json',mapping),('solc-input.json',request)]:
        (a.output/name).write_text(json.dumps(data,indent=2)+'\n')
    (a.output/'solc-output.json.gz').write_bytes(gzip.compress(json.dumps(output).encode(),mtime=0))


if __name__ == '__main__':
    main()
