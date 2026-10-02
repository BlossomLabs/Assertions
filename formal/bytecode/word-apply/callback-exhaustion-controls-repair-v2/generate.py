#!/usr/bin/env python3
"""Extract complete physical failed-callback exhaustion decisions, including GAS."""
import argparse, hashlib, json, subprocess, sys
from pathlib import Path
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
CASES = [('OtherLengthExhausted',False,True,False),
         ('FourLengthExhausted',True,True,False),
         ('OtherLengthContinue',False,False,False),
         ('FourLengthSignal',True,False,True),
         ('FourLengthContinue',True,False,False)]


def generate(out):
    artifact = ROOT/'artifacts/contracts/Collections.sol/Collections.json'
    code = bytes.fromhex(json.loads(artifact.read_text())['deployedBytecode'][2:])
    digest = hashlib.sha256(code).hexdigest()
    assert digest == json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Collections']['runtimeSha256']
    out.mkdir(parents=True,exist_ok=True)
    params = 'mem: seq<Byte>,prefix: seq<Word>,receipt: Word,length: Word,head: Word,gasBefore: Word,gasAfter: Word,self: Word,value: Word,data: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>'
    args = 'mem,prefix,receipt,length,head,gasBefore,gasAfter,self,value,data,returned,cursor,observations'
    for name,four,exhausted,signal in CASES:
        stack,states,required,pc,stage = ['17017','gasBefore','receipt'],[],{},16107,0
        while pc not in [16171,17017]:
            op=code[pc];width=op-95 if 96<=op<=127 else 0;nxt=pc+1+width
            imm=int.from_bytes(code[pc+1:nxt],'big')
            required.update({p:code[p] for p in range(pc,nxt)})
            states.append(dict(id=len(states),pc=pc,op=op,next=nxt,immediate=imm,stack=stack.copy(),cursorDelta=stage))
            assert len(states)<80
            if op==95:stack.append('0')
            elif 96<=op<=127:stack.append(str(imm))
            elif 128<=op<=143:stack.append(stack[-(op-127)])
            elif 144<=op<=159:
                k=op-143;stack[-1],stack[-1-k]=stack[-1-k],stack[-1]
            elif op==80:stack.pop()
            elif op==81:
                addr=stack.pop();assert addr in ['receipt','receipt+32'];stack.append('length' if addr=='receipt' else 'head')
            elif op==1:
                a,b=stack.pop(),stack.pop();assert (a,b) in [('32','receipt'),('receipt','32')];stack.append('receipt+32')
            elif op==3:
                a,b=stack.pop(),stack.pop()
                if (a,b)==('4','length'):stack.append('H.Difference(length)')
                else:assert (a,b)==('W.Unit()','1');stack.append('W.Unit()-1')
            elif op==4:
                a,b=stack.pop(),stack.pop();assert (a,b)==('gasBefore','63');stack.append('gasBefore/63')
            elif op==27:
                a,b=stack.pop(),stack.pop()
                if (a,b)==('224','1'):stack.append('W.Unit()')
                else:assert (a,b)==('225',str(0x69388307));stack.append('O.Header()')
            elif op==25:assert stack.pop()=='W.Unit()-1';stack.append('W.HighMask()')
            elif op==22:
                a,b=stack.pop(),stack.pop();assert b=='W.HighMask()' and a==('head' if four else '0');stack.append('H.Masked(head)' if four else '0')
            elif op==17:
                a,b=stack.pop(),stack.pop();assert (a,b)==('gasAfter','gasBefore/63');stack.append('0' if exhausted else '1')
            elif op==20:
                a,b=stack.pop(),stack.pop();assert a=='O.Header()' and b==('H.Masked(head)' if four else '0');stack.append('1' if signal else '0')
            elif op==21:
                a=stack.pop();assert a in ['0','1'];stack.append('1' if a=='0' else '0')
            elif op==90:stack.append('gasAfter');stage+=1;assert stage==1
            elif op==86:pc=int(stack.pop());continue
            elif op==87:
                dest,condition=stack.pop(),stack.pop()
                if condition=='H.Difference(length)':jump=not four
                elif condition=='63':jump=True
                else:assert condition in ['0','1'];jump=condition=='1'
                pc=int(dest) if jump else nxt;continue
            else:assert op==91,(pc,op,stack)
            pc=nxt
        assert pc==(16171 if exhausted or signal else 17017)
        assert stage==1
        states.append(dict(id=len(states),pc=pc,stack=stack.copy(),cursorDelta=stage,terminal=True))
        destinations={23562,23576,16124,16135,16165,16195,17017}
        for p in destinations:assert code[p]==91;required[p]=91
        capacity=1024-max(len(s['stack']) for s in states)
        admitted=f'H.Fits(mem,receipt,length,head) && X.Context(self) && |prefix| <= {capacity} && cursor < |observations| && observations[cursor] == X.Gas(gasAfter) && '
        admitted+=('length == 4' if four else 'length != 4')+' && '+('gasAfter <= gasBefore/63' if exhausted else 'gasAfter > gasBefore/63')
        if four and not exhausted:admitted+=' && H.Masked(head) '+('==' if signal else '!=')+' O.Header()'
        literal=lambda s:f"X.Frame(Running({s['pc']},prefix+[{','.join(s['stack'])}],mem),returned,cursor+{s['cursorDelta']})"
        matches=' &&\n    '.join(f'code[{p}] == {v}' for p,v in sorted(required.items()))
        good='\n'.join('    '+('if' if s['id']==0 else 'else if')+f" id == {s['id']} then frame == {literal(s)}" for s in states)+'\n    else false'
        text=f'''// SPDX-License-Identifier: MIT
// Generated from complete runtime guard path; GAS consumes a truthful observation.
include "Scalar.dfy"
include "../../scans/Push.dfy"
module BytecodeApplyCallbackExhaustion{name} {{
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import X = BytecodeExternalMachine
  import C = BytecodeCopyMachine
  import E = BytecodeExternalExecution
  import F = BytecodeScanFetch
  import P = BytecodeScanPush
  import H = BytecodeApplyCallbackExhaustionScalar
  import W = BytecodeApplyWrongCallbackScalar
  import O = BytecodeApplyCallbackOutOfGasReturnMemory
  opaque predicate Matches(code: seq<Byte>) {{ |code| == {len(code)} && {matches} }}
  function Destinations(): set<nat> {{ {{{','.join(map(str,sorted(destinations)))}}} }}
  opaque predicate Admitted({params}) {{ {admitted} }}
  lemma Admission({params})
    requires Admitted({args})
    ensures {admitted}
  {{ reveal Admitted(); }}
  opaque predicate Good(id: nat,frame: X.Frame,{params}) {{ Admitted({args}) && H.Fits(mem,receipt,length,head) && (
{good}) }}
'''
        for s in states[:-1]:
            i=s['id'];op=s['op']
            facts='    H.Arithmetic(length); H.Bounds(mem,receipt,length,head);\n'
            if op==27:facts+='    W.UnitLiteral(); O.Literal();\n'
            if op==25:facts+='    W.NotLiteral();\n'
            if op==22:facts+='    H.Projection(head); H.Projection(0); H.ZeroMask();\n'
            fetch=''
            if 96<=op<=127:
                fetch=f"    {'P.Push4' if op==99 else 'F.Push2' if op==97 else 'F.Push1'}(code,{s['pc']});\n"
                assert op in [96,97,99]
            text+=f'''  lemma Advance{i}(code: seq<Byte>,frame: X.Frame,{params})
    requires Matches(code) && Admitted({args}) && Good({i},frame,{args})
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures Good({i+1},X.Step(code,Destinations(),frame,self,value,data,observations),{args})
  {{ hide G.BitAnd(); hide BitNot(); hide H.Masked(); reveal Matches(); reveal Good();
    Admission({args});
{facts}    assert frame == {literal(s)};
{fetch}    assert Fetch(code,{s['pc']}) == Op({op},{s['next']},{s['immediate']});
'''
            if op==90:text+='    reveal X.Step();\n'
            else:text+='    X.Delegate(code,Destinations(),frame,self,value,data,observations);\n    C.Delegate(code,Destinations(),frame.state,value,data); reveal Step();\n'
            text+='  }\n'
        joins=[]
        for start in range(0,len(states)-1,20):
            end=min(start+20,len(states)-1);block=start//20
            calls='\n'.join(f'    Advance{i}(code,frame,{args});\n    var next{i} := X.Step(code,Destinations(),frame,self,value,data,observations);\n    E.Extend(code,Destinations(),self,value,data,observations,trace,next{i});trace := trace+[next{i}];frame := next{i};' for i in range(start,end))
            text+=f'''  ghost method Block{block}(code: seq<Byte>,initial: X.Frame,{params}) returns (frame: X.Frame,trace: seq<X.Frame>)
    requires Matches(code) && Admitted({args}) && Good({start},initial,{args})
    ensures Good({end},frame,{args}) && E.Trace(code,Destinations(),self,value,data,observations,trace)
    ensures |trace| == {end-start+1} && trace[0] == initial && trace[|trace|-1] == frame
  {{ hide E.Trace(); frame := initial;trace := [frame];
    assert E.Trace(code,Destinations(),self,value,data,observations,trace) by {{ reveal E.Trace(); }}
{calls}
  }}
'''
            joins.append(f'    frame,part := Block{block}(code,frame,{args});\n    E.Join(code,Destinations(),self,value,data,observations,trace,part);trace := trace+part[1..];')
        calls='\n'.join(joins)
        text+=f'''  ghost method Run(code: seq<Byte>,{params}) returns (frame: X.Frame,trace: seq<X.Frame>)
    requires Matches(code) && Admitted({args})
    ensures frame == {literal(states[-1])}
    ensures E.Trace(code,Destinations(),self,value,data,observations,trace)
    ensures |trace| == {len(states)} && trace[0] == {literal(states[0])} && trace[|trace|-1] == frame
  {{ hide E.Trace(); Admission({args}); frame := {literal(states[0])};trace := [frame];reveal Good();
    var initial := frame;var part: seq<X.Frame>;
    assert prefix+[] == prefix;
    assert E.Trace(code,Destinations(),self,value,data,observations,trace) by {{ reveal E.Trace(); }}
{calls}
    assert trace[0] == initial;
  }}
}}
'''
        (out/(name+'.generated.dfy')).write_text(text)
        (out/(name+'.mapping.json')).write_text(json.dumps(dict(runtimeSha256=digest,states=states,requiredBytes=required,scope='Complete local guard path. Raw callback composition and retained graph remain open.'),indent=2)+'\n')
        print(name,len(states)-1,'instructions',flush=True)


if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();generate(a.output)
    subprocess.run([sys.executable,'-B',HERE.parent/'map-prefix/format-generated.py','--output',a.output,'--include-root',HERE],check=True)
