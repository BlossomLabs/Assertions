#!/usr/bin/env python3
"""Translate the checkWords recursion/copy schedule through a full AST gate."""
import argparse
import gzip
import hashlib
import importlib.util
import json
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
spec=importlib.util.spec_from_file_location('shape_generator',HERE.parent/'shape/generate.py')
shape=importlib.util.module_from_spec(spec);spec.loader.exec_module(shape)

def expr(n):
    k=n['nodeType']
    if k=='Identifier':
        assert n['name'] in ('p','words','i','count','copies')
        return n['name']
    if k=='Literal':return str(int(n['value'],0))
    if k=='BinaryOperation':
        assert n['operator'] in ('+','-','*','==')
        return '('+expr(n['leftExpression'])+' '+n['operator']+' '+expr(n['rightExpression'])+')'
    if k=='Conditional':return '(if '+expr(n['condition'])+' then '+expr(n['trueExpression'])+' else '+expr(n['falseExpression'])+')'
    raise ValueError(k)

def generate(source,solc):
    _,prior,request,output=shape.generate(source,solc)
    contract=next(n for n in output['sources']['AbiCodec.sol']['ast']['nodes'] if n['nodeType']=='ContractDefinition')
    fs={n['name']:n for n in contract['nodes'] if n['nodeType']=='FunctionDefinition'}
    tree=shape.form(fs['checkWords']);slots={}
    for n in shape.walk(tree):
        if n.get('nodeType')=='ForStatement':
            value=n['initializationExpression']['initialValue'];slots['COPY_START']=expr(value)
            n['initializationExpression']['initialValue']={'slot':'COPY_START'}
        if n.get('nodeType')=='FunctionCall' and n['expression'].get('name')=='checkWords':
            args=n['arguments']
            if args[3].get('nodeType')=='Conditional':
                slots['FIRST_COUNT']=expr(args[3]);args[3]={'slot':'FIRST_COUNT'}
                slots['FIRST_CURSOR']=expr(args[5]);args[5]={'slot':'FIRST_CURSOR'}
            else:
                slots['COPY_CURSOR']=expr(args[5]);args[5]={'slot':'COPY_CURSOR'}
        if n.get('nodeType')=='Assignment' and n['leftHandSide'].get('name')=='words' and n['operator'] in ('*=','+=') and n['rightHandSide'].get('name')=='copies':
            slots['FINAL_WORDS']='(words '+n['operator'][0]+' copies)';n['operator']='$FINAL_OPERATOR'
    structure={'checkWords':tree,'checkRule':shape.form(fs['checkRule']),'suffixes':shape.form(fs['suffixes'])}
    assert structure==json.loads((HERE/'structure.json').read_text()),'Unsupported checkWords source drift'
    assert set(slots)=={'COPY_START','COPY_CURSOR','FIRST_COUNT','FIRST_CURSOR','FINAL_WORDS'}
    text=(HERE/'CheckWords.template.dfy').read_text().replace('$HASH',hashlib.sha256(source.encode()).hexdigest())
    for name,value in slots.items():text=text.replace('$'+name,value)
    assert '$' not in text
    mapping={'sourceSha256':prior['sourceSha256'],'functions':{n:{'id':fs[n]['id'],'src':fs[n]['src']} for n in ('checkWords','checkRule','suffixes','wordRule')},'translatedSlots':slots,
      'normalizations':['Recursive reverts are explicit Outcome propagation; do/while is a loop with a trailing condition.',
        'Tuple first pass is factored as TupleOnce. Ghost descriptor witnesses do not compute machine outputs.',
        'wordRule maps through the separately exhaustive SMT whitelist, with arbitrary calldata surroundings.',
        'checkRule at n=0 has an unreachable MLOAD loop body and requires no in-allocation data origin.']}
    return text,mapping,request,output

def main():
    p=argparse.ArgumentParser();p.add_argument('--solc',required=True);p.add_argument('--source',type=Path,default=ROOT/'contracts/lib/AbiCodec.sol');p.add_argument('--output',type=Path,required=True);a=p.parse_args()
    text,mapping,request,output=generate(a.source.read_text(),a.solc)
    a.output.mkdir(parents=True,exist_ok=True)
    (a.output/'CheckWords.generated.dfy').write_text(text)
    (a.output/'mapping.json').write_text(json.dumps(mapping,indent=2)+'\n')
    (a.output/'solc-input.json').write_text(json.dumps(request))
    with gzip.open(a.output/'solc-output.json.gz','wt') as f:json.dump(output,f)
if __name__=='__main__':main()
