#!/usr/bin/env python3
"""Generate complete finite UTF-8 unit paths from canonical runtime instructions.

Profiles partition unit values, not whole input lengths. The outer loop requires
a separate induction over all finite calldata. Every generated claim is native
pending until the complete retained closure passes.
"""
import argparse, hashlib, json, subprocess
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
M = 1 << 256
DAFNY = '/tmp/assertions-dafny-4.11.0/dafny/dafny'
PARAMS = 'prefix:seq<S.Word>,ret:S.Word,offset:S.Word,length:S.Word,cursor:S.Word,mem:seq<S.Byte>,self:S.Word,value:S.Word,data:seq<S.Byte>,observations:seq<M.Observation>'
ARGS = 'prefix,ret,offset,length,cursor,mem,self,value,data,observations'
STEP = 'F.Step(code,destinations,state,self,value,data,observations)'

def profiles():
    result = [dict(name='Entry', kind='entry', sample=b'', guard='cursor==0'),
              dict(name='Done', kind='done', sample=b'', guard='cursor==length'),
              dict(name='Ascii', kind='good', width=1, sample=b'A', guard='cursor<length && K.Cell(data,offset,length,cursor,0)<128')]
    for name, low, high in [('BadLeadLow',128,193),('BadLeadHigh',245,255)]:
        result.append(dict(name=name,kind='bad',error=0,sample=bytes([low]),guard=f'cursor<length && {low}<=K.Cell(data,offset,length,cursor,0)<={high}'))
    for width, low, high in [(2,194,223),(3,224,239),(4,240,244)]:
        result.append(dict(name=f'Truncated{width}',kind='bad',error=0,sample=bytes([low]+[160 if low==224 else 144 if low==240 else 128]*(width-2)),guard=f'cursor<length && {low}<=K.Cell(data,offset,length,cursor,0)<={high} && length-cursor<{width}'))
    # These intervals distinguish every short-circuited special lead branch.
    classes = [('Two',2,194,223,128,191),('E0',3,224,224,160,191),
               ('E1EC',3,225,236,128,191),('ED',3,237,237,128,159),
               ('EEEF',3,238,239,128,191),('F0',4,240,240,144,191),
               ('F1F3',4,241,243,128,191),('F4',4,244,244,128,143)]
    for name,width,lo,hi,secondlo,secondhi in classes:
        lead=f'{lo}<=K.Cell(data,offset,length,cursor,0)<={hi}'
        base=f'cursor<length && cursor+{width}<=length && {lead}'
        unit=[lo,secondlo]+[128]*(width-2)
        valid=[f'{secondlo}<=K.Cell(data,offset,length,cursor,1)<={secondhi}'] + [f'I.Continuation(K.Cell(data,offset,length,cursor,{j}))' for j in range(2,width)]
        result.append(dict(name='Good'+name,kind='good',width=width,sample=bytes(unit),guard=base+' && '+' && '.join(valid)))
        for j in range(1,width):
            low,high=(secondlo,secondhi) if j==1 else (128,191)
            for side,bounds in [('Low',(0,low-1)),('High',(high+1,255))]:
                bad=list(unit);bad[j]=bounds[0]
                earlier=valid[:j-1]
                guard=base+' && '+(' && '.join(earlier)+' && ' if earlier else '')+f'{bounds[0]}<=K.Cell(data,offset,length,cursor,{j})<={bounds[1]}'
                result.append(dict(name=f'Bad{name}At{j}{side}',kind='bad',error=j,sample=bytes(bad),guard=guard))
    return result

class Scalar:
    def __init__(self,v,e=None,lin=None,kind=None,j=None):
        self.v=v;self.e=str(v) if e is None else e;self.lin=({None:v} if e is None else lin);self.kind=kind;self.j=j
    @staticmethod
    def var(v,name): return Scalar(v,name,{name:1})
    def record(self):return dict(value=self.v,expression=self.e,kind=self.kind,j=self.j)

def affine(parts):
    parts={k:v for k,v in parts.items() if v};plus=[];minus=[]
    for k in sorted(parts,key=lambda x:'' if x is None else x):
        v=parts[k];s=str(abs(v)) if k is None else k if abs(v)==1 else str(abs(v))+'*'+k
        (plus if v>0 else minus).append(s)
    return ('+'.join(plus) or '0')+(''.join('-'+x for x in minus))

