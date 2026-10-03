"""Concrete full-runtime addition regression; this is not universal proof credit.
Harness adapted from PR #5, commit 20df4c3b117c063c6b57fae13488fd34a666fe4b.
"""
import argparse, hashlib, json, sys
from pathlib import Path
ROOT = Path(__file__).resolve().parents[2]
def sha(b): return hashlib.sha256(b).hexdigest()
def canonical(x): return json.dumps(x, sort_keys=True, separators=(',', ':')).encode()
class Harness:
    def __init__(self, interpreter, vendor, runtime, profile):
        sys.path[:0] = [str(vendor), str(interpreter)]
        import _dafny, EVM, EvmFork, EvmState, Precompiled, Execution
        from eth.vm.forks.cancun import CancunVM
        from eth.vm.chain_context import ChainContext
        from eth.db.atomic import AtomicDB
        self.d = _dafny
        self.evm, self.fork, self.state = EVM, EvmFork, EvmState
        self.execution = Execution
        self.code, self.profile = runtime, profile
        def unavailable(*_):
            raise AssertionError('Unexpected external or cryptographic backend use')
        self.backend = Precompiled.T_Dispatcher(unavailable, unavailable)
        header = CancunVM.create_genesis_header(difficulty=0, gas_limit=30_000_000, timestamp=1)
        self.py_state = CancunVM.build_state(AtomicDB(), header, ChainContext(1))
        self.address = b'\x11'*20

    def initial(self, calldata, gas, value, code):
        st = self.evm.default__.Init(gas, self.backend, self.fork.default__.CANCUN,
                                    self.d.Seq([]), self.d.Seq(code))
        return self.state.State_EXECUTING(st.evm._replace(
            context=st.evm.context._replace(callData=self.d.Seq(calldata),
                                            callValue=value, writePermission=False)))

    def dafny(self, calldata, gas, value=0, code=None, fuel=None):
        code = self.code if code is None else code
        fuel = self.profile['stepLimit'] if fuel is None else fuel
        start = self.initial(calldata, gas, value, code)
        # The reusable native-verified driver determines the bounded outcome.
        driven = self.execution.default__.Run(start, fuel, self.d.Seq([]))
        st, trace = start, []
        for _ in range(fuel):
            if not st.is_EXECUTING:
                break
            pc = st.evm.pc
            op = code[pc] if pc < len(code) else 0
            assert op in self.profile['opcodeScope'], f'Unsupported profile opcode {op:#x}'
            trace.append({'pc':pc, 'op':op, 'gas':st.evm.gas,
                          'stack':[str(v) for v in st.evm.stack],
                          'memory':bytes(st.evm.memory).hex()})
            st = self.evm.default__.Execute(st)
        result = self.terminal(st)
        assert self.terminal(driven.state) == result, 'Driver/step replay disagreement'
        assert list(driven.pcs) == [row['pc'] for row in trace], 'Driver trace disagreement'
        if st.is_RETURNS:
            assert st.world == start.evm.world, 'World state changed'
            assert st.transient == start.evm.transient, 'Transient storage changed'
            assert st.substate == start.evm.substate, 'Substate changed'
        return result, trace

    @staticmethod
    def terminal(st):
        if st.is_EXECUTING:
            return {'kind':'fuel-exhausted', 'gas':st.evm.gas, 'pc':st.evm.pc}
        if st.is_RETURNS:
            return {'kind':'return', 'gas':st.gas, 'data':bytes(st.data).hex()}
        assert st.is_ERROR, 'Unexpected suspended external call'
        return {'kind':'revert' if st.error.is_REVERTS else 'fault',
                'gas':st.gas, 'data':bytes(st.data).hex()}

    def independent(self, calldata, gas, value=0, code=None):
        from eth.vm.message import Message
        from eth.exceptions import Halt, Revert
        from eth.vm.logic.invalid import InvalidOpcode
        code = self.code if code is None else code
        msg = Message(gas=gas, to=self.address, sender=self.address, value=value,
                      data=calldata, code=code, is_static=True)
        context = self.py_state.get_transaction_context_class()(gas_price=0, origin=self.address)
        comp = self.py_state.computation_class(self.py_state, msg, context)
        trace = []
        iterator = iter(comp.code)
        with comp:
            for _ in range(self.profile['stepLimit']):
                pc = comp.code.program_counter
                op = next(iterator)
                assert op in self.profile['opcodeScope'], f'Unsupported profile opcode {op:#x}'
                trace.append({'pc':pc, 'op':op, 'gas':comp.get_gas_remaining(),
                              'stack':[str(int.from_bytes(v, 'big') if isinstance(v, bytes) else v)
                                       for v in reversed(comp._stack.values)],
                              'memory':bytes(comp._memory._bytes).hex()})
                try:
                    comp.opcodes.get(op, InvalidOpcode(op))(computation=comp)
                except Halt:
                    break
            else:
                raise AssertionError('Independent step bound exhausted')
        result = {'kind':'revert' if comp.is_error and isinstance(comp.error, Revert)
                  else 'fault' if comp.is_error else 'return',
                  'gas':comp.get_gas_remaining(), 'data':comp.output.hex()}
        return result, trace

    def compare(self, name, calldata, gas, value=0, code=None, expected=None):
        d, dt = self.dafny(calldata, gas, value, code)
        p, pt = self.independent(calldata, gas, value, code)
        agree = d == p and dt == pt
        row = {'name':name, 'calldataSha256':sha(calldata), 'gasBudget':gas,
               'callValue':value, 'agree':agree, 'steps':len(dt),
               'traceSha256':sha(canonical(dt)), 'pcsSha256':sha(canonical([r['pc'] for r in dt])),
               'dafny':d, 'pyEvm':p}
        if expected is not None:
            row['specMatches'] = d['kind'] == expected['kind'] and d.get('data') == expected['data']
        assert agree, 'Full public trace/outcome disagreement: '+name
        return row




