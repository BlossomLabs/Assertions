# Exact out-of-gas signal return

This package extracts the actual local error-return branch at PC16171 through REVERT16194. It proves the exact four-byte SubcallOutOfGas selector d271060e over an arbitrary fitting caller heap, including the physical selector shift, store and final free-pointer subtraction. It is reached only after the separate exhaustion guard has chosen this branch; the local return theorem does not establish that guard.

Collections._rejectOutOfGas recognizes a returned selector only when the receipt length equals four. A longer receipt with the same leading bytes follows the ordinary callback-failure path unless the independent gas observation comparison chooses exhaustion. Truthful gas observations and sufficient resources remain explicit; there is no gas-cost, deployment or performance claim.

Generated controls and mappings are owned by generate.py and never edited directly. The development runner snapshots the complete included graph, direct owners and pinned runtime/verifier inputs before selected native verification. Complete guard and raw failed-callback composition, fresh included verification, retained physical fixtures and semantic mutations remain required. This is development work with no public coverage credit.
