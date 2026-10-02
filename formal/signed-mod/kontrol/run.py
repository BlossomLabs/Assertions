#!/usr/bin/env python3
"""Prove signed-mod properties against the exact canonical Hardhat runtime.

Runs sequential, resource-limited, network-disabled Kontrol containers. Never
uses an existing Kontrol checkout, custom gas lemmas, or production mutations.
"""
import argparse
import datetime
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import time
import uuid

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
IMAGE = 'runtimeverificationinc/kontrol:ubuntu-jammy-1.0.255'
ENV = ['-e', 'HOME=/home/user', '-e',
       'PATH=/home/user/.foundry/bin:/home/user/.local/bin:/usr/local/bin:/usr/bin:/bin',
       '-e', 'KPROFILE_TELEMETRY_DISABLED=true']


def digest(data):
    return hashlib.sha256(data).hexdigest()


def sha(path):
    return digest(path.read_bytes())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--solc', required=True, type=Path)
    parser.add_argument('--output', required=True, type=Path)
    parser.add_argument('--seconds', type=int, default=300,
                        help='Per-property wall time; timeout means incomplete')
    args = parser.parse_args()
    assert args.seconds > 0
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=True)
    if (output / 'manifest.json').exists():
        raise SystemExit('Refusing to overwrite existing evidence')
    solc = args.solc.resolve()
    artifact_path = ROOT / 'artifacts/contracts/Operations.sol/Operations.json'
    artifact = json.loads(artifact_path.read_text())
    build_path = ROOT / 'artifacts/build-info' / (artifact['buildInfoId'] + '.json')
    build = json.loads(build_path.read_text())
    source = ROOT / 'contracts/Operations.sol'
    matching = [v['content'] for k, v in build['input']['sources'].items()
                if k.endswith('/contracts/Operations.sol') or k == 'contracts/Operations.sol']
    assert matching == [source.read_text()], 'Canonical artifact source is stale'
    assert build['solcLongVersion'] == '0.8.36+commit.8a079791'
    assert '0.8.36+commit.8a079791' in subprocess.check_output([solc, '--version'], text=True)
    runtime = artifact['deployedBytecode']
    assert runtime.startswith('0x') and len(runtime) > 2
    spec = (HERE / 'SignedModSpec.t.sol').read_text()
    properties = re.findall(r'function (prove_\w+)\(', spec)
    assert len(properties) == 4 and len(set(properties)) == 4
    assert not re.search(r'\b(?:assume|expectRevert|mockCall)\s*\(', spec)
    paths = [source, HERE / 'SignedModSpec.t.sol', HERE / 'foundry.toml',
             HERE / 'prepare-backend.py', HERE / 'audit-proofs.py', Path(__file__)]
    hashes = {str(p.relative_to(ROOT)): sha(p) for p in paths}
    work = Path(tempfile.mkdtemp(prefix='signed-mod-kontrol-'))
    (work / 'spec').mkdir()
    shutil.copy(solc, work / 'solc')
    shutil.copy(HERE / 'foundry.toml', work / 'foundry.toml')
    shutil.copy(HERE / 'prepare-backend.py', work / 'prepare-backend.py')
    shutil.copy(HERE / 'audit-proofs.py', work / 'audit-proofs.py')
    (work / 'spec/SignedModSpec.t.sol').write_text(spec)
    (work / 'spec/OperationsRuntime.sol').write_text(
        '// SPDX-License-Identifier: MIT\npragma solidity 0.8.36;\n'
        'library OperationsRuntime { function code() internal pure returns(bytes memory) '
        '{ return hex"' + runtime[2:] + '"; } }\n')
    for path in [work / 'spec/SignedModSpec.t.sol', work / 'spec/OperationsRuntime.sol',
                 HERE / 'foundry.toml', HERE / 'prepare-backend.py',
                 HERE / 'audit-proofs.py', Path(__file__)]:
        shutil.copy(path, output / (path.name + '.txt'))
    (output / 'runtime.hex').write_text(runtime + '\n')
    image = json.loads(subprocess.check_output(['docker', 'image', 'inspect', IMAGE], text=True))[0]
    # Use the resolved image identity for every run, not a mutable registry tag.
    image_id = image['Id']
    manifest = dict(schemaVersion=1, startedAt=datetime.datetime.now(datetime.timezone.utc).isoformat(),
                    revision=subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip(),
                    image=IMAGE, imageId=image_id, imageRepoDigests=image.get('RepoDigests', []),
                    sourceSha256=hashes, runtimeSha256=digest(bytes.fromhex(runtime[2:])),
                    runtimeBytes=(len(runtime)-2)//2, artifactSha256=sha(artifact_path),
                    compiler=build['solcLongVersion'], compilerSettings=build['input']['settings'],
                    buildInfoSha256=sha(build_path), solcSha256=sha(solc),
                    workDirectory=str(work), status='incomplete',
                    assumptions=['KEVM/Kontrol EVM and cheatcode semantics; trusted prover/solver toolchain',
                                 'Valid ABI int256 inputs; Cancun EVM; sufficient gas (gas abstracted)',
                                 'No custom K lemmas, CSE summaries, or bounded-model checking'],
                    bounds=dict(input='All int256 a,b,m; nonzero properties exclude m=0, covered separately',
                                workers=1, cpus=2, memoryGiB=8, wallSecondsPerProperty=args.seconds,
                                smtTimeoutMs=3000, smtRetries=0, maxIterations=400),
                    properties=[dict(name=p, status='incomplete') for p in properties], checks=[])

    def save():
        (output / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')

    def run(label, command, seconds):
        name = 'signed-mod-proof-' + uuid.uuid4().hex[:12]
        invocation = ['docker', 'run', '--rm', '--name', name, '--network', 'none',
                      '--memory', '8g', '--memory-swap', '8g', '--cpus', '2', '--user', '0',
                      *ENV, '-v', str(work) + ':/work', '-w', '/work', image_id,
                      'bash', '-c',
                      'timeout -k 10s "$1" "${@:2}"; result=$?; '
                      f'chown -R {os.getuid()}:{os.getgid()} /work; exit "$result"',
                      '_', str(seconds) + 's', *command]
        log = output / (label + '.log')
        started = time.monotonic()
        code = None
        try:
            with log.open('w') as stream:
                code = subprocess.run(invocation, stdout=stream, stderr=subprocess.STDOUT,
                                      timeout=seconds + 30).returncode
        except subprocess.TimeoutExpired:
            pass
        finally:
            subprocess.run(['docker', 'rm', '-f', name], stdout=subprocess.DEVNULL,
                           stderr=subprocess.DEVNULL, timeout=20)
        item = dict(name=label, command=command, containerCommand=invocation,
                    exitCode=code, seconds=round(time.monotonic()-started, 3),
                    log=log.name, logSha256=sha(log))
        manifest['checks'].append(item)
        save()
        print(label, 'exit=', code, 'seconds=', item['seconds'], flush=True)
        return item, log.read_text()

    save()
    run('versions', ['bash', '-c', 'kontrol version; forge --version; z3 --version; kompile --version'], 30)
    built, _ = run('build', ['bash', '-c', 'forge build && python3 prepare-backend.py'], 60)
    if (work / 'backend.json').exists():
        shutil.copy(work / 'backend.json', output / 'backend.json')
    if built['exitCode'] == 0:
        for prop in manifest['properties']:
            name = prop['name']
            result, text = run(name, ['kontrol', 'prove', '--match-test', 'SignedModSpec.' + name,
                                     '--workers', '1', '--force-sequential', '--max-frontier-parallel', '1',
                                     '--schedule', 'CANCUN', '--no-gas', '--no-log-rewrites',
                                     '--smt-timeout', '3000', '--smt-retry-limit', '0',
                                     '--max-iterations', '400', '--hide-status-bar',
                                     '--xml-test-report', '--xml-test-report-name', name + '.xml'], args.seconds)
            # Only explicit completed proofs count. Timeout/open paths cannot pass.
            if result['exitCode'] == 0 and 'PROOF PASSED' in text and name in text:
                prop['status'] = 'proved'
            elif 'PROOF FAILED' in text:
                prop['status'] = 'failed' if '0 pending' in text else 'incomplete'
            prop['log'] = result['log']
            save()
        audit, _ = run('proof-audit', ['python3', 'audit-proofs.py'], 30)
        audit_path = work / 'proof-status.json'
        records = json.loads(audit_path.read_text()) if audit_path.exists() else []
        if audit_path.exists():
            shutil.copy(audit_path, output / 'proof-status.json')
        setup = [p for p in records if '.setUp():' in p['id']]
        def closed(p):
            return (p['status'] == 'passed' and not p['admitted'] and not p['pending']
                    and not p['failing'] and not p['bounded'] and not p['subproofs'])
        setup_ok = len(setup) == 1 and closed(setup[0])
        for prop in manifest['properties']:
            proofs = [p for p in records if '.' + prop['name'] + '(' in p['id']]
            prop['proofStates'] = proofs
            if not (audit['exitCode'] == 0 and setup_ok and len(proofs) == 1 and closed(proofs[0])):
                # Do not label an unclosed obligation a contract counterexample.
                prop['status'] = 'incomplete'
    for path in work.rglob('*.xml'):
        shutil.copy(path, output / path.name)
    assert all(sha(ROOT / path) == value for path, value in hashes.items()), 'Source changed during run'
    assert sha(artifact_path) == manifest['artifactSha256'], 'Artifact changed during run'
    manifest['status'] = 'proved' if all(p['status'] == 'proved' for p in manifest['properties']) else 'incomplete'
    manifest['completedAt'] = datetime.datetime.now(datetime.timezone.utc).isoformat()
    save()
    print(json.dumps({p['name']: p['status'] for p in manifest['properties']}))
    if manifest['status'] != 'proved':
        raise SystemExit(1)


if __name__ == '__main__':
    main()
