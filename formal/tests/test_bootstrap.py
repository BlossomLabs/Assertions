"""Bootstrap must publish only complete validated installations."""
import hashlib
import json
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'tools'))
import bootstrap


class BootstrapTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        self.deps = self.root / 'deps'
        self.deps.mkdir()
        self.destination = self.root / 'installed'
        self.tools = self.root / 'dafny'
        self.tools.mkdir()
        self.files = {'core.dfy': 'module Core {}\n',
                      'tools/bootstrap.py': 'def install_dafny(destination):\n    return destination / "dafny"\n',
                      'libs/DafnyCrypto/option.dfy': 'module Optional {}\n'}
        h = lambda s: hashlib.sha256(s.encode()).hexdigest()
        self.lock = {'revision': 'published', 'cryptoRevision': 'crypto',
                     'installationSources': {p: h(s) for p, s in self.files.items() if not p.startswith('libs/')},
                     'cryptoSources': {'libs/DafnyCrypto/option.dfy': h(self.files['libs/DafnyCrypto/option.dfy'])},
                     'effectiveSources': {'core.dfy': h(self.files['core.dfy'])}}
        (self.deps / 'lock.json').write_text(json.dumps(self.lock))

    def tearDown(self):
        self.temp.cleanup()

    def extract(self, url, destination):
        source = destination / 'source'
        source.mkdir(parents=True)
        for name, text in self.files.items():
            if '/Consensys/DafnyCrypto/' in url:
                if not name.startswith('libs/DafnyCrypto/'):
                    continue
                name = name.removeprefix('libs/DafnyCrypto/')
            elif name.startswith('libs/'):
                continue
            path = source / name
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(text)
        return source

    def install(self, extract=None):
        with patch.object(bootstrap, 'DEPS', self.deps), patch.object(bootstrap, 'extract', extract or self.extract), patch.object(bootstrap, 'install_solc'):
            return bootstrap.bootstrap(True, self.destination, self.tools)

    def test_clean_install_and_repeated_validation(self):
        self.assertEqual(self.install(), self.destination)
        self.assertEqual(self.install(), self.destination)
        self.assertEqual(set(self.files), {str(p.relative_to(self.destination)) for p in self.destination.rglob('*') if p.is_file()})

    def test_interruption_before_crypto_download_never_publishes(self):
        def interrupted(url, destination):
            if '/Consensys/DafnyCrypto/' in url:
                raise OSError('interrupted download')
            return self.extract(url, destination)
        with self.assertRaisesRegex(OSError, 'interrupted'):
            self.install(interrupted)
        self.assertFalse(self.destination.exists())
        self.assertFalse(list(self.root.glob('.dafnyevm-stage-*')))
        self.assertEqual(self.install(), self.destination)

    def test_bad_crypto_download_never_publishes(self):
        def tampered(url, destination):
            source = self.extract(url, destination)
            if '/Consensys/DafnyCrypto/' in url:
                (source / 'option.dfy').write_text('wrong revision')
            return source
        with self.assertRaisesRegex(AssertionError, 'Modified installation'):
            self.install(tampered)
        self.assertFalse(self.destination.exists())

    def test_existing_tampered_install_is_refused_without_replacement(self):
        self.install()
        path = self.destination / 'core.dfy'
        path.write_text('local edit must survive')
        with self.assertRaisesRegex(AssertionError, 'Modified installation'):
            self.install()
        self.assertEqual(path.read_text(), 'local edit must survive')

    def test_unbound_source_is_refused(self):
        self.install()
        (self.destination / 'extra.dfy').write_text('module Extra {}')
        with self.assertRaisesRegex(AssertionError, 'inventory'):
            self.install()


if __name__ == '__main__':
    unittest.main()
