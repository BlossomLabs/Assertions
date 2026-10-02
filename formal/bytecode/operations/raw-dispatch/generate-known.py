#!/usr/bin/env python3
"""Generate physical routing prefixes ending before compiler-bound ABI wrappers."""
import argparse, hashlib, json, subprocess, sys
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[3]
def generate(out):
 mapping=json.loads((HERE/'Operations.mapping.json').read_text())
 artifact=json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text())
 code=bytes.fromhex(artifact['deployedBytecode'][2:]);assert hashlib.sha256(code).hexdigest()==mapping['runtimeSha256']
 nodes=mapping['states']
 text='''// SPDX-License-Identifier: MIT
// Generated exact physical prefix to compiler-bound Operations ABI wrappers.
include "Execution.dfy"
include "Operations.generated.dfy"
module OperationsRawKnownOperations {
  import opened OperationsRawDispatchMachine
  import G = OperationsRawDispatchPhysical
  import C = OperationsRawDispatchOperations
  import B = OperationsRawDispatchBridge
  import E = OperationsRawDispatchExecution
  predicate Admitted(value: Word,size: Word,word: Word) {
    value == 0 && size >= 4 && C.ExpectedSelector(Selector(word)) >= 0
  }
  opaque predicate Matches(code: seq<G.Byte>) {
    |code| == RUNTIME_BYTES && (forall i: nat | i < |C.Code()| :: code[i] == C.Code()[i])
  }
  lemma DestinationBytes(code: seq<G.Byte>)
    requires Matches(code)
    ensures forall d: nat | d in C.Destinations() :: d < |C.Code()| && d < |code| && C.Code()[d] == code[d]
  { reveal Matches(); }
'''.replace('RUNTIME_BYTES',str(len(code)))
 for n in nodes:
  i=n['id'];pc=n['pc'];stack=','.join(n['stack']);flag=str(n['init']).lower()
  text+=f'''  lemma Frame{i}(code: seq<G.Byte>,state: State,value: Word,size: Word,word: Word)
    requires Matches(code) && C.Good({i},state,value,size,word) && state.Running?
    requires state.pc !in C.Entries() && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && |state.stack| <= 3
    ensures B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {{
    reveal C.Good(); reveal Matches();
    assert state == Running({pc},[{stack}],{flag});
'''
  text+='    assert false;\n' if n.get('terminal')=='chosen' else f'    B.PrefixFetch(C.Code(),code,{pc});\n'
  text+='  }\n'
 calls='\n'.join('    '+('if' if n['id']==0 else 'else if')+f" id == {n['id']} {{ Frame{n['id']}(code,state,value,size,word); }}" for n in nodes)+'\n    else { reveal C.Good(); assert false; }'
 text+='''  lemma Frame(id: nat,code: seq<G.Byte>,state: State,value: Word,size: Word,word: Word)
    requires Matches(code) && C.Good(id,state,value,size,word) && state.Running?
    requires state.pc !in C.Entries() && Admitted(value,size,word)
    ensures state.pc+4 < |C.Code()| <= |code| && |state.stack| <= 3
    ensures B.FetchAgrees(C.Code(),code,state.pc)
    ensures Fetch(C.Code(),state.pc).op == 0x52 ==> !state.initialized
  {
CALLS
  }
  ghost method Run(code: seq<G.Byte>,value: Word,size: Word,word: Word) returns (state: G.State,trace: seq<G.State>)
    requires Matches(code) && Admitted(value,size,word)
    ensures state == G.Running(C.ExpectedSelector(Selector(word)) as nat,[Selector(word)],G.Store([],64,128))
    ensures E.Trace(code,C.Destinations(),value,size,word,trace)
    ensures trace[0] == G.Running(0,[],[]) && trace[|trace|-1] == state
    ensures forall i: nat | i < |trace| && trace[i].Running? :: |trace[i].stack| <= 3 && |trace[i].memory| <= 96
  {
    DestinationBytes(code);
    reveal C.Good();
    var abstractState := Running(0,[],false);
    var id: nat := 0;
    state := B.Project(abstractState); trace := [state];
    while abstractState.pc !in C.Entries()
      invariant Matches(code) && Admitted(value,size,word)
      invariant abstractState.Running? && C.Good(id,abstractState,value,size,word)
      invariant state == B.Project(abstractState)
      invariant E.Trace(code,C.Destinations(),value,size,word,trace) && trace[|trace|-1] == state
      invariant trace[0] == G.Running(0,[],[])
      invariant forall i: nat | i < |trace| && trace[i].Running? :: |trace[i].stack| <= 3 && |trace[i].memory| <= 96
      decreases C.Limit()-abstractState.pc
    {
      C.Advance(id,abstractState,value,size,word);
      Frame(id,code,abstractState,value,size,word);
      var next := Step(C.Code(),C.Destinations(),C.Entries(),abstractState,value,size,word);
      assert next.Running?;
      B.Step(C.Code(),code,C.Destinations(),C.Entries(),abstractState,value,size,word);
      var physicalNext := G.Step(code,C.Destinations(),state,value,size,word);
      assert physicalNext == B.Project(next);
      reveal C.Good();
      assert |physicalNext.stack| <= 3 && |physicalNext.memory| <= 96;
      E.Extend(code,C.Destinations(),value,size,word,trace,physicalNext);
      trace := trace+[physicalNext]; state := physicalNext;
      abstractState := next; id := C.NextId(id,value,size,word);
    }
    C.Advance(id,abstractState,value,size,word);
    var chosen := Step(C.Code(),C.Destinations(),C.Entries(),abstractState,value,size,word);
    assert chosen.Chosen?;
    assert chosen.entryPc == abstractState.pc;
    assert chosen.freePointer == abstractState.initialized;
    assert chosen.remaining == abstractState.stack;
  }
}
'''.replace('CALLS',calls)
 out.mkdir(parents=True,exist_ok=True);(out/'OperationsKnown.generated.dfy').write_text(text)
 (out/'OperationsKnown.mapping.json').write_text(json.dumps({'runtimeSha256':mapping['runtimeSha256'],'states':nodes,'scope':'Unverified physical prefix ending before each exact compiler-bound ABI wrapper; no body or public coverage claim.'},indent=2)+'\n')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();generate(a.output)
 subprocess.run([sys.executable,'-B',HERE/'format-generated.py','--output',a.output,'--include-root',HERE],check=True)
