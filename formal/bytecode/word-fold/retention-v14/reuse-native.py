#!/usr/bin/env python3
"""Validate complete prior modules against their current transitive contracts.

This prepares native provenance, not public evidence. The retained verifier must
cover every module of the current root graph, freshly reproduce its generated
owners, and pass compiler, audit, physical, mutation and independent checks.
Prior failed runs may contribute only independently complete whole modules.
"""
import argparse
import copy
import importlib.util
import json
import re
import shutil
from pathlib import Path

if not __debug__:
    raise RuntimeError('Run without Python -O')
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]


def module(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    obj = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(obj)
    return obj


getter = module('fold_reuse_getter', ROOT / 'formal/bytecode/getters/verify.py')
common = getter.common
sha = common.sha


def graph(roots, base=ROOT):
    closed = set()

    def visit(path):
        path = path.resolve()
        assert path.is_relative_to(base) and path.is_file(), str(path)
        if path in closed:
            return
        closed.add(path)
        for include in re.findall(r'^include "([^"]+)"', path.read_text(), re.M):
            visit(path.parent / include)

    for path in roots:
        visit(path)
    return sorted(closed)


class Evidence:
    def __init__(self, executable_hashes):
        self.executable_hashes = executable_hashes
        self.cache = {}
        self.hash_cache = {}

    def digest(self, path):
        path = path.resolve()
        # Cache only within this validation. Retained verification and the
        # independent checker recheck current inputs and evidence afterward.
        if path not in self.hash_cache:
            self.hash_cache[path] = sha(path)
        return self.hash_cache[path]

    def load(self, path):
        path = path.resolve()
        assert path.is_relative_to(ROOT) and path.name == 'manifest.json'
        if path in self.cache:
            return self.cache[path]
        m = json.loads(path.read_text())
        assert m.get('completedAt'), 'Prior native run is not terminal'
        assert m['status'] in {
            'passed', 'failed', 'development-native-passed-not-retained',
            'development-native-failed',
            'development-native-failed-incomplete-after-required-error',
        }, 'Unreviewed prior status'
        # A failed whole driver may have stopped before writing its final drift
        # booleans. No whole-driver claim is reused: every snapshot/evidence hash
        # is checked below, and validate() checks the selected module's complete
        # current transitive contracts and compiler inputs independently.
        assert set(m['executableSha256']) in [
            {'dafny', 'Dafny.dll', 'z3'}, {'dafny', 'Dafny.dll', 'z3', 'solc'}
        ], 'Uninventoried prior native tool identities'
        assert all(self.executable_hashes[k] == digest
                   for k, digest in m['executableSha256'].items()), 'Changed native tool'
        assert m.get('sourceSha256') and m.get('evidenceSha256')
        for relative, digest in m['sourceSha256'].items():
            assert self.digest(path.parent / 'source-snapshot' / relative) == digest
        for relative, digest in m['evidenceSha256'].items():
            assert self.digest(path.parent / relative) == digest, relative
        audits = [j for j in m['checks'] if j['name'].startswith('audit-')]
        assert audits and all(j['passed'] and j['exitCode'] == 0 and
                              'auditor completed with 0 findings' in
                              (path.parent / j['log']).read_text() for j in audits)
        self.cache[path] = m
        return m

    def validate(self, manifest, path, job, active=()):
        manifest = manifest.resolve()
        assert manifest not in active, 'Cyclic native provenance'
        m = self.load(manifest)
        mod = re.search(r'^module (\w+)', path.read_text(), re.M)[1]
        name = 'proof-' + mod
        assert job['name'] == name and job['passed'] and job['exitCode'] == 0
        assert self.digest(Path(job['command'][0])) == self.executable_hashes['dafny']
        assert self.digest(Path(job['command'][0]).parent / 'Dafny.dll') == self.executable_hashes['Dafny.dll']
        solver = Path(job['command'][job['command'].index('--solver-path') + 1])
        assert self.digest(solver) == self.executable_hashes['z3']
        required = graph([path]) + getter.inputs()
        for source in set(required):
            relative = str(source.relative_to(ROOT))
            assert m['sourceSha256'].get(relative) == self.digest(source), (
                'Changed or uncaptured transitive contract/compiler input', relative)
        snapshot = manifest.parent / 'source-snapshot' / path.relative_to(ROOT)
        # A copied reused job retains its original command. Recursively validate
        # that origin, including its actual whole-module source, command and CSV.
        if 'priorManifest' in job:
            origin = ROOT / job['priorManifest']
            assert self.digest(origin) == job['priorManifestSha256']
            prior = self.load(origin)
            prior_job = next(j for j in prior['checks'] if j['name'] == name)
            for key in ['command', 'exitCode', 'nativeResults', 'declarations']:
                assert job[key] == prior_job[key], ('Reused result drift', key)
            assert self.digest(origin.parent / (name + '.log')) == job['priorLogSha256']
            assert self.digest(origin.parent / (name + '.csv')) == job['priorCsvSha256']
            self.validate(origin, path, prior_job, active + (manifest,))
        else:
            csv_path = manifest.parent / (name + '.csv')
            expected = list(map(str, common.proof_command(
                Path(job['command'][0]), snapshot, csv_path)))
            limit = job['command'][job['command'].index('--verification-time-limit') + 1]
            # Some complete, separately reviewed predecessors used 120 seconds.
            # Reuse their completed result; every newly run fold module uses 30.
            assert limit in {'30', '120'}, 'Unreviewed prior verification allowance'
            expected[expected.index('--verification-time-limit') + 1] = limit
            expected += ['--filter-symbol', mod, '--filter-position', str(snapshot),
                         '--progress', 'Symbol']
            assert job['command'] == expected, 'Partial or changed native command'
        checked = copy.deepcopy(job)
        common.check_proof(checked, manifest.parent / (name + '.log'),
                           manifest.parent / (name + '.csv'), getter.inventory(path))
        assert checked['passed'] and checked['nativeResults'] == job['nativeResults']
        assert checked['declarations'] == job['declarations'], 'Incomplete declaration inventory'
        return dict(manifest=str(manifest.relative_to(ROOT)),
                    manifestSha256=self.digest(manifest), source=str(path.relative_to(ROOT)),
                    sourceSha256=self.digest(path), module=mod, proof=name,
                    logSha256=self.digest(manifest.parent / (name + '.log')),
                    csvSha256=self.digest(manifest.parent / (name + '.csv')),
                    transitiveContractSha256={str(f.relative_to(ROOT)): self.digest(f)
                                             for f in graph([path])},
                    nativeObligations=len(checked['nativeResults']),
                    declarations=len(checked['declarations']),
                    priorStatus=m['status'],
                    scope='Complete selected module only; imported bodies close only when every current graph module is covered.')


def prepare(manifests, roots, executable_hashes, output=None):
    evidence = Evidence(executable_hashes)
    closed = graph(roots)
    names = [re.search(r'^module (\w+)', f.read_text(), re.M)[1]
             for f in closed if re.search(r'^module (\w+)', f.read_text(), re.M)]
    assert len(names) == len(set(names)), 'Duplicate module owners'
    candidates = {}
    rejected_manifests = []
    for manifest in manifests:
        try:
            m = evidence.load(manifest)
        except (AssertionError, OSError, KeyError, StopIteration) as error:
            rejected_manifests.append(dict(manifest=str(manifest.relative_to(ROOT)), reason=str(error)))
            continue
        for job in m['checks']:
            if job.get('passed') and job['name'].startswith('proof-'):
                candidates.setdefault(job['name'], []).append((manifest, job))
    accepted, provenance, missing = {}, [], []
    for path in closed:
        match = re.search(r'^module (\w+)', path.read_text(), re.M)
        if not match:
            assert not re.search(r'\b(?:lemma|method|function|predicate|type)\s+\w+', path.read_text()), 'Forwarder has declarations'
            continue
        name = 'proof-' + match[1]
        failures = []
        for manifest, job in candidates.get(name, []):
            try:
                origin = evidence.validate(manifest, path, job)
            except (AssertionError, OSError, KeyError, StopIteration) as error:
                failures.append(dict(manifest=str(manifest.relative_to(ROOT)), reason=str(error)))
                continue
            accepted[name] = copy.deepcopy(job)
            provenance.append(origin)
            if output:
                shutil.copy2(manifest.parent / (name + '.log'), output / (name + '.log'))
                shutil.copy2(manifest.parent / (name + '.csv'), output / (name + '.csv'))
                accepted[name].update(nativeEvidenceOrigin='reused-complete-module-identical-current-transitive-contracts',
                                      foldReuseProvenance=origin)
            break
        else:
            missing.append(dict(module=match[1], source=str(path.relative_to(ROOT)), rejectedCandidates=failures))
    record = dict(status='native-provenance-preparation-not-retained', moduleCount=len(names),
                  acceptedModules=len(accepted), nativeObligations=sum(p['nativeObligations'] for p in provenance),
                  provenance=provenance, missingModules=missing, rejectedManifests=rejected_manifests,
                  includeOnlyFiles=[str(f.relative_to(ROOT)) for f in closed if not re.search(r'^module (\w+)', f.read_text(), re.M)],
                  scope='No public evidence. Every missing module must pass fresh complete native verification; all retained compiler/generation/audit/EVM/mutation/checker gates remain required.')
    return accepted, record


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--sources', type=Path, required=True)
    parser.add_argument('--dafny', type=Path, required=True)
    parser.add_argument('--solc', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    dafny = args.dafny.resolve()
    tools = {'dafny': dafny, 'Dafny.dll': dafny.parent / 'Dafny.dll',
             'z3': dafny.parent / 'z3/bin/z3-4.12.1', 'solc': args.solc.resolve()}
    sources = json.loads(args.sources.read_text())
    spec = json.loads((HERE / 'proof-spec.json').read_text())
    _, record = prepare([ROOT / p for p in sources], [ROOT / p for p in spec['rootProofs']],
                        {k: sha(v) for k, v in tools.items()})
    args.output.parent.mkdir(parents=True, exist_ok=True)
    assert not args.output.exists(), 'Preserve prior preparation evidence'
    args.output.write_text(json.dumps(record, indent=2) + '\n')
    print(json.dumps({k: record[k] for k in ['moduleCount', 'acceptedModules', 'nativeObligations']} |
                     dict(missingModules=[m['module'] for m in record['missingModules']],
                          rejectedManifests=record['rejectedManifests'])))


if __name__ == '__main__':
    main()
