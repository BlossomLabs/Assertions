"""Exercise independent review against deliberately corrupted fresh evidence."""
import csv
import hashlib
import io
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
EVIDENCE = os.environ.get('FORMAL_NATIVE_EVIDENCE')


@unittest.skipUnless(EVIDENCE, 'Run after native verification with FORMAL_NATIVE_EVIDENCE')
class NativeEvidenceReviewTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix='formal-review-fault-')
        self.addCleanup(self.temporary.cleanup)
        self.directory = Path(self.temporary.name)
        self.evidence = self.directory/'native'
        shutil.copytree(Path(EVIDENCE).resolve(), self.evidence)
        self.manifest = json.loads((self.evidence/'manifest.json').read_text())

    def review(self):
        return subprocess.run([
            sys.executable, str(ROOT/'formal/tools/review.py'), self.manifest['package'],
            '--evidence', str(self.evidence), '--output', str(self.directory/'review.json'),
        ], cwd=ROOT, capture_output=True, text=True)

    def save(self, *changed):
        # Rebind the altered artifact hashes too: review must inspect their content,
        # rather than reject only the easily repaired outer checksum.
        for relative in changed:
            self.manifest['evidenceSha256'][relative] = hashlib.sha256(
                (self.evidence/relative).read_bytes()).hexdigest()
        (self.evidence/'manifest.json').write_text(json.dumps(self.manifest, indent=2)+'\n')

    def assert_rejected(self, reason):
        result = self.review()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn(reason, result.stderr)
        self.assertFalse((self.directory/'review.json').exists())

    def test_fresh_complete_evidence_is_accepted(self):
        result = self.review()
        self.assertEqual(result.returncode, 0, result.stdout+result.stderr)
        receipt = json.loads((self.directory/'review.json').read_text())
        self.assertGreater(receipt['nativeRows'], 0)
        self.assertFalse(receipt['sourceAcceptance'])
        self.assertFalse(receipt['bytecodeCredit'])

    def test_missing_method_rows_fail_even_with_rebound_counts(self):
        path = self.evidence/'proof-000.csv'
        reader = csv.DictReader(io.StringIO(path.read_text()))
        rows = list(reader)
        name = 'EvmSourceRefinement.ModularStore'
        retained = [r for r in rows if r['TestResult.DisplayName'].split(' (')[0] != name]
        self.assertLess(len(retained), len(rows), 'Required source refinement absent from fixture')
        with path.open('w', newline='') as stream:
            writer = csv.DictWriter(stream, fieldnames=reader.fieldnames)
            writer.writeheader()
            writer.writerows(retained)
        log = self.evidence/'proof-000.log'
        log.write_text(re.sub(r'finished with \d+ verified',
                             f'finished with {len(retained)} verified', log.read_text()))
        self.save('proof-000.csv', 'proof-000.log')
        self.assert_rejected('Unverified executable/proof declaration: '+name)

    def test_changed_time_limit_is_rejected(self):
        command = self.manifest['commands'][0]['command']
        command[command.index('--verification-time-limit')+1] = '300'
        self.save()
        self.assert_rejected('Native command scope or policy changed')

    def test_hidden_timeout_cannot_keep_a_pass_flag(self):
        path = self.evidence/'proof-000.log'
        path.write_text(path.read_text()+'\nError: Verification timed out\n')
        self.save('proof-000.log')
        self.assert_rejected('AssertionError')

    def test_zero_rows_cannot_pass(self):
        path = self.evidence/'proof-000.csv'
        path.write_text(path.read_text().splitlines()[0]+'\n')
        log = self.evidence/'proof-000.log'
        log.write_text(re.sub(r'finished with \d+ verified',
                             'finished with 0 verified', log.read_text()))
        self.save('proof-000.csv', 'proof-000.log')
        self.assert_rejected('AssertionError')

    def test_snapshot_tampering_is_rejected(self):
        relative = 'snapshot/formal/bridges/dafnyevm/SourceRefinement.dfy'
        path = self.evidence/relative
        path.write_text(path.read_text()+'\n// altered snapshot\n')
        self.save(relative)
        self.assert_rejected('AssertionError')


if __name__ == '__main__':
    unittest.main()
