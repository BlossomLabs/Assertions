"""Concrete production-block validation: compiled Dafny interpreter vs py-evm Cancun."""
import argparse, json, pathlib, random, sys
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('--interpreter',type=pathlib.Path,required=True)
parser.add_argument('--vendor',type=pathlib.Path,required=True)
parser.add_argument('--runtime',type=pathlib.Path,required=True)
parser.add_argument('--output',type=pathlib.Path,required=True)
args=parser.parse_args()
sys.path[:0]=[str(args.vendor),str(args.interpreter)]
import _dafny, EVM, EvmFork, EvmState, Memory, Precompiled
from eth.vm.forks.cancun import CancunVM
from eth.vm.chain_context import ChainContext
from eth.db.atomic import AtomicDB
from eth.vm.message import Message
from eth.exceptions import Halt, Revert
from eth.vm.logic.invalid import InvalidOpcode
from eth_utils import keccak

CODE=bytes.fromhex(args.runtime.read_text().strip())
SCOPE={0x20,0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x10,0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1b,0x1c,0x1d,0x50,0x51,0x52,0x53,0x56,0x57,0x58,0x59,0x5b,0x5e,0x5f,0xf3,0xfd,0xfe,*range(0x60,0xa0)}
def unavailable(*_):
    raise AssertionError('Unexpected cryptographic backend use outside smoke scope')
BACKEND=Precompiled.T_Dispatcher(unavailable,unavailable)
HEADER=CancunVM.create_genesis_header(difficulty=0,gas_limit=30_000_000,timestamp=1)
STATE=CancunVM.build_state(AtomicDB(),HEADER,ChainContext(1))
ADDRESS=b'\x11'*20
CONT=1423
GAS=100000
def fixture(helper,length=32,word=0,index=0,pointer=160):
    mem=bytearray(1024)
    mem[64:96]=(512).to_bytes(32,'big')
    payload=bytes((i*17+3)%256 for i in range(length))
    mem[pointer:pointer+32]=length.to_bytes(32,'big')
    mem[pointer+32:pointer+32+length]=payload
    return {'helper':helper,'entry':3975 if helper=='first' else 4031,
            'stack':[pointer,CONT] if helper=='first' else [index,word,CONT],
            'memory':bytes(mem),'length':length,'payload':payload,'word':word,'index':index}
def dafny(f,code=CODE):
    st=EVM.default__.Init(f.get('gas',GAS),BACKEND,f.get('fork',EvmFork.default__.CANCUN),_dafny.Seq(f['stack']),_dafny.Seq(code))
    st=EvmState.State_EXECUTING(st.evm._replace(memory=_dafny.Seq(f['memory']),pc=f['entry']))
    trace=[];mem=f['memory']
    for _ in range(80):
        if not st.is_EXECUTING: break
        if f.get('helper') in ('first','address') and st.evm.pc==CONT and len(st.evm.stack)==1:break
        assert code[st.evm.pc] in SCOPE, 'Unsupported smoke opcode'
        trace.append(st.evm.pc)
        st=EVM.default__.Execute(st)
        if st.is_EXECUTING:mem=bytes(st.evm.memory)
    else:raise AssertionError('Dafny step bound exhausted')
    if st.is_EXECUTING:
        return {'kind':'success','pc':st.evm.pc,'stack':list(st.evm.stack),'memory':mem.hex(),'gas':st.evm.gas,'trace':trace}
    if st.is_ERROR:
        return {'kind':'revert' if isinstance(st.error,EvmState.Error_REVERTS) else str(st.error), 'data':bytes(st.data).hex(),'memory':mem.hex(),'gas':st.gas,'trace':trace}
    if st.is_RETURNS:
        return {'kind':'success','pc':trace[-1]+1,'stack':[], 'memory':mem.hex(),'gas':st.gas,'trace':trace,'data':bytes(st.data).hex()}
    raise AssertionError('Unexpected Dafny outcome '+str(st))
