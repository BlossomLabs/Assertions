#!/usr/bin/env python3
"""Bind the independent byte-membership specification to exact case-fold source AST."""
import argparse,hashlib,json,re
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
def generate(out):
 artifact=json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text());build=json.loads((ROOT/'artifacts/build-info'/(artifact['buildInfoId']+'.json')).read_text());output=json.loads((ROOT/'artifacts/build-info'/(artifact['buildInfoId']+'.output.json')).read_text())['output'];key=artifact['inputSourceName'];source=(ROOT/'contracts/Operations.sol').read_text();assert build['input']['sources'][key]['content']==source
 expected={'toLower':'functiontoLower(bytescalldatas)externalpurereturns(bytesmemory){return_foldCase(s,"A","Z");}',
 'toUpper':'functiontoUpper(bytescalldatas)externalpurereturns(bytesmemory){return_foldCase(s,"a","z");}',
 '_foldCase':'function_foldCase(bytescalldatas,bytes1low,bytes1high)privatepurereturns(bytesmemoryout){out=s;for(uint256i=0;i<out.length;i++){bytes1c=out[i];if(c>=low&&c<=high)out[i]=c^0x20;}}'}
 nodes={name:[] for name in expected}
 def walk(value):
  if isinstance(value,dict):
   if value.get('nodeType')=='FunctionDefinition' and value.get('name') in nodes:nodes[value['name']].append(value)
   for item in value.values():walk(item)
  elif isinstance(value,list):
   for item in value:walk(item)
 walk(output['sources'][key]['ast']);rows=[]
 for name,group in nodes.items():
  assert len(group)==1;node=group[0];assert node['stateMutability']=='pure';start,length,_=map(int,node['src'].split(':'));body=source.encode()[start:start+length].decode();compact=re.sub(r'\s+','',body);assert compact==expected[name],('Case-fold source semantics drift',name);rows.append(dict(name=name,bodySha256=hashlib.sha256(body.encode()).hexdigest(),exactNormalizedBody=compact))
 out.mkdir(parents=True,exist_ok=True);row=dict(source='contracts/Operations.sol',sourceSha256=hashlib.sha256(source.encode()).hexdigest(),buildInfoId=artifact['buildInfoId'],selectors=['c1459c04','feec0cff'],functions=rows);(out/'source-gate.json').write_text(json.dumps(row,indent=2)+'\n');print('PASS exact case-fold source AST/body gate; native proof pending')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);generate(p.parse_args().output)
