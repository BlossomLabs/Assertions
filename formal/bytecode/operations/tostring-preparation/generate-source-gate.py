#!/usr/bin/env python3
"""Bind the independent decimal specification to the exact two overloads and signed magnitude source AST."""
import argparse,hashlib,json,re
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
def generate(out):
 artifact=json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text());build=json.loads((ROOT/'artifacts/build-info'/(artifact['buildInfoId']+'.json')).read_text());output=json.loads((ROOT/'artifacts/build-info'/(artifact['buildInfoId']+'.output.json')).read_text())['output'];key=artifact['inputSourceName'];source=(ROOT/'contracts/Operations.sol').read_text();assert build['input']['sources'][key]['content']==source
 expected={'uint256':'functiontoString(uint256v)publicpurereturns(stringmemory){if(v==0)return"0";uint256digits;for(uint256t=v;t>0;t/=10){digits++;}bytesmemorybuf=newbytes(digits);for(uint256t=v;t>0;t/=10){digits--;buf[digits]=bytes1(uint8(48+(t%10)));}returnstring(buf);}',
 'int256':'functiontoString(int256value)externalpurereturns(stringmemory){returnstring.concat(value<0?"-":"",toString(_magnitude(value)));}',
 '_magnitude':'function_magnitude(int256value)privatepurereturns(uint256){unchecked{returnvalue<0?uint256(-(value+1))+1:uint256(value);}}'}
 nodes={name:[] for name in expected}
 def walk(value):
  if isinstance(value,dict):
   if value.get('nodeType')=='FunctionDefinition' and value.get('name') in {'toString','_magnitude'}:
    name=value['parameters']['parameters'][0]['typeDescriptions']['typeString'] if value['name']=='toString' else value['name'];nodes[name].append(value)
   for item in value.values():walk(item)
  elif isinstance(value,list):
   for item in value:walk(item)
 walk(output['sources'][key]['ast']);rows=[]
 for name,group in nodes.items():
  assert len(group)==1;node=group[0];assert node['stateMutability']=='pure';start,length,_=map(int,node['src'].split(':'));body=source.encode()[start:start+length].decode();compact=re.sub(r'\s+','',body);assert compact==expected[name],('Decimal source semantics drift',name);rows.append(dict(name=name,bodySha256=hashlib.sha256(body.encode()).hexdigest(),exactNormalizedBody=compact))
 out.mkdir(parents=True,exist_ok=True);row=dict(source='contracts/Operations.sol',sourceSha256=hashlib.sha256(source.encode()).hexdigest(),buildInfoId=artifact['buildInfoId'],selectors=['6900a3ae','a322c40e'],functions=rows);(out/'source-gate.json').write_text(json.dumps(row,indent=2)+'\n');print('PASS exact decimal source AST/body gate; native proof pending')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);generate(p.parse_args().output)