def independent(f,code=CODE):
    msg=Message(gas=f.get('gas',GAS),to=ADDRESS,sender=ADDRESS,value=0,data=b'',code=code,is_static=True)
    ctx=STATE.get_transaction_context_class()(gas_price=0,origin=ADDRESS)
    comp=STATE.computation_class(STATE,msg,ctx)
    comp._memory.extend(0,len(f['memory']));comp.memory_write(0,len(f['memory']),f['memory'])
    for value in reversed(f['stack']):comp.stack_push_int(value)
    comp.code.program_counter=f['entry'];trace=[];iterator=iter(comp.code)
    with comp:
        for _ in range(80):
            pc=comp.code.program_counter
            if f.get('helper') in ('first','address') and pc==CONT and len(comp._stack.values)==1:break
            trace.append(pc);op=next(iterator)
            try:comp.opcodes.get(op,InvalidOpcode(op))(computation=comp)
            except Halt:break
        else:raise AssertionError('py-evm step bound exhausted')
    result={'memory':bytes(comp._memory._bytes).hex(),'gas':comp.get_gas_remaining(),'trace':trace}
    if comp.is_error:
        result.update(kind='revert' if isinstance(comp.error,Revert) else type(comp.error).__name__,data=comp.output.hex())
    else:result.update(kind='success',pc=comp.code.program_counter,stack=[int.from_bytes(v,'big') if isinstance(v,bytes) else v for v in reversed(comp._stack.values)])
    if trace and code[trace[-1]] in (0,0xf3) and not comp.is_error:
        result.update(stack=[],data=comp.output.hex())
    return result
def expected(f,r):
    if r['kind']=='revert':
        mem=bytes.fromhex(r['memory']);initial=f['memory'];free=int.from_bytes(initial[64:96],'big')
        if any(mem[i]!=initial[i] for i in range(len(initial)) if not free<=i<free+68):return False

    if f['helper']=='first':
        if f['length']<32:
            data=keccak(text='ReturnDataOutOfBounds(int256,uint256)')[:4]+bytes(32)+f['length'].to_bytes(32,'big')
            return r['kind']=='revert' and r['data']==data.hex()
        return r['kind']=='success' and r['stack']==[int.from_bytes(f['payload'][:32],'big')] and r['memory']==f['memory'].hex()
    if f['word']>=2**160:
        data=keccak(text='InvalidAddressWord(uint256,bytes32)')[:4]+f['index'].to_bytes(32,'big')+f['word'].to_bytes(32,'big')
        return r['kind']=='revert' and r['data']==data.hex()
    return r['kind']=='success' and r['stack']==[f['word']] and r['memory']==f['memory'].hex()
def generic_cases():
    mask=2**256-1
    programs=[('add-overflow',0x01,[mask,1],0),('multiply',0x02,[7,9],63),
              ('signed-div-negative',0x05,[(-9)&mask,2],(-4)&mask),
              ('signed-rem-negative',0x07,[(-9)&mask,2],(-1)&mask),
              ('and',0x16,[0x15,0x0f],5),('or',0x17,[0x10,3],19),('xor',0x18,[0x15,0x0f],26),
              ('left',0x1b,[160,1],2**160),('right',0x1c,[160,2**160],1),
              ('arithmetic-right',0x1d,[3,(-9)&mask],(-2)&mask),
              ('overshift-left',0x1b,[256,mask],0),('overshift-right',0x1c,[256,mask],0)]
    rows=[]
    for name,op,stack,w in programs:
        code=bytes([op,0x60,0,0x52,0x60,32,0x60,0,0xf3])
        f={'helper':'generic','entry':0,'stack':stack,'memory':bytes(1024)}
        d=dafny(f,code);p=independent(f,code)
        rows.append({'name':name,'agree':d==p,'specMatches':d.get('data')==w.to_bytes(32,'big').hex(),'dafny':d,'pyEvm':p})
    for name,dest,src,size in [('mcopy-overlap-forward',2,0,8),('mcopy-overlap-backward',0,2,8),('mcopy-empty',0,0,0)]:
        memory=bytes(range(32))+bytes(992)
        expected_memory=bytearray(memory);expected_memory[dest:dest+size]=memory[src:src+size]
        code=bytes([0x5e,0x00]);f={'helper':'generic','entry':0,'stack':[dest,src,size],'memory':memory}
        d=dafny(f,code);p=independent(f,code)
        rows.append({'name':name,'agree':d==p,'specMatches':d['memory']==expected_memory.hex(),'dafny':d,'pyEvm':p})
    return rows

