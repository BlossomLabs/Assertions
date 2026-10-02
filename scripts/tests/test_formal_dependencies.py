"""Dependency reuse must reject stale, incomplete or unsuccessful evidence."""
import copy
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest

REPOSITORY = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location('formal_common', REPOSITORY / 'formal/constraints/verify.py')
common = importlib.util.module_from_spec(spec)
spec.loader.exec_module(common)


class DependencyEvidenceTests(unittest.TestCase):
    def setUp(self):
        self.scratch = tempfile.TemporaryDirectory()
        self.addCleanup(self.scratch.cleanup)
        self.root = Path(self.scratch.name)
        self.here = self.root / 'package'
        self.here.mkdir()
        library = self.root / 'library'
        library.mkdir()
        self.a, self.b = library / 'A.dfy', library / 'B.dfy'
        self.a.write_text('include "B.dfy"\nmodule A { lemma L() {} }\n')
        self.b.write_text('module B { lemma L() {} }\n')
        tools = self.root / 'tools'
        (tools / 'z3/bin').mkdir(parents=True)
        self.dafny, self.solc = tools / 'dafny', tools / 'solc'
        binaries = {'dafny': self.dafny, 'solc': self.solc, 'Dafny.dll': tools / 'Dafny.dll',
                    'z3': tools / 'z3/bin/z3-4.12.1'}
        for name, path in binaries.items():
            path.write_text(name)
        self.manifest = self.root / 'evidence/baseline/manifest.json'
        self.manifest.parent.mkdir(parents=True)
        artifact = self.manifest.parent / 'proof.log'
        artifact.write_text('Original native proof receipt')
        self.prior = {
            'status': 'passed',
            'nativeResults': [{'TestResult.DisplayName': name + '.L (batch 0)', 'TestResult.Outcome': 'Passed'}
                              for name in ('A', 'B')],
            'declarationResults': self.inventory({self.a, self.b}),
            'executableSha256': {name: common.sha(path) for name, path in binaries.items()},
            'evidenceSha256': {'proof.log': common.sha(artifact)},
            'sourceSha256': {str(path.relative_to(self.root)): common.sha(path) for path in (self.a, self.b)},
        }
        self.ordinal = 0

    def inventory(self, paths):
        return [{'name': path.stem + '.L', 'kind': 'lemma', 'status': 'passed',
                 'file': str(path.relative_to(self.root))} for path in sorted(paths)]

    def check(self, prior=None):
        self.manifest.write_text(json.dumps(self.prior if prior is None else prior))
        self.ordinal += 1
        output = self.root / ('output-' + str(self.ordinal))
        output.mkdir()
        result = common.check_dependencies(
            self.dafny, self.solc, {self.a, self.b}, output, root=self.root, here=self.here,
            paths=[str(self.manifest.relative_to(self.root))], inventory=self.inventory,
            closure=lambda path: {self.a, self.b} if path == self.a else {self.b}, hash_file=common.sha)
        return result, output

    def test_complete_evidence_retains_manifest_and_both_modules(self):
        result, output = self.check()
        self.assertTrue(result['passed'])
        self.assertEqual(result['reusedModules'], ['library/A.dfy', 'library/B.dfy'])
        retained = output / result['dependencies'][0]['retainedManifest']
        self.assertEqual(retained.read_bytes(), self.manifest.read_bytes())
        self.assertEqual(result['dependencies'][0]['sha256'], common.sha(self.manifest))

    def test_legacy_tool_names_and_nested_native_receipts_remain_supported(self):
        prior = copy.deepcopy(self.prior)
        keys = [('dafnyLauncher', 'dafny'), ('dafnyAssembly', 'Dafny.dll'), ('solver', 'z3'), ('solc', 'solc')]
        prior['executableSha256'] = {new: prior['executableSha256'][old] for new, old in keys}
        prior['checks'] = [{'name': 'proof', 'passed': True, 'nativeResults': prior.pop('nativeResults'),
                            'declarations': prior.pop('declarationResults')}]
        self.assertTrue(self.check(prior)[0]['passed'])

    def test_incomplete_or_stale_evidence_is_rejected(self):
        for fault in ('status', 'empty-native', 'native-failure', 'tool-drift', 'artifact-drift',
                      'source-drift', 'missing-transitive-source', 'declaration-failure',
                      'missing-declaration-batch', 'wrong-declaration-owner'):
            with self.subTest(fault=fault):
                prior = copy.deepcopy(self.prior)
                if fault == 'status':
                    prior['status'] = 'incomplete'
                elif fault == 'empty-native':
                    prior['nativeResults'] = []
                elif fault == 'native-failure':
                    prior['nativeResults'][0]['TestResult.Outcome'] = 'Failed'
                elif fault == 'tool-drift':
                    prior['executableSha256']['dafny'] = '0' * 64
                elif fault == 'artifact-drift':
                    prior['evidenceSha256']['proof.log'] = '0' * 64
                elif fault == 'source-drift':
                    prior['sourceSha256']['library/A.dfy'] = '0' * 64
                elif fault == 'missing-transitive-source':
                    del prior['sourceSha256']['library/B.dfy']
                elif fault == 'declaration-failure':
                    prior['declarationResults'][0]['status'] = 'failed'
                elif fault == 'missing-declaration-batch':
                    prior['nativeResults'].pop()
                elif fault == 'wrong-declaration-owner':
                    prior['declarationResults'][0]['file'] = 'other/A.dfy'
                with self.assertRaises(ValueError):
                    self.check(prior)

    def test_failed_nested_proof_is_rejected(self):
        prior = copy.deepcopy(self.prior)
        prior['checks'] = [{'name': 'proof', 'passed': False, 'nativeResults': prior.pop('nativeResults'),
                            'declarations': prior.pop('declarationResults')}]
        with self.assertRaisesRegex(ValueError, 'Dependency proof not passed'):
            self.check(prior)


if __name__ == '__main__':
    unittest.main()
