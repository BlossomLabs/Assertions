#!/usr/bin/env python3
"""Bind the independent byte-membership specification to exact charset source AST."""
import argparse,hashlib,json,re
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
def generate(out):
 artifact=json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text());build=json.loads((ROOT/'artifacts/build-info'/(artifact['buildInfoId']+'.json')).read_text());output=json.loads((ROOT/'artifacts/build-info'/(artifact['buildInfoId']+'.output.json')).read_text())['output'];key=artifact['inputSourceName'];source=(ROOT/'contracts/Operations.sol').read_text();assert build['input']['sources'][key]['content']==source
 nodes=[]
 def walk(value):
  if isinstance(value,dict):
   if value.get('nodeType')=='FunctionDefinition' and value.get('name')=='charset':nodes.append(value)
   for item in value.values():walk(item)
  elif isinstance(value,list):
   for item in value:walk(item)
 walk(output['sources'][key]['ast']);assert len(nodes)==1;node=nodes[0];assert node['visibility']=='external' and node['stateMutability']=='pure' and len(node['parameters']['parameters'])==2 and len(node['returnParameters']['parameters'])==1
 start,length,_=map(int,node['src'].split(':'));body=source.encode()[start:start+length].decode();compact=re.sub(r'\s+','',body);expected='functioncharset(bytescalldatas,uint256mask)externalpurereturns(bool){for(uint256i=0;i<s.length;i++){if(mask&(uint256(1)<<uint8(s[i]))==0)returnfalse;}returntrue;}'
 assert compact==expected,'Charset source semantics drift';out.mkdir(parents=True,exist_ok=True);row=dict(source='contracts/Operations.sol',sourceSha256=hashlib.sha256(source.encode()).hexdigest(),bodySha256=hashlib.sha256(body.encode()).hexdigest(),buildInfoId=artifact['buildInfoId'],selector='3e8c97e3',parameters=['bytes calldata','uint256'],result='bool',loop='all original bytes, short-circuit false on a missing bit, true for empty bytes',exactNormalizedBody=compact);(out/'source-gate.json').write_text(json.dumps(row,indent=2)+'\n');print('PASS exact charset source AST/body byte-membership gate; native proof pending')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);generate(p.parse_args().output)
