# Repeated-iteration memory admission and protected bytes

Generic finite memory lemmas connect arbitrary ordered overlapping template stamps, actual payload packing, caller-local32-byte successful receipt and output writes. The source/output region below the template pointer is protected from stamp and callback allocation/copy. The template header and free-pointer word remain exact across each callback; the successful receipt increases the free pointer by64.

The stamping memory bound is2^67, widened from2^66 to cover the admitted overlapping raw layouts over all source iterations. Source count below2^59, original template length below2^64 and the actual64-byte per-iteration receipt growth must derive that bound in the complete raw loop theorem; it is not a calldata or iteration fixture cap. Native verification, the complete raw loop, errors/serialization and full retained include graph remain required. No gas/deployment/performance claim.
