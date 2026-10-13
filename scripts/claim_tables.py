"""Render concise claim coverage and navigable retained evidence."""
from pathlib import Path
import collections
import hashlib
import json
import os
import re

CATEGORIES = ('Formally verified', 'Partially verified', 'Tested', 'Partially tested', 'Scope limitation', 'Environment assumption', 'Unverified')

def record_digest(record):
    return hashlib.sha256(json.dumps(record, sort_keys=True, separators=(',', ':')).encode()).hexdigest()

def validate_claim_identities(text, registry):
    """An ID names one statement; replacements retain the original record."""
    active = []
    retired = registry.get('retiredClaims', {})
    identities = registry.get('statementSha256', {})
    for claim_id, record in registry['claims'].items():
        digest = hashlib.sha256(record['recordedClaim'].encode()).hexdigest()
        if identities.get(claim_id) != digest:
            raise ValueError('Statement identity changed under ' + claim_id + ': allocate a new claim ID')
    for line in text.splitlines():
        match = re.match(r'\| ([CAWOLER]\d+) \|', line)
        if not match:
            continue
        claim_id = match[1]
        if claim_id in active:
            raise ValueError('Duplicate active claim: ' + claim_id)
        if claim_id in retired:
            raise ValueError('Retired claim ID cannot be reused: ' + claim_id)
        record = registry['claims'][claim_id]
        if line.split('|')[2].strip() != record['recordedClaim']:
            raise ValueError('Statement changed under ' + claim_id + ': allocate a new claim ID')
        active.append(claim_id)
    if not active:
        raise ValueError('Empty claims ledger')
    for claim_id, retirement in retired.items():
        if record_digest(registry['claims'][claim_id]) != retirement['recordSha256']:
            raise ValueError('Retained claim record changed: ' + claim_id)
        replacements = retirement['replacedBy']
        if not replacements or any(item not in active and item not in retired for item in replacements):
            raise ValueError('Missing replacement for ' + claim_id)
        for replacement in replacements:
            if claim_id not in registry['claims'][replacement].get('replaces', []):
                # An exact duplicate may point to an unchanged existing claim.
                if retirement.get('relationship') != 'duplicate':
                    raise ValueError('Replacement does not identify predecessor: ' + replacement)
    return active

def current_snapshot(root, registry):
    """Keep retained symbolic credit tied to the source/configuration that ran."""
    root = Path(root)
    path = root / registry.get('halmosBaseline', '') / 'manifest.json'
    if not path.is_file():
        return False
    manifest = json.loads(path.read_text())
    sources = {str(p.relative_to(root)): hashlib.sha256(p.read_bytes()).hexdigest()
               for p in (root / 'contracts').rglob('*.sol')}
    return sources == manifest.get('sourceSha256') and all(
        (root / name).is_file() and hashlib.sha256((root / name).read_bytes()).hexdigest() == sha
        for name, sha in manifest.get('configurationSha256', {}).items())

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
            if record.get('symbolicScope'):
                label += ' (' + record['symbolicScope'] + ')'
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

