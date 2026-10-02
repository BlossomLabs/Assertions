"""Run inside the pinned Kontrol image after a proof run; emit compact status.

Reads proof state through Kontrol/Pyk rather than inferring proof success from
process exit status. Does not alter or advance any proof.
"""
import hashlib
import json
from pathlib import Path

from pyk.proof.reachability import APRProof

root = Path('out/proofs')
records = []
for path in sorted(root.glob('*/proof.json')):
    proof = APRProof.read_proof_data(root, path.parent.name)
    record = dict(id=proof.id, status=proof.status.value, admitted=proof.admitted,
                  pending=[node.id for node in proof.pending],
                  failing=[node.id for node in proof.failing],
                  bounded=list(proof.bounded),
                  subproofs=list(proof.subproof_ids),
                  proofJsonSha256=hashlib.sha256(path.read_bytes()).hexdigest())
    records.append(record)
Path('proof-status.json').write_text(json.dumps(records, indent=2) + '\n')
print(json.dumps(records, indent=2))
