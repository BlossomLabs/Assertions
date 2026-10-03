"""Complete public resolve calls: compiled DafnyEVM against independent Cancun execution.

This is finite concrete evidence. Universal dispatch/decoder/return correctness
is a separate proof obligation, even when every run and mutation passes.
"""
import argparse
import hashlib
import json
from pathlib import Path
import random
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
PROFILE = ROOT/'formal/bytecode/dafnyevm/public-resolve.json'


def sha(value):
    return hashlib.sha256(value).hexdigest()


def canonical(value):
    return json.dumps(value, sort_keys=True, separators=(',', ':')).encode()


def success_cases(profile):
    cases = []
    for length in profile['boundaryLengths']:
        for route in profile['routes']:
            payload = bytes((i*17+3+route)%256 for i in range(length))
            cases.append({'name':f'length-{length}-route-{route}', 'route':route,
                          'payload':payload.hex(), 'gas':profile['gasBudget']})
    rng = random.Random(profile['seed'])
    for i in range(profile['randomCases']):
        length = rng.randrange(profile['maximumPayloadLength']+1)
        cases.append({'name':f'random-{i}', 'route':rng.choice(profile['routes']),
                      'payload':rng.randbytes(length).hex(), 'gas':profile['gasBudget']})
    return cases


def independent_calldata(cases):
    request = [{'route':c['route'], 'payload':'0x'+c['payload']} for c in cases]
    result = subprocess.run(['node', str(ROOT/'formal/tools/public_resolve_abi.mjs')],
                            input=json.dumps(request), text=True, capture_output=True,
                            cwd=ROOT, check=True)
    encoded = json.loads(result.stdout)
    assert len(encoded) == len(cases), 'Empty or incomplete ABI oracle'
    return [bytes.fromhex(data[2:]) for data in encoded]


class Harness:
    def __init__(self, interpreter, vendor, runtime, profile):
        sys.path[:0] = [str(vendor), str(interpreter)]
        import _dafny, EVM, EvmFork, EvmState, Precompiled, Execution, PublicResolve, ResolutionModel
        from eth.vm.forks.cancun import CancunVM
        from eth.vm.chain_context import ChainContext
        from eth.db.atomic import AtomicDB
        self.d = _dafny
        self.evm, self.fork, self.state = EVM, EvmFork, EvmState
        self.execution, self.public, self.source = Execution, PublicResolve, ResolutionModel
        self.code, self.profile = runtime, profile
        def unavailable(*_):
            raise AssertionError('Unexpected external or cryptographic backend use')
        self.backend = Precompiled.T_Dispatcher(unavailable, unavailable)
        header = CancunVM.create_genesis_header(difficulty=0, gas_limit=30_000_000, timestamp=1)
        self.py_state = CancunVM.build_state(AtomicDB(), header, ChainContext(1))
        self.address = b'\x11'*20

    def encoded(self, route, payload):
        routes = [self.source.Route_TARGET(), self.source.Route_VALUE(), self.source.Route_CALL__DATA()]
        return bytes(self.public.default__.Calldata(routes[route], self.d.Seq(payload)))

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
            row['specMatches'] = d['kind'] == 'return' and d.get('data') == expected.hex()
        assert agree, 'Full public trace/outcome disagreement: '+name
        return row


