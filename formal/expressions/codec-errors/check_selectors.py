#!/usr/bin/env python3
"""Bind the error byte constants and signatures to the actual solc AST."""
import argparse,json,re,subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
p=argparse.ArgumentParser();p.add_argument('--root',type=Path,default=ROOT);p.add_argument('--solc',type=Path,required=True);a=p.parse_args()
assert '0.8.36+commit.8a079791' in subprocess.check_output([str(a.solc),'--version'],text=True)
sources={s:{'content':(a.root/s).read_text()} for s in ['contracts/Expressions.sol','contracts/lib/AbiCodec.sol','contracts/lib/ERC8211.sol']}
request={'language':'Solidity','sources':sources,'settings':{'outputSelection':{'*':{'':['ast']}}}}
output=json.loads(subprocess.check_output([str(a.solc),'--standard-json'],input=json.dumps(request),text=True))
assert not any(e['severity']=='error' for e in output.get('errors',[]))
nodes=output['sources']['contracts/lib/AbiCodec.sol']['ast']['nodes']
contract=next(n for n in nodes if n.get('name')=='AbiCodec')
errors={n['name']:n for n in nodes+contract['nodes'] if n.get('nodeType')=='ErrorDefinition'}
expected={'InvalidValue':('InvalidValueSelector',['uint256']),'InvalidComponentLength':('LengthSelector',['uint256','uint256','uint256']),'InvalidComponentEnvelope':('EnvelopeSelector',['uint256','uint256','bytes32']),'InvalidComponentValue':('ComponentSelector',['uint256','uint256']),'ComponentCountMismatch':('CountSelector',['uint256','uint256']),'InvalidCallbackResult':('CallbackSelector',['bytes4','uint256','uint256','address']),'InvalidTypeDescriptor':('DescriptorSelector',['uint256'])}
for name,(fn,types) in expected.items():
 path=a.root/('formal/resolution/Model.dfy' if fn=='Signal' else 'formal/expressions/codec-errors/Encoding.dfy')
 m=re.search(r'function '+fn+r'\(\): seq<Byte> \{ \[([^\]]+)\] \}',path.read_text());assert m,name
 literal=bytes(int(x.strip(),0) for x in m[1].split(',')).hex()
 assert errors[name]['errorSelector']==literal,name
 assert [x['typeDescriptions']['typeString'] for x in errors[name]['parameters']['parameters']]==types,name
print(json.dumps({name:errors[name]['errorSelector'] for name in expected},indent=2))
