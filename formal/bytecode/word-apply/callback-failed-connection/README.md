# Actual failed callback to complete CallbackFailed packet

The connection composes the full actual callback/receipt/guard with checked memory admission and complete compiled two-copy serialization on the nonrefused branch. It retains exact stamped calldata and all returned reason bytes, the public operation, index, other=0 and target. Empty/nonword reasons and arbitrary loaded receipt padding are included. Returndata and observation cursor are preserved by serialization; only the actual call and three reached GAS observations consume the tape.

Representation, fitting memory/stack/combined serialization resource, compiler-loaded map/filter selector and truthful observations are explicit. Selected imported contracts are assumed and cannot count as a full public proof. Reached/raw caller composition and fresh entire native/physical/semantic/independent evidence remain mandatory. No gas/deployment/performance claim.
