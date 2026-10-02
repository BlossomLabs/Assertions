"""Render concise claim coverage and navigable retained evidence."""
from pathlib import Path
import collections
import json
import os
import re

CATEGORIES = ('Formally verified', 'Partially verified', 'Tested', 'Partially tested', 'Scope limitation', 'Environment assumption', 'Unverified')

def verification_label(record, prior_snapshot=False):
    kind, status, notes = record['evidenceType'], record['executionStatus'], record['notes']
    partial = notes.startswith('Partial:')
    if kind == 'LIMITATION':
        return 'Scope limitation'
    if kind == 'ASSUMPTION':
        return 'Environment assumption'
    if kind == 'SYMBOLIC':
        if status == 'PROVED':
            label = 'Partially verified' if partial else 'Formally verified'
            return label + (' (prior snapshot)' if prior_snapshot else '')
        return 'Unverified (formal ' + status.lower() + ')'
    if kind in ('UNIT', 'FUZZED', 'DIFFERENTIAL') and status == 'SUITE PASSED':
        return ('Partially tested' if partial else 'Tested') + ' (' + {'UNIT': 'unit', 'FUZZED': 'fuzz', 'DIFFERENTIAL': 'differential'}[kind] + ')'
    return 'Unverified'

def coverage_table(labels):
    counts = collections.Counter(next((c for c in CATEGORIES if label.startswith(c)), 'Unverified') for label in labels)
    return '\n'.join(('<!-- claim-coverage -->', '| | ' + ' | '.join(CATEGORIES) + ' |', '|---|' + '---|' * len(CATEGORIES), '| Claims | ' + ' | '.join(str(counts[c]) for c in CATEGORIES) + ' |', '<!-- /claim-coverage -->'))

def evidence_cell(claim_id, record):
    if record['evidenceType'] in ('LIMITATION', 'ASSUMPTION'):
        return '[Scope](claim-evidence.md#' + claim_id.lower() + ')'
    if record['executionStatus'] not in ('PROVED', 'SUITE PASSED'):
        return '—'
    label = 'Proof & scope' if record['evidenceType'] == 'SYMBOLIC' else 'Tests & scope'
    return '[' + label + '](claim-evidence.md#' + claim_id.lower() + ')'