def run(interpreter, vendor, runtime, output):
    assert not output.exists(), 'Public-call evidence must be fresh'
    profile = json.loads(PROFILE.read_text())
    code = bytes.fromhex(runtime.read_text().strip())
    assert sha(code) == profile['runtimeSha256'], 'Public profile runtime drift'
    h = Harness(interpreter, vendor, code, profile)
    cases = success_cases(profile)
    encoded = independent_calldata(cases)
    records = []
    for case, calldata in zip(cases, encoded):
        payload = bytes.fromhex(case['payload'])
        assert h.encoded(case['route'], payload) == calldata, 'Dafny/viem ABI disagreement'
        row = h.compare(case['name'], calldata, case['gas'], expected=payload)
        row.update(route=case['route'], length=len(payload), payloadSha256=sha(payload))
        assert row['specMatches'], 'Public resolve returned the wrong bytes'
        assert row['steps'] == profile['successInstructionCount'], 'Unbound success path'
        assert row['pcsSha256'] == profile['successPcsSha256'], 'Success path drift'
        records.append(row)
    probes = []
    # Measured instruction gas becomes an exact boundary probe, not a guessed bound.
    for index in profile['gasBoundaryCaseIndexes']:
        case, calldata, reference = cases[index], encoded[index], records[index]
        required = case['gas']-reference['dafny']['gas']
        for gas, kind in [(required, 'return'), (required-1, 'fault'), (0, 'fault')]:
            row = h.compare(f"gas-boundary-{index}-{gas}", calldata, gas)
            row['expectationMet'] = row['dafny']['kind'] == kind
            if kind == 'return':
                row['expectationMet'] &= row['dafny']['data'] == case['payload']
            else:
                row['expectationMet'] &= row['dafny']['gas'] == 0
            probes.append(row)
    base = next(i for i,c in enumerate(cases) if c['route'] == 0 and len(bytes.fromhex(c['payload'])) == 33)
    calldata, payload = encoded[base], bytes.fromhex(cases[base]['payload'])
    broken = []
    for name, data, value in [('empty-calldata', b'', 0), ('short-selector', calldata[:3], 0),
                              ('truncated-struct', calldata[:35], 0),
                              ('truncated-payload', calldata[:196+len(payload)-1], 0),
                              ('nonpayable-value', calldata, 1)]:
        row = h.compare(name, data, profile['gasBudget'], value)
        row['expectationMet'] = row['dafny']['kind'] == 'revert'
        broken.append(row)
    for name, start, word in [('invalid-fetcher',68,3),
                               ('data-offset-overflow',100,2**256-1),
                               ('length-overflow',164,2**256-1)]:
        data = bytearray(calldata); data[start:start+32] = word.to_bytes(32,'big')
        row = h.compare(name, bytes(data), profile['gasBudget'])
        row['expectationMet'] = row['dafny']['kind'] == 'revert'
        broken.append(row)
    probes += broken
    unused_route = bytearray(calldata); unused_route[36:68] = (3).to_bytes(32,'big')
    observation = h.compare('unused-route-tag-outside-canonical-profile', bytes(unused_route),
                            profile['gasBudget'], expected=payload)
    assert observation['specMatches'], 'Unused route observation changed'
    result, trace = h.dafny(calldata, profile['gasBudget'], fuel=profile['successInstructionCount']-1)
    probes.append({'name':'driver-fuel-exhaustion', 'expectationMet':result['kind']=='fuel-exhausted'
                   and len(trace)==profile['successInstructionCount']-1})
    mutants = []
    for mutation in profile['mutations']:
        altered = bytearray(code)
        pc = mutation['pc']
        assert altered[pc] == mutation['before'], 'Mutation site drift'
        altered[pc] = mutation['after']
        row = h.compare(mutation['name'], calldata, profile['gasBudget'], code=bytes(altered), expected=payload)
        row.update(pc=pc, killed=not row['specMatches'])
        mutants.append(row)
    passed = all(r['agree'] and r['specMatches'] for r in records)
    passed &= all(r['expectationMet'] for r in probes) and all(r['agree'] and r['killed'] for r in mutants)
    report = {'status':'passed' if passed else 'failed', 'scope':profile['scope'],
              'kind':'finite concrete public-call conformance; no universal bytecode credit',
              'profileSha256':sha(PROFILE.read_bytes()), 'runtimeSha256':sha(code),
              'cases':records, 'probes':probes, 'mutations':mutants,
              'outOfProfileObservations':[observation],
              'comparison':'Every pre-instruction PC, opcode, stack, memory and remaining gas; terminal verdict, returndata and gas.',
              'sourceAcceptance':False, 'bytecodeCredit':False}
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(report, indent=2)+'\n')
    assert passed, 'Public-call validation failed'
    return report


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ['interpreter','vendor','runtime','output']:
        parser.add_argument('--'+name, type=Path, required=True)
    args = parser.parse_args()
    report = run(args.interpreter, args.vendor, args.runtime, args.output)
    print(f"PASS {len(report['cases'])} public calls, {len(report['probes'])} probes, {len(report['mutations'])} mutants")