def add(a,b,subtract=False):
    v=(a.v-b.v if subtract else a.v+b.v)%M
    if a.lin is not None and b.lin is not None:
        p=a.lin.copy()
        for k,w in b.lin.items():p[k]=p.get(k,0)+(-w if subtract else w)
        e=affine(p)
        if not any(k is not None and w for k,w in p.items()):return Scalar(v)
        return Scalar(v,e,p)
    e=f'(({a.e})+G.Modulus()-({b.e}))%G.Modulus()' if subtract else f'(({a.e})+({b.e}))%G.Modulus()'
    return Scalar(v,e)

def run_path(profile,ins):
    start=11583 if profile['kind']=='entry' else 11585
    data=bytes(100)+profile['sample'];n=len(profile['sample'])
    stack=[Scalar.var(7291,'ret'),Scalar.var(100,'offset'),Scalar.var(n,'length')]
    if profile['kind']!='entry':stack.append(Scalar.var(n if profile['kind']=='done' else 0,'cursor'))
    memory='mem';nodes=[];dests=set();pc=start;terminal=None;free=Scalar.var(128,'K.Free(mem)')
    while True:
        if nodes and (pc==11585 or pc==7291):break
        op,nxt,imm=ins[pc];before=[x.record() for x in stack];beforemem=memory;guide=[]
        def pop():return stack.pop()
        def push(x):stack.append(x)
        if op==91:pass
        elif op==95 or 96<=op<=127:push(Scalar(imm))
        elif 128<=op<=143:
            a=stack[-(op-127)];push(a)
        elif 144<=op<=159:
            k=op-143;stack[-1],stack[-1-k]=stack[-1-k],stack[-1]
        elif op==80:pop()
        elif op==21:
            a=pop();push(Scalar(int(a.v==0)))
        elif op in [1,3]:
            a,b=pop(),pop();push(add(a,b,op==3))
        elif op in [16,17,20]:
            a,b=pop(),pop();push(Scalar(int(a.v<b.v if op==16 else a.v>b.v if op==17 else a.v==b.v)))
        elif op==22:
            a,b=pop(),pop();v=a.v&b.v
            if a.e=='255' and b.kind in ['cell','mask'] or b.e=='255' and a.kind in ['cell','mask']:
                cell=b if a.e=='255' else a;push(cell);guide.append(f'K.Mask({cell.e});')
            elif a.e=='192' and b.kind=='cell' or b.e=='192' and a.kind=='cell':
                cell=b if a.e=='192' else a;push(Scalar(v,f'K.Mask192({cell.e})',kind='mask'));guide.append(f'K.ContinuationMask({cell.e});')
            elif a.e.isdecimal() and b.e.isdecimal():push(Scalar(v))
            else:push(Scalar(v,f'G.BitAnd({a.e},{b.e})'))
        elif op==53:
            a=pop();at=a.v;value=int.from_bytes(data[at:at+32].ljust(32,b'\0'),'big') if at<len(data) else 0
            push(Scalar(value,f'S.DataWord(data,{a.e})',kind='word',j=a.v-100))
        elif op in [27,28]:
            amount,a=pop(),pop();v=((a.v<<amount.v)%M if op==27 else a.v>>amount.v)
            if op==28 and amount.v==248 and a.kind=='word':
                j=a.j;e=f'K.Cell(data,offset,length,cursor,{j})';push(Scalar(v,e,kind='cell',j=j));guide.append(f'K.First(data,offset,length,cursor,{j});')
            elif op==27 and amount.v==248 and a.kind=='cell':
                push(Scalar(v,f'S.ShiftLeft({a.e},248)',kind='top',j=a.j))
            elif op==28 and amount.v==248 and a.kind=='top':
                e=f'K.Cell(data,offset,length,cursor,{a.j})';push(Scalar(v,e,kind='cell',j=a.j));guide.append(f'K.ShiftCell({e});')
            elif a.e.isdecimal() and amount.e.isdecimal():
                push(Scalar(v));guide.append('K.HeadLiteral();')
            else:raise AssertionError(('Unclassified shift',pc,a.e,amount.e))
        elif op==81:
            a=pop();assert a.e=='64';push(free);guide.append(f'K.FreePreserved(mem,cursor+{profile.get("error",0)});')
        elif op==82:
            at,v=pop(),pop();memory=f'S.Store({memory},{at.e},{v.e})';guide.append(f'K.FreePreserved(mem,cursor+{profile.get("error",0)});')
        elif op in [86,87]:
            at=pop();take=op==86 or pop().v!=0
            if at.e=='ret':dests.add('ret')
            else:assert at.e.isdecimal();dests.add(at.v)
            if take:nxt=at.v
        elif op==253:
            at,count=pop(),pop();assert count.v==36 and at.v==128
            terminal=f'M.Frame(S.Reverted(K.Packet(cursor+{profile["error"]})),[],0)';guide.append(f'K.ErrorPacket(mem,cursor+{profile["error"]});')
        else:raise AssertionError(('Unexpected UTF8 opcode',pc,op))
        nodes.append(dict(pc=pc,opcode=op,next=ins[pc][1],immediate=imm,actualNext=nxt,stack=before,memory=beforemem,guide=''.join(guide)))
        pc=nxt
        assert len(nodes)<800,profile['name']
        if terminal:break
    if terminal is None:
        terminal=frame('ret' if pc==7291 else pc,[x.e for x in stack],memory)
    return dict(name=profile['name'],kind=profile['kind'],guard=profile['guard'],width=profile.get('width'),error=profile.get('error'),sample=profile['sample'].hex(),start=start,nodes=nodes,terminal=terminal,terminalPc=None if profile['kind']=='bad' else 'ret' if pc==7291 else pc,terminalStack=[x.record() for x in stack],terminalMemory=memory,destinations=sorted(dests,key=str))

