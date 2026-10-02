#!/usr/bin/env python3
"""Reuse the checked Solidity AST boundary and strengthen parser correspondence."""
import argparse
import gzip
import importlib.util
import json
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
spec=importlib.util.spec_from_file_location('shape_generator',HERE.parent/'shape/generate.py')
shape=importlib.util.module_from_spec(spec);spec.loader.exec_module(shape)

def generate(source,solc):
    _,mapping,request,output=shape.generate(source,solc)
    text=(HERE/'Parser.template.dfy').read_text().replace('$HASH',mapping['sourceSha256'])
    for key,value in mapping['translatedSlots'].items():text=text.replace('$'+key,value)
    assert '$' not in text
    mapping['scope']='Full source-derived parser agrees with the recursive reference recognizer, including rejections and checked panics.'
    return text,mapping,request,output

def main():
    p=argparse.ArgumentParser();p.add_argument('--solc',required=True);p.add_argument('--source',type=Path,default=ROOT/'contracts/lib/AbiCodec.sol');p.add_argument('--output',type=Path,required=True);a=p.parse_args()
    text,mapping,request,output=generate(a.source.read_text(),a.solc)
    a.output.mkdir(parents=True,exist_ok=True)
    (a.output/'Parser.generated.dfy').write_text(text)
    (a.output/'mapping.json').write_text(json.dumps(mapping,indent=2)+'\n')
    (a.output/'solc-input.json').write_text(json.dumps(request))
    with gzip.open(a.output/'solc-output.json.gz','wt') as f:json.dump(output,f)
if __name__=='__main__':main()
