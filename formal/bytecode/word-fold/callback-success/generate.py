#!/usr/bin/env python3
"""Extract complete exact-32 successful callback receipt instructions."""
import argparse,hashlib,json,subprocess,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];MOD=1<<256
class Expr:
 def __init__(self,value,text=None):self.value=value;self.text=str(value) if text is None else text
 def constant(self):return self.text.isdecimal()
def generate(out):
 obj=json.loads((ROOT/'artifacts/contracts/Collections.sol/Collections.json').read_text());code=bytes.fromhex(obj['deployedBytecode'][2:]);digest=hashlib.sha256(code).hexdigest();pin=json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Collections'];assert digest==pin['runtimeSha256'] and pin['methodIdentifiers']['foldRange(uint256,address,bytes,uint256,uint256[],bytes32,uint8)']=='f1d88dc8' and pin['methodIdentifiers']['foldBytes(bytes,address,bytes,uint256,uint256[],bytes32,uint8)']=='6d24e79c' and pin['methodIdentifiers']['foldWords(bytes,address,bytes,uint256,uint256[],bytes32,uint8)']=='6de60cb0'
 ins={};pc=0
 while pc<len(code):
  op=code[pc];w=op-95 if 96<=op<=127 else 0;ins[pc]=(op,pc+1+w,int.from_bytes(code[pc+1:pc+1+w],'big'));pc+=1+w
 destinations={x for x,(op,_,_) in ins.items() if op==0x5b}
 fields=['16553','target','ptr','index','0','gasBefore','0','0','target','end','1'];stack=[Expr(v,t) for v,t in zip([16553,18176,192,0,0,9971805,0,0,18176,288,1],fields)];pc=16948;mem='mem';states=[];required={16553:code[16553]};targets={16553}
 while pc!=16553:
  op,nxt,imm=ins[pc];required.update({x:code[x] for x in range(pc,nxt)});states.append(dict(id=len(states),pc=pc,op=op,next=nxt,immediate=imm,stack=[x.text for x in stack],memory=mem));assert len(states)<140
  if op==0x5b:pass
  elif op==0x5f or 96<=op<=127:stack.append(Expr(imm))
  elif 0x80<=op<=0x8f:stack.append(stack[-(op-127)])
  elif 0x90<=op<=0x9f:k=op-143;stack[-1],stack[-1-k]=stack[-1-k],stack[-1]
  elif op==0x50:stack.pop()
  elif op==0x3d:stack.append(Expr(32))
  elif op==0x19:a=stack.pop();assert a.constant();stack.append(Expr(MOD-1-a.value))
  elif op==0x16:a,b=stack.pop(),stack.pop();assert a.constant() and b.constant();stack.append(Expr(a.value&b.value))
  elif op==0x14:a,b=stack.pop(),stack.pop();assert a.constant() and b.constant();stack.append(Expr(int(a.value==b.value)))
  elif op==1:
   a,b=stack.pop(),stack.pop()
   if a.constant() and b.constant():text=str((a.value+b.value)%MOD)
   elif {a.text,b.text}=={'free','64'}:text='free+64'
   elif {a.text,b.text}=={'free','32'}:text='free+32'
   else:raise ValueError((pc,a.text,b.text))
   stack.append(Expr((a.value+b.value)%MOD,text))
  elif op==0x51:
   a=stack.pop()
   if pc==16962:assert a.text=='64' and mem=='mem';stack.append(Expr(256,'free'))
   elif pc==17067:assert a.text=='free' and mem=='H.Complete(mem,free,returned)';stack.append(Expr(32))
   elif pc==17122:assert a.text=='free+32' and mem=='H.Complete(mem,free,returned)';stack.append(Expr(1,'H.Result(returned)'))
   else:raise ValueError((pc,a.text,mem))
  elif op==0x52:
   a,b=stack.pop(),stack.pop()
   if pc==16977:assert (a.text,b.text)==('64','free+64');mem='H.Pointer(mem,free)'
   elif pc==16980:assert (a.text,b.text)==('free','32');mem='H.Head(mem,free)'
   else:raise ValueError((pc,a.text,b.text))
  elif op==0x3e:
   a,b,c=stack.pop(),stack.pop(),stack.pop();assert (a.text,b.text,c.text)==('free+32','0','32');mem='H.Complete(mem,free,returned)'
  elif op in (0x56,0x57):
   dest=stack.pop();assert dest.constant() and dest.value in destinations;targets.add(dest.value);required[dest.value]=code[dest.value]
   if op==0x56 or stack.pop().value:nxt=dest.value
  else:raise ValueError((pc,hex(op)))
  pc=nxt
 assert [x.text for x in stack]==['H.Result(returned)'];cap=max(max(len(s['stack']) for s in states),1)
 params='data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,end: Word,free: Word,gasBefore: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,self: Word,value: Word';args='data,mem,prefix,target,ptr,index,end,free,gasBefore,returned,cursor,observations,self,value'
 literal=lambda s:f"X.Frame(Running({s['pc']},prefix+[{','.join(s['stack'])}],{s['memory']}),returned,cursor)"
 initial=f"X.Frame(Running(16948,prefix+[{','.join(fields)}],mem),returned,cursor)";final='X.Frame(Running(16553,prefix+[H.Result(returned)],H.Complete(mem,free,returned)),returned,cursor)'
 good='\n'.join('    '+('if' if s['id']==0 else 'else if')+f" id == {s['id']} then frame == {literal(s)}" for s in states)+'\n    else false';matches=' &&\n    '.join(f'code[{x}] == {v}' for x,v in sorted(required.items()))
 text=f"""// SPDX-License-Identifier: MIT
// Generated complete successful32 receipt, copying actual caller-local returned bytes and loading the exact word.
include "../../word-apply/callback-success/Memory.dfy"
include "../../word-apply/callback-success/Scalar.dfy"
module BytecodeFoldExactWordCallbackReturn {{
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import X = BytecodeExternalMachine
  import E = BytecodeExternalExecution
  import C = BytecodeCopyMachine
  import H = BytecodeApplyCallbackSuccessMemory
  import SC = BytecodeApplyCallbackSuccessScalar
  predicate Admitted({params}) {{ H.Fits(mem,free) && |returned| == 32 && X.Context(self) && |prefix| <= {1024-cap} }}
  opaque predicate Matches(code: seq<Byte>) {{ |code| == {len(code)} &&
    {matches}
  }}
  function Destinations(): set<nat> {{ {{{','.join(map(str,sorted(targets)))}}} }}
  opaque predicate Good(id: nat,frame: X.Frame,{params}) {{ Admitted({args}) && (
{good}) }}
"""
 for s in states:
  i=s['id'];post=f'next == {final}' if i==len(states)-1 else f'Good({i+1},next,{args})';fetch=f"    F.Push{s['op']-95}(code,{s['pc']});\n" if s['op'] in (96,97) else '';facts=''
  if s['op']==0x3d:
   tail=','.join(s['stack']);facts+=f'    X.ReturnSizeStep(code,{s["pc"]},prefix+[{tail}],{s["memory"]},self,returned,cursor,observations,value,data);\n    E.WidenStep(code,{{}},Destinations(),frame,self,value,data,observations);\n'
  elif s['op']==0x3e:
   tail=','.join(s['stack'][:-3]);facts+=f'    SC.Fourteen(prefix,{tail},32,0,free+32);\n    assert frame == X.Frame(Running({s["pc"]},(prefix+[{tail}])+[32,0,free+32],{s["memory"]}),returned,cursor);\n    X.ReturnCopyStep(code,{s["pc"]},prefix+[{tail}],{s["memory"]},self,free+32,0,32,returned,cursor,observations,value,data);\n    E.WidenStep(code,{{}},Destinations(),frame,self,value,data,observations);\n'
  else:
   facts+='    X.Delegate(code,Destinations(),frame,self,value,data,observations);\n    C.Delegate(code,Destinations(),frame.state,value,data);\n'
   if s['op']==0x16:
    tail=','.join(s['stack'][:-2]);facts+=f'    assert frame.state == Running(16972,(prefix+[{tail}])+[0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0,95],{s["memory"]});\n    SC.At(code,Destinations(),prefix+[{tail}],{s["memory"]},value,data);\n'
   else:
    facts+='    reveal Step();\n'
    if s['op']==0x19:facts+='    SC.Not31();\n'
  text+=f"""  lemma Advance{i}(code: seq<Byte>,frame: X.Frame,{params})
    requires Matches(code) && Admitted({args}) && Good({i},frame,{args})
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); {post}
  {{ hide G.BitAnd(); reveal Matches(); reveal Good();
    H.Bounds(mem,free,returned); H.Layout(mem,free,returned);
    assert frame == {literal(s)};
{fetch}    assert Fetch(code,{s['pc']}) == Op({s['op']},{s['next']},{s['immediate']});
{facts}
  }}
"""
 joins=[]
 for start in range(0,len(states),20):
  end=min(start+20,len(states));block=start//20;post=f'frame == {final}' if end==len(states) else f'Good({end},frame,{args})';calls='\n'.join(f'    Advance{i}(code,frame,{args});\n    var next{i} := X.Step(code,Destinations(),frame,self,value,data,observations);\n    E.Extend(code,Destinations(),self,value,data,observations,trace,next{i});trace := trace+[next{i}];frame := next{i};' for i in range(start,end))
  text+=f'''  ghost method Block{block}(code: seq<Byte>,initial: X.Frame,{params}) returns (frame: X.Frame,trace: seq<X.Frame>)
    requires Matches(code) && Admitted({args}) && Good({start},initial,{args})
    ensures {post} && E.Trace(code,Destinations(),self,value,data,observations,trace)
    ensures |trace| == {end-start+1} && trace[0] == initial && trace[|trace|-1] == frame
  {{ frame := initial;trace := [frame];
{calls}
  }}
'''
  joins.append(f'    frame,part := Block{block}(code,frame,{args});\n    E.Join(code,Destinations(),self,value,data,observations,trace,part);trace := trace+part[1..];')
 text+=f'''  ghost method Run(code: seq<Byte>,{params}) returns (frame: X.Frame,trace: seq<X.Frame>)
    requires Matches(code) && Admitted({args})
    ensures frame == {final} && E.Trace(code,Destinations(),self,value,data,observations,trace)
    ensures |trace| == {len(states)+1} && trace[0] == {initial} && trace[|trace|-1] == frame
  {{ frame := {initial};trace := [frame];reveal Good();var part: seq<X.Frame>;
'''+ '\n'.join(joins)+'\n  }\n}\n'
 out.mkdir(parents=True,exist_ok=True);(out/'Success.generated.dfy').write_text(text);(out/'Success.mapping.json').write_text(json.dumps(dict(runtimeSha256=digest,states=states,requiredBytes=required,destinations=sorted(targets),scope='Complete successful32-byte receipt, exact physical caller return copy/result word. Wrong length/failure/OOG/full public retained graph remain open.'),indent=2)+'\n');print(len(states),'actual callback successful receipt instructions')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();generate(a.output);subprocess.run([sys.executable,'-B',HERE/'format-generated.py','--output',a.output,'--include-root',HERE],check=True)
