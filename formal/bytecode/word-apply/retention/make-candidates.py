#!/usr/bin/env python3
"""Single-byte physical faults judged against unchanged success/error oracles."""
import argparse
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--output', type=Path, required=True)
    a = p.parse_args()
    out = a.output.resolve()
    out.mkdir(parents=True, exist_ok=False)
    code = bytes.fromhex(json.loads((ROOT / 'artifacts/contracts/Collections.sol/Collections.json').read_text())['deployedBytecode'][2:])
    sha = lambda b: hashlib.sha256(b).hexdigest()
    assert sha(code) == json.loads((ROOT / 'formal/bytecode/dispatch/inventory.json').read_text())['Collections']['runtimeSha256']
    base = 'formal/bytecode/word-apply/'
    faults = [
        ('wrong-abi-head', 21213, 32, 33, base+'serializer-repair-v2/generate.py', base+'serializer-repair-v2', 'Control.generated.dfy', 'BytecodeApplyBytesReturnControl.Advance11', 'map-count-0'),
        ('success-returns-revert', 498, 0xf3, 0xfd, base+'return-kind/generate.py', base+'return-kind', 'Control.generated.dfy', 'BytecodeApplyReturnKind.Terminal', 'filter-count-1'),
        ('predicate-error-returns-success', 1122, 0xfd, 0xf3, base+'retention/generate-predicate-candidate.py', base+'predicate-error-repair-v3', 'Predicate.generated.dfy', 'BytecodeApplyPredicateError.Advance87', 'filter-noncanonical-predicate'),
    ]
    results = []
    for name, pc, old, new, generator, package, source, symbol, fixture in faults:
        assert code[pc] == old
        candidate = bytearray(code)
        candidate[pc] = new
        runtime = name+'.bin'
        (out / runtime).write_bytes(candidate)
        results.append(dict(name=name, runtime=runtime, runtimeSha256=sha(candidate), baselineRuntimeSha256=sha(code), byteOffset=pc, before=old, after=new, generator=generator, package=package, source=source, nativeSymbol=symbol, evmFixture=fixture,
                            oracle='Unchanged ABI bytes, successful RETURN and exact predicate error REVERT native postconditions and independent PC-zero full receipts. Extraction refusal, hash drift, timeout and precondition failure do not count as a semantic contradiction.'))
    (out / 'candidates.json').write_text(json.dumps(results, indent=2)+'\n')
    print('Prepared', len(results), 'semantic single-byte faults')


if __name__ == '__main__':
    main()
