"""Reject incomplete and forged receipts even after outer hashes are refreshed."""
import csv
import hashlib
import json
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'tools'))
import capture
import evidence
import review


class ReceiptTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name) / 'root'
        self.directory = Path(self.temp.name) / 'receipt'
        self.snapshot = self.directory / 'snapshot'
        self.signature = 'Operations.add(uint256,uint256)'
        self.entry = 'formal/contracts/Operations/add/Unsigned.dfy'
        self.name = 'OperationsUnsignedAdd.VerifyAdd'
        self.put(self.entry, 'include "../../../.generated/OperationsRuntime.dfy"\nmodule OperationsUnsignedAdd { lemma VerifyAdd() {} }\n')
        self.put('proof-tools/dafnyevm/src/dafny/core/code.dfy', 'module Code {}\n')
        self.put('formal/.generated/OperationsRuntime.dfy', capture.runtime_source(b'\x00'))
        self.put('formal/.generated/Operations.runtime.hex', '00\n')
        self.put('formal/.generated/solc-input.json', '{}')
        self.put('formal/catalog.json', json.dumps({'specifications': {}, 'functions': [{'id': self.signature, 'theorems': [
            {'file': self.entry, 'entrypoint': self.name, 'contractSha256': evidence.theorem_contract(self.snapshot / self.entry, self.name)}]}]}))
        self.put('formal/claims.json', '{}')
        self.put('docs/claim-evidence.json', '{}')
        self.put('formal/contracts/Operations/runtime.json', json.dumps({'runtimeSha256': hashlib.sha256(b'\x00').hexdigest(),
                 'inputSha256': hashlib.sha256(b'{}').hexdigest()}))
        self.put('formal/dependencies/dafnyevm/lock.json', json.dumps({'effectiveSources': {
            'src/dafny/core/code.dfy': evidence.sha(self.snapshot / 'proof-tools/dafnyevm/src/dafny/core/code.dfy')}}))
        self.put('formal/dependencies/dafnyevm/tools.json', '{"solcSha256":"compiler"}')
        self.sources = [self.entry, 'formal/.generated/OperationsRuntime.dfy', 'proof-tools/dafnyevm/src/dafny/core/code.dfy']
        self.bindings = ['formal/catalog.json', 'formal/claims.json', 'docs/claim-evidence.json',
                         'formal/contracts/Operations/runtime.json', 'formal/dependencies/dafnyevm/lock.json',
                         'formal/dependencies/dafnyevm/tools.json']
        for name in self.bindings:
            dest = self.root / name
            dest.parent.mkdir(parents=True, exist_ok=True)
            dest.write_bytes((self.snapshot / name).read_bytes())
        self.rows = [(self.name + ' (well-formedness)', 'Passed'), (self.name + ' (correctness) (assertion batch 1)', 'Passed')]
        self.csv()
        (self.directory / 'verify.log').write_text('Dafny program verifier finished with 2 verified, 0 errors\n')
        (self.directory / 'audit.log').write_text('Dafny auditor completed with 0 findings\n')
        self.manifest = {'schemaVersion': 1, 'status': 'verified', 'signatures': [self.signature],
                         'entries': [self.entry], 'entrypoints': [self.name], 'tools': {},
                         'runtimeSha256': hashlib.sha256(b'\x00').hexdigest(), 'sources': {}, 'bindings': {},
                         'results': [{'gate': 'verify', 'exitCode': 0, 'passed': True, 'rows': 2, 'coverage': {self.name: True},
                                      'command': ['dafny', 'verify', str(self.snapshot / self.entry), *evidence.POLICY,
                                                  '--solver-path', 'z3-4.12.1', '--log-format', 'csv;LogFileName=' + str(self.directory / 'native.csv')]},
                                     {'gate': 'audit', 'exitCode': 0, 'passed': True, 'command': ['dafny', 'audit', str(self.snapshot / self.entry)]},
                                     {'gate': 'format', 'exitCode': 0, 'passed': True},
                                     {'gate': 'compiler', 'exitCode': 0, 'passed': True, 'compilerSha256': 'compiler',
                                      'runtimeSha256': hashlib.sha256(b'\x00').hexdigest()}]}
        self.refresh()

    def tearDown(self):
        self.temp.cleanup()

    def put(self, name, text):
        path = self.snapshot / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text)

    def csv(self):
        with (self.directory / 'native.csv').open('w') as output:
            writer = csv.writer(output)
            writer.writerow(['TestResult.DisplayName', 'TestResult.Outcome'])
            writer.writerows(self.rows)

    def refresh(self):
        self.manifest['sources'] = {p: evidence.sha(self.snapshot / p) for p in self.sources if (self.snapshot / p).is_file()}
        self.manifest['bindings'] = {p: evidence.sha(self.snapshot / p) for p in self.bindings}
        self.manifest['evidenceSha256'] = {str(p.relative_to(self.directory)): evidence.sha(p) for p in self.directory.rglob('*')
                                          if p.is_file() and p != self.directory / 'manifest.json'}
        evidence.write(self.directory / 'manifest.json', self.manifest)

    def inspect(self):
        with patch.object(evidence, 'ROOT', self.root):
            return review.inspect(self.directory)

    def test_complete_structural_fixture_is_readable(self):
        self.assertEqual(self.inspect()[0]['status'], 'verified')

    def test_missing_verification_gate(self):
        self.manifest['results'] = self.manifest['results'][1:]
        self.refresh()
        with self.assertRaisesRegex(AssertionError, 'Missing verification gate'):
            self.inspect()

    def test_missing_correctness_row_with_refreshed_counts(self):
        self.rows.pop()
        self.csv()
        self.manifest['results'][0]['rows'] = 1
        (self.directory / 'verify.log').write_text('Dafny program verifier finished with 1 verified, 0 errors\n')
        self.refresh()
        with self.assertRaisesRegex(AssertionError, 'Missing native results'):
            self.inspect()

    def test_dropped_imported_source(self):
        (self.snapshot / 'formal/.generated/OperationsRuntime.dfy').unlink()
        self.refresh()
        with self.assertRaises(FileNotFoundError):
            self.inspect()

    def test_modified_runtime_constants_with_refreshed_hashes(self):
        name = 'formal/.generated/OperationsRuntime.dfy'
        self.put(name, (self.snapshot / name).read_text().replace('0x00', '0x01'))
        self.refresh()
        with self.assertRaisesRegex(AssertionError, 'Runtime constants differ'):
            self.inspect()

    def test_relaxed_solver_policy(self):
        command = self.manifest['results'][0]['command']
        command[command.index('--cores') + 1] = '4'
        self.refresh()
        with self.assertRaisesRegex(AssertionError, 'Wrong verification policy'):
            self.inspect()

    def test_interrupted_receipt(self):
        self.manifest['status'] = 'running'
        self.refresh()
        with self.assertRaisesRegex(AssertionError, 'Incomplete native receipt'):
            self.inspect()

    def test_extra_false_precondition_with_refreshed_source_hashes(self):
        self.put(self.entry, (self.snapshot / self.entry).read_text().replace('VerifyAdd() {}', 'VerifyAdd() requires false {}'))
        self.refresh()
        with self.assertRaisesRegex(AssertionError, 'Changed public theorem contract'):
            self.inspect()

    def partitioned_fixture(self):
        sources = evidence.closure(self.snapshot, [self.entry])
        parts = evidence.partitions(self.snapshot, sources)
        recorded = []
        for i, selection in enumerate(parts):
            rows = self.rows if selection == ['--filter-position', self.entry] else []
            with (self.directory / f'native-{i:03d}.csv').open('w') as output:
                writer = csv.writer(output)
                writer.writerow(['TestResult.DisplayName', 'TestResult.Outcome'])
                writer.writerows(rows)
            (self.directory / f'verify-{i:03d}.log').write_text(f'Dafny program verifier finished with {len(rows)} verified, 0 errors\n')
            command = ['dafny', 'verify', str(self.snapshot / self.entry), *evidence.POLICY, *selection,
                       '--solver-path', 'z3-4.12.1', '--log-format', 'csv;LogFileName=' + str(self.directory / f'native-{i:03d}.csv')]
            recorded.append({'selection': selection, 'command': command, 'exitCode': 0, 'passed': True, 'rows': len(rows)})
        self.manifest['nativePartitions'] = recorded
        self.manifest['results'][0]['command'] = None
        self.refresh()

    def test_complete_partition_structure(self):
        self.partitioned_fixture()
        self.assertEqual(len(self.inspect()[1]), 2)

    def test_dropped_native_partition_with_refreshed_hashes(self):
        self.partitioned_fixture()
        self.manifest['nativePartitions'].pop()
        self.refresh()
        with self.assertRaisesRegex(AssertionError, 'Missing native partition'):
            self.inspect()


if __name__ == '__main__':
    unittest.main()
