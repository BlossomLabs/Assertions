# Assertions physical scalar helpers

This package targets only code in the exact current Assertions runtime. It
covers reached `_firstWord`, `_asAddress`, and `_rawWord` bodies and their
physical errors. It does not count as successful public ABI-entry coverage;
raw decoding, operand resolution and complete primitive composition remain
separate obligations. No Collections, Operations or Expressions code is proved.

The independent specifications require a complete first word, a clean address
word (all high96 bits clear), and signed whole-word selection: nonnegative
indices start at zero, negative indices count back from the number of complete
words. Every out-of-bounds index, including int256 minimum, has the exact
`ReturnDataOutOfBounds(index,length)` bytes. Dirty address words have exact
`InvalidAddressWord(index,word)` bytes. Memory stores and shared physical REVERT
instructions are part of the trace; error serialization is not assumed.

`generate.py` extracts all actual instructions for eight complete helper path
classes. The native proofs check every extracted step against reviewed EVM
semantics and independent guards. Runtime length is not a fixture bound: all
symbolic lengths fitting the represented memory object are covered. The finite
helper-path rank is the number of remaining actual instructions, including both
checked negations in negative word selection; no application loop or recursive
operand tree is shortened by that rank.

A caller supplies actual rounded memory, a representable nonwrapping bytes
object, physical free memory pointer, a valid operand stack, a return label in
the full-runtime instruction-boundary destination set, and sufficient reached
resources. These are call-frame obligations to establish when composing the
public entries. There is no gas-cost or unconditional resource-availability
claim. The mathematical word/byte projection, instruction interpretation,
canonical extraction, full-runtime instruction-boundary scanner and tools
remain trusted. No assumed compiler allocator, decoder, call or return theorem
substitutes for their body instructions in this package.

`verify.py` reproduces the entire canonical runtime, snapshots the complete
include graph, regenerates every extracted file, verifies every native
proof declaration in that graph, audits assumptions, checks formatting, retains
20 actual-EVM fixtures, and requires native and concrete rejection of three
semantic physical-error mutations. A pass requires all evidence and stable
source/tool hashes. Development runs and partial checks are not retained passes.

```sh
python3 -B formal/bytecode/assertions-primitives/verify.py \
  --dafny /home/sem/assertions-tools/dafny/dafny \
  --solc /home/sem/assertions-tools/solc-0.8.36 \
  --node /home/sem/assertions-tools/node-v24.14.0-linux-x64/bin/node \
  --jobs 4 --output /tmp/assertions-primitives-evidence
```
