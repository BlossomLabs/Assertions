"""Reject claim loss and logical-domain changes during the DafnyEVM migration."""
import hashlib
import json
import re
import subprocess
import tempfile
from declarations import declarations
from check import ROOT, LIBRARY, digest
from declarations import body


def contract_tokens(text):
    # Preserve literal contents while ignoring layout and comments. Nested block
    # comments in a contract are rejected rather than normalized ambiguously.
    tokens = re.findall(r'//[^\n]*|/\*.*?\*/|"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|\w+\'*|[^\s]', text, re.S)
    return [t for t in tokens if not t.startswith(('//','/*'))]


def validate_migration(parsed):
    path = LIBRARY/'migrations/dafnyevm.json'
    if not path.exists():
        return
    migration = json.loads(path.read_text())
    assert digest(ROOT/'docs/claim-evidence.json') == migration['publicLedgerSha256'], 'Existing public claims or evidence changed'
    assert digest(LIBRARY/'claims.json') == migration['publicClaimsSha256'], 'Existing formal claim inventory changed'
    for record in migration['files']:
        relative = record['file']
        original = subprocess.check_output(['git','show',migration['baselineCommit']+':'+relative],cwd=ROOT)
        assert hashlib.sha256(original).hexdigest() == record['originalSha256'], 'Migration provenance drift'
        with tempfile.TemporaryDirectory() as directory:
            frozen = __import__('pathlib').Path(directory)/'Original.dfy'
            frozen.write_bytes(original)
            expected = {symbol:{'kind':d['kind'],'interface':d['interface'],
                                'fullSha256':hashlib.sha256(d['full'].encode()).hexdigest()}
                        for symbol,d in declarations(frozen).items()}
        assert expected == record['originalDeclarations'], 'Altered original declaration inventory: '+relative
        current = parsed[relative]
        assert set(current) == set(record['originalDeclarations']), 'Lost declaration obligation: '+relative
        for symbol, previous in record['originalDeclarations'].items():
            new = current[symbol]
            assert new['kind'] == previous['kind']
            assert contract_tokens(new['interface']) == contract_tokens(previous['interface']), 'Changed logical contract: '+relative+'::'+symbol
        changed = {s for s,d in current.items() if hashlib.sha256(d['full'].encode()).hexdigest() != record['originalDeclarations'][s]['fullSha256']}
        assert changed == set(record['replacements']), 'Unbound replacement declaration: '+relative
        assert set(record['replacements'].values()) <= {t['declaration'] for t in migration['equivalenceTheorems']}, 'Missing direct source equivalence'
        assert digest(ROOT/relative) == record['replacementSha256'], 'Replacement binding drift: '+relative
    assert migration['equivalenceTheorems'], 'Missing equivalence obligations'
    for theorem in migration['equivalenceTheorems']:
        relative,symbol = theorem['declaration'].rsplit('::',1)
        declaration = parsed[relative][symbol]
        assert declaration['kind'] in ['lemma','method']
        assert hashlib.sha256(declaration['full'].encode()).hexdigest() == theorem['fullSha256'], 'Migration equivalence theorem drift'
    registry = json.loads((LIBRARY/'registry.json').read_text())
    package = next(p for p in registry['packages'] if p['id']==migration['cleanNativePackage'])
    closure = json.loads((ROOT/package['canonicalDescriptor']).read_text())['closureSha256']
    assert all(r['file'] in closure for r in migration['files']), 'Incomplete adopted-model closure'
    assert all(t['declaration'].rsplit('::',1)[0] in closure for t in migration['equivalenceTheorems']), 'Unverified migration theorem file'
