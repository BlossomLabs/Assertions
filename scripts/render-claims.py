#!/usr/bin/env python3
"""Render existing evidence labels without running proofs or changing receipts."""
import argparse
import json
from pathlib import Path
import re
from claim_tables import coverage_table, current_snapshot, evidence_cell, render_evidence, validate_claim_identities, verification_label

ROOT = Path(__file__).resolve().parents[1]

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true', help='validate identities and labels without writing')
    args = parser.parse_args()
    path = ROOT / 'docs/claims.md'
    text = path.read_text()
    registry = json.loads((ROOT / 'docs/claim-evidence.json').read_text())
    ids = validate_claim_identities(text, registry)
    prior = not current_snapshot(ROOT, registry)
    lines = []
    for line in text.splitlines():
        match = re.match(r'\| ([CAWOLER]\d+) \|', line)
        if match:
            claim_id = match[1]
            record = registry['claims'][claim_id]
            line = '| ' + ' | '.join([claim_id, record['recordedClaim'], verification_label(record, prior), evidence_cell(claim_id, record)]) + ' |'
        lines.append(line)
    rendered = '\n'.join(lines) + '\n'
    rendered = re.sub(r'(?s)<!-- claim-coverage -->.*?<!-- /claim-coverage -->',
                      lambda _: coverage_table(verification_label(registry['claims'][item], prior) for item in ids), rendered, count=1)
    if args.check:
        if rendered != text:
            raise SystemExit('Claims labels or coverage are stale: run scripts/render-claims.py')
    else:
        path.write_text(rendered)
        # Unchanged statements retain their original evidence sections and result links.
        preserve = [] if prior else [item for item in ids if not registry['claims'][item].get('replaces') and not registry['claims'][item].get('introducedIn')]
        render_evidence(ROOT, ids, registry, registry['halmosBaseline'], preserve_ids=preserve)
    print(f'{len(ids)} active claims; {len(registry.get("retiredClaims", {}))} retained predecessor IDs')

if __name__ == '__main__':
    main()
