"""Fault gates against real complete public-call evidence."""
import copy
import json
import os
from pathlib import Path
import sys
import unittest

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT/'formal/tools'))
from evm_public_evidence import validate


class PublicResolveEvidenceTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        evidence = os.environ.get('FORMAL_PUBLIC_EVIDENCE')
        if not evidence:
            raise unittest.SkipTest('Set FORMAL_PUBLIC_EVIDENCE to fresh public-resolve.json')
        cls.report = json.loads(Path(evidence).read_text())
        cls.profile = json.loads((ROOT/'formal/bytecode/dafnyevm/public-resolve.json').read_text())
        validate(cls.report, cls.profile)

    def reject(self, edit):
        changed = copy.deepcopy(self.report)
        edit(changed)
        with self.assertRaises(AssertionError):
            validate(changed, self.profile)

    def test_empty_case_inventory_is_rejected(self):
        self.reject(lambda r:r.update(cases=[]))

    def test_lost_routing_case_is_rejected(self):
        self.reject(lambda r:r['cases'].pop(1))

    def test_wrong_return_even_with_rebound_pass_flags_is_rejected(self):
        def edit(r):
            r['cases'][3]['dafny']['data'] = 'ff'
            r['cases'][3]['pyEvm']['data'] = 'ff'
        self.reject(edit)

    def test_helper_entry_substitution_is_rejected(self):
        self.reject(lambda r:r['cases'][0].update(steps=23))

    def test_lost_gas_rejection_is_rejected(self):
        self.reject(lambda r:r['probes'].pop(1))

    def test_surviving_bytecode_mutation_is_rejected(self):
        self.reject(lambda r:r['mutations'][0].update(killed=False))

    def test_concrete_evidence_cannot_grant_universal_credit(self):
        self.reject(lambda r:r.update(bytecodeCredit=True))


if __name__ == '__main__':
    unittest.main()
