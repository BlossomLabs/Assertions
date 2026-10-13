#!/usr/bin/env python3
"""Identity and evidence-scope regressions for the functional claims ledger."""
import copy
import json
import hashlib
from pathlib import Path
import tempfile
import unittest
from claim_tables import current_snapshot, validate_claim_identities, verification_label

ROOT = Path(__file__).resolve().parents[1]

class ClaimLedgerTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.text = (ROOT / 'docs/claims.md').read_text()
        cls.registry = json.loads((ROOT / 'docs/claim-evidence.json').read_text())

    def test_current_ledger_preserves_predecessors_under_distinct_ids(self):
        active = validate_claim_identities(self.text, self.registry)
        for old, retirement in self.registry['retiredClaims'].items():
            self.assertNotIn(old, active)
            self.assertNotIn(old, retirement['replacedBy'])

    def test_rewording_an_existing_id_is_rejected(self):
        text = self.text.replace(self.registry['claims']['C85']['recordedClaim'], 'isValid always succeeds', 1)
        with self.assertRaisesRegex(ValueError, 'allocate a new claim ID'):
            validate_claim_identities(text, self.registry)

    def test_changing_both_prose_and_registry_does_not_rebind_an_id(self):
        registry = copy.deepcopy(self.registry)
        old = registry['claims']['C85']['recordedClaim']
        registry['claims']['C85']['recordedClaim'] = 'isValid always succeeds'
        text = self.text.replace(old, registry['claims']['C85']['recordedClaim'], 1)
        with self.assertRaisesRegex(ValueError, 'Statement identity changed'):
            validate_claim_identities(text, registry)

    def test_retired_id_cannot_be_reactivated(self):
        record = self.registry['claims']['L55']
        row = '| L55 | ' + record['recordedClaim'] + ' | Tested (unit) | — |'
        with self.assertRaisesRegex(ValueError, 'cannot be reused'):
            validate_claim_identities(self.text + '\n' + row, self.registry)

    def test_retained_evidence_cannot_be_rewritten(self):
        registry = copy.deepcopy(self.registry)
        registry['claims']['L69']['notes'] = 'Unrestricted proof'
        with self.assertRaisesRegex(ValueError, 'Retained claim record changed'):
            validate_claim_identities(self.text, registry)

    def test_replacement_links_must_resolve(self):
        registry = copy.deepcopy(self.registry)
        registry['retiredClaims']['L69']['replacedBy'] = ['L999']
        with self.assertRaisesRegex(ValueError, 'Missing replacement'):
            validate_claim_identities(self.text, registry)

    def test_different_sources_or_compiler_configuration_are_prior_snapshots(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = root / 'contracts/Sample.sol'
            source.parent.mkdir()
            source.write_text('contract Sample {}\n')
            config = root / 'foundry.toml'
            config.write_text('optimizer_runs = 200\n')
            baseline = root / 'docs/verification/sample'
            baseline.mkdir(parents=True)
            manifest = {'sourceSha256': {'contracts/Sample.sol': hashlib.sha256(source.read_bytes()).hexdigest()},
                        'configurationSha256': {'foundry.toml': hashlib.sha256(config.read_bytes()).hexdigest()}}
            (baseline / 'manifest.json').write_text(json.dumps(manifest))
            registry = {'halmosBaseline': 'docs/verification/sample'}
            self.assertTrue(current_snapshot(root, registry))
            config.write_text('optimizer_runs = 201\n')
            self.assertFalse(current_snapshot(root, registry))
            config.write_text('optimizer_runs = 200\n')
            source.write_text('contract Sample { function changed() public {} }\n')
            self.assertFalse(current_snapshot(root, registry))

    def test_new_symbolic_claims_display_bounds_and_partial_coverage(self):
        claims = self.registry['claims']
        behavior = ['C24', 'C1', 'C8', 'C57', 'C59', 'C81', 'C82', 'C83',
                    'E7', 'E10', 'E38', 'C38', 'C66', 'E15', 'L33', 'O11',
                    'E39', 'L35', 'E8', 'L70', 'L75']
        following = ['O6','O7','O29','O30','O31','O32','O34','C6','C28','W19','L31',
                     'C29','C33','C35','C36','C37','C41','C44','A21','A22','A23','A24',
                     'O70','O71','O72','E41','L60']
        core_wire = ['C2','C4','C17','C19','C21','W5','W6','W15','L4','L5','O1','O2','O3','O75']
        complete = ['C81','C82','O11','O6','O7','O29','O30','O31','O32','O34','L31']
        for claim_id in ['C85', 'L70', 'L71', 'L72', 'L73', 'L74', 'L75', 'E50', 'E41', 'L60', *behavior, *following, *core_wire]:
            record = claims[claim_id]
            self.assertEqual(record['evidenceType'], 'SYMBOLIC')
            self.assertEqual(record['executionStatus'], 'PROVED')
            self.assertTrue(record['symbolicScope'])
            self.assertIn(record['symbolicScope'], verification_label(record))
        for claim_id in ['C85', 'L70', 'L74', 'L75', 'E50', 'E41', 'L60',
                         *(claim_id for claim_id in [*behavior, *following, *core_wire] if claim_id not in complete)]:
            self.assertTrue(verification_label(claims[claim_id]).startswith('Partially verified'))
        for claim_id in complete:
            self.assertTrue(verification_label(claims[claim_id]).startswith('Formally verified'))

if __name__ == '__main__':
    unittest.main(verbosity=2)
