#!/usr/bin/env python3
"""Inventory actual guard paths in preserved EVM traces; not native evidence."""
import argparse, hashlib, json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
p = argparse.ArgumentParser()
p.add_argument('--fixtures', type=Path, required=True)
p.add_argument('--output', type=Path, required=True)
a = p.parse_args()
assert not a.output.exists()
artifact = ROOT/'artifacts/contracts/Collections.sol/Collections.json'
code = bytes.fromhex(json.loads(artifact.read_text())['deployedBytecode'][2:])
digest = hashlib.sha256(code).hexdigest()
assert digest == json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Collections']['runtimeSha256']
ins, pc = {}, 0
while pc < len(code):
    op = code[pc]
    width = op-95 if 96 <= op <= 127 else 0
    ins[pc] = (op, code[pc:pc+1+width].hex())
    pc += 1+width
files = [HERE/'inspect-paths.py', HERE/'README.md', artifact,
         ROOT/'contracts/Collections.sol', ROOT/'formal/bytecode/dispatch/inventory.json']
initial = {str(f): sha(f) for f in files}
rows = []
for mode in ['map', 'filter']:
    for kind in ['fail', 'signal', 'longSignal']:
        f = a.fixtures/(mode+'-callback-'+kind+'.json')
        m = json.loads(f.read_text())
        assert m['runtimeSha256'] == digest
        logs = [s for s in m['trace']['structLogs'] if s['depth'] == 1]
        start = next(i for i,s in enumerate(logs) if s['pc'] == 16107)
        guard = logs[start:]
        end = next(i for i,s in enumerate(guard) if s['pc'] in [16171,17017])
        guard = guard[:end+1]
        gas = next(i for i,s in enumerate(guard) if s['pc'] == 16136)
        nat = lambda x: int(x,16)
        before = nat(guard[0]['stack'][-2])
        after = nat(guard[gas+1]['stack'][-1])
        ret = bytes.fromhex(m['calls'][-1]['returned'])
        exhausted = after <= before//63
        signaled = len(ret) == 4 and ret.hex() == 'd271060e'
        refused = exhausted or signaled
        assert guard[-1]['pc'] == (16171 if refused else 17017)
        assert m['expected'].startswith('d271060e' if refused else '117cf6f6')
        for s in guard:
            op, _ = ins[s['pc']]
            names = {0x01:'ADD',0x03:'SUB',0x04:'DIV',0x11:'GT',0x14:'EQ',0x15:'ISZERO',0x16:'AND',0x19:'NOT',0x1b:'SHL',0x50:'POP',0x51:'MLOAD',0x56:'JUMP',0x57:'JUMPI',0x5a:'GAS',0x5b:'JUMPDEST',0x5f:'PUSH0'}
            name = 'PUSH'+str(op-95) if 96 <= op <= 127 else 'DUP'+str(op-127) if 128 <= op <= 143 else 'SWAP'+str(op-143) if 144 <= op <= 159 else names[op]
            assert s['op'] == name
        rows.append(dict(fixture=str(f),fixtureSha256=sha(f),gasBefore=str(before),
                         gasAfter=str(after),returnedBytes=len(ret),exhausted=exhausted,
                         exactFourByteSignal=signaled,refused=refused,
                         path=[dict(pc=s['pc'],op=s['op'],bytes=ins[s['pc']][1]) for s in guard]))
        initial[str(f)] = sha(f)
assert all(sha(Path(f)) == h for f,h in initial.items())
a.output.mkdir(parents=True)
(a.output/'manifest.json').write_text(json.dumps(dict(
    status='development-existing-physical-guard-path-inventory-not-native-evidence',
    runtimeSha256=digest,inputSha256=initial,inputsUnchanged=True,cases=rows,
    scope='Six preserved EVM paths checked against exact guard decision/bytes. No new EVM run, native proof, gas-cost/deployment or public coverage claim.',
    remaining=['Native guard controls and truthful GAS binding.',
               'Physical low-gas/failed empty/ordinary4-byte/nonzero-padding signal geometries.',
               'Complete dynamic CallbackFailed serializer/raw prefix/fresh retained graph.']),indent=2)+'\n')
print('PASS six preserved physical guard paths; native/full fresh evidence remains open')