def render_evidence(root, claim_ids, registry, baseline, preserve_ids=()):
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
    evidence_path = root / 'docs/claim-evidence.md'
    existing = {}
    if evidence_path.is_file():
        text = evidence_path.read_text()
        headings = list(re.finditer(r'^## ([CAWOLER]\d+)\s*$', text, re.M))
        for i, heading in enumerate(headings):
            end = headings[i + 1].start() if i + 1 < len(headings) else len(text)
            existing[heading[1]] = text[heading.start():end].rstrip()
    snapshot = root / registry.get('documentationSnapshot', {}).get('source', '')
    def source_path(path):
        path = Path(path)
        if path.is_absolute():
            return path
        current = root / path
        frozen = snapshot / path
        if snapshot != root and frozen.is_file() and (not current.is_file() or current.read_bytes() != frozen.read_bytes()):
            return frozen
        return current
    def link(path, label=None):
        path = Path(path)
        if not path.is_absolute():
            path = source_path(path)
        return '[' + (label or path.name) + '](' + os.path.relpath(path, root / 'docs') + ')'
    path_pattern = re.compile(r'`?((?:contracts|test|scripts|docs|formal|website)/[A-Za-z0-9_./-]+\.(?:sol|mjs|ts|py|json|md))(?::[0-9-]+)?`?')
    def link_paths(text):
        return path_pattern.sub(lambda m: link(m[1], m[1]) if source_path(m[1]).is_file() else m[0], text)
    definitions = collections.defaultdict(list)
    name_pattern = r'(?:check_|test(?=[A-Z_]))[A-Za-z0-9_]+'
    for base in ('contracts/tests', 'test', 'scripts'):
        paths = {str(path.relative_to(root)): path for path in (root / base).rglob('*') if path.is_file()}
        if snapshot != root and (snapshot / base).is_dir():
            paths.update({str(path.relative_to(snapshot)): path for path in (snapshot / base).rglob('*') if path.is_file()})
        for path in paths.values():
            if path.is_file() and path.suffix in ('.sol', '.ts', '.py'):
                for name in re.findall(r'\b(?:function|def)\s+(' + name_pattern + r')\s*\(', path.read_text()):
                    definitions[name].append(path)
    lines = ['# Claim evidence', '', 'Evidence references and limitations for [the functional claims](claims.md). Each recorded run applies to its own source snapshot, assumptions and bounds. File links open the current test source; run records identify the source snapshot that actually ran. A passing test supports its stated coverage, rather than an unrestricted proof of the claim. Some detailed run artifacts are retained locally and excluded from Git.', '', 'The evidence records are preserved in [claim-evidence.json](claim-evidence.json).', '']
    if not current_snapshot(root, registry):
        lines.extend(['**Prior snapshot:** this checkout differs from the recorded Halmos sources/configuration. Passing results apply to the retained review snapshot. Source links use preserved tested sources where available.', ''])
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
    retired = registry.get('retiredClaims', {})
    for claim_id in [*claim_ids, *retired]:
        record = registry['claims'][claim_id]
        if claim_id in retired:
            replacements = ', '.join('[' + item + '](#' + item.lower() + ')' for item in retired[claim_id]['replacedBy'])
            lines.extend(['## ' + claim_id, '', '**Historical statement:** ' + record['recordedClaim'], '',
                          '**Replaced by:** ' + replacements + '. ' + retired[claim_id]['reason'], '',
                          '**Retained evidence:** ' + record['evidenceType'] + ' / ' + record['executionStatus'] + ' for this historical statement.', ''])
            if claim_id in existing:
                # Keep original result links even when local run artifacts are absent.
                body = existing[claim_id].split('\n', 1)[1]
                if '**Historical statement:**' in body:
                    body = body[body.index('**Recorded evidence:**'):]
                lines.extend([body.strip(), ''])
                continue
            lines.extend(['**References:** ' + link_paths(record['evidence']), '',
                          '**Scope and limitations:** ' + link_paths(record['notes']), ''])
            if record.get('run') and (root / record['run']).is_file():
                lines.extend(['**Recorded historical run:** ' + link(record['run']) + '.', ''])
            continue
        if claim_id in preserve_ids and claim_id in existing:
            lines.extend([existing[claim_id], ''])
            continue
        lines.extend(['## ' + claim_id, '', '**Recorded evidence:** ' + record['evidenceType'] + ' / ' + record['executionStatus'] + '.', '', '**References:** ' + link_paths(record['evidence']), ''])
        if record.get('replaces'):
            lines.extend(['**Replaces:** ' + ', '.join('[' + item + '](#' + item.lower() + ')' for item in record['replaces']) + '; each prior statement and its evidence are retained below.', ''])
        if record.get('run') and source_path(record['run']).is_file():
            lines.extend(['**Recorded run:** ' + link(record['run'], 'results, commands and source hashes') + '.', ''])
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
    (root / 'docs/claim-evidence.md').write_text('\n'.join(line.rstrip() for line in lines))
