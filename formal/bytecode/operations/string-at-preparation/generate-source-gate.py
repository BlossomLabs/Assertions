#!/usr/bin/env python3
"""Bind the independent decimal specification to the exact stringAt, signed indexing and shared UTF8 validator source AST."""
import argparse,hashlib,json,re
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
def generate(out):
 artifact=json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text());build=json.loads((ROOT/'artifacts/build-info'/(artifact['buildInfoId']+'.json')).read_text());output=json.loads((ROOT/'artifacts/build-info'/(artifact['buildInfoId']+'.output.json')).read_text())['output'];key=artifact['inputSourceName'];source=(ROOT/'contracts/Operations.sol').read_text();assert build['input']['sources'][key]['content']==source
 expected={'stringAt': 'functionstringAt(bytescalldatadata,int256index)externalpurereturns(bytesmemory){_checkUtf8(data);uint256position=_strictIndex(index,data.length);if(uint8(data[position])>=0x80)revertInvalidUtf8(position);returndata[position:position+1];}', '_strictIndex': 'function_strictIndex(int256index,uint256length)privatepurereturns(uint256){if(index>=int256(length)||index<-int256(length))revertInvalidByteIndex(index,length);returnindex<0?uint256(int256(length)+index):uint256(index);}', '_checkUtf8': 'function_checkUtf8(bytescalldatadata)privatepure{for(uint256i;i<data.length;){uint8first=uint8(data[i]);if(first<0x80){i++;continue;}uint256count;if(first>=0xc2&&first<=0xdf)count=1;elseif(first>=0xe0&&first<=0xef)count=2;elseif(first>=0xf0&&first<=0xf4)count=3;elserevertInvalidUtf8(i);if(data.length-i<=count)revertInvalidUtf8(i);uint8second=uint8(data[i+1]);if((first==0xe0&&second<0xa0)||(first==0xed&&second>=0xa0)||(first==0xf0&&second<0x90)||(first==0xf4&&second>=0x90))revertInvalidUtf8(i+1);for(uint256j=1;j<=count;j++){if(uint8(data[i+j])&0xc0!=0x80)revertInvalidUtf8(i+j);}i+=count+1;}}'}
 nodes={name:[] for name in expected}
 def walk(value):
  if isinstance(value,dict):
   if value.get('nodeType')=='FunctionDefinition' and value.get('name') in set(expected):
    name=value['name'];nodes[name].append(value)
   for item in value.values():walk(item)
  elif isinstance(value,list):
   for item in value:walk(item)
 walk(output['sources'][key]['ast']);rows=[]
 for name,group in nodes.items():
  assert len(group)==1;node=group[0];assert node['stateMutability']=='pure';start,length,_=map(int,node['src'].split(':'));body=source.encode()[start:start+length].decode();compact=re.sub(r'\s+','',body);assert compact==expected[name],('UTF8 stringAt source semantics drift',name);rows.append(dict(name=name,bodySha256=hashlib.sha256(body.encode()).hexdigest(),exactNormalizedBody=compact))
 out.mkdir(parents=True,exist_ok=True);row=dict(source='contracts/Operations.sol',sourceSha256=hashlib.sha256(source.encode()).hexdigest(),buildInfoId=artifact['buildInfoId'],selectors=['a1bc2139'],errorSignatures={'InvalidByteIndex':'int256,uint256','InvalidUtf8':'uint256'},functions=rows);(out/'source-gate.json').write_text(json.dumps(row,indent=2)+'\n');print('PASS exact stringAt/UTF8 source AST/body gate; native proof pending')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);generate(p.parse_args().output)
