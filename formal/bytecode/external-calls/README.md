# Reached external-call and returndata foundations

This development extension adds STATICCALL, GAS, EXTCODESIZE, ADDRESS, RETURNDATASIZE and RETURNDATACOPY to the existing copy machine without modifying its frozen source. Typed, history-indexed observations must match the actual caller, masked target, requested gas and original input bytes. Call success, full original return/revert bytes, code size and gas observations must be truthful for the actual execution context. Requested gas is not claimed to equal gas forwarded to the child.

Physical semantics snapshot input before output writes, expand both nonempty memory windows, copy only the minimum of output capacity and returned length, preserve the remaining output bytes, and replace the caller-local returndata buffer after every call, including failure and empty output. Returndata copy checks source+size even for zero-size copies; an offset one byte beyond the buffer is exceptional. Code-size and gas observations leave the previous returndata intact. ADDRESS depends on the current execution address.

Finite fitting word/memory representation, reviewed instruction interpretation and adequate reached resources remain explicit. The actual external world, gas schedule, child code correctness and deployment are not proved. Generic foundations and physical fixture checks do not count as public entry coverage; each remaining callback entry still requires complete current bytecode extraction, raw boundary/body/error/serializer connections and retained evidence.

Semantics references: [EIP-211](https://eips.ethereum.org/EIPS/eip-211) and [Ethereum execution-specs system instructions](https://github.com/ethereum/execution-specs/blob/master/src/ethereum/forks/cancun/vm/instructions/system.py).
