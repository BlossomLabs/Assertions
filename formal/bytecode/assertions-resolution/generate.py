#!/usr/bin/env python3
"""Exact _checkConstraint reached instructions, with independent symbolic cases.

Concrete representatives select finite paths only. Every path condition and
transition is proved natively over arbitrary words and physical byte memory;
no representative value is a theorem premise.
"""
import argparse,hashlib,json,os,subprocess,sys
from dataclasses import dataclass
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2];MOD=1<<256
@dataclass
class E:
    value:int
    text:str
    const:bool=False
def k(v):return E(v,str(v),True)
def sym(v,t):return E(v,t)
def signed(v):return v if v<MOD//2 else v-MOD
def generate(out,runtime=None):
    artifact=json.loads((ROOT/'artifacts/contracts/Assertions.sol/Assertions.json').read_text())
    code=runtime.read_bytes() if runtime else bytes.fromhex(artifact['deployedBytecode'][2:])
    baseline=json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Assertions']
    if not runtime:assert hashlib.sha256(code).hexdigest()==baseline['runtimeSha256']
    ins={};p=0
    while p<len(code):
        op=code[p];w=op-95 if 96<=op<=127 else 0;ins[p]=(op,p+1+w,int.from_bytes(code[p+1:p+1+w].ljust(w,b'\0'),'big'));p+=1+w
    dests={p for p,(op,_,_) in ins.items() if op==91}
    cases=[]
    for kind in [0,1,2,3,4,5,7,8]:
        width=0 if kind==7 else 64 if kind in [3,8] else 32
        cases.append((f'Kind{kind}BadData',kind,1,7,5,10,f'length != P.Width({kind})','P.BadData'))
        if kind in [3,8]:
            for name,x,lo,hi,pred in [
              ('BadRange',7,10,5,'higher < lower'),
              ('Below',4,5,10,'lower <= higher && actual < lower'),
              ('Inside',7,5,10,'lower <= actual <= higher'),
              ('Above',12,5,10,'lower <= higher && higher < actual')]:
                if kind==8:pred=pred.replace('higher','G.Signed(higher)').replace('lower','G.Signed(lower)').replace('actual','G.Signed(actual)')
                verdict='P.BadRange' if name=='BadRange' else 'P.Holds' if name=='Inside' else 'P.Fails'
                cases.append((f'Kind{kind}{name}',kind,64,x,lo,hi,'length == 64 && '+pred,verdict))
        else:cases.append((f'Kind{kind}Valid',kind,width,7,5,10,f'length == {width}',None))
    out.mkdir(parents=True,exist_ok=True);inventory=[];allbytes={}
    params='ret: Word, actual: Word, constraint: Word, reference: Word, free: Word, entry: Word, param: Word, index: Word, length: Word, lower: Word, higher: Word, prefix: seq<Word>, mem: seq<Byte>'
    actuals='ret,actual,constraint,reference,free,entry,param,index,length,lower,higher,prefix,mem'
    for name,kind,length,x,lo,hi,pred,verdict in cases:
        memory='mem';s=[sym(0,'ret'),sym(x,'actual'),sym(128,'constraint'),sym(1,'entry'),sym(2,'param'),sym(3,'index')];pc=10646;states=[];required={};targets=set();seen=set();stores=[]
        loads={128:(str(kind),kind),160:('reference',192),192:('length',length),224:('lower',lo),256:('higher',hi),64:('free',320)}
        def pop():return s.pop()
        def push(v):s.append(v)
        def binary(op,a,b):
            if op==1:v=(a.value+b.value)%MOD;t=f'(({a.text} as nat)+({b.text} as nat))%G.Modulus()'
            elif op==3:v=(a.value-b.value)%MOD;t=f'(({a.text} as nat)+G.Modulus()-({b.text} as nat))%G.Modulus()'
            elif op in [16,17,18,19,20]:
                pred2={16:f'{a.text} < {b.text}',17:f'{a.text} > {b.text}',18:f'G.Signed({a.text}) < G.Signed({b.text})',19:f'G.Signed({a.text}) > G.Signed({b.text})',20:f'{a.text} == {b.text}'}[op]
                v=int({16:a.value<b.value,17:a.value>b.value,18:signed(a.value)<signed(b.value),19:signed(a.value)>signed(b.value),20:a.value==b.value}[op]);t=f'(if {pred2} then 1 else 0)'
            elif op==27:v=(b.value<<a.value)%MOD if a.value<256 else 0;t=f'S.ShiftLeft({b.text},{a.text})'
            else:raise ValueError(op)
            return k(v) if a.const and b.const else sym(v,t)
        while True:
            assert pc in ins and pc not in seen,(name,pc,'Repeated instruction: unsupported cycle');seen.add(pc)
            op,nxt,imm=ins[pc]
            assert nxt<=len(code)
            for q in range(pc,nxt):required[q]=code[q]
            node={'id':len(states),'pc':pc,'op':op,'next':nxt,'immediate':imm,'stack':[e.text for e in s],'memory':memory,'guide':[]};states.append(node)
            if op==91:pass
            elif op==95 or 96<=op<=127:push(k(imm))
            elif 128<=op<=143:push(s[-(op-127)])
            elif 144<=op<=159:q=op-143;s[-1],s[-1-q]=s[-1-q],s[-1]
            elif op==80:pop()
            elif op==21:
                a=pop();push(k(int(a.value==0)) if a.const else sym(int(a.value==0),f'(if {a.text} == 0 then 1 else 0)'))
            elif op in [1,3,16,17,18,19,20,27]:push(binary(op,pop(),pop()))
            elif op==81:
                a=pop();t,v=loads[a.value];push(k(v) if t.isdecimal() else sym(v,t))
                if stores:
                    for m,off,val in stores:node['guide'].append(f'    R.StoredFrame({m},{off},{val},64);')
                node['guide'].append(f'    assert S.Load({memory},{a.text}) == {t};')
                node['guide'].append(f'    assert S.Expand({memory},({a.text} as nat)+32) == {memory};')
            elif op==82:
                a,b=pop(),pop();offset=a.value-320;assert offset in [0,4,36,68,100]
                canonical='free' if offset==0 else f'free+{offset}'
                node['guide'].append(f'    assert {a.text} == {canonical};')
                stores.append((memory,canonical,b.text));node['guide'].append(f'    R.StoredWord({memory},{canonical},{b.text});');memory=f'S.Store({memory},{canonical},{b.text})'
            elif op in [86,87]:
                a=pop()
                if op==87:cond=pop();take=cond.value!=0
                else:take=True
                if a.text=='ret':
                    assert op==86;node['jump']='ret';targets.add('ret');break
                assert a.const and a.value in dests,(name,pc,a)
                required[a.value]=code[a.value];targets.add(str(a.value));node['jump']=a.text
                if take:nxt=a.value
            elif op==253:
                a,b=pop(),pop();node['revert']={'offset':a.text,'length':b.text};break
            else:raise ValueError((name,pc,hex(op)))
            pc=nxt
            assert len(s)<=1024
        finalstack=[e.text for e in s];inventory.append({'name':name,'kind':kind,'condition':pred,'verdict':verdict,'states':len(states),'finalStack':finalstack,'terminalPc':states[-1]['pc']})
        constraints=' &&\n    '.join(f'code[{q}] == {v}' for q,v in sorted(required.items()));allbytes.update(required)
        good='\n'.join('    '+('if' if n['id']==0 else 'else if')+f' id == {n["id"]} then state == S.Running({n["pc"]},prefix+[{",".join(n["stack"])}],{n["memory"]})' for n in states)+'\n    else false'
        targets=sorted(targets,key=lambda t:(t=='ret',int(t) if t!='ret' else 0));peak=max(len(n['stack']) for n in states)
        final=f'S.Running(ret,prefix+[{",".join(finalstack)}],mem)' if 'revert' not in states[-1] else f'S.Reverted(P.Error({verdict},entry,param,index,length))'
        header=f'''// SPDX-License-Identifier: MIT
// Generated reached-opcode certificate; no concrete sample is a premise.
include "Execution.dfy"
include "ErrorMemory.dfy"
include "Fetch.dfy"
include "Scalar.dfy"
module AssertionsConstraint{name} {{
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import M = AssertionsSignedMachine
  import E = AssertionsConstraintExecution
  import P = AssertionsConstraintSpec
  import R = BytecodeScanRepresentation
  import F = BytecodeScanFetch
  import J = AssertionsConstraintFetch
  import H = AssertionsConstraintScalar
  import B = AssertionsConstraintErrorMemory
  type Word = S.Word
  type Byte = S.Byte
  predicate Admitted({params}) {{
    P.Memory(mem,constraint,reference,free,{kind},length,lower,higher) && |prefix| <= {1024-peak} && ret in {{7993,8035}} &&
    {pred}
  }}
  opaque predicate Matches(code: seq<Byte>, ret: Word) {{ |code| == {len(code)} && ret < |code| && code[ret] == 91 &&
    {constraints}
  }}
  function Destinations(ret: Word): set<nat> {{ {{{','.join(targets)}}} }}
  opaque predicate Good(id: nat, state: S.State, {params}) {{
    Admitted({actuals}) && (
{good})
  }}
'''
        text=header
        for n in states:
            i=n['id'];post=f'next == {final}' if i==len(states)-1 else f'Good({i+1},next,{actuals})'
            guide='\n'.join(n['guide'])
            if n['op']==27:guide+='\n    H.ErrorHeaders();'
            fetch=f'    F.Push{n["op"]-95}(code,{n["pc"]});\n' if n['op'] in [96,97] else ''
            if n['op']==99:
                fetch+=f'    J.Push4(code,{n["pc"]});\n'
            if 'revert' in n:
                guide+=f'\n    assert {n["revert"]["offset"]} == free && {n["revert"]["length"]} == {132 if verdict=="P.BadData" else 100};'
                if verdict=='P.BadData':guide+=f'\n    assert {n["memory"]} == B.Data(mem,free,entry,param,index,length);\n    B.Four(mem,free,entry,param,index,length);'
                else:guide+=f'\n    assert {n["memory"]} == B.RangeWithSelector(mem,free,0x295a41c5,entry,param,index);\n    B.Three(mem,free,0x295a41c5,entry,param,index);'
                guide+=f'\n    assert G.Grow({n["memory"]},(free as nat)+{132 if verdict=="P.BadData" else 100}) == {n["memory"]};'
            attributes=' {:isolate_assertions}' if 'revert' in n else ''
            text+=f'''  lemma{attributes} Advance{i}(code: seq<Byte>, state: S.State, {params}, value: Word, data: seq<Byte>)
    requires Matches(code,ret) && Admitted({actuals}) && Good({i},state,{actuals})
    ensures M.Step(code,Destinations(ret),state,value,data) != S.Bad
    ensures var next := M.Step(code,Destinations(ret),state,value,data); {post}
  {{
    reveal Matches(); reveal Good(); reveal M.Step(); reveal S.Step();
{fetch}    assert S.Fetch(code,{n['pc']}) == S.Op({n['op']},{n['next']},{n['immediate']});
{guide}
  }}
'''
        judgment=f'P.Judge({kind},length,actual,lower,higher)'
        specpost=(f'state == S.Running(ret,prefix+[if {judgment} == P.Holds then 1 else 0],mem)' if verdict not in ['P.BadData','P.BadRange'] else f'state == S.Reverted(P.Error({judgment},entry,param,index,length))')
        calls='\n'.join(f'    {"if" if i==0 else "else if"} id == {i} {{ Advance{i}(code,state,{actuals},value,data); }}' for i in range(len(states)))
        text+=f'''  lemma Start({params})
    requires Admitted({actuals})
    ensures Good(0,S.Running(10646,prefix+[ret,actual,constraint,entry,param,index],mem),{actuals})
  {{ reveal Good(); }}
  lemma Advance(id: nat, code: seq<Byte>, state: S.State, {params}, value: Word, data: seq<Byte>)
    requires Matches(code,ret) && Admitted({actuals}) && Good(id,state,{actuals}) && id < {len(states)}
    ensures M.Step(code,Destinations(ret),state,value,data) != S.Bad
    ensures var next := M.Step(code,Destinations(ret),state,value,data);
      if id == {len(states)-1} then next == {final} else Good(id+1,next,{actuals})
  {{
{calls}
  }}
  ghost method Run(code: seq<Byte>, {params}, value: Word, data: seq<Byte>) returns (state: S.State, trace: seq<S.State>)
    requires Matches(code,ret) && Admitted({actuals})
    ensures {specpost}
    ensures E.Trace(code,Destinations(ret),value,data,trace)
    ensures trace[0] == S.Running(10646,prefix+[ret,actual,constraint,entry,param,index],mem) && trace[|trace|-1] == state
    ensures |trace| == {len(states)+1}
  {{
    state := S.Running(10646,prefix+[ret,actual,constraint,entry,param,index],mem);
    Start({actuals});
    trace := [state];
    var id: nat := 0;
    while id < {len(states)}
      invariant id <= {len(states)} && |trace| == id+1
      invariant E.Trace(code,Destinations(ret),value,data,trace)
      invariant trace[0] == S.Running(10646,prefix+[ret,actual,constraint,entry,param,index],mem) && trace[|trace|-1] == state
      invariant id < {len(states)} ==> Good(id,state,{actuals})
      invariant id == {len(states)} ==> state == {final}
      decreases {len(states)}-id
    {{
      Advance(id,code,state,{actuals},value,data);
      var next := M.Step(code,Destinations(ret),state,value,data);
      E.Extend(code,Destinations(ret),value,data,trace,next);
      trace := trace+[next];
      state := next;
      id := id+1;
    }}
  }}
}}
'''
        (out/(name+'.generated.dfy')).write_text(text)
        (out/(name+'.mapping.json')).write_text(json.dumps({'runtimeSha256':hashlib.sha256(code).hexdigest(),'runtimeBytes':len(code),'entryPc':10646,'condition':pred,'kind':kind,'requiredBytes':required,'states':states,'finalStack':finalstack,'scope':'complete internal leaf helper under caller-discharge representation premises; public entries and OR validation not yet connected'},indent=2)+'\n')
        print(name,len(states),'states')
    (out/'inventory.json').write_text(json.dumps({'runtimeSha256':hashlib.sha256(code).hexdigest(),'entryPc':10646,'cases':inventory,'requiredBytes':allbytes},indent=2)+'\n')
    names=[item['name'] for item in inventory];includes='\n'.join(f'include "{name}.generated.dfy"' for name in names)
    imports='\n'.join(f'  import C{i} = AssertionsConstraint{name}' for i,name in enumerate(names))
    matches=' &&\n    '.join(f'C{i}.Matches(code,ret)' for i in range(len(names)))
    destinations={q for q in allbytes if q in dests};destination_expr=','.join(map(str,sorted(destinations)))+',ret'
    globalparams=params.replace('ret: Word, actual: Word,','ret: Word, kind: Word, actual: Word,');globalactuals=actuals.replace('ret,actual,','ret,kind,actual,')
    certificate=f'''// SPDX-License-Identifier: MIT
// Complete exact internal non-OR leaf helper; caller representation remains explicit.
{includes}
module AssertionsConstraintConnection {{
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import P = AssertionsConstraintSpec
  import E = AssertionsConstraintExecution
{imports}
  type Word = S.Word
  type Byte = S.Byte
  predicate Admitted({globalparams}) {{
    kind <= 8 && kind != 6 && P.Memory(mem,constraint,reference,free,kind,length,lower,higher) &&
    |prefix| <= 1000 && ret in {{7993,8035}}
  }}
  opaque predicate Matches(code: seq<Byte>, ret: Word) {{
    {matches}
  }}
  function Destinations(ret: Word): set<nat> {{ {{{destination_expr}}} }}
  predicate Result(state: S.State, ret: Word, kind: Word, actual: Word, length: Word,
                   lower: Word, higher: Word, entry: Word, param: Word, index: Word,
                   prefix: seq<Word>, mem: seq<Byte>)
    requires kind <= 8 && kind != 6
  {{
    var verdict := P.Judge(kind,length,actual,lower,higher);
    if verdict in {{P.BadData,P.BadRange}} then state == S.Reverted(P.Error(verdict,entry,param,index,length))
    else state == S.Running(ret,prefix+[if verdict == P.Holds then 1 else 0],mem)
  }}
'''
    for i,item in enumerate(inventory):
        certificate+=f'''  lemma Binding{i}(code: seq<Byte>, ret: Word)
    requires Matches(code,ret)
    ensures C{i}.Matches(code,ret) && C{i}.Destinations(ret) <= Destinations(ret)
  {{ reveal Matches(); }}
'''
    certificate+=f'''  ghost method {{:isolate_assertions}} Run(code: seq<Byte>, {globalparams}, value: Word, data: seq<Byte>) returns (state: S.State, trace: seq<S.State>)
    requires Matches(code,ret) && Admitted({globalactuals})
    ensures Result(state,ret,kind,actual,length,lower,higher,entry,param,index,prefix,mem)
    ensures E.Trace(code,Destinations(ret),value,data,trace)
    ensures trace[0] == S.Running(10646,prefix+[ret,actual,constraint,entry,param,index],mem) && trace[|trace|-1] == state
  {{
'''
    # Case partitions are independent of a candidate's executed branch choices.
    # Native coverage therefore fails if regenerated candidate paths differ.
    for i,item in enumerate(inventory):
        condition=f'kind == {item["kind"]} && ({item["condition"]})'
        certificate+=f'''    {"if" if i==0 else "else if"} {condition} {{
      Binding{i}(code,ret);
      state,trace := C{i}.Run(code,{actuals},value,data);
      E.WidenTrace(code,C{i}.Destinations(ret),Destinations(ret),value,data,trace);
    }}
'''
    certificate+='    else { assert false; }\n  }\n}\n'
    (out/'Connection.generated.dfy').write_text(certificate)
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);p.add_argument('--runtime',type=Path);p.add_argument('--dafny',type=Path);a=p.parse_args();generate(a.output,a.runtime)
    if a.dafny:
        env=dict(os.environ,DAFNY=str(a.dafny.resolve()))
        subprocess.run([sys.executable,'-B',ROOT/'formal/bytecode/format-generated.py','--output',a.output,'--include-root',HERE],env=env,check=True)
