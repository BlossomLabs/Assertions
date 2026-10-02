# Signed word opcode preparation

This local extension models SIGNEXTEND on arbitrary words and indices, proves its intended equality with the independent signed ABI rule, and delegates all earlier opcode behavior through the existing BYTE machine. The four complete owners, including the isolated Euclidean helper, require fresh whole native verification. The V17 failed batch is preserved and excluded. No public array coverage is assigned. Full checkRule/checkWords and codec composition, actual complete physical receipts, faults and retained independent acceptance remain open.

The opcode representation follows the [Ethereum execution specification](https://github.com/ethereum/execution-specs/blob/master/src/ethereum/forks/cancun/vm/instructions/arithmetic.py), function `signextend`: index above 31 returns the original word; otherwise retain index+1 low bytes and propagate their high sign bit. Gas and reached stack/memory resources remain explicit premises.
