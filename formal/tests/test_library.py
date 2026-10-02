import hashlib
import json
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
LIBRARY=Path(__file__).resolve().parents[1]
ROOT=LIBRARY.parent
sys.path.insert(0,str(LIBRARY/'tools'))
from declarations import declarations

class LibraryTests(unittest.TestCase):
    def test_bootstrap_restores_all_adapters_from_missing_files(self):
        with tempfile.TemporaryDirectory() as directory:
            root=Path(directory)
            target=root/'formal'
            shutil.copytree(LIBRARY,target,ignore=shutil.ignore_patterns('*.generated.dfy','evidence','__pycache__'))
            subprocess.run(['git','init',str(root)],capture_output=True,check=True)
            objects=Path(subprocess.check_output(['git','rev-parse','--git-path','objects'],cwd=ROOT,text=True).strip())
            if not objects.is_absolute():objects=ROOT/objects
            (root/'.git/objects/info/alternates').write_text(str(objects.resolve())+'\n')
            self.assertFalse(list(target.rglob('*.generated.dfy')))
            result=subprocess.run([sys.executable,str(target/'tools/bootstrap_adapters.py')],capture_output=True,text=True)
            self.assertEqual(result.returncode,0,result.stderr)
            result=subprocess.run([sys.executable,str(target/'tools/check.py')],capture_output=True,text=True)
            self.assertEqual(result.returncode,0,result.stderr)
            adapters=list(target.rglob('*.generated.dfy'))
            self.assertEqual(len(adapters),126)
            changed=adapters[0]
            changed.write_text(changed.read_text()+'// local edit\n')
            result=subprocess.run([sys.executable,str(target/'tools/bootstrap_adapters.py')],capture_output=True,text=True)
            self.assertNotEqual(result.returncode,0)
            self.assertIn('Refusing to overwrite edited adapter',result.stderr)
            self.assertTrue(changed.read_text().endswith('// local edit\n'))


    def test_import_does_not_become_part_of_previous_proof(self):
        with tempfile.TemporaryDirectory() as directory:
            path=Path(directory)/'Example.dfy'
            path.write_text('module Example {\n  lemma A(x: int)\n    requires x in {1,2}\n    ensures x > 0\n  { assert x > 0; }\n  import M = Other\n  predicate P(x: int) { x > 0 }\n}\n')
            parsed=declarations(path)
            self.assertEqual(set(parsed),{'A','P'})
            self.assertNotIn('import',parsed['A']['body'])
            self.assertIn('requires x in {1,2}',parsed['A']['interface'])

    def test_changed_proof_is_rejected_even_after_updating_file_hash(self):
        with tempfile.TemporaryDirectory() as directory:
            target=Path(directory)/'formal'
            shutil.copytree(LIBRARY,target,ignore=shutil.ignore_patterns('evidence','__pycache__'))
            preservation=target/'preservation.json'
            receipt=json.loads(preservation.read_text())
            relative='formal/foundations/SourceNaturalProductV8.dfy'
            path=Path(directory)/relative
            text=path.read_text()
            self.assertIn('ensures',text)
            path.write_text(text.replace('ensures','ensures false &&',1))
            receipt['files'][relative]['sha256']=hashlib.sha256(path.read_bytes()).hexdigest()
            preservation.write_text(json.dumps(receipt))
            result=subprocess.run([sys.executable,str(target/'tools/check.py')],capture_output=True,text=True)
            self.assertNotEqual(result.returncode,0)
            self.assertIn('Changed logical interface or proof body',result.stderr)

if __name__=='__main__':unittest.main()
