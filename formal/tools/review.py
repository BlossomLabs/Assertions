"""Review native library evidence independently of its producer's pass flag."""
import argparse
import csv
import hashlib
import json
import re
from pathlib import Path
from check import ROOT, LIBRARY, check, digest
from declarations import declarations


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('package')
    parser.add_argument('--evidence', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    check()
    assert not args.output.exists(), 'Review receipt must be fresh'
    registry = json.loads((LIBRARY/'registry.json').read_text())
    packages = [p for p in registry['packages'] if p['id'] == args.package]
    assert len(packages) == 1
    descriptor = json.loads((ROOT/packages[0]['canonicalDescriptor']).read_text())
    manifest = json.loads((args.evidence/'manifest.json').read_text())
    assert manifest['package'] == args.package
    assert manifest['status'] == 'native-gates-passed'
    assert manifest['sources'] == descriptor['closureSha256']
    tools = {'dafny':ROOT/'proof-tools/assertions/dafny/dafny',
             'Dafny.dll':ROOT/'proof-tools/assertions/dafny/Dafny.dll',
             'z3':ROOT/'proof-tools/assertions/dafny/z3/bin/z3-4.12.1'}
    assert set(manifest['tools']) == set(tools), 'Incomplete tool binding'
    # Retained evidence may have moved, but commands must describe one exact
    # execution directory and every declared root, audit and format input.
    first = manifest['commands'][0]['command']
    first_entry = descriptor['verificationEntries'][0]
    suffix = '/snapshot/'+first_entry
    assert first[2].endswith(suffix), 'Unexpected native root'
    run_directory = first[2][:-len(suffix)]
    expected_commands = []
    for index, entry in enumerate(descriptor['verificationEntries']):
        snapshot = run_directory+'/snapshot/'+entry
        label = f'proof-{index:03d}'
        expected_commands.append({'gate':label,'command':[
            str(tools['dafny']),'verify',snapshot,'--verify-included-files',
            '--manual-lemma-induction','--isolate-assertions','--cores',
            str(descriptor['resourcePolicy']['cores']),'--verification-time-limit',
            str(descriptor['resourcePolicy']['secondsPerObligation']),
            '--solver-path',str(tools['z3']),'--log-format',
            'csv;LogFileName='+run_directory+'/'+label+'.csv','--progress','Symbol']})
        expected_commands.append({'gate':f'audit-{index:03d}',
                                  'command':[str(tools['dafny']),'audit',snapshot]})
    expected_commands.append({'gate':'format','command':[
        str(tools['dafny']),'format','--check']+
        [run_directory+'/snapshot/'+path for path in descriptor['closureSha256']]})
    assert manifest['commands'] == expected_commands, 'Native command scope or policy changed'
    assert [r['gate'] for r in manifest['results']] == [c['gate'] for c in expected_commands], 'Incomplete gate results'
    for name,value in manifest['tools'].items():
        assert digest(tools[name]) == value
    if 'producerInputs' in manifest:
        assert manifest['producerInputsUnchanged'], 'Producer inputs changed during verification'
        for relative,value in manifest['producerInputs'].items():
            assert digest(args.evidence/'producer'/relative)==value, 'Producer snapshot changed: '+relative
        descriptor_path = packages[0]['canonicalDescriptor']
        assert manifest['producerInputs'][descriptor_path] == digest(ROOT/descriptor_path), 'Descriptor provenance mismatch'
    inventory = {}
    for relative,value in manifest['sources'].items():
        original, snapshot = ROOT/relative, args.evidence/'snapshot'/relative
        assert digest(original) == value == digest(snapshot)
        module = re.search(r'^module (\w+)',snapshot.read_text(),re.M)[1]
        for symbol,d in declarations(snapshot).items():
            name = module+'.'+symbol
            assert name not in inventory, 'Conflicting modules in native closure: '+name
            inventory[name] = d['kind']
    assert all(r['exitCode'] == 0 for r in manifest['results'])
    names = set()
    batches = 0
    proof_count = 0
    audit_count = 0
    for gate in manifest['commands']:
        label,command = gate['gate'],gate['command']
        text = (args.evidence/(label+'.log')).read_text()
        if label.startswith('proof-'):
            proof_count += 1
            assert '--verify-included-files' in command and '--manual-lemma-induction' in command and '--isolate-assertions' in command
            assert command[command.index('--verification-time-limit')+1] == str(descriptor['resourcePolicy']['secondsPerObligation'])
            rows = list(csv.DictReader((args.evidence/(label+'.csv')).open()))
            summary = re.search(r'finished with (\d+) verified, (\d+) errors',text)
            assert summary and int(summary[1]) == len(rows) and int(summary[2]) == 0
            assert not re.search(r'Error:|timed out|inconclusive',text,re.I)
            assert rows and all(r['TestResult.Outcome'] == 'Passed' for r in rows)
            names.update(r['TestResult.DisplayName'].split(' (')[0] for r in rows)
            batches += len(rows)
        elif label.startswith('audit-'):
            audit_count += 1
            assert 'auditor completed with 0 findings' in text
        elif label == 'format':
            assert '--check' in command and text.strip() == 'All files are correctly formatted'
    assert proof_count == audit_count == len(descriptor['verificationEntries'])
    assert names <= set(inventory), names-set(inventory)
    for name,kind in inventory.items():
        if kind in ['method','lemma']:
            assert name in names, 'Unverified executable/proof declaration: '+name
    for relative,value in manifest['evidenceSha256'].items():
        assert digest(args.evidence/relative) == value
    result = {'status':'independently-reviewed-native-closure','package':args.package,
              'manifestSha256':digest(args.evidence/'manifest.json'),'evidence':str(args.evidence),
              'declarations':len(inventory),'nativeRows':batches,
              'definitionOnlyDeclarations':[name for name in inventory if name not in names],
              'producerInputsBound':'producerInputs' in manifest,
              'sourceAcceptance':False,'bytecodeCredit':False}
    args.output.parent.mkdir(parents=True,exist_ok=True)
    args.output.write_text(json.dumps(result,indent=2)+'\n')
    print('PASS independent native review:',len(inventory),'declarations,',batches,'rows.')

if __name__ == '__main__':
    main()
