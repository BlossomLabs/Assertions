import csv
import hashlib
import json
import re
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

LIBRARY = Path(__file__).resolve().parents[1]
ROOT = LIBRARY.parents[2]
sys.path.insert(0,str(LIBRARY))
from declarations import declarations
from status import covers_closure
from generate import format_dependency_path


class DeclarationTests(unittest.TestCase):
    def test_import_does_not_truncate_or_extend_interface(self):
        original = '''module Example {
  lemma {:isolate_assertions} A(x: int)
    requires x in {1, 2}
    ensures x > 0
  { assert x > 0; }
  import B = Other
  ghost opaque predicate P(x: int) { x > 0 }
}
'''
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory)/'Example.dfy'
            path.write_text(original)
            parsed = declarations(path)
            self.assertEqual(set(parsed),{'A','P'})
            self.assertIn('requires x in {1, 2}',parsed['A']['interface'])
            self.assertNotIn('import',parsed['A']['body'])
            path.write_text(original.replace('x in {1, 2}','x in {1}'))
            self.assertNotEqual(parsed['A']['interface'],declarations(path)['A']['interface'])


class StagingTests(unittest.TestCase):
    def test_sibling_dependency_keeps_relative_include_and_escape_is_rejected(self):
        config={'canonical':'formal/source/library/src/operations/decimal-digits/Control.generated.dfy'}
        with tempfile.TemporaryDirectory() as directory:
            generated=Path(directory)/'generated'
            sibling=format_dependency_path(generated,config,'formal/source/library/src/operations/modular/Math.generated.dfy')
            self.assertEqual(sibling,Path(directory)/'modular/Math.generated.dfy')
            with self.assertRaisesRegex(AssertionError,'escapes evidence'):
                format_dependency_path(generated,config,'formal/source/library/src/foundations/SourceSequenceMemoryV1.dfy')


class EvidenceTests(unittest.TestCase):
    def test_superset_coverage_requires_every_dependency_hash(self):
        manifest = json.loads((LIBRARY/'evidence/native/abi-relocation-v1/manifest.json').read_text())
        descriptor = json.loads((LIBRARY/'packages/original-abi/canonical.json').read_text())
        self.assertTrue(covers_closure(manifest,descriptor))
        dependency = next(iter(descriptor['closureSha256']))
        del manifest['sources'][dependency]
        self.assertFalse(covers_closure(manifest,descriptor))
        manifest['sources'][dependency] = '0'*64
        self.assertFalse(covers_closure(manifest,descriptor))
        descriptor['missingInputs'] = ['absent/Memory.dfy']
        self.assertFalse(covers_closure(manifest,descriptor))

    def test_changed_compiler_settings_are_rejected_after_rehash(self):
        source = LIBRARY/'evidence/generation/environment-canonical-v1'
        with tempfile.TemporaryDirectory() as directory:
            evidence = Path(directory)/'evidence'
            shutil.copytree(source,evidence)
            request = evidence/'generated/solc-input.json'
            value = json.loads(request.read_text())
            value['settings']['optimizer']['runs'] = 201
            request.write_text(json.dumps(value))
            manifest = json.loads((evidence/'manifest.json').read_text())
            manifest['evidenceSha256'] = {str(p.relative_to(evidence)):hashlib.sha256(p.read_bytes()).hexdigest() for p in evidence.rglob('*') if p.is_file() and p.name!='manifest.json'}
            (evidence/'manifest.json').write_text(json.dumps(manifest))
            result = subprocess.run([sys.executable,str(LIBRARY/'review_generation.py'),'original-operations-environment','--evidence',str(evidence),'--output',str(Path(directory)/'review.json')],cwd=ROOT,capture_output=True,text=True)
            self.assertNotEqual(result.returncode,0)
            self.assertIn('Generator replay compiler settings mismatch',result.stderr)

    def test_reduced_native_command_scope_is_rejected(self):
        source = LIBRARY/'evidence/native/concat-relocation-v1'
        with tempfile.TemporaryDirectory() as directory:
            evidence = Path(directory)/'evidence'
            shutil.copytree(source,evidence)
            manifest = json.loads((evidence/'manifest.json').read_text())
            manifest['commands'][0]['command'].remove('--verify-included-files')
            (evidence/'manifest.json').write_text(json.dumps(manifest))
            result = subprocess.run([sys.executable,str(LIBRARY/'review.py'),'concat','--evidence',str(evidence),'--output',str(Path(directory)/'review.json')],cwd=ROOT,capture_output=True,text=True)
            self.assertNotEqual(result.returncode,0)
            self.assertIn('Native command scope or policy changed',result.stderr)

    def test_missing_method_batches_are_rejected_even_with_green_summary(self):
        source = LIBRARY/'evidence/native/concat-relocation-v1'
        with tempfile.TemporaryDirectory() as directory:
            evidence = Path(directory)/'evidence'
            shutil.copytree(source,evidence)
            csvpath = evidence/'proof-000.csv'
            with csvpath.open() as stream:
                reader = csv.DictReader(stream)
                fields = reader.fieldnames
                rows = list(reader)
            removed = [r for r in rows if r['TestResult.DisplayName'].split(' (')[0]=='OperationsConcatConnection.Concat']
            self.assertTrue(removed,'Mutant must remove actual proof batches')
            rows = [r for r in rows if r not in removed]
            with csvpath.open('w') as stream:
                writer = csv.DictWriter(stream,fieldnames=fields)
                writer.writeheader()
                writer.writerows(rows)
            log = evidence/'proof-000.log'
            log.write_text(re.sub(r'finished with \d+ verified, 0 errors',f'finished with {len(rows)} verified, 0 errors',log.read_text()))
            manifest = json.loads((evidence/'manifest.json').read_text())
            manifest['evidenceSha256'] = {str(p.relative_to(evidence)):hashlib.sha256(p.read_bytes()).hexdigest() for p in evidence.rglob('*') if p.is_file() and p.name!='manifest.json'}
            (evidence/'manifest.json').write_text(json.dumps(manifest))
            result = subprocess.run([sys.executable,str(LIBRARY/'review.py'),'concat','--evidence',str(evidence),'--output',str(Path(directory)/'review.json')],cwd=ROOT,capture_output=True,text=True)
            self.assertNotEqual(result.returncode,0)
            self.assertIn('Unverified executable/proof declaration',result.stderr)


if __name__ == '__main__':
    unittest.main()