def main():
    cases=[fixture('first',length=n,pointer=p) for n in [0,1,31,32,33,64] for p in [160,161,193]]
    cases += [fixture('address',word=w,index=i) for w in [0,2**160-1,2**160,2**256-1] for i in [0,2**256-1]]
    rng=random.Random(20260930)
    cases += [fixture('address',word=rng.getrandbits(256),index=rng.getrandbits(256)) for _ in range(20)]
    records=[]
    for i,f in enumerate(cases):
        d=dafny(f);p=independent(f)
        records.append({'case':i,'helper':f['helper'],'length':f['length'],'word':str(f['word']),'index':str(f['index']),
                        'agree':d==p,'specMatches':expected(f,d),'dafny':d,'pyEvm':p})
    mutations=[('length-guard',3978,33,fixture('first',length=32)),
               ('load-offset',4026,31,fixture('first',length=32)),
               ('address-width',4034,161,fixture('address',word=2**160)),
               ('error-index',4060,0x82,fixture('address',word=2**160,index=9))]
    mutant_records=[]
    for name,pc,op,f in mutations:
        mutated=bytearray(CODE);mutated[pc]=op
        d=dafny(f,bytes(mutated));p=independent(f,bytes(mutated))
        mutant_records.append({'name':name,'pc':pc,'agree':d==p,'killed':not expected(f,d),'dafny':d,'pyEvm':p})
    f=fixture('address',word=0);invalid=bytearray(CODE);invalid[f['entry']]=0xfe
    d=dafny(f,bytes(invalid));p=independent(f,bytes(invalid))
    rejected=d['kind']!='success' and p['kind']!='success' and d['gas']==p['gas']==0
    probe={'name':'invalid reachable opcode','rejected':rejected,'dafny':d,'pyEvm':p}
    f=fixture('address');f['entry']=2;f['stack']=[1]
    d=dafny(f,bytes([0x60,0x5b,0x56,0]));p=independent(f,bytes([0x60,0x5b,0x56,0]))
    boundary_ok=d['kind']!='success' and p['kind']!='success' and d['trace']==p['trace']==[2] and d['gas']==p['gas']==0
    boundary={'name':'PUSH data is not a jump destination','rejected':boundary_ok,'dafny':d,'pyEvm':p}
    safety=[]
    for name,code,stack,message in [
        ('unavailable cryptographic backend',bytes([0x20,0]),[0,0],'Unexpected cryptographic backend use'),
        ('unsupported smoke opcode',bytes([0x40,0]),[0],'Unsupported smoke opcode'),
        ('step bound exhaustion',bytes([0x5b,0x5f,0x56]),[],'Dafny step bound exhausted')]:
        f={'helper':'generic','entry':0,'stack':stack,'memory':bytes(1024)}
        try: dafny(f,code)
        except AssertionError as error: rejected_guard=message in str(error)
        else: rejected_guard=False
        safety.append({'name':name,'rejected':rejected_guard})
    for name,code,stack,gas in [('out of gas',bytes([0x60,1,0]),[],0),('stack underflow',bytes([1,0]),[],GAS)]:
        f={'helper':'generic','entry':0,'stack':stack,'memory':bytes(1024),'gas':gas}
        d=dafny(f,code);p=independent(f,code)
        safety.append({'name':name,'rejected':d['kind']!='success' and p['kind']!='success' and d['gas']==p['gas']==0,'dafny':d,'pyEvm':p})
    generic=generic_cases()
    report={'status':'passed' if all(r['agree'] and r['specMatches'] for r in records) and all(r['agree'] and r['killed'] for r in mutant_records) and rejected and boundary_ok and all(r['rejected'] for r in safety) and all(r['agree'] and r['specMatches'] for r in generic) else 'failed',
            'kind':'concrete validation only; not a universal proof','cases':records,'mutations':mutant_records,'negativeProbes':[probe,boundary]+safety,'genericCases':generic,'backend':'callbacks fail closed if used','opcodeScope':sorted(SCOPE)}
    args.output.write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps({'status':report['status'],'cases':len(records),'mutations':len(mutant_records),'genericCases':len(generic)}))
    return 0 if report['status']=='passed' else 1
if __name__=='__main__':raise SystemExit(main())
