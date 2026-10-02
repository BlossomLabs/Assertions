# zipWords body admission development

The actual body first checks alignment of input a, then input b, then equality of byte lengths. Aligned unequal lengths must return the exact WordCountMismatch with both word counts. Equal-length inputs undergo checked doubling, followed by the actual 64-bit allocation-size guard. Oversized doubled output must take Panic(0x41); successful allocation implies count below 2^58. The accepted instruction segments here are separate from error paths, raw ABI rejection and retained public-entry evidence.