def frame(pc,stack,mem):
    return f'M.Frame(S.Running({pc},prefix+['+','.join(stack)+f'],{mem}),[],0)'

def emit(path,out):
    name=path['name'];module='OperationsUtf8'+name;nodes=path['nodes'];count=len(nodes)
    text='// SPDX-License-Identifier: MIT\n// Generated from complete canonical UTF8 unit instructions. Native pending.\ninclude "Kernel.dfy"\ninclude "../casefold-machine/Execution.dfy"\nmodule '+module+' {\n  import S = BytecodeScanMachine\n  import G = BytecodeGetterMachine\n  import M = BytecodeExternalMachine\n  import CM = BytecodeCopyMachine\n  import F = OperationsCaseFoldMachine\n  import E = OperationsCaseFoldExecution\n  import I = OperationsUtf8Inputs\n  import K = OperationsUtf8Kernel\n'
    text+=f'  predicate Admitted({PARAMS}) {{ K.Common(prefix,ret,data,offset,length,cursor,mem) && {path["guard"]} }}\n'
    text+='  predicate Matches(code:seq<S.Byte>,ret:S.Word) {\n    '+' &&\n    '.join(f'{n["pc"]}<|code| && S.Fetch(code,{n["pc"]})==S.Op({n["opcode"]},{n["next"]},{n["immediate"]})' for n in nodes)
    text+=' &&\n    '+' &&\n    '.join(f'{d}<|code| && code[{d}]==0x5b' for d in path['destinations'])+'\n  }\n' if path['destinations'] else '\n  }\n'
    text+='  function Destinations(ret:S.Word):set<nat> { {'+','.join(map(str,path['destinations']))+'} }\n'
    states=[frame(n['pc'],[s['expression'] for s in n['stack']],n['memory']) for n in nodes]+[path['terminal']]
    text+=f'  opaque predicate Good(id:nat,state:M.Frame,{PARAMS}) requires Admitted({ARGS}) {{\n'
    text+='\n'.join(f'    {"if" if i==0 else "else if"} id=={i} then state=={s}' for i,s in enumerate(states))+'\n    else false\n  }\n'
    for i,n in enumerate(nodes):
        text+=f'  lemma Advance{i}(code:seq<S.Byte>,destinations:set<nat>,state:M.Frame,{PARAMS})\n    requires Matches(code,ret) && Destinations(ret)<=destinations && Admitted({ARGS}) && Good({i},state,{ARGS})\n    ensures Good({i+1},{STEP},{ARGS})\n  {{ reveal Good();{n["guide"]}reveal F.Step();reveal M.Step();reveal CM.Step();reveal S.Step();reveal G.Step(); }}\n'
    chunks=[]
    for start in range(0,count,24):
        end=min(count,start+24);chunk=len(chunks);chunks.append((start,end))
        text+=f'  ghost method Chunk{chunk}(code:seq<S.Byte>,destinations:set<nat>,initial:M.Frame,{PARAMS}) returns(state:M.Frame,trace:seq<M.Frame>)\n    requires Matches(code,ret) && Destinations(ret)<=destinations && Admitted({ARGS}) && Good({start},initial,{ARGS})\n    ensures Good({end},state,{ARGS})\n    ensures E.Trace(code,destinations,self,value,data,observations,trace) && trace[0]==initial && trace[|trace|-1]==state && |trace|=={end-start+1}\n  {{ state:=initial;trace:=[state];\n'
        for i in range(start,end):
            text+=f'    Advance{i}(code,destinations,state,{ARGS});reveal Good();assert {STEP}.state!=S.Bad;E.Extend(code,destinations,self,value,data,observations,trace,{STEP});state:={STEP};trace:=trace+[state];\n'
        text+='  }\n'
    text+=f'  ghost method Run(code:seq<S.Byte>,destinations:set<nat>,{PARAMS}) returns(state:M.Frame,trace:seq<M.Frame>)\n    requires Matches(code,ret) && Destinations(ret)<=destinations && Admitted({ARGS})\n    ensures state=={states[-1]}\n    ensures E.Trace(code,destinations,self,value,data,observations,trace) && trace[0]=={states[0]} && trace[|trace|-1]==state && |trace|=={count+1}\n'
    if path['kind']=='good':text+=f'    ensures I.Unit(K.Payload(data,offset,length),cursor)==I.Good({path["width"]})\n'
    elif path['kind']=='bad':text+=f'    ensures I.Unit(K.Payload(data,offset,length),cursor)==I.Bad(cursor+{path["error"]})\n'
    text+=f'  {{ state:={states[0]};trace:=[state];reveal Good();assert Good(0,state,{ARGS});\n'
    for i,(start,end) in enumerate(chunks):
        text+=f'    var next{i},part{i}:=Chunk{i}(code,destinations,state,{ARGS});E.Join(code,destinations,self,value,data,observations,trace,part{i});trace:=trace+part{i}[1..];state:=next{i};\n'
    text+='    reveal Good();\n  }\n}\n'
    r=subprocess.run([DAFNY,'format','--stdin','--print'],input=text.replace('include "','//FORMAT_INCLUDE "'),capture_output=True,text=True)
    if r.returncode:raise RuntimeError(name+'\n'+r.stdout+r.stderr)
    (out/(name+'.generated.dfy')).write_text(r.stdout.replace('//FORMAT_INCLUDE "','include "'))

def generate(out):
    code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text())['deployedBytecode'][2:]);inventory=json.loads((ROOT/'formal/bytecode/operations/inventory.json').read_text())
    assert hashlib.sha256(code).hexdigest()==inventory['runtimeSha256'];ins={};pc=0
    while pc<len(code):
        op=code[pc];width=op-95 if 96<=op<=127 else 0;ins[pc]=(op,pc+width+1,int.from_bytes(code[pc+1:pc+width+1],'big'));pc+=width+1
    paths=[run_path(p,ins) for p in profiles()];out.mkdir(parents=True,exist_ok=True)
    for path in paths:emit(path,out)
    result=dict(status='prepared-native-unverified',runtimeSha256=inventory['runtimeSha256'],paths=paths,instructions=sum(len(p['nodes']) for p in paths))
    (out/'controls.mapping.json').write_text(json.dumps(result,indent=2)+'\n')
    print(f'Prepared {len(paths)} complete UTF8 macro classes; {result["instructions"]} explicit instruction states; native pending')

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);generate(p.parse_args().output)
