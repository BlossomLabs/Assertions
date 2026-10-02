#!/usr/bin/env python3
"""Exact termination byte, with a fixed independent successful RETURN oracle."""
import argparse
import hashlib
import json
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--output', type=Path, required=True)
    a = p.parse_args()
    code = bytes.fromhex(json.loads((ROOT / 'artifacts/contracts/Collections.sol/Collections.json').read_text())['deployedBytecode'][2:])
    digest = hashlib.sha256(code).hexdigest()
    pin = json.loads((ROOT / 'formal/bytecode/dispatch/inventory.json').read_text())['Collections']
    assert digest == pin['runtimeSha256']
    assert pin['methodIdentifiers']['mapWords(bytes,address,bytes,uint256[])'] == 'ed6dc3be'
    assert pin['methodIdentifiers']['filterWords(bytes,address,bytes,uint256[])'] == '7787eb48'
    opcode = code[498]
    assert opcode in [0xf3, 0xfd], 'Unsupported physical terminal opcode'
    template = (HERE / 'Control.template.dfy').read_text()
    source = template.replace('@RUNTIME_LENGTH@', str(len(code))).replace('@TERMINAL_OPCODE@', str(opcode))
    assert '@' not in source
    a.output.mkdir(parents=True, exist_ok=True)
    (a.output / 'Control.generated.dfy').write_text(source)
    (a.output / 'Control.mapping.json').write_text(json.dumps(dict(runtimeSha256=digest, requiredBytes={'498': opcode}, pc=498, nativeSymbol='BytecodeApplyReturnKind.Terminal', scope='Actual termination instruction over fitting physical slices, fixed successful RETURN semantics; full public caller/ABI/loop composition remains a separate theorem.'), indent=2)+'\n')
    subprocess.run([sys.executable, '-B', HERE.parent / 'map-prefix/format-generated.py', '--output', a.output, '--include-root', HERE], check=True)


if __name__ == '__main__':
    main()
