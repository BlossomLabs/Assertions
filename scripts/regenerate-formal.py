#!/usr/bin/env python3
"""Recreate ignored formal models without changing reviewed AST gates or specs."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import shutil
import tempfile
from concurrent.futures import ThreadPoolExecutor, wait, FIRST_COMPLETED

ROOT = Path(__file__).resolve().parents[1]


def digest(path):
    data = path.read_bytes()
    if path.suffix == '.json':
        data = json.dumps(json.loads(data), sort_keys=True, separators=(',', ':')).encode()
    return hashlib.sha256(data).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--solc', type=Path)
    parser.add_argument('--package', action='append', help='Package path from --list; repeatable')
    parser.add_argument('--list', action='store_true')
    parser.add_argument('--jobs', type=int, default=1, help='Independent packages to regenerate concurrently')
    args = parser.parse_args()
    recipes = json.loads((ROOT / 'formal/generated-files.json').read_text())
    if args.list:
        print('\n'.join(recipe['package'] for recipe in recipes))
        return
    if args.solc is None:
        parser.error('--solc is required for regeneration')
    if args.jobs < 1:
        parser.error('--jobs must be positive')
    by_name = {r['package']: r for r in recipes}
    if args.package:
        unknown = set(args.package) - {r['package'] for r in recipes}
        if unknown:
            parser.error('Unknown packages: ' + ', '.join(sorted(unknown)))
        selected = set()
        def select(name):
            if name in selected:
                return
            selected.add(name)
            for dependency in by_name[name]['requires']:
                select(dependency)
        for name in args.package:
            select(name)
        recipes = [r for r in recipes if r['package'] in selected]
    solc = str(args.solc.resolve())
    compiler_version = subprocess.check_output([solc, '--version'], text=True)
    if '0.8.36+commit.8a079791' not in compiler_version:
        parser.error('Use pinned solc 0.8.36+commit.8a079791')
    toolchain = json.loads((ROOT / 'formal/abi/toolchain.json').read_text())
    dafny_version = subprocess.check_output(
        ['/tmp/assertions-dafny-4.11.0/dafny/dafny', '--version'], text=True).strip()
    if dafny_version != toolchain['dafnyVersion']:
        parser.error('Use the pinned Dafny distribution described in formal/REPRODUCING.md')
    def regenerate(recipe):
        # Missing output must never be hidden by a stale local copy.
        for name in recipe['outputs']:
            (ROOT / name).unlink(missing_ok=True)
        print('Regenerating ' + recipe['package'], flush=True)
        with tempfile.TemporaryDirectory(prefix='formal-regeneration-') as folder:
            output = str(Path(folder) / 'output')
            for command in recipe['commands']:
                expanded = [s.replace('{solc}', solc) for s in command]
                for flag in ('--output', '--mapping-root'):
                    if flag in expanded:
                        expanded[expanded.index(flag) + 1] = output
                subprocess.run([sys.executable, '-B', *expanded], cwd=ROOT, check=True)
                for name in recipe['outputs']:
                    generated = Path(output) / Path(name).name
                    if generated.is_file():
                        shutil.copy2(generated, ROOT / name)
        for name, expected in recipe['outputs'].items():
            path = ROOT / name
            if not path.is_file() or digest(path) != expected:
                raise RuntimeError('Generated output drift: ' + name)
    pending = list(recipes)
    completed = set()
    running = {}
    with ThreadPoolExecutor(max_workers=args.jobs) as executor:
        while pending or running:
            for recipe in list(pending):
                if len(running) == args.jobs:
                    break
                if set(recipe['requires']) <= completed:
                    running[executor.submit(regenerate, recipe)] = recipe['package']
                    pending.remove(recipe)
            if not running:
                raise RuntimeError('Cyclic or missing regeneration dependency')
            finished, _ = wait(running, return_when=FIRST_COMPLETED)
            for future in finished:
                future.result()
                completed.add(running.pop(future))
    print(f'Checked {sum(len(r["outputs"]) for r in recipes)} regenerated files in {len(recipes)} packages.')


if __name__ == '__main__':
    main()
