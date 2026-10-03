import copy
import hashlib
import json
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch
ROOT=Path(__file__).resolve().parents[2]
LIBRARY=ROOT/'formal'
sys.path.insert(0,str(LIBRARY/'tools'))
from declarations import declarations
from evm_dependency import qualified_inventory, closure, external_sources
from declaration_body import mask_literals_and_comments
from migration import validate_migration


class EvmAdoptionTests(unittest.TestCase):
    def test_prime_identifiers_and_character_literals(self):
        text="st' := st; var c := 'x'; // st' is a name\n"
        masked=mask_literals_and_comments(text)
        self.assertIn("st' := st",masked)
        self.assertNotIn("'x'",masked)

    def test_upstream_multiple_modules_and_datatype_members(self):
        with tempfile.TemporaryDirectory() as directory:
            p=Path(directory)/'upstream.dfy'
            p.write_text('module First { datatype T = Make(x:int) { function Next():int { x+1 } } lemma L() {} }\nmodule Second { lemma {:isolate_assertions} Proof(st:int) { var st\' := st; } }')
            members=qualified_inventory(p)
            self.assertEqual(members['First.T.Next'],'function')
            self.assertEqual(members['#First.T.Make'],'constructor')
            self.assertEqual(members['First.L'],'lemma')
            self.assertEqual(members['Second.Proof'],'lemma')

    def test_modified_dependency_install_is_refused(self):
        import shutil, subprocess
        with tempfile.TemporaryDirectory() as directory:
            root=Path(directory)
            shutil.copytree(LIBRARY,root/'formal',ignore=shutil.ignore_patterns('evidence','__pycache__'))
            lock=json.loads((LIBRARY/'dependencies/dafnyevm/lock.json').read_text())
            for relative in lock['installationSources']:
                dest=root/relative;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(ROOT/relative,dest)
            p=root/'proof-tools/dafnyevm/src/dafny/util/int.dfy'
            p.write_text(p.read_text()+'// local edit\n')
            result=subprocess.run([sys.executable,str(root/'formal/tools/bootstrap_evm.py')],capture_output=True,text=True)
            self.assertNotEqual(result.returncode,0)
            self.assertIn('DafnyEVM source drift',result.stderr)
            self.assertTrue(p.read_text().endswith('// local edit\n'))

    def test_foreign_closure_refuses_escape_and_missing_file(self):
        with tempfile.TemporaryDirectory() as directory:
            root=Path(directory);p=root/'A.dfy'
            p.write_text('include "../outside.dfy"\nmodule A {}')
            with self.assertRaises(ValueError):closure([p],root)
            p.write_text('include "Missing.dfy"\nmodule A {}')
            with self.assertRaisesRegex(AssertionError,'Missing closure'):closure([p],root)

    def test_all_foreign_files_pinned_and_admission_free(self):
        sources=external_sources()
        self.assertGreaterEqual(len(sources),20)
        inventory={}
        for relative in sources:
            names=qualified_inventory(ROOT/relative)
            self.assertFalse(set(names)&set(inventory))
            inventory.update(names)
        self.assertIn('EVM.Execute',inventory)
        self.assertIn('InstructionSteps.SwapStep',inventory)
        self.assertNotIn('PrecompiledCrypto.CallModExp',inventory)

    def test_no_declaration_loss_or_narrowed_domain(self):
        migration=json.loads((LIBRARY/'migrations/dafnyevm.json').read_text())
        files={r['file'] for r in migration['files']}|{t['declaration'].rsplit('::',1)[0] for t in migration['equivalenceTheorems']}
        parsed={f:declarations(ROOT/f) for f in files}
        validate_migration(parsed)
        target='formal/source/operations/scalars/Model.dfy'
        lost=copy.deepcopy(parsed);del lost[target]['Rem']
        with self.assertRaisesRegex(AssertionError,'Lost declaration obligation'):validate_migration(lost)
        narrowed=copy.deepcopy(parsed);narrowed[target]['Rem']['interface']+='\n    requires b != 0'
        with self.assertRaisesRegex(AssertionError,'Changed logical contract'):validate_migration(narrowed)
        weakened=copy.deepcopy(parsed);weakened[target]['And']['interface']=weakened[target]['And']['interface'].replace('ensures Word(And(a,b))','ensures true')
        with self.assertRaisesRegex(AssertionError,'Changed logical contract'):validate_migration(weakened)

    def test_stale_equivalence_theorem_is_rejected(self):
        migration=json.loads((LIBRARY/'migrations/dafnyevm.json').read_text())
        files={r['file'] for r in migration['files']}|{t['declaration'].rsplit('::',1)[0] for t in migration['equivalenceTheorems']}
        parsed={f:declarations(ROOT/f) for f in files}
        name='formal/bridges/dafnyevm/SourceRefinement.dfy'
        parsed[name]['ScalarDivision']['full']+='\n// changed proof'
        with self.assertRaisesRegex(AssertionError,'equivalence theorem drift'):validate_migration(parsed)


if __name__=='__main__':unittest.main()
