# Raw-return memory boundaries

The full normalized solc ASTs of evaluate and evaluateEncoded are gated. Their
final assembly return statements are lowered to reads from a byte-memory model:
mload(result) reads the bytes-object length, and return starts at result + 32.
Each translated tail proves that its output is exactly the object's payload for
arbitrary finite payloads, pointer locations and surrounding memory contents.
There is no extra bytes envelope, truncation or trailing data in the result.
CanonicalReturn connects both tails to the independent ABI validator/encoder:
a canonical input value remains the exact encoding of the same typed value.

Object is an explicit memory projection premise. It requires a valid Solidity
bytes-memory object, nonwrapping representable memory bounds and the correct
length word. Sufficient local resources are assumed. Window models zero-filled
memory outside the current extent, but the proved returns lie wholly inside the
object. This is an AST-gated manual source translation, not compiler correctness
or exact-bytecode verification.

The evaluator's canonical-result theorem supplies the canonical value premise;
its actual memory representation still has to satisfy Object. This package
covers only successful raw-return tails. It does not prove evaluateEncoded's
input decoder or self-call/error wrapper, encode admission errors, or establish
evaluateGuarded's external tuple return and actual frame provenance.

Six EVM tests compare exact returndata for direct and encoded word, dynamic,
static tuple and empty-bytes values. Two actual Solidity faults independently
change a return pointer from result + 32 to result + 0. Each must pass source
translation, fail its semantic return postcondition without timeout/type errors,
and fail its named EVM exact-byte test. Mutations run only in retained scratch
snapshots; production Solidity is unchanged.

The baseline retains source/compiler inputs, normalized AST structure, generated
mapping, native declaration inventory, tool hashes, dependency audits, test
results and proof audit. Separate mutation evidence retains each translated
fault and its proof/EVM rejection.