def render_evidence(root, claim_ids, registry, baseline):
    """Keep original evidence wording; resolve links only to files that exist."""
    root = Path(root)
    baseline = Path(baseline)
    if not baseline.is_absolute():
        baseline = root / baseline
    manifest_path = baseline / 'manifest.json'
    mapping_path = baseline / 'claims.json'
    manifest = json.loads(manifest_path.read_text()) if manifest_path.exists() else {}
    mapping = json.loads(mapping_path.read_text()).get('claims', {}) if mapping_path.exists() else {}
    properties = {p['property']: p for p in manifest.get('results', [])}
    def link(path, label=None):
        path = Path(path)
        if not path.is_absolute():
            path = root / path
        return '[' + (label or path.name) + '](' + os.path.relpath(path, root / 'docs') + ')'
    path_pattern = re.compile(r'`?((?:contracts|test|scripts|docs|formal|website)/[A-Za-z0-9_./-]+\.(?:sol|mjs|ts|py|json|md))(?::[0-9-]+)?`?')
    def link_paths(text):
        return path_pattern.sub(lambda m: link(m[1], m[1]) if (root / m[1]).is_file() else m[0], text)
    definitions = collections.defaultdict(list)
    name_pattern = r'(?:check_|test(?=[A-Z_]))[A-Za-z0-9_]+'
    for base in ('contracts/tests', 'test', 'scripts'):
        for path in (root / base).rglob('*'):
            if path.is_file() and path.suffix in ('.sol', '.ts', '.py'):
                for name in re.findall(r'\b(?:function|def)\s+(' + name_pattern + r')\s*\(', path.read_text()):
                    definitions[name].append(path)
    lines = ['# Claim evidence', '', 'Evidence references and limitations for [the functional claims](claims.md). Each recorded run applies to its own source snapshot, assumptions and bounds. File links open the current test source; run records identify the source snapshot that actually ran. A passing test supports its stated coverage, rather than an unrestricted proof of the claim. Some detailed run artifacts are retained locally and excluded from Git.', '', 'The evidence records are preserved in [claim-evidence.json](claim-evidence.json).', '']
    run_path = root / registry.get('halmosRun', '')
    if (registry.get('halmosBaseline') == os.path.relpath(baseline, root)
            and run_path.is_file()):
        run = json.loads(run_path.read_text())
        summary = run['manifest']['summary']
        lines.extend(['**Halmos baseline:** ' + link(run_path, 'results, source hashes and logs')
                      + ' — ' + ', '.join(str(summary[k]) + ' ' + k for k in ('passed', 'failed', 'incomplete'))
                      + '. Separate source and bytecode proof campaigns are excluded.', ''])
        for check in run['checks'].get('checks', []):
            if check['name'] == 'full-forge-suite' and check['exitCode'] == 0:
                lines.extend(['**Concrete suite:** ' + str(check['passed'])
                              + ' passed, 0 failed against this source snapshot. See the linked run record.', ''])
        for check in run['checks'].get('supplementalChecks', []):
            if check['exitCode'] != 0:
                lines.extend(['**Concrete suite exception:** ' + str(check['passed']) + ' passed, '
                              + str(check['failed']) + ' failed in the supplemental full Forge run. '
                              + ('Its source snapshot was ' + check['sourceSnapshot'] + '. '
                                 if check.get('sourceSnapshot') else '')
                              + check['diagnosis'] + ' See the linked run record.', ''])
    for claim_id in claim_ids:
        record = registry['claims'][claim_id]
        lines.extend(['## ' + claim_id, '', '**Recorded evidence:** ' + record['evidenceType'] + ' / ' + record['executionStatus'] + '.', '', '**References:** ' + link_paths(record['evidence']), ''])
        if record.get('run') and (root / record['run']).is_file():
            lines.extend(['**Recorded test run:** ' + link(record['run'], 'results, commands and source hashes') + '.', ''])
        lines.extend(['**Supporting sources:** ' + link_paths(record['sources']), ''])
        related = [id for id in dict.fromkeys(re.findall(r'\b[CAWOLER]\d+\b', record['evidence'])) if id != claim_id and id in claim_ids]
        if related:
            lines.extend(['**Related behavioral evidence:** ' + ', '.join('[' + id + '](#' + id.lower() + ')' for id in related) + '.', ''])
        if 'pnpm check:integration' in record['evidence'] and (root / 'website/scripts/check-integration.mjs').is_file():
            lines.extend(['**Integration check:** ' + link('website/scripts/check-integration.mjs', 'check:integration') + '.', ''])
        if '/concrete' in record['evidence'] and (baseline / 'checks.json').is_file():
            lines.extend(['**Concrete run results:** ' + link(baseline / 'checks.json', 'checks and exit statuses') + '.', ''])
        names = set(re.findall(r'\b' + name_pattern + r'\b', record['evidence']))
        test_links = []
        for name in sorted(names):
            for path in definitions[name]:
                test_links.append(link(path, name))
        if test_links:
            lines.extend(['**Test/property definitions:** ' + ', '.join(dict.fromkeys(test_links)) + '.', ''])
        if record['evidenceType'] == 'SYMBOLIC' and claim_id in mapping:
            result_links = []
            for result in mapping[claim_id].get('properties', []):
                prop = properties.get(result['property'])
                if not prop:
                    continue
                artifact = baseline / prop.get('json', prop['log'])
                if not artifact.is_file():
                    artifact = baseline / prop['log']
                if artifact.is_file():
                    result_links.append(link(artifact, result['property'] + ': ' + prop['status']))
            if result_links:
                lines.extend(['**Retained formal results:** ' + ', '.join(result_links) + '.', '', '**Run assumptions and source identity:** ' + link(manifest_path, 'manifest') + ' (source hashes, tool configuration, bounds and gas model).', ''])
        if record['notes']:
            lines.extend(['**Scope and limitations:** ' + link_paths(record['notes']), ''])
    (root / 'docs/claim-evidence.md').write_text('\n'.join(lines))
