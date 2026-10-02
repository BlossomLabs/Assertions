# Operations shifts development

Four exact-runtime raw entries: `shl(uint256,uint256)`, unsigned and signed `shr`, and `bitSet`. All 256-bit argument words and arbitrary trailing calldata are admitted after complete 68-byte head checks. Signed arithmetic shifts use exact two’s-complement sign filling, with nonnegative/negative saturation at shifts of 256 or greater. This is development work; no retained evidence or public coverage.

The reviewed reached-opcode model extends the isolated scalar interpreter with general SHR and SAR. `SelectorRight` establishes the direct finite-word selector extraction; `SignedRight` states the complement and saturation identities. Neither lemma is claimed verified until fresh native evidence exists. Source proofs and concrete fixtures do not substitute for these obligations.

Generated files are owned by `generate.py` and `rejections/generate.py`; never edit directly. Exact instruction boundaries/JUMPDESTs, fitting calldata length below 2^64, truthful call observations and sufficient reached resources remain explicit. No gas/deployment/performance claims.

The new shift owner rounds memory expansion to 32-byte boundaries. This preserves its reached aligned 64/128-byte stores and permits later reuse for unaligned error frames without treating a 36-byte logical prefix as a 36-byte physical EVM allocation. Existing live owners remain unchanged.

The original helper bridging SHR224 to an alternate integer-division notation timed out after 30 seconds and is preserved in `development/selector-right-v1`. The new owner uses direct finite-word bitvector selector extraction, exactly the reached EVM operation; no header admission, input word, resource premise or time limit is narrowed. No integer-division equivalence claim is counted.
