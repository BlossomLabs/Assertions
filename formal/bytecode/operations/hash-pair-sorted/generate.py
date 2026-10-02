#!/usr/bin/env python3
"""Derive complete constant-getter execution certificates from exact runtime bytes.

The certificate constrains every reached instruction/immediate byte. All other
runtime bytes remain arbitrary in the theorem, so it also applies to the exact
full runtime. No instruction count cut-off or symbolic branch is silently dropped.
"""
import argparse, hashlib, json
from pathlib import Path
if not __debug__: raise RuntimeError('Run without Python -O')
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[3]
MOD=1<<256
GETTERS={'Keep':('c203edb3','Hash(h,SortedPair(a,b))'),'Swap':('c203edb3','Hash(h,SortedPair(a,b))')}
CASES={'Keep':{'signature':'hashPairSorted(bytes32,bytes32)','guard':'a <= b','a':123,'b':456},'Swap':{'signature':'hashPairSorted(bytes32,bytes32)','guard':'a > b','a':456,'b':123}}


def signed(w):return w if w<MOD//2 else w-MOD

def generate(out,runtime=None):
    frozen=json.loads((HERE.parent/'inventory.json').read_text())
    artifact=json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text())
    code=runtime.read_bytes() if runtime else bytes.fromhex(artifact['deployedBytecode'][2:])
    if not runtime:assert hashlib.sha256(code).hexdigest()==frozen['runtimeSha256'] and len(code)==frozen['runtimeBytes']
    ins={};p=0
    while p<len(code):
        op=code[p];n=op-95 if 96<=op<=127 else 0
        ins[p]=(op,p+1+n,int.from_bytes(code[p+1:p+1+n].ljust(n,b'\0'),'big'));p+=1+n
    jumpdest={p for p,v in ins.items() if v[0]==0x5b}
    out.mkdir(parents=True,exist_ok=True)
    for name,(selector,result) in GETTERS.items():
        assert next(x['selector'] for x in frozen['publicEntries'] if x['signature']==CASES[name]['signature'])==selector
        word=int(selector,16)<<224;pc=0;stack=[];expr=[];memory='[]';memory_values={};store_history=[];nodes=[];seen=set();reachedbytes={};visited_entry=False
        while True:
            assert pc in ins,'Not an instruction boundary'
            state=(pc,tuple(stack),tuple(expr),memory)
            assert state not in seen,'Repeated complete state: no termination certificate'
            seen.add(state);op,nxt,immediate=ins[pc]
            assert nxt<=len(code),'Truncated executed PUSH'
            for i in range(pc,nxt):reachedbytes[i]=code[i]
            node={'id':len(nodes),'pc':pc,'stack':expr.copy(),'memory':memory,'opcode':op,'next':nxt,'immediate':immediate};nodes.append(node)
            if pc==frozen['selectorToDeclaredEntryPc'][str(int(selector,16))]:visited_entry=True
            def pop():return stack.pop(),expr.pop()
            def push(v,e=None):stack.append(v);expr.append(str(v) if e is None else e)
            if op==0x5f or 0x60<=op<=0x63:push(immediate)
            elif op==0x34:push(0,'value')
            elif op==0x36:push(68,'size')
            elif op==0x35:
                offset=pop()[0];assert offset in [0,4,36];push({0:word,4:CASES[name]['a'],36:CASES[name]['b']}[offset],{0:'word',4:'a',36:'b'}[offset])
            elif op==0x1c:assert pop()[0]==224;pop();push(int(selector,16))
            elif 0x80<=op<=0x8f:
                k=op-0x7f;push(stack[-k],expr[-k])
            elif 0x90<=op<=0x9f:
                k=op-0x8f;stack[-1],stack[-1-k]=stack[-1-k],stack[-1];expr[-1],expr[-1-k]=expr[-1-k],expr[-1]
            elif op==0x50:pop()
            elif op==0x15:
                v,e=pop();push(int(v==0),'(if '+e+' == 0 then 1 else 0)' if any(t in e for t in ['size','a','b','Bit']) else None)
            elif op in [0x01,0x02,0x03,0x04,0x06,0x10,0x11,0x12,0x13,0x14,0x16,0x17,0x18,0x1b]:
                a,ae=pop();b,be=pop()
                v={0x01:lambda:(a+b)%MOD,0x02:lambda:(a*b)%MOD,0x03:lambda:(a-b)%MOD,0x04:lambda:0 if b==0 else a//b,0x06:lambda:0 if b==0 else a%b,0x10:lambda:int(a<b),0x11:lambda:int(a>b),0x12:lambda:int(signed(a)<signed(b)),0x13:lambda:int(signed(a)>signed(b)),0x14:lambda:int(a==b),0x16:lambda:a&b,0x17:lambda:a|b,0x18:lambda:a^b,0x1b:lambda:(b<<a)%MOD if a<256 else 0}[op]()
                symbolic=any(t in ae+be for t in ['size','a','b','word','Bit'])
                expressions={0x02:f'Product({ae},{be})',0x01:f'(({ae})+({be}))%Modulus()',0x03:f'(({ae})+Modulus()-({be}))%Modulus()',0x04:f'Quotient({ae},{be})',0x06:f'Remainder({ae},{be})',0x10:f'(if ({ae}) < ({be}) then 1 else 0)',0x11:f'(if ({ae}) > ({be}) then 1 else 0)',0x12:f'(if Signed({ae}) < Signed({be}) then 1 else 0)',0x13:f'(if Signed({ae}) > Signed({be}) then 1 else 0)',0x14:f'(if ({ae}) == ({be}) then 1 else 0)',0x16:f'BitAnd({ae},{be})',0x17:f'BitOr({ae},{be})',0x18:f'BitXor({ae},{be})',0x1b:f'Shift({be},{ae})'}
                push(v,expressions[op] if symbolic else None)
            elif op==0x20:
                offset=pop()[0];length=pop()[0];assert (offset,length)==(160,64);node['hashWindow']=[offset,length];push(1,f'Hash(h,{memory}[160..224])')
            elif op==0x52:
                offset=pop()[0];value,expression=pop();assert offset in [0,4,32,64,128,160,192,224],(name,pc,offset,value,expression,memory);store_history.append((memory,offset,expression));memory=f'Store({memory},{offset},{expression})';memory_values[offset]=(value,expression);node['store']=[offset,expression]
            elif op==0x51:
                offset=pop()[0];assert offset in memory_values;push(*memory_values[offset]);node['load']=offset;node['loadGuides']=store_history.copy();node['outputWord']=memory_values.get(224,(0,'0'))[1]
            elif op==0x5b:pass
            elif op in [0x56,0x57]:
                dest=pop()[0];take=op==0x56 or pop()[0]!=0
                assert dest in jumpdest,'Invalid JUMP destination';node['jump']=dest
                if take:nxt=dest
            elif op in [0xf3,0xfd]:
                offset,length=pop()[0],pop()[0];assert visited_entry
                if op==0xf3:assert (runtime or not name.endswith('Overflow')) and offset==224 and length==32;node['returned']=True;node['outputWord']=memory_values[offset][1]
                else:assert (runtime or name.endswith('Overflow')) and offset==0 and length==36;node['reverted']=True;node['panic']=17
                break
            else:raise ValueError(('Unsupported reached opcode',pc,hex(op)))
            pc=nxt
            assert len(stack)<=1024
        peakstack=max(len(n['stack']) for n in nodes)
        assert peakstack <= 1024
        dests=sorted({n['jump'] for n in nodes if 'jump' in n});required=reachedbytes|{p:code[p] for p in dests}
        constraints=' &&\n    '.join(f'code[{p}] == {v}' for p,v in sorted(required.items()))
        good='\n'.join('    '+('if' if n['id']==0 else 'else if')+f" id == {n['id']} then state == Running({n['pc']},[{','.join(n['stack'])}],{n['memory']})" for n in nodes)+'\n    else false'
        header=f'''// SPDX-License-Identifier: MIT
// Generated exact executed-byte certificate. Never edit directly.
include "Machine.dfy"
include "Binary.dfy"
module OperationsHashPairSorted{name} {{
  import opened OperationsHashPairSortedMachine
  import K = OperationsHashPairSortedBinaryKernel
  function Result(a: Word, b: Word, h: HashEngine): Word {{ {result} }}
  predicate Admitted(value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine) {{
    HashDomain(h,a,b) && value == 0 && 68 <= size < 0x10000000000000000 && Selector(word) == {int(selector,16)} && ({CASES[name]['guard']})
  }}
  opaque predicate Matches(code: seq<Byte>) {{
    |code| == {len(code)} &&
    {constraints}
  }}
  function Destinations(): set<nat> {{ {{{','.join(map(str,dests))}}} }}
  opaque predicate Good(id: nat, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine) {{
{good}
  }}
'''
        lemmas=[]
        for n in nodes:
            i=n['id'];pc=n['pc'];op=n['opcode'];stack='['+','.join(n['stack'])+']';mem=n['memory']
            guide=f'    reveal Good();\n    reveal Matches();\n    '+('' if op in [0x01,0x03] else 'reveal Step();\n    ')+f'assert state == Running({pc},{stack},{mem});\n    assert Fetch(code,{pc}) == Op({op},{n["next"]},{n["immediate"]});\n'
            if any('hashWindow' in past for past in nodes[:i+1]):
                left,right=memory_values[160][1],memory_values[192][1];guide+=f'    PairWindow({left},{right});\n'
            if op in [0x01,0x03]:
                prefix='['+','.join(n['stack'][:-2])+']';top=n['stack'][-1];below=n['stack'][-2]
                guide+=f'    var prefix: seq<Word> := {prefix};\n    assert state == Running({pc},prefix+[{below},{top}],{mem});\n'
                guide+=f"    K.{('AddStep' if op==0x01 else 'SubStep')}(code,Destinations(),{pc},{n['next']},prefix,{mem},{top},{below},value,size,word,a,b,h);\n"
            if op == 0x02:guide+='    \n'
            
            if op == 0x1b:guide+='    PanicShift();\n'

            if 'jump' in n:guide+=f'    assert {n["jump"]} in Destinations() && code[{n["jump"]}] == 91;\n'
            if 'load' in n:
                offset=n['load'];history=n['loadGuides'];j=max(j for j,item in enumerate(history) if item[1]==offset)
                base,stored_offset,v=history[j];guide+=f'    StoreLoad({base},{stored_offset},{v});\n'
                for base,stored_offset,v in history[j+1:]:guide+=f'    StoreFrame({base},{stored_offset},{v},{offset});\n'
            if 'hashWindow' in n:
                left,right=memory_values[160][1],memory_values[192][1];guide+=f'    PairWindow({left},{right});\n'
            if 'reverted' in n:guide+='    PanicStores(Store([],64,128),17);\n'
            if 'returned' in n:
                base,stored_offset,v=store_history[-1];guide+=f'    StoreLoad({base},{stored_offset},{v});\n'
            if 'store' in n:
                offset,v=n['store'];guide+=f'    StoreLoad({mem},{offset},{v});\n'
            post='next == Returned(Encode(Result(a,b,h),32))' if 'returned' in n else 'next == Reverted(Panic(17))' if 'reverted' in n else f'Good({i+1},next,value,size,word,a,b,h)'
            lemmas.append(f'''  lemma Advance{i}(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good({i},state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= {peakstack} && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); {post}
  {{
{guide}  }}
''')
        if True:
            hashes=[n for n in nodes if 'hashWindow' in n];assert len(hashes)==1;checkpoint=hashes[0]
            left,right=memory_values[160][1],memory_values[192][1]
            for symbol in ['SemanticPreimage','SemanticWitness']:
                fixed=('    requires a == 123 && b == 456\n' if name=='Keep' else '    requires a == 456 && b == 123\n') if symbol=='SemanticWitness' else ''
                lemmas.append(f"""  lemma {symbol}(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good({checkpoint['id']},state,value,size,word,a,b,h)
{fixed}    ensures state.Running? && |state.memory| >= 224
    ensures state.memory[160..224] == SortedPair(a,b)
  {{ reveal Good(); PairWindow({left},{right}); }}
""")
        calls='\n'.join(f'    Advance{i}(code,state,value,size,word,a,b,h);\n    state := Step(code,Destinations(),state,value,size,word,a,b,h);' for i in range(len(nodes)))
        tail=f'''  lemma Start(value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)\n    ensures Good(0,Running(0,[],[]),value,size,word,a,b,h)\n  {{ reveal Good(); }}\n  ghost method Run(code: seq<Byte>, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine) returns (state: State)
    requires Matches(code) && Admitted(value,size,word,a,b,h)
    ensures state == {"Returned(Encode(Result(a,b,h),32))" if not name.endswith("Overflow") else "Reverted(Panic(17))"}
  {{
    Start(value,size,word,a,b,h);
    state := Running(0,[],[]);
{calls}
  }}
}}
'''
        (out/(name+'.generated.dfy')).write_text(header+''.join(lemmas)+tail)
        (out/(name+'.mapping.json')).write_text(json.dumps({'name':name,'runtimeSha256':hashlib.sha256(code).hexdigest(),'runtimeBytes':len(code),'selector':selector,'specification':result,'maximumStackWords':peakstack,'certificateByteCount':len(required),'requiredBytes':required,'states':nodes,'candidateRuntime':bool(runtime)},indent=2)+'\n')
        print(name,len(nodes),'complete instruction states',len(required),'required runtime bytes')
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);p.add_argument('--runtime',type=Path);a=p.parse_args();generate(a.output,a.runtime)
