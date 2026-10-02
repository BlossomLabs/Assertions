#!/usr/bin/env python3
"""Independently match every generic charset body state to complete physical traces."""
import argparse,ast,json
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
 for name in ['DataWord','ShiftRight','ShiftLeft']:
  text=text.replace('S.'+name,name)
 text=text.replace('G.BitAnd','BitAnd').replace('G.BitOr','BitOr').replace('G.Modulus()',str(M))
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
def main():
 p=argparse.ArgumentParser();p.add_argument('directory',type=Path);p.add_argument('--mapping',type=Path,default=HERE/'controls.mapping.json');a=p.parse_args();mapping=json.loads(a.mapping.read_text());paths={r['name']:r for r in mapping['paths']};rows=json.loads((a.directory/'results.json').read_text());seen=set();states=fixtures=iterations=0
 for row in rows:
  if row['reason']!='Success':continue
  observation=json.loads((a.directory/row['trace']).read_text());require(observation['runtimeSha256']==mapping['runtimeSha256'],'Mapping runtime drift');steps=observation['trace']['structLogs'];at=next(i for i,s in enumerate(steps) if s['pc']==4121);entry=[int(x,16) for x in steps[at]['stack']];values=dict(offset=entry[2],length=entry[3],mask=entry[4],index=0,data=bytes.fromhex(observation['data'][2:]));mem=memory(steps[at]);name='Start'
  while True:
   path=paths[name];seen.add(name)
   for i,node in enumerate(path['nodes']):
    step=steps[at+i];require(step['pc']==node['pc'] and [int(v,16) for v in step['stack']]==[expression(e,values) for e in node['stack']],(row['name'],name,i,'Complete symbolic stack mismatch'))
    wanted=mem
    if node['memory']!='mem':
     require(node['memory'] in ['S.Store(mem,128,0)','S.Store(mem,128,1)'],'Unknown generated memory');word=0 if node['memory'].endswith(',0)') else 1;wanted=(mem+b'\0'*max(0,160-len(mem)))[:128]+word.to_bytes(32,'big')+(mem[160:] if len(mem)>160 else b'')
    require(memory(step)==wanted,(row['name'],name,i,'Complete symbolic memory mismatch'));states+=1
   at+=len(path['nodes'])
   if name in ['Done','Reject']:require(at==len(steps),'Missing terminal instruction');break
   require(steps[at]['pc']==4124,'Loop entry mismatch')
   if name=='Next':values['index']+=1;iterations+=1
   expected=[0x3e8c97e3,1289,values['offset'],values['length'],values['mask'],0,values['index']];require([int(v,16) for v in steps[at]['stack']]==expected and memory(steps[at])==mem,'Loop successor mismatch')
   if values['index']==values['length']:name='Done'
   else:
    cell=values['data'][values['offset']+values['index']];name='Next' if (values['mask']//(1<<cell))%2 else 'Reject'
  fixtures+=1
 require(seen==set(paths),('Missing actual loop geometries',set(paths)-seen))
 print(f'PASS4 complete generated charset controls: {states} exact stack/memory states, {iterations} physical iterations, {fixtures} accepted raw fixtures. Native proof pending.')
if __name__=='__main__':main()
