#!/usr/bin/env python3
"""Independently instantiate complete signed wrapper stacks in physical receipts."""
import argparse,ast,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;M=1<<256;H=M//2

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
 # Generated templates use only these named arithmetic functions.
 text=text.replace('K.Half',str(H))
 for word in ['base','modulusWord']:
  text=text.replace(f'K.Magnitude({word})',str(values[word] if values[word]<H else M-values[word]))
 text=text.replace('K.Odd(exponent)',str(values['exponent']%2==1))
 negative=values['base']>=H and values['exponent']%2==1
 text=text.replace('K.SignedResult(result,base>=K.Half && K.Odd(exponent))',str((-values['result'])%M if negative else values['result']))
 # Rewrite before Odd for the two generated result forms.
 text=text.replace('K.SignedResult(result,true)',str((-values['result'])%M))
 import re
 text=re.sub(r'K.SignedResult\(result,base>=\d+ && (True|False)\)',lambda m:str((-values['result'])%M if negative else values['result']),text)
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
  if isinstance(n,ast.Compare):
   a=go(n.left)
   for op,right in zip(n.ops,n.comparators):
    b=go(right);ok=a==b if isinstance(op,ast.Eq) else a!=b if isinstance(op,ast.NotEq) else a<b if isinstance(op,ast.Lt) else a<=b if isinstance(op,ast.LtE) else a>b if isinstance(op,ast.Gt) else a>=b if isinstance(op,ast.GtE) else False
    if not ok:return False
    a=b
   return True
  raise RuntimeError(('Unsupported generated expression',ast.dump(n)))
 return go(tree)
def memory(step):return bytes.fromhex(''.join(x.removeprefix('0x') for x in step['memory']))
def main():
 p=argparse.ArgumentParser();p.add_argument('directory',type=Path);p.add_argument('--mapping',type=Path,default=HERE/'signed.mapping.json');a=p.parse_args();mapping=json.loads(a.mapping.read_text());paths={r['name']:r for r in mapping['paths']};rows=json.loads((a.directory/'results.json').read_text());checked=set();states=fixtures=0
 for row in rows:
  if row['kind']!='SU' or row['value']!='0x0' or len(row['data'][2:])<200:continue
  trace=json.loads((a.directory/row['trace']).read_text());require(trace['runtimeSha256']==mapping['runtimeSha256'],'Runtime mapping drift');steps=trace['trace']['structLogs'];start=next(i for i,s in enumerate(steps) if s['pc']==5210);initial=[int(x,16) for x in steps[start]['stack']];values=dict(base=initial[2],exponent=initial[3],modulusWord=initial[4],finalBase=0,finalExponent=0,result=0)
  name='Enter'+str(int(values['base']>=H))+str(int(values['modulusWord']>=H));selected=[(name,start,memory(steps[start]))]
  if row['reason']=='Success':
   at=next(i for i,s in enumerate(steps) if s['pc']==3085);stack=[int(x,16) for x in steps[at]['stack']];values.update(finalBase=stack[-4],finalExponent=stack[-3],result=stack[-1]);name='ReturnPositiveBase' if values['base']<H else 'ReturnNegativeEven' if values['exponent']%2==0 else 'ReturnNegativeOdd';selected.append((name,at,memory(steps[at])))
  for name,at,mem in selected:
   path=paths[name];checked.add(name)
   for i,node in enumerate(path['nodes']):
    step=steps[at+i];expected=[expression(e,values) for e in node['stack']];require(step['pc']==node['pc'] and [int(x,16) for x in step['stack']]==expected,(row['name'],name,i,'Complete stack mismatch'))
    wanted=mem
    if node['memory']!='mem':
     require(node['memory']=='S.Store(mem,128,K.SignedResult(result,base>=K.Half && K.Odd(exponent)))','Unknown generated memory');value=(-values['result'])%M if values['base']>=H and values['exponent']%2==1 else values['result'];wanted=(mem+b'\0'*max(0,160-len(mem)))[:128]+value.to_bytes(32,'big')+(mem[160:] if len(mem)>160 else b'')
    require(memory(step)==wanted,(row['name'],name,i,'Complete memory mismatch'));states+=1
   if name.startswith('Enter'):
    end=steps[at+len(path['nodes'])];b=values['base'];m=values['modulusWord'];expected=[0x640c3e5a,1329,b,values['exponent'],m,0,3390,5241,b if b<H else M-b,values['exponent'],m if m<H else M-m]
    require(end['pc']==9244 and [int(x,16) for x in end['stack']]==expected and memory(end)==mem,'Body entry mismatch')
   else:require(at+len(path['nodes'])==len(steps),'Serializer omitted final instruction')
  fixtures+=1
 require(checked==set(paths),('Missing wrapper geometries',set(paths)-checked))
 print(f'PASS {len(paths)} complete generated signed wrapper paths: {states} physical stack/memory states across {fixtures} accepted signed fixtures. Native proof remains pending.')
if __name__=='__main__':main()
