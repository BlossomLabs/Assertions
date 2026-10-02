#!/usr/bin/env python3
"""Instrument the proved recursive source adapter; check exact control erasure."""
import argparse,hashlib,json,re
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
def generate(root):
    original=(root/'formal/expressions/recursive/Source.generated.dfy').read_text()
    edits=[]
    def change(old,new):
        nonlocal text
        if text.count(old)!=1: raise ValueError('Ambiguous instrumentation: '+old)
        text=text.replace(old,new);edits.append((old,new))
    text=original
    change('include "Spec.dfy"','include "Model.dfy"')
    change('module ExpressionRecursiveSource {','module ExpressionFramesSource {')
    change('  import S = ExpressionRecursiveSpec','  import S = ExpressionRecursiveSpec\n  import F = ExpressionFramesModel')
    change('memo: map<nat,Value>, history: seq<Request>) returns (out: Result)',
           'memo: map<nat,Value>, history: seq<Request>, guardOwner: int) returns (out: Result, frames: seq<F.Frame>)')
    change('    requires Program(nodes) && index < |nodes| && Good(nodes,valid,memo)',
           '    requires Program(nodes) && index < |nodes| && Good(nodes,valid,memo)\n    requires F.Origin(nodes,index,guardOwner)')
    change('    decreases index\n  {','    ensures frames == F.Trace(nodes,valid,truth,reject,oracle,index,memo,history,guardOwner)\n    ensures F.Safe(nodes,valid,memo,history,index,frames)\n    ensures |frames| > 0 && frames[0] == F.Frame(index,memo,history,guardOwner)\n    decreases index\n  {\n    frames := [F.Frame(index,memo,history,guardOwner)];')
    sites=[('cond','node.refs[0]','working','seen','-1'),('selected','branch','cond.memo','cond.history','-1'),
           ('attempted','node.refs[0]','memo','history','index'),('fallback','node.refs[1]','working','seen','-1'),
           ('child','childIndex','working','seen','-1')]
    for name,idx,memo,history,owner in sites:
        indent=' '*(8 if name in {'fallback','child'} else 6)
        old=f'{indent}var {name} := Run(nodes,valid,truth,reject,oracle,{idx},{memo},{history});'
        new=f'{indent}var {name},{name}Frames := Run(nodes,valid,truth,reject,oracle,{idx},{memo},{history},{owner});\n{indent}F.Append(nodes,valid,memo,history,index,frames,{memo},{history},{idx},{name}Frames);\n{indent}frames := frames+{name}Frames;'
        change(old,new)
    change('        invariant |values| == pos','        invariant |values| == pos\n        invariant frames+F.GatherTrace(nodes,valid,truth,reject,oracle,index,pos,working,seen) == F.Trace(nodes,valid,truth,reject,oracle,index,memo,history,guardOwner)\n        invariant F.Safe(nodes,valid,memo,history,index,frames)\n        invariant |frames| > 0 && frames[0] == F.Frame(index,memo,history,guardOwner)')
    erased=text
    for old,new in reversed(edits):
        if erased.count(new)!=1:raise ValueError('Ambiguous erasure')
        erased=erased.replace(new,old)
    if erased!=original:raise ValueError('Control changed')
    return text,{'controlErasureExact':True,'sourceSha256':hashlib.sha256(original.encode()).hexdigest(),
                 'instrumentedCallSites':[x[0] for x in sites],'edits':[{'before':a,'after':b} for a,b in edits]}
def main():
    p=argparse.ArgumentParser();p.add_argument('--root',type=Path,default=ROOT);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
    text,mapping=generate(a.root);a.output.mkdir(parents=True,exist_ok=True)
    (a.output/'Source.generated.dfy').write_text(text)
    (a.output/'instrumentation.json').write_text(json.dumps(mapping,indent=2)+'\n')
if __name__=='__main__':main()