def cases():
    m, h = 2**256-1, 2**255
    unsigned = [(0,0),(7,19),(m,0),(m-1,1),(m,1),(h,h)]
    signed = [(0,0),(7,19),(-7,-19),(-19,7),(-h,h-1),(-h,0),
              (h-1,0),(h-1,1),(-h,-1),(h-1,h-1),(-h,-h),(-7,7)]
    return [(False,a,b) for a,b in unsigned]+[(True,a,b) for a,b in signed]

def expected(signed,a,b):
    s=a+b; fits=(-2**255<=s<2**255) if signed else (s<2**256)
    return {'kind':'return' if fits else 'revert',
            'data':((s%2**256).to_bytes(32,'big') if fits else
                    bytes.fromhex('4e487b71')+(17).to_bytes(32,'big')).hex()}

def run(interpreter,vendor,runtime,output):
    if output.exists(): raise ValueError('Evidence destination must be fresh')
    code=bytes.fromhex(runtime.read_text().strip())
    profile={'stepLimit':300,'opcodeScope':list(range(256))}
    h=Harness(interpreter,vendor,code,profile)
    rows=[];traces={}
    for signed,a,b in cases():
        selector=bytes.fromhex('a5f3c23b' if signed else '771602f7')
        calldata=selector+(a%2**256).to_bytes(32,'big')+(b%2**256).to_bytes(32,'big')
        name=('signed' if signed else 'unsigned')+f'-{a}-{b}'
        row=h.compare(name,calldata,100000,expected=expected(signed,a,b))
        assert row['specMatches'], name
        d,t=h.dafny(calldata,100000)
        row.update(signed=signed,a=str(a),b=str(b),instructionGas=100000-d['gas'])
        rows.append(row);traces[name]=t
    mutants=[]
    for name,pc,before,after,signed,a,b in [
        ('unsigned-arithmetic',20235,1,3,False,7,19),
        ('signed-arithmetic',20858,1,3,True,7,19),
        ('unsigned-overflow-branch',20239,0x15,0x5f,False,7,19),
        ('signed-overflow-branch',20874,0x15,0x5f,True,7,19),
        ('return-length',1337,32,31,False,7,19)]:
        assert code[pc]==before
        altered=bytearray(code);altered[pc]=after
        calldata=bytes.fromhex('a5f3c23b' if signed else '771602f7')+(a%2**256).to_bytes(32,'big')+(b%2**256).to_bytes(32,'big')
        row=h.compare(name,calldata,100000,code=bytes(altered),expected=expected(signed,a,b))
        row.update(pc=pc,runtimeSha256=sha(bytes(altered)),killed=not row['specMatches'])
        assert row['killed'], name
        mutants.append(row)
    report={'status':'passed','kind':'finite concrete conformance; no universal proof credit',
            'runtimeSha256':sha(code),'cases':rows,'traces':traces,'mutations':mutants,
            'backend':'callbacks raise if invoked','comparison':'Every PC, opcode, stack, memory and gas; exact terminal kind/data/gas'}
    output.parent.mkdir(parents=True,exist_ok=True)
    output.write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps({'cases':len(rows),'maxSteps':max(r['steps'] for r in rows),'maxGas':max(r['instructionGas'] for r in rows)}))
    return report

if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    for name in ['interpreter','vendor','runtime','output']: parser.add_argument('--'+name,type=Path,required=True)
    run(**vars(parser.parse_args()))
