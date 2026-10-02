"""Report current generation evidence separately from native and source acceptance."""
import json
from pathlib import Path
from check import ROOT, LIBRARY, digest
from generate import CONFIG


def generation_status():
    evidence={}
    for path in (LIBRARY/'evidence/reviews').glob('*.json'):
        review=json.loads(path.read_text())
        if review.get('status')!='independently-reviewed-generation-correspondence':
            continue
        package=review['package']
        if package not in CONFIG:
            continue
        manifest_path=ROOT/review['evidence']/'manifest.json'
        if not manifest_path.is_file() or digest(manifest_path)!=review['manifestSha256']:
            continue
        manifest=json.loads(manifest_path.read_text())
        directory=manifest_path.parent
        if any(not (directory/p).is_file() or digest(directory/p)!=h for p,h in manifest['evidenceSha256'].items()):
            continue
        if any(not (ROOT/p).is_file() or digest(ROOT/p)!=h for p,h in manifest['tools'].items()):
            continue
        config=CONFIG[package]
        # Producer scripts are frozen provenance; changing library tooling does
        # not change the input Solidity, template, or adapter correspondence.
        required=[config['generator'],config['canonical']]+config['formatDependencies']
        required += [str(Path(config['generator']).parent/name) for name in config['inputs']]
        required += [p for p in manifest['inputs'] if p.startswith('contracts/') or p.startswith('node_modules/')]
        if any(not (ROOT/p).is_file() or manifest['inputs'].get(p)!=digest(ROOT/p) for p in required):
            continue
        evidence.setdefault(package,[]).append({'review':str(path.relative_to(ROOT)),
                                               'declarations':review['declarations']})
    return evidence
