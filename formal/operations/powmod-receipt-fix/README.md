# powMod fresh receipt regression

The canonical fix assigns the STATICCALL success value before reading RETURNDATASIZE. This regression observes complete pinned-compiler EVM traces for all four public overloads at large exponents, checks the exact MODEXP input bytes and successful output, and requires the accepted receipt to return without entering the MULMOD fallback. The previous source still returns the mathematical result, so output-only tests would miss the routing bug.

This packet contains concrete regression observations, not Operations bytecode proof coverage or gas/performance evidence. Operations source proof retention and original-bytecode work remain separate. Old retained snapshots are preserved and require current-source revalidation after the source hash changes.
