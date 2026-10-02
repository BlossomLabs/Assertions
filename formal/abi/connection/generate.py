#!/usr/bin/env python3
"""AST-gated suffix search, static validation and body descriptor/head preludes."""
import argparse
import gzip
import hashlib
import importlib.util
import json
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
spec=importlib.util.spec_from_file_location('tuple_generator',HERE.parent/'tuples/generate.py')
prior=importlib.util.module_from_spec(spec);spec.loader.exec_module(prior)
shape=prior.shape

def expr(n, aliases=None):
    aliases=aliases or {}
    k=n['nodeType']
    if k=='Literal':
        return str(ord(n['value'])) if n['kind']=='string' else str(int(n['value'],0))
    if k=='Identifier':return aliases.get(n['name'],n['name'])
    if k=='MemberAccess':
        name=n['expression']['name']+'.'+n['memberName']
        assert name in aliases,name
        return aliases[name]
    if k=='IndexAccess':
        assert n['baseExpression'].get('name')=='t'
        return 'c'
    if k=='FunctionCall':
        assert n['kind']=='typeConversion' and n['expression']['typeName']['name']=='uint8'
        return expr(n['arguments'][0],aliases)
    if k=='BinaryOperation':
        assert n['operator'] in ('+','-','*','/','%','==','!=','&&','||','>=','<=')
        return '('+expr(n['leftExpression'],aliases)+' '+n['operator']+' '+expr(n['rightExpression'],aliases)+')'
    raise ValueError(k)

def generate(source,solc,bootstrap=False):
    _,_,request,output=prior.generate(source,solc)
    contract=next(n for n in output['sources']['AbiCodec.sol']['ast']['nodes'] if n['nodeType']=='ContractDefinition')
    fs={n['name']:n for n in contract['nodes'] if n['nodeType']=='FunctionDefinition'}
    suffix=shape.form(fs['suffixStart']);static=shape.form(fs['validateStatic']);body=shape.form(fs['body'])
    slots={}
    initial=suffix['body']['statements'][0]['expression']
    slots['LAST_CANDIDATE']=expr(initial['rightHandSide']);initial['rightHandSide']={'slot':'LAST_CANDIDATE'}
    cond=suffix['body']['statements'][1]['condition']
    # Source short-circuit guard j > ts is retained in the structural gate.
    assert cond['operator']=='&&' and cond['leftExpression']['operator']=='&&'
    low=cond['leftExpression']['rightExpression'];high=cond['rightExpression']
    slots['DIGIT_GUARD']='('+expr(low)+' && '+expr(high)+')'
    cond['leftExpression']['rightExpression']={'slot':'DIGIT_LOW'};cond['rightExpression']={'slot':'DIGIT_HIGH'}
    check=suffix['body']['statements'][2]['condition'];assert check['operator']=='!='
    slots['OPENING_GUARD']='('+expr(check['leftExpression'])+' == '+expr(check['rightExpression'])+')'
    check['rightExpression']={'slot':'OPENING_BYTE'}
    call=static['body']['statements'][0]['expression']
    slots['LENGTH_GUARD']=expr(call['arguments'][0],{'v.length':'length'})
    call['arguments'][0]={'slot':'LENGTH_GUARD'}
    count_found=False;next_found=False
    for n in shape.walk(body):
        if n.get('nodeType')!='Assignment':continue
        lhs=n['leftHandSide'];rhs=n['rightHandSide']
        if lhs.get('nodeType')=='MemberAccess' and lhs['memberName']=='count' and rhs.get('nodeType')=='BinaryOperation':
            assert not count_found;count_found=True
            slots['COUNT_DIGIT']=expr(rhs,{'x.count':'count'});n['rightHandSide']={'slot':'COUNT_DIGIT'}
        if lhs.get('nodeType')=='MemberAccess' and lhs['memberName']=='j' and rhs.get('nodeType')=='BinaryOperation' and rhs['leftExpression'].get('name')=='next' and not next_found:
            next_found=True;slots['TUPLE_NEXT']=expr(rhs);n['rightHandSide']={'slot':'TUPLE_NEXT'}
    dispatch=[shape.form(n) for n in contract['nodes'] if n['nodeType']=='FunctionDefinition' and n['name']=='validate']
    structure={'suffixStart':suffix,'validateStatic':static,'validateDispatch':dispatch,'body':body}
    if bootstrap:return structure
    assert structure==json.loads((HERE/'structure.json').read_text()),'Unsupported connection source drift'
    assert set(slots)=={'LAST_CANDIDATE','DIGIT_GUARD','OPENING_GUARD','LENGTH_GUARD','COUNT_DIGIT','TUPLE_NEXT'}
    text=(HERE/'Bridge.template.dfy').read_text().replace('$HASH',hashlib.sha256(source.encode()).hexdigest())
    for name,value in slots.items():text=text.replace('$'+name,value)
    assert '$' not in text
    mapping={'sourceSha256':hashlib.sha256(source.encode()).hexdigest(),'translatedSlots':slots,'functions':{n:{'id':fs[n]['id'],'src':fs[n]['src']} for n in ('suffixStart','validateStatic','body')},
      'scope':'Full suffixStart and validateStatic; static validate dispatch; array descriptor/count/head prelude and first tuple head-sizing pass of body. Recursive body validation and second tuple pass remain separate.',
      'normalizations':['Short-circuit suffix loop is factored with a digit predicate and trailing break. Raw helper domain requires safely indexed bounds; parsed array syntax establishes them.',
        'Source state-struct zero initialization becomes explicit locals. Decimal accumulation and first-pass tuple cursor update are separate checked arithmetic obligations.',
        'Value-context reverts are explicit Outcome values; descriptor errors use SuffixResult. Existing proved parser, word scanner and head kernels are called through their verified contracts.']}
    return text,mapping,request,output

def main():
    p=argparse.ArgumentParser();p.add_argument('--solc',required=True);p.add_argument('--source',type=Path,default=ROOT/'contracts/lib/AbiCodec.sol');p.add_argument('--output',type=Path,required=True);a=p.parse_args()
    text,mapping,request,output=generate(a.source.read_text(),a.solc)
    a.output.mkdir(parents=True,exist_ok=True)
    (a.output/'Bridge.generated.dfy').write_text(text)
    (a.output/'mapping.json').write_text(json.dumps(mapping,indent=2)+'\n')
    (a.output/'solc-input.json').write_text(json.dumps(request))
    with gzip.open(a.output/'solc-output.json.gz','wt') as f:json.dump(output,f)
if __name__=='__main__':main()
