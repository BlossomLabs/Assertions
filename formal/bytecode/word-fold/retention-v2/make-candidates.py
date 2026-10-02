#!/usr/bin/env python3
"""Single-byte fold faults against fixed native and PC-zero EVM oracles."""
import argparse
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    out = args.output.resolve()
    out.mkdir(parents=True, exist_ok=False)
    code = bytes.fromhex(json.loads((ROOT / 'artifacts/contracts/Collections.sol/Collections.json').read_text())['deployedBytecode'][2:])
    sha = lambda value: hashlib.sha256(value).hexdigest()
    assert sha(code) == json.loads((ROOT / 'formal/bytecode/dispatch/inventory.json').read_text())['Collections']['runtimeSha256']
    base = 'formal/bytecode/word-fold/'
    faults = [
        ('scalar-return-size-33', 612, 32, 33, 'generate-scalar-candidate.py',
         'scalar-return', 'Range.generated.dfy', 'BytecodeFoldScalarReturnRange.Advance51', 'range-count-1'),
        ('successful-return-is-revert', 498, 0xf3, 0xfd, 'generate-scalar-candidate.py',
         'scalar-return', 'Words.generated.dfy', 'BytecodeFoldScalarReturnWords.Advance52', 'words-count-2'),
        ('callback-error-is-return', 1122, 0xfd, 0xf3, 'generate-error-candidate.py',
         'callback-failed-repair-v2', 'After.generated.dfy', 'BytecodeFoldCallbackFailedAfter.Advance20', 'bytes-callback-fail'),
    ]
    records = []
    for name, pc, before, after, generator, package, source, symbol, fixture in faults:
        assert code[pc] == before, (name, pc)
        candidate = bytearray(code)
        candidate[pc] = after
        runtime = name + '.bin'
        (out / runtime).write_bytes(candidate)
        records.append(dict(name=name, runtime=runtime, runtimeSha256=sha(candidate),
                            baselineRuntimeSha256=sha(code), byteOffset=pc, before=before, after=after,
                            generator=base+'retention/'+generator, package=base+package,
                            source=source, nativeSymbol=symbol, evmFixture=fixture,
                            oracle='Unchanged 32-byte successful RETURN or full CallbackFailed REVERT postcondition, with matching complete PC-zero physical receipt. Parser refusals, timeouts and precondition failures do not count.'))
    (out / 'candidates.json').write_text(json.dumps(records, indent=2)+'\n')
    print('Prepared', len(records), 'single-byte semantic fold candidates')


if __name__ == '__main__':
    main()
