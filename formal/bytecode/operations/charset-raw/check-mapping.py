#!/usr/bin/env python3
"""Independently match every generic charset body state to complete physical traces."""
import argparse,ast,json,re
from pathlib import Path
HERE=Path(__file__).resolve().parent;M=1<<256

def require(ok,msg):
 if not ok:raise RuntimeError(msg)
def expression(text,values):
 text=text.strip()
 while text.startswith('(') and text.endswith(')'):
  depth=0;whole=True
  for i,c in enumerate(text):
   depth += (c=='(')-(c==')')
   if depth==0 and i<len(text)-1:whole=False;break
  if not whole:break
  text=text[1:-1].strip()
 while '(if ' in text:
  at=text.rfind('(if ');depth=0;end=None
  for i in range(at,len(text)):
   depth += (text[i]=='(')-(text[i]==')')
   if depth==0:end=i;break
  require(end is not None,'Unclosed generated branch')
  text=text[:at]+str(expression(text[at+1:end],values))+text[end+1:]
 if text.startswith('if '):
  depth=0;then=otherwise=None
  for i,c in enumerate(text):
   depth += (c=='(')-(c==')')
   if depth==0 and text.startswith(' then ',i):then=i
   if depth==0 and text.startswith(' else ',i):otherwise=i;break
  require(then is not None and otherwise is not None,('Malformed symbolic branch',text))
  return expression(text[then+6:otherwise] if expression(text[3:then],values) else text[otherwise+6:],values)
 text=re.sub(r"\s+as\s+nat", "", text)
 for name in ['DataWord','ShiftRight','ShiftLeft']:
  text=text.replace('S.'+name,name)
 text=text.replace('G.Signed','Signed').replace('G.BitAnd','BitAnd').replace('G.BitOr','BitOr').replace('G.Modulus()',str(M))
 text=text.replace('&&',' and ').replace('||',' or ').replace('true','True').replace('false','False')
 tree=ast.parse(text.strip(),mode='eval')
 def go(n):
  if isinstance(n,ast.Expression):return go(n.body)
  if isinstance(n,ast.Constant) and isinstance(n.value,(int,bool)):return n.value
  if isinstance(n,ast.Name):require(n.id in values,('Unknown symbolic word',n.id));return values[n.id]
  if isinstance(n,ast.BinOp):
   a,b=go(n.left),go(n.right)
   if isinstance(n.op,ast.Add):return a+b
   if isinstance(n.op,ast.Sub):return a-b
   if isinstance(n.op,ast.Mod):return a%b
  if isinstance(n,ast.UnaryOp) and isinstance(n.op,ast.USub):return -go(n.operand)
  if isinstance(n,ast.BoolOp):return all(go(v) for v in n.values) if isinstance(n.op,ast.And) else any(go(v) for v in n.values)
  if isinstance(n,ast.Call) and isinstance(n.func,ast.Name):
   args=[go(a) for a in n.args];name=n.func.id
   if name=='Bool':return int(args[0])
   if name=='Signed':return args[0] if args[0]<M//2 else args[0]-M
   if name=='DataWord':return int.from_bytes(args[0][args[1]:args[1]+32].ljust(32,b'\0'),'big')
   if name=='ShiftRight':return 0 if args[1]>=256 else args[0]>>args[1]
   if name=='ShiftLeft':return 0 if args[1]>=256 else (args[0]<<args[1])%M
   if name=='BitAnd':return args[0]&args[1]
   if name=='BitOr':return args[0]|args[1]
   raise RuntimeError(('Unknown generated function',name))
  if isinstance(n,ast.Compare):
   a=go(n.left)
   for op,right in zip(n.ops,n.comparators):
    b=go(right);ok=a==b if isinstance(op,ast.Eq) else a!=b if isinstance(op,ast.NotEq) else a<b if isinstance(op,ast.Lt) else a<=b if isinstance(op,ast.LtE) else a>b if isinstance(op,ast.Gt) else a>=b if isinstance(op,ast.GtE) else False
    if not ok:return False
    a=b
   return True
  raise RuntimeError(('Unsupported generated expression',ast.dump(n)))
 return go(tree)
def memory(step):return bytes.fromhex(''.join(w.removeprefix('0x') for w in step['memory']))
def load(data,offset):return int.from_bytes(data[offset:offset+32].ljust(32,b'\0'),'big')
def main():
 p=argparse.ArgumentParser();p.add_argument('directory',type=Path);p.add_argument('--mapping',type=Path,default=HERE/'raw.mapping.json');a=p.parse_args();mapping=json.loads(a.mapping.read_text());paths={r['name']:r for r in mapping['paths']};rows=json.loads((a.directory/'results.json').read_text());seen=set();states=0
 names={'Nonzero':'Nonzero','Short':'Short','Args':'Args','OffsetBound':'OffsetBound','LengthWindow':'LengthWindow','LengthBound':'LengthBound','PayloadWindow':'PayloadWindow','Success':'Accepted'}
 for row in rows:
  name=names[row['reason']];path=paths[name];seen.add(name);observation=json.loads((a.directory/row['trace']).read_text());require(observation['runtimeSha256']==mapping['runtimeSha256'],'Raw mapping runtime drift');steps=observation['trace']['structLogs'];data=bytes.fromhex(observation['data'][2:]);off=load(data,4);aliases={'I.Offset(data)':off,'I.Mask(data)':load(data,36),'I.Length(data)':load(data,off+4),'|data|':len(data)};values=dict(data=data,value=int(observation['value']))
  for i,node in enumerate(path['nodes']):
   step=steps[i];wanted=[]
   for item in node['stack']:
    for src,dst in aliases.items():item=item.replace(src,str(dst))
    wanted.append(expression(item,values))
   require(step['pc']==node['pc'] and [int(v,16) for v in step['stack']]==wanted,(row['name'],name,i,'Complete raw stack mismatch'))
   wantedmem=b'' if node['memory']=='[]' else b'\0'*64+(128).to_bytes(32,'big');require(memory(step)==wantedmem,(row['name'],name,i,'Complete raw memory mismatch'));states+=1
   if i+1<len(path['nodes']):require(steps[i+1]['pc']==node['actualNext'],'Raw successor pc mismatch')
  if name=='Accepted':
   at=len(path['nodes']);require(steps[at]['pc']==4121 and [int(v,16) for v in steps[at]['stack']]==[0x3e8c97e3,1289,off+36,load(data,off+4),load(data,36)] and memory(steps[at])==b'\0'*64+(128).to_bytes(32,'big'),'Raw accepted endpoint mismatch')
  else:require(len(steps)==len(path['nodes']) and observation['trace']['failed'],'Raw rejection terminal mismatch')
 require(seen==set(paths),('Missing complete raw admission geometries',set(paths)-seen))
 print(f'PASS8 charset complete raw prefixes: {states} exact stack/memory states across {len(rows)} full physical fixtures. Native proof pending.')
if __name__=='__main__':main()
