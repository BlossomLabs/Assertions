#!/usr/bin/env python3
"""Compose immutable dispatch controls with physical byte memory, no body claims."""
import argparse,hashlib,json,subprocess,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
def generate(out):
 for name in ['Operations']:
  mapping=json.loads((HERE/f'{name}.mapping.json').read_text());code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts'/f'{name}.sol'/f'{name}.json').read_text())['deployedBytecode'][2:]);assert hashlib.sha256(code).hexdigest()==mapping['runtimeSha256'];nodes=mapping['states']
  text=f'''// SPDX-License-Identifier: MIT
// Generated physical connection to immutable retained dispatcher controls.
include "Execution.dfy"
include "{name}.generated.dfy"
module OperationsRawUnknown{name} {{
  import opened OperationsRawDispatchMachine
  import G = OperationsRawDispatchPhysical
  import C = OperationsRawDispatch{name}
  import B = OperationsRawDispatchBridge
  import E = OperationsRawDispatchExecution
  predicate Admitted(value: Word, size: Word, word: Word) {{
    value == 0 && size >= 4 && C.ExpectedSelector(Selector(word)) == -1
  }}
  opaque predicate Matches(code: seq<G.Byte>) {{
    |code| == {len(code)} && (forall i: nat | i < |C.Code()| :: code[i] == C.Code()[i])
  }}
  lemma DestinationBytes(code: seq<G.Byte>)
    requires Matches(code)
    ensures forall d: nat | d in C.Destinations() :: d < |C.Code()| && d < |code| && C.Code()[d] == code[d]
  {{ reveal Matches(); }}
'''
  for node in nodes:
   i=node['id'];pc=node['pc'];stack=','.join(node['stack']);flag=str(node['init']).lower()
   text+=f'''  lemma Frame{i}(code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good({i},state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {{
    reveal C.Good(); reveal Matches();
    C.Advance{i}(state,value,size,word);
    assert C.Expected(value,size,word) == -1;
    assert state == Running({pc},[{stack}],{flag});
    assert !Step(C.Code(),C.Destinations(),C.Entries(),state,value,size,word).Chosen?;
'''
   if node.get('terminal')=='chosen':text+='    assert false;\n'
   else:text+=f'    B.PrefixFetch(C.Code(),code,{pc});\n'
   text+='  }\n'
  dispatch='\n'.join('    '+('if' if n['id']==0 else 'else if')+f" id == {n['id']} {{ Frame{n['id']}(code,state,value,size,word); }}" for n in nodes)+'\n    else { reveal C.Good(); assert false; }'
  text+=f'''  lemma Frame(id: nat, code: seq<G.Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && C.Good(id,state,value,size,word) && state.Running? && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && state.pc !in C.Entries()
    ensures |state.stack| <= 3 && B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {{
{dispatch}
  }}
  lemma Start(value: Word, size: Word, word: Word)
    ensures C.Good(0,Running(0,[],false),value,size,word)
  {{ reveal C.Good(); }}
  ghost method Run(code: seq<G.Byte>, value: Word, size: Word, word: Word) returns (state: G.State, trace: seq<G.State>)
    requires Matches(code) && Admitted(value,size,word)
    ensures state == G.Reverted([])
    ensures E.Trace(code,C.Destinations(),value,size,word,trace)
    ensures trace[0] == G.Running(0,[],[]) && trace[|trace|-1] == state
    ensures forall i: nat | i < |trace| && trace[i].Running? :: |trace[i].stack| <= 3 && |trace[i].memory| <= 96
  {{
    DestinationBytes(code);
    Start(value,size,word);
    var abstractState := Running(0,[],false);
    var id: nat := 0;
    state := B.Project(abstractState);
    trace := [state];
    while abstractState.Running?
      invariant Matches(code) && Admitted(value,size,word)
      invariant abstractState.Running? ==> C.Good(id,abstractState,value,size,word)
      invariant !abstractState.Running? ==> abstractState.Rejected?
      invariant state == B.Project(abstractState)
      invariant E.Trace(code,C.Destinations(),value,size,word,trace) && trace[|trace|-1] == state
      invariant trace[0] == G.Running(0,[],[])
      invariant forall i: nat | i < |trace| && trace[i].Running? :: |trace[i].stack| <= 3 && |trace[i].memory| <= 96
      decreases if abstractState.Running? then C.Limit()-abstractState.pc else 0
    {{
      C.Advance(id,abstractState,value,size,word);
      Frame(id,code,abstractState,value,size,word);
      var next := Step(C.Code(),C.Destinations(),C.Entries(),abstractState,value,size,word);
      assert !next.Chosen?;
      B.Step(C.Code(),code,C.Destinations(),C.Entries(),abstractState,value,size,word);
      var physicalNext := G.Step(code,C.Destinations(),state,value,size,word);
      assert physicalNext == B.Project(next);
      if next.Running? {{
        Frame(C.NextId(id,value,size,word),code,next,value,size,word);
        assert |physicalNext.stack| <= 3 && |physicalNext.memory| <= 96;
      }}
      E.Extend(code,C.Destinations(),value,size,word,trace,physicalNext);
      trace := trace+[physicalNext];
      state := physicalNext;
      abstractState := next;
      id := C.NextId(id,value,size,word);
    }}
  }}
}}
'''
  out.mkdir(parents=True,exist_ok=True);(out/(name+'Unknown.generated.dfy')).write_text(text);(out/(name+'Unknown.mapping.json')).write_text(json.dumps({'runtimeSha256':mapping['runtimeSha256'],'runtimeBytes':len(code),'dispatchDevelopmentMapping':'formal/bytecode/operations/raw-dispatch/Operations.mapping.json','modeledPrefixBytes':mapping['modeledPrefixBytes'],'states':nodes,'scope':'Development physical unknown-selector connection; complete retention/dependency/native/audit/EVM/mutation closure required.'},indent=2)+'\n');print(name,len(nodes),'physical frame certificates')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();generate(a.output)
 subprocess.run([sys.executable,'-B',HERE/'format-generated.py','--output',a.output,'--include-root',HERE],check=True)
