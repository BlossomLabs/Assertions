"""Uniform source-package native verification; other acceptance gates remain separate."""
import argparse
import csv
import datetime
import hashlib
import json
import re
import shutil
import subprocess
import sys
from pathlib import Path
from check import ROOT, LIBRARY, check, digest


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('package')
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--run', action='store_true', help='Execute; otherwise print the bound verification plan.')
    args = parser.parse_args()
    check()
    registry = json.loads((LIBRARY / 'registry.json').read_text())
    matches = [p for p in registry['packages'] if p['id'] == args.package]
    if len(matches) != 1:
        parser.error('Unknown package: ' + args.package)
    package = json.loads((ROOT / matches[0].get('canonicalDescriptor', matches[0]['descriptor'])).read_text())
    if package.get('missingInputs'):
        parser.error('Package blocked by missing inputs: ' + ', '.join(package['missingInputs']))
    for relative, expected in package['closureSha256'].items():
        assert digest(ROOT / relative) == expected, relative
    output = args.output.resolve()
    assert not output.exists(), 'Evidence output must be fresh'
    tools = {'dafny': ROOT/'proof-tools/assertions/dafny/dafny',
             'Dafny.dll': ROOT/'proof-tools/assertions/dafny/Dafny.dll',
             'z3': ROOT/'proof-tools/assertions/dafny/z3/bin/z3-4.12.1'}
    tool_hashes = {k: digest(v) for k, v in tools.items()}
    producer_paths = [Path(__file__), LIBRARY/'tools/check.py', LIBRARY/'tools/declarations.py',
                      LIBRARY/'tools/declaration_body.py', ROOT/matches[0]['canonicalDescriptor'],
                      LIBRARY/'registry.json']
    producer_paths += [LIBRARY/'tools/evm_dependency.py',LIBRARY/'tools/migration.py']
    for relative in ['dependencies/dafnyevm/lock.json','dependencies/dafnyevm/generic.patch','dependencies/dafnyevm/crypto.patch','dependencies/dafnyevm/tools.json','dependencies/dafnyevm/requirements.lock','migrations/dafnyevm.json','bytecode/dafnyevm/runtime-binding.json']:
        path = LIBRARY/relative
        if path.exists():
            producer_paths.append(path)
    producer_inputs = {str(path.relative_to(ROOT)):digest(path) for path in producer_paths}
    commands = []
    for i, entry in enumerate(package['verificationEntries']):
        snapshot = output/'snapshot'/entry
        csvpath = output/f'proof-{i:03d}.csv'
        commands += [(f'proof-{i:03d}', [str(tools['dafny']), 'verify', str(snapshot),
                      '--verify-included-files', '--manual-lemma-induction', '--isolate-assertions',
                      '--cores', str(package['resourcePolicy']['cores']),
                      '--verification-time-limit', str(package['resourcePolicy']['secondsPerObligation']),
                      '--solver-path', str(tools['z3']), '--log-format', 'csv;LogFileName='+str(csvpath),
                      '--progress', 'Symbol']),
                     (f'audit-{i:03d}', [str(tools['dafny']), 'audit', str(snapshot)])]
    commands.append(('format', [str(tools['dafny']), 'format', '--check'] +
                     [str(output/'snapshot'/p) for p in package['closureSha256']]))
    plan = {'package': args.package, 'scope': package['verificationScope'],
            'sources': package['closureSha256'], 'tools': tool_hashes,
            'producerInputs':producer_inputs, 'pythonVersion':sys.version,
            'pythonExecutableSha256':digest(Path(sys.executable).resolve()),
            'commands': [{'gate': label, 'command': cmd} for label, cmd in commands]}
    if not args.run:
        print(json.dumps(plan, indent=2))
        return
    output.mkdir(parents=True, exist_ok=False)
    for relative in producer_inputs:
        destination = output/'producer'/relative
        destination.parent.mkdir(parents=True,exist_ok=True)
        shutil.copy2(ROOT/relative,destination)
    for relative in package['closureSha256']:
        destination = output/'snapshot'/relative
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(ROOT/relative, destination)
    receipt = dict(plan, status='running', startedAt=datetime.datetime.now(datetime.timezone.utc).isoformat(), results=[])
    def save():
        (output/'manifest.json').write_text(json.dumps(receipt, indent=2)+'\n')
    save()
    try:
        for label, command in commands:
            with (output/(label+'.log')).open('w') as log:
                proc = subprocess.run(command, stdout=log, stderr=subprocess.STDOUT, cwd=ROOT)
            text = (output/(label+'.log')).read_text()
            passed = proc.returncode == 0
            result = {'gate': label, 'exitCode': proc.returncode}
            if label.startswith('proof-'):
                rows = list(csv.DictReader((output/(label+'.csv')).open()))
                summary = re.search(r'finished with (\d+) verified, (\d+) errors', text)
                passed &= bool(rows) and all(r['TestResult.Outcome'] == 'Passed' for r in rows)
                passed &= bool(summary) and int(summary[1]) == len(rows) and int(summary[2]) == 0
                passed &= not bool(re.search(r'Error:|timed out|inconclusive', text, re.I))
                result['nativeRows'] = len(rows)
            elif label.startswith('audit-'):
                passed &= 'auditor completed with 0 findings' in text
            result['passed'] = bool(passed)
            receipt['results'].append(result)
            save()
        receipt['sourceHashesUnchanged'] = all(digest(ROOT/p) == h for p,h in package['closureSha256'].items())
        receipt['snapshotHashesMatch'] = all(digest(output/'snapshot'/p) == h for p,h in package['closureSha256'].items())
        receipt['toolHashesUnchanged'] = all(digest(tools[k]) == h for k,h in tool_hashes.items())
        receipt['producerInputsUnchanged'] = all(digest(ROOT/p)==h and digest(output/'producer'/p)==h for p,h in producer_inputs.items())
        passed = all(r['passed'] for r in receipt['results']) and all(receipt[k] for k in ['sourceHashesUnchanged','snapshotHashesMatch','toolHashesUnchanged','producerInputsUnchanged'])
        receipt['status'] = 'native-gates-passed' if passed else 'failed'
        receipt['completedAt'] = datetime.datetime.now(datetime.timezone.utc).isoformat()
        receipt['evidenceSha256'] = {str(p.relative_to(output)):digest(p) for p in output.rglob('*') if p.is_file() and p.name != 'manifest.json'}
        save()
        sys.exit(0 if passed else 1)
    except BaseException as error:
        if receipt['status'] == 'running':
            receipt['status'] = 'interrupted-or-error'
            receipt['error'] = str(error)
            save()
        raise

if __name__ == '__main__':
    main()
