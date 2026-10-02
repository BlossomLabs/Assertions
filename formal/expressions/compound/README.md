# Compound expression construction

The source adapters cover `_arguments`, Wrap, Array, Tuple and Call's argument
prefix. They consume already evaluated child values; the recursive-control
package proves child order and failure short-circuiting separately.

Arguments preserve the existing independently specified parser and tuple
constructor verdicts, including the empty `()` zero-argument case, component
count errors and first invalid component fields. The dynamic flag is proved
from the actual tuple plan. Successful Tuple output is exactly the canonical
single-value tuple encoding: dynamic tuples have an outer offset, static tuples
do not. Call arguments use the tuple body directly after the selector. The
Array adapter reuses the proved pack implementation for arbitrary finite lists;
Wrap constructs a bytes envelope and proves validator acceptance under an
explicit allocation bound.

The full normalized `_evaluate` and `_arguments` ASTs are gated, but only these
construction paths are lowered here. A source fault changes the dynamic tuple
offset from 32 to 64 and must translate and fail both the Tuple theorem and its
EVM test. Other source-control paths are covered by their own packages.

Assumptions retain the codec's memory, arithmetic/cursor and resource premises,
pinned translator/toolchain, standard Solidity ABI word/bytes encoding and
concatenation. Successful encoding does not bypass the final declared node-type
validation. Arbitrary codec failure serialization, full evaluator receipt/oracle
composition and compiled-bytecode verification remain separate obligations.
