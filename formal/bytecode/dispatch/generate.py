#!/usr/bin/env python3
"""Generate per-instruction reachable dispatch states from exact runtime bytes."""
import argparse,hashlib,json,subprocess
from pathlib import Path
if not __debug__:raise RuntimeError('Run without Python -O')
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
def canonical(t):return '('+','.join(canonical(x) for x in t['components'])+')'+t['type'][5:] if t['type'].startswith('tuple') else t['type']
def compile_ids(solc):
    names=['contracts/Assertions.sol','contracts/Expressions.sol','contracts/Collections.sol','contracts/lib/AbiCodec.sol','contracts/lib/ERC8211.sol']
    req={'language':'Solidity','sources':{n:{'content':(ROOT/n).read_text()} for n in names},'settings':{'evmVersion':'cancun','outputSelection':{'*':{'*':['evm.methodIdentifiers','abi']}}}}
    proc=subprocess.run([str(solc),'--standard-json'],input=json.dumps(req),text=True,capture_output=True,check=True);data=json.loads(proc.stdout)
    assert not any(e['severity']=='error' for e in data.get('errors',[]));return data

def generate(name,solc,out,runtime=None):
    artifactpath=ROOT/'artifacts/contracts'/f'{name}.sol'/f'{name}.json';artifact=json.loads(artifactpath.read_text());code=runtime.read_bytes() if runtime is not None else bytes.fromhex(artifact['deployedBytecode'][2:])
    inventory=json.loads((HERE/'inventory.json').read_text())[name]
    if runtime is None:assert hashlib.sha256(code).hexdigest()==inventory['runtimeSha256'] and len(code)==inventory['runtimeBytes'],'Baseline runtime drift'
    assert '0.8.36+commit.8a079791' in subprocess.check_output([str(solc),'--version'],text=True)
    ids=compile_ids(solc)['contracts']['contracts/'+name+'.sol'][name]
    assert ids['abi']==artifact['abi'];methods=ids['evm']['methodIdentifiers'];assert methods==inventory['methodIdentifiers'],'ABI selector drift'
    instructions={};pc=0
    while pc<len(code):
        op=code[pc];n=op-95 if 96<=op<=127 else 0;instructions[pc]=(op,pc+1+n,int.from_bytes(code[pc+1:pc+1+n].ljust(n,b'\0'),'big'));pc+=1+n
    destinations={pc for pc,(op,_,_) in instructions.items() if op==91}
    entries={}
    for pc,(op,nxt,imm) in instructions.items():
        if op!=0x63 or f'{imm:08x}' not in methods.values():continue
        after=instructions.get(nxt)
        if after is None or after[0]!=0x14:continue
        push=instructions.get(after[1]);jump=instructions.get(push[1]) if push else None
        if push and push[0]==0x61 and jump and jump[0]==0x57:
            assert imm not in entries;entries[imm]=push[2]
    assert len(entries)==len(methods) and set(entries)=={int(v,16) for v in methods.values()}
    assert all(p in destinations for p in entries.values())
    parsed_entries=dict(entries)
    entries={int(k):v for k,v in inventory['selectorToDeclaredEntryPc'].items()}
    assert all(p in destinations for p in entries.values()),'Declared entry is not a valid runtime JUMPDEST'
    if runtime is None:assert parsed_entries==entries,'Baseline declared entry drift'
    # Symbolic stack expressions and all exact path conditions. Never drop a path.
    nodes=[]
    def visit(pc,stack,guard,initialized):
        ident=len(nodes);node={'id':ident,'pc':pc,'stack':list(stack),'guard':guard,'init':initialized};nodes.append(node)
        if pc in entries.values():node['terminal']='chosen';return ident
        op,nxt,imm=instructions[pc];s=list(stack);truth=None
        if op in [0x5f,0x60,0x61,0x63]:s.append(str(imm))
        elif op==0x34:s.append('value')
        elif op==0x36:s.append('size')
        elif op==0x80:s.append(s[-1])
        elif op==0x50:s.pop()
        elif op==0x15:s.append('(if '+s.pop()+' == 0 then 1 else 0)')
        elif op==0x35:assert s.pop()=='0';s.append('word')
        elif op==0x1c:assert s.pop()=='224';assert s.pop()=='word';s.append('Selector(word)')
        elif op in [0x10,0x11,0x14]:
            a,b=s.pop(),s.pop();s.append('(if '+a+{0x10:' < ',0x11:' > ',0x14:' == '}[op]+b+' then 1 else 0)')
        elif op==0x52:assert s.pop()=='64' and s.pop()=='128';initialized=True
        elif op==0x5b:pass
        elif op==0xfd:
            assert s[-2:]==['0','0'];node['terminal']='rejected';return ident
        elif op==0x57:
            dest=int(s.pop());condition=s.pop();assert dest in destinations and dest>pc;truth='('+condition+' != 0)'
            node['condition']=truth;node['yes']=visit(dest,s,'('+guard+' && '+truth+')',initialized);node['no']=visit(nxt,s,'('+guard+' && !'+truth+')',initialized);return ident
        else:raise ValueError(('Unsupported reachable opcode',pc,op))
        assert nxt>pc;node['next']=visit(nxt,s,guard,initialized);return ident
    visit(0,[],'true',False)
    limit=max(entries.values())+1;prefix=list(code[:limit]);select='\n'.join('    '+('if' if i==0 else 'else if')+f' s == {selector} then {dest}' for i,(selector,dest) in enumerate(sorted(entries.items())))+'\n    else -1'
    # A positive expected result identifies the compiler ABI wrapper PC, not its decoded body.
    header='''// SPDX-License-Identifier: MIT
// Generated from exact canonical runtime bytes by generate.py.
include "Machine.dfy"
module BytecodeDispatchNAME {
  import opened BytecodeDispatchMachine
  function At(i: nat): Byte { AT }
  function Code(): seq<Byte> { seq(LIMIT,i requires 0 <= i < LIMIT => At(i)) }
  predicate IsDestination(p: nat) { DESTS }
  predicate IsEntry(p: nat) { ENTRIES }
  function Destinations(): set<nat> { set p: nat | p < LIMIT && IsDestination(p) }
  function Entries(): set<nat> { set p: nat | p < LIMIT && IsEntry(p) }
  function Limit(): nat { LIMIT }
  function ExpectedSelector(s: Word): int {
SELECT
  }
  function Expected(value: Word, size: Word, word: Word): int {
    if value != 0 || size < 4 then -1 else ExpectedSelector(Selector(word))
  }
  function Result(state: State): int {
    if state.Chosen? then state.entryPc as int else -1
  }
  opaque predicate Good(id: nat, state: State, value: Word, size: Word, word: Word) {
GOOD
  }
  function NextId(id: nat, value: Word, size: Word, word: Word): nat {
NEXT
  }
'''
    good=[];nexts=[];lemmas=[]
    for node in nodes:
        i=node['id'];pc=node['pc'];stack='['+','.join(node['stack'])+']';init=str(node['init']).lower()
        condition=node.get('condition');nid='(if '+condition+' then '+str(node['yes'])+' else '+str(node['no'])+')' if condition else str(node.get('next',i))
        nexts.append('    '+('if' if i==0 else 'else if')+f' id == {i} then {nid}')
        good.append('    '+('if' if i==0 else 'else if')+f' id == {i} then state == Running({pc},{stack},{init}) && '+node['guard'])
        terminal=node.get('terminal')
        op,nxt,imm=instructions[pc]
        guide=f'    reveal Good();\n    assert state == Running({pc},{stack},{init});\n    assert Code()[{pc}] == {op};\n'
        if not terminal or terminal=='rejected':guide+=f'    assert {pc} !in Entries();\n    assert Fetch(Code(),{pc}) == Op({op},{nxt},{imm});\n'
        if op==0x57:
            dest=int(node['stack'][-1]);guide+=f'    assert {dest} in Destinations();\n    assert {dest} < |Code()| && Code()[{dest}] == 91;\n'
        guide+='    SelectorBound(word);\n'
        lemma=f'''  lemma Advance{i}(state: State, value: Word, size: Word, word: Word)
    requires Good({i},state,value,size,word)
    ensures state.Running? && state.pc < Limit()
    ensures Step(Code(),Destinations(),Entries(),state,value,size,word) != Bad
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Running? ==> Good(NextId({i},value,size,word),next,value,size,word) && state.pc < next.pc < Limit()
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            !next.Running? ==> next != Bad && Result(next) == Expected(value,size,word)
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Chosen? ==> next.freePointer && next.remaining == [Selector(word)]
  {{
{guide}  }}
'''
        lemmas.append(lemma)
    header=header.replace('NAME',name).replace('AT','\n'.join('    '+('if' if i==0 else 'else if')+f' i == {i} then {v}' for i,v in enumerate(prefix))+'\n    else 0').replace('DESTS',' || '.join('p == '+str(p) for p in sorted(destinations) if p<limit)).replace('ENTRIES',' || '.join('p == '+str(p) for p in sorted(entries.values()))).replace('LIMIT',str(limit)).replace('SELECT',select).replace('GOOD','\n'.join(good)+'\n    else false').replace('NEXT','\n'.join(nexts)+'\n    else 0')
    advance='''  lemma Advance(id: nat, state: State, value: Word, size: Word, word: Word)
    requires Good(id,state,value,size,word)
    ensures state.Running? && state.pc < Limit()
    ensures Step(Code(),Destinations(),Entries(),state,value,size,word) != Bad
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Running? ==> Good(NextId(id,value,size,word),next,value,size,word) && state.pc < next.pc < Limit()
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            !next.Running? ==> next != Bad && Result(next) == Expected(value,size,word)
    ensures var next := Step(Code(),Destinations(),Entries(),state,value,size,word);
            next.Chosen? ==> next.freePointer && next.remaining == [Selector(word)]
  {
    reveal Good();
CALLS
  }
  ghost method Run(value: Word, size: Word, word: Word) returns (state: State)
    ensures state.Chosen? || state.Rejected?
    ensures Result(state) == Expected(value,size,word)
    ensures state.Chosen? ==> state.freePointer && state.remaining == [Selector(word)]
  {
    reveal Good();
    state := Running(0,[],false);
    var id: nat := 0;
    while state.Running?
      invariant state != Bad
      invariant state.Running? ==> Good(id,state,value,size,word)
      invariant !state.Running? ==> Result(state) == Expected(value,size,word)
      invariant state.Chosen? ==> state.freePointer && state.remaining == [Selector(word)]
      decreases if state.Running? then Limit()-state.pc else 0
    {
      Advance(id,state,value,size,word);
      state := Step(Code(),Destinations(),Entries(),state,value,size,word);
      id := NextId(id,value,size,word);
    }
  }
}
'''
    calls='\n'.join('    '+('if' if i==0 else 'else if')+f' id == {i} {{ Advance{i}(state,value,size,word); }}' for i in range(len(nodes)))+'\n    else { assert false; }'
    out.mkdir(parents=True,exist_ok=True);(out/(name+'.generated.dfy')).write_text(header+'\n'.join(lemmas)+advance.replace('CALLS',calls))
    (out/(name+'.mapping.json')).write_text(json.dumps({'runtimeSha256':hashlib.sha256(code).hexdigest(),'runtimeBytes':len(code),'modeledPrefixBytes':len(prefix),'ABI':methods,'selectorToWrapper':entries,'actualEqualityTargets':parsed_entries,'candidateRuntime':runtime is not None,'reachableInstructionStates':len(nodes),'states':nodes},indent=2)+'\n')
    print(name,len(entries),'public selectors',len(nodes),'exact instruction states')
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--solc',type=Path,required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--runtime',type=Path);p.add_argument('--contract',choices=['Assertions','Expressions','Collections'],required=True);a=p.parse_args();generate(a.contract,a.solc,a.output,a.runtime)
