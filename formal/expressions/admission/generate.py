#!/usr/bin/env python3
"""Gate evaluate's admission prefix; evaluation itself remains a separate obligation."""
import argparse,gzip,hashlib,importlib.util,json,subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
spec=importlib.util.spec_from_file_location('resolution_generator',HERE.parents[1]/'resolution/generate.py')
r=importlib.util.module_from_spec(spec);spec.loader.exec_module(r)

def generate(solc,root,out,bootstrap=False):
 if '0.8.36+commit.8a079791' not in subprocess.check_output([str(solc),'--version'],text=True):raise ValueError('Unpinned solc')
 sources={p:(root/p).read_text() for p in ['contracts/Expressions.sol','contracts/lib/AbiCodec.sol','contracts/lib/ERC8211.sol']}
 request={'language':'Solidity','sources':{p:{'content':s} for p,s in sources.items()},'settings':{'evmVersion':'cancun','outputSelection':{'*':{'':['ast']}}}}
 proc=subprocess.run([str(solc),'--standard-json'],input=json.dumps(request),capture_output=True,text=True,check=True);ast=json.loads(proc.stdout)
 if any(e['severity']=='error' for e in ast.get('errors',[])):raise ValueError(ast['errors'])
 contract=next(n for n in ast['sources']['contracts/Expressions.sol']['ast']['nodes'] if n.get('name')=='Expressions')
 function=r.nav.normalized_form(next(n for n in contract['nodes'] if n.get('name')=='evaluate'))
 slots={};guard=function['body']['statements'][1]
 slots['RESULT_CHECK']=r.expr(guard['condition'],{'expression.result':'result','count':'|nodes|'})
 guard['condition']={'slot':'RESULT_CHECK'}
 refs=[n for n in r.nav.shape.walk(function) if n.get('nodeType')=='BinaryOperation' and n.get('operator') in {'>=','>'} and n['leftExpression']['nodeType']=='IndexAccess']
 if len(refs)!=1:raise ValueError('Reference guard drift')
 ref=refs[0]
 if ref['leftExpression']['baseExpression'].get('memberName')!='refs' or ref['leftExpression']['indexExpression'].get('name')!='j' or ref['rightExpression'].get('name')!='i':raise ValueError('Reference expression drift')
 slots['REF_CHECK']='(refs[j] '+ref['operator']+' index)'
 ref.clear();ref.update({'slot':'REF_CHECK'})
 choices=[n for n in r.nav.shape.walk(function) if n.get('nodeType')=='BinaryOperation' and n['rightExpression'].get('value')=='3']
 if len(choices)!=1:raise ValueError('Select guard drift')
 slots['SELECT_COUNT']=r.expr(choices[0],{'node.refs':'node.refs'})
 choices[0].clear();choices[0].update({'slot':'SELECT_COUNT'})
 structure={'evaluate':function,'typesAndErrors':[r.nav.normalized_form(n) for n in contract['nodes'] if n['nodeType'] in {'StructDefinition','EnumDefinition','ErrorDefinition'}]}
 if bootstrap:(HERE/'structure.json').write_text(json.dumps(structure,indent=2)+'\n');return
 if structure!=json.loads((HERE/'structure.json').read_text()):raise ValueError('Unsupported admission source drift')
 out.mkdir(parents=True,exist_ok=True)
 text=(HERE/'Source.template.dfy').read_text().replace('$HASH',hashlib.sha256(sources['contracts/Expressions.sol'].encode()).hexdigest())
 for key,value in slots.items():text=text.replace('$'+key,value)
 if '$' in text:raise ValueError('Unexpanded template')
 (out/'Source.generated.dfy').write_text(text)
 (out/'solc-input.json').write_text(json.dumps(request));(out/'solc-output.json.gz').write_bytes(gzip.compress(proc.stdout.encode(),mtime=0))
 (out/'mapping.json').write_text(json.dumps({'scope':'evaluate admission prefix only; final evaluation/return not proved here','translatedSlots':slots,'sourceSha256':{p:hashlib.sha256(s.encode()).hexdigest() for p,s in sources.items()}},indent=2)+'\n')

if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--solc',type=Path,required=True);p.add_argument('--root',type=Path,default=ROOT);p.add_argument('--output',type=Path,required=True);p.add_argument('--bootstrap',action='store_true');a=p.parse_args();generate(a.solc,a.root,a.output,a.bootstrap)
