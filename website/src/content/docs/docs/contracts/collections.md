---
title: Collections
description: "Array management for assertions: check every or any element, find, filter, sort, deduplicate and total the lists that contracts return, in one call instead of one read per element."
---

`Collections` is the expansion pack of Assertions that allows array management: checking, finding, filtering, sorting and totalling the lists that contracts return. Checking that every owner of a Safe is on an allowlist, that the sum of a vault's caps stays above a floor, or that a returned list has no duplicates means visiting every element. Resolved one element at a time through the Assertions core, that costs one resolution per element. Collections runs the loop in a single `staticcall`, and the core splices the already-resolved operands into its calldata through [`read`](/docs/contracts/assertions).

You meet it in a decoded batch as a `STATIC_CALL` whose target is the Collections deployment (see [Deployments](/docs/contracts/deployments)) and whose selector is one of the names below. Its functions take and return plain ABI types, with no ERC-8211 coupling. Scalar functions used inside a loop come from [Operations](/docs/contracts/operations), and a callback can be an [Expressions](/docs/contracts/expressions) graph.

Collections has two families:

- The **word family** works on payloads: a `bytes` value holding N packed 32-byte words (one-word array elements with the ABI offset and length stripped, or the output of another word operation). Lambdas are calldata templates whose 32-byte windows are rewritten per element.
- The **values family** works on `bytes[]`, where each element is the canonical `abi.encode` of one value of any type (strings, tuples, nested arrays included). Callbacks are bound through a `Callback` descriptor.

All Collections applications are `staticcall`s, so lambdas and callbacks cannot have side effects. They are trusted to satisfy their semantic laws: sorting needs a consistent total preorder and uniqueness needs an equivalence relation. Inconsistency is not checked, and the algorithms follow the callback's answers. Failed calls and malformed results still revert.

## Functions by task

EVML spellings are helpers from the `lang` module ([helper table](/docs/evml)). A helper chooses between the word family and the values family from the element type.

| Task | Function | Meaning | EVML |
|---|---|---|---|
| Fold | `foldRange(n, target, template, accOffset, elemOffsets, init, exit)` | Fold a lambda over `0 .. n-1` | none, call from Solidity or an SDK |
| | `foldBytes(s, ...)` | Fold over the byte values of `s` | none (`@str.charset!` covers the common case) |
| | `foldWords(s, ...)` | Fold over the 32-byte words of `s` | `@reduce!`, `@all!`, `@any!`, `@includes!` |
| Word map and filter | `mapWords(s, target, template, elemOffsets)` | Transform every word with a lambda | `@map!` |
| | `filterWords(s, target, template, elemOffsets)` | Keep the words a lambda accepts | `@filter!`, `@find!` |
| | `reduceWords(s, target, template, elemOffsets, mode, cmp, bound)` | Apply a lambda to every word and reduce the results in the same loop | `@all!`, `@any!`, `@count!`, `@sum!` over `@map!` |
| Word shape | `iotaWords(n)` | The payload `0 .. n-1` | `@enumerate!` |
| | `wordIndexOf(s, w)` | Index of the first equal word, or the word count | `@lookup!`, `@includes!` |
| | `reverseWords(s)` | Reverse the word order | `@reverse!` |
| | `zipWords(a, b)` / `unzipWords(s, which)` | Interleave two payloads, or split one lane back out | `@zip!` / `@unzip!`, `@keys!`, `@values!` |
| | `sortWords(s)` | Sort ascending as unsigned words | `@sort!` |
| | `uniqueWords(s, ordered)` | Remove duplicate words | `@unique!` |
| | `sumWords(s)` | Checked sum of all words | `@sum!` |
| Value codec | `packArray(elementType, values)` | `bytes[]` of single values to one array encoding | used inside `@flat!` |
| | `unpackArray(elementType, encoded)` | One array encoding to a `bytes[]` of single values | used inside `@flat!` |
| Value map, filter, fold | `mapValues`, `filterValues`, `foldValues` | Callback map, filter, left fold | `@map!`, `@filter!`, `@reduce!` |
| Value order | `sortValues`, `uniqueValues`, `reverseValues` | Comparator sort, equality dedupe, reverse | `@sort!`, `@unique!`, `@reverse!` |
| Value shape | `flattenValues`, `sliceValues`, `zipValues`, `unzipValues` | Flatten one level, slice, pair, unpair | `@flat!`, `@slice!`, `@zip!`, `@unzip!` |
| Value search | `indexOfValues`, `anyValues`, `allValues`, `findValues` | Index of a match, exists, forall, first match | `@includes!`, `@any!`, `@all!`, `@find!` |

## Folds

The folds are the one loop primitive: apply a lambda over a bounded domain, threading a 32-byte accumulator. Three functions share one engine and differ only in what the element is.

```solidity
enum FoldExit { Full, Any, All }

function foldRange(uint256 n, address target, bytes template,
                   uint256 accOffset, uint256[] elemOffsets, bytes32 init, FoldExit exit)
    external view returns (bytes32);
function foldBytes(bytes s, address target, bytes template, ...) // same tail
function foldWords(bytes s, address target, bytes template, ...) // same tail
```

- **`foldRange`** iterates the index range `0 .. n-1`; the element is the index itself.
- **`foldBytes`** iterates the bytes of `s`; the element is the byte VALUE as a word.
- **`foldWords`** iterates the 32-byte words of `s`; the element is the word. Feed it a payload (elements without the ABI envelope), for example sliced out of a returned array. A length that is not a multiple of 32 reverts with `UnalignedWords`, because silently dropping a partial trailing word would give a wrong answer. The `nav` `PAYLOAD` sentinel accepts only `bytes` and `string`, not arrays.

In EVML the word folds are spelled by the array helpers. `@reduce!` folds with an accumulator, and `@all!`/`@any!` use the `All`/`Any` exit modes below:

```evml
load lang
set $vault 0x44fA8E6f47987339850636F88629646662444217
def @ge100! "$x: number -> bool" @bool!($x >= 100)
assert @all!($vault::!{caps()(uint256[])} @ge100!) == true "a cap is below 100"
assert @reduce!($vault::!{caps()(uint256[])} add 0) >= 100 "caps too small"
```

### Template lambdas

The lambda is a single `staticcall` per element, described by a *template*: complete, valid calldata for `target` in which 32-byte windows are rewritten on every iteration. The accumulator is written at `accOffset`, then the element at every offset in `elemOffsets`, in the supplied order. The element wins over the accumulator on overlap, later element windows win over earlier ones, and every byte outside the windows stays as in the template. The lambda must return exactly 32 bytes, which become the new accumulator. The final accumulator is the fold's result.

Any view or pure function that returns one word is a lambda; there is no closure format to learn. Window offsets are byte offsets into the template: after the 4-byte selector, argument words sit at 4, 36, 68, and so on. An empty `elemOffsets` writes only the accumulator. A lambda that ignores the accumulator (a pure predicate) can put both windows on the same offset, since the element wins.

Summing `0..4` with Operations' unsigned `add` as the lambda (`ADD_U` is its selector constant, see [Operations](/docs/contracts/operations)):

```solidity
/** Template add(0, 0): accumulator window at byte 4 (first argument), element at 36 (second). */
bytes memory template = abi.encodeWithSelector(ADD_U, uint256(0), uint256(0));
uint256[] memory elemOffsets = new uint256[](1);
elemOffsets[0] = 36;
collections.foldRange(5, address(operations), template, 4, elemOffsets, bytes32(0), Collections.FoldExit.Full);
// = 10
```

### Exit modes

`FoldExit` is ABI-encoded as `uint8`: `Full = 0` scans every element, `Any = 1` stops at the first nonzero accumulator (exists), `All = 2` stops at the first zero accumulator (forall). The final accumulator is returned either way, so `Any` folds judge a word compared against 1, and `All` folds start from `init = 1`. An out-of-range value is refused by the ABI decoder, which reverts without data.

Early exit also avoids failure: elements after the exit point are never touched, so a failing application past a satisfied `Any` never happens.

An empty domain validates the template (it must hold at least one word, and every window must fit) and returns `init`, without inspecting or calling the target.

### Recipes

**Character class.** "Every byte of the string is in the class" has a native operation, `charset(bytes s, uint256 mask)` on Operations ([bytes](/docs/contracts/operations#bytes)). The mask is a 256-bit set where bit `i` covers byte value `i`, built off-chain (`a-z` is bits 97..122). EVML's `@str.charset!` builds the mask from a class spec at composition time and compiles to that call, not to a fold.

```evml
load lang
set $vault 0x44fA8E6f47987339850636F88629646662444217
assert @str.charset!($vault::!{name()(string)} "a-z0-9-") == true "name outside the allowed characters"
```

```solidity
/** mask: bits 97..122 = a-z */
operations.charset(bytes(symbol), mask); // true iff every byte is a-z
```

The fold form is what `charset` collapses, and it stays the general pattern for any other per-byte predicate: `foldBytes` with a lambda over the byte value, the `All` exit and `init = 1`. With `bitSet(mask, elem)` as the lambda it reproduces `charset`. Both windows share the element offset, since `bitSet` ignores its accumulator:

```solidity
bytes memory template = abi.encodeWithSelector(Operations.bitSet.selector, mask, uint256(0));
uint256[] memory elemOffsets = new uint256[](1);
elemOffsets[0] = 36;
collections.foldBytes(bytes(symbol), address(operations), template, 36, elemOffsets, bytes32(uint256(1)), Collections.FoldExit.All);
```

The check is byte-level: multi-byte UTF-8 characters (every byte at or above 0x80) fail any ASCII-only mask, and the empty string is vacuously in every set.

**Includes and split segments** need no fold. They are `indexOf`/`byteLen`/`slice` compositions, documented on the [Operations bytes page](/docs/contracts/operations#bytes). Array membership is either an `Any`-exit `foldWords` with an `eq(item, elem)` lambda, or the `wordIndexOf` sentinel composition below.

## Word maps and filters

`mapWords` and `filterWords` take the same arguments as the folds without an accumulator: `s`, `target`, `template`, `elemOffsets`. The `template` windows at `elemOffsets` are rewritten per element in the supplied order, later windows winning on overlap.

```solidity
function mapWords   (bytes s, address target, bytes template, uint256[] elemOffsets) external view returns (bytes);
function filterWords(bytes s, address target, bytes template, uint256[] elemOffsets) external view returns (bytes);
```

**`mapWords`** returns the transformed payload, with the same word count as `s`. It is the bytes-producing map the scalar folds cannot express. The lambda must return exactly one word, the mapped element.

**`filterWords`** keeps the elements whose lambda application returns canonical ABI true, in order. The returned word must be exactly 0 or 1, otherwise `InvalidCallbackResult`. The output length is the kept count, so the result nests into `len`, the folds and the other word operations.

An empty payload validates the template (at least one word, windows in bounds), then returns empty without inspecting or calling the target. One call is made per word.

In EVML both take a named definition. `@find!` is a core `pick` of the first kept word, so no match leaves the pick out of bounds and the assertion reverts:

```evml
load lang
set $vault 0x44fA8E6f47987339850636F88629646662444217
def @dbl! "$x: number -> number" @calc!($x * 2)
def @ge100! "$x: number -> bool" @bool!($x >= 100)
assert @sum!(@map!($vault::!{caps()(uint256[])} @dbl!)) >= 200 "doubled caps too small"
assert @len!(@filter!($vault::!{caps()(uint256[])} @ge100!)) >= 1 "no cap at 100"
assert @find!($vault::!{caps()(uint256[])} @ge100!) >= 100 "no cap at 100"
```

## Reducing a lambda's results

`reduceWords` applies a lambda to every word, as `mapWords` does, and reduces the results as it goes. It answers "every holder has at least this balance", "some cap is above the limit", "how many accounts are funded" and "the total of what each element maps to" with one call per element, where a fold over a comparison would need a second call per element for the comparison.

```solidity
enum Reduce { All, Any, Count, Sum }
enum Cmp { EQ, NE, LT, LE, GT, GE, SLT, SLE, SGT, SGE }

function reduceWords(bytes s, address target, bytes template, uint256[] elemOffsets,
                     Reduce mode, Cmp cmp, bytes32 bound)
    external view returns (uint256);
```

Each result is compared with `bound` using `cmp`. The six plain comparisons read both words as unsigned; the four that start with `S` read both as signed `int256`.

- **`All`** returns 1 when every result passes and 0 otherwise. It stops at the first result that does not pass, so later elements are never applied. An empty payload returns 1.
- **`Any`** returns 1 when some result passes and 0 otherwise. It stops at the first result that passes. An empty payload returns 0.
- **`Count`** returns how many results pass. It applies every element.
- **`Sum`** returns the unsigned sum of the results and ignores `cmp` and `bound`. A sum past `2^256 - 1` reverts with `Panic(0x11)`.

The lambda follows the `mapWords` conventions: one call per word, exactly one word back. Results are compared as raw words, so a lambda that returns a narrower type is not range-checked. An empty payload validates the template windows, then returns without inspecting or calling the target. A `mode` or `cmp` outside its enum is refused by the ABI decoder, without revert data.

In EVML, `@all!`, `@any!` and `@count!` compile to `reduceWords` when the test compares one call over the element with a value. The value may be a call of its own: it is read once, not once per element.

```evml
load lang
set $vault 0x44fA8E6f47987339850636F88629646662444217
set $token 0x6B175474E89094C44Da98b954EedeAC495271d0F
def @funded! "$who: address -> bool" @bool!($token::!{balanceOf(address)(uint256) $who} >= 1000)
assert @all!($vault::!{holders()(address[])} @funded!) == true "a holder is underfunded"
assert @count!($vault::!{holders()(address[])} @funded!) >= 3 "fewer than three funded holders"
```

## Word-array operations

These operate on the same aligned payloads `foldWords` consumes. Every one validates alignment first (`UnalignedWords`) and returns a plain `bytes` payload, so they nest into each other, into the folds and into `read` splicing.

```solidity
function iotaWords   (uint256 n) external pure returns (bytes);
function wordIndexOf (bytes s, bytes32 w) external pure returns (uint256);
function reverseWords(bytes s) external pure returns (bytes);
function zipWords    (bytes a, bytes b) external pure returns (bytes);
function unzipWords  (bytes s, uint256 which) external pure returns (bytes);
function sortWords   (bytes s) external pure returns (bytes);
function uniqueWords (bytes s, bool ordered) external pure returns (bytes);
function sumWords    (bytes s) external pure returns (uint256);
```

- **`iotaWords(n)`** is the index generator: the payload `0, 1, ..., n-1`, paired with a payload by `zipWords(iotaWords(n), payload)`. EVML's `@enumerate!` compiles to that with a live `n`. Its cost is its output's: an absurd `n` runs out of gas, and past about 2^59 the allocation panics (0x41, or 0x11 once `n * 32` overflows). No bound is enforced.
- **`wordIndexOf(s, w)`** returns the index of the first word equal to `w`, with the word COUNT as the not-found sentinel. The sentinel composes: contains is `lt(wordIndexOf(s, w), div(byteLen(s), 32))`. A word read at the sentinel index reverts, which is how `@lookup!` turns a missing key into an assertion failure.
- **`reverseWords(s)`** reverses the word order.
- **`zipWords(a, b)`** interleaves two payloads as `a0, b0, a1, b1, ...`, for a fold or for `unzipWords` to split back. Different word counts revert with `WordCountMismatch`.
- **`unzipWords(s, which)`** returns every second word: lane 0 (words 0, 2, 4, ...) or lane 1 (words 1, 3, 5, ...). A lane past 1 reverts with `InvalidLane`. An odd word count leaves the extra word in lane 0.
- **`sortWords(s)`** sorts ascending as UNSIGNED words, with a stable bottom-up merge sort (O(n log n) comparisons and moves, O(n) scratch memory). Signed sorting is a three-node recipe instead of an overload: flip the sign bit (`mapWords` with `bitXor(2^255, elem)`), sort, flip back.
- **`uniqueWords(s, ordered)`** removes duplicate words, keeping the first occurrence of each in its original position. With `ordered = true`, equal words must already be grouped (as after `sortWords`), only adjacent words are compared and the cost is O(n). With `false`, every retained word is checked, O(n squared). The grouping is trusted, not validated: an ungrouped payload declared ordered keeps non-adjacent duplicates. Sorted deduplication is `uniqueWords(sortWords(s), true)`.
- **`sumWords(s)`** is the checked sum of the words. Overflow past 2^256 - 1 reverts with `Panic(0x11)`. It is the fixed-operation form of the `foldWords(add)` recipe: one on-chain loop instead of a call per element. Use `@reduce!` or `foldWords` for any other reduction (min, max, bitOr, bitAnd) or a nonzero initial accumulator.

The EVML helpers for the word family:

```evml
load lang
set $vault 0x44fA8E6f47987339850636F88629646662444217
assert @sum!($vault::!{caps()(uint256[])}) >= 100 "caps too small"
assert @unique!(@sort!($vault::!{getOwners()(address[])})) == 0x1122
assert @len!(@reverse!($vault::!{caps()(uint256[])})) >= 1
assert @len!(@zip!($vault::!{caps()(uint256[])} $vault::!{caps()(uint256[])})) >= 1
```

`@unique!` on word arrays removes non-adjacent duplicates as well and does not require sorted input. `@sum!` compiles to `sumWords`. The word-array form of `@sum!` handles arrays of single-word elements only, and an empty array sums to 0.

### On-chain records

A zipped key/value word-pair payload, the interleaved words `zipWords` and `iotaWords` produce, is also EVML's on-chain RECORD representation. String keys travel as their keccak digests.

| Helper | Compiles to | Description |
|---|---|---|
| `@enumerate!(call)` | `zipWords(iotaWords(n), payload)` | Pair every element with its index, with `n` the live length; the result is a record |
| `@zip!(a b)` / `@unzip!(record lane)` | `zipWords` / `unzipWords` | Interleave two word payloads into a record, or split a record back into a lane |
| `@keys!(record)` / `@values!(record)` | `unzipWords(record, 0)` / `unzipWords(record, 1)` | The key lane and the value lane of a record |
| `@lookup!(record name)` | `wordIndexOf` over the key lane, then a word read at that index of the value lane | The value stored under a key: literal string keys keccak-hash at composition time, live keys hash on-chain; a missing key REVERTS because the sentinel index lands past the value lane |

```evml
load lang
set $vault 0x44fA8E6f47987339850636F88629646662444217
assert @lookup!(@enumerate!($vault::!{caps()(uint256[])}) 2) >= 100 "cap 2 below 100"
```

## Values: envelopes and the codec

Each `bytes[]` element of the values family is one canonical `abi.encode(value)`: not packed bytes and not a raw array payload. A string includes its leading offset, length and padded data; a static struct includes all its words. Elements may be words, structs, strings, nested arrays, or tuples containing dynamic fields. The element type is a descriptor in the shared AbiCodec grammar, for example `(uint256,string)` or `string[2]`.

```solidity
function packArray  (string elementType, bytes[] values)  external pure returns (bytes);
function unpackArray(string elementType, bytes encoded)   external pure returns (bytes[]);
```

- **`packArray`** assembles the canonical `abi.encode(T[])` from canonical `abi.encode(T)` elements: the bridge from a values array back to a single array value. Every element is validated against `elementType`; a mismatch reverts with AbiCodec's `InvalidValue`. To check a single encoded value without keeping the result, pass it as the only element and discard the output.
- **`unpackArray`** reverses it: a canonical `abi.encode(T[])` (a `nav` terminal, a call return) becomes the elements the values family consumes, with dynamic element offsets rebased. The whole input is validated on the way, and a non-canonical encoding reverts with `InvalidValue` at the offending offset.

### What the codec checks

The codec checks descriptor structure, canonical offsets, bounds, exact lengths and zero padding of `bytes` and `string`. It also range-checks every static word for its type the way solc's decoder does: a `uint8` above 255, an address with dirty upper bits, an `intN` that is not sign-extended and a `bytesN` with dirty low bytes are refused with `InvalidValue`. The 256-bit types admit every word. What the codec cannot check is the type claim itself: a shape-compatible wrong descriptor (`uint256` where the value is really an address) reads the wrong value, as with `nav` descriptors. Predicate callbacks separately require canonical booleans.

## Values: callbacks

```solidity
struct Callback {
    address target;
    bytes4 selector;
    string arguments;    // the argument tuple descriptor, e.g. "(uint256,string)"
    bytes[] constants;   // one single-value envelope per argument slot, placeholders included
    uint256 first;       // the slot the element (or the fold accumulator) is bound to
    uint256 second;      // the slot the other value is bound to, binary operations only
    bytes expression;    // empty: a direct call; else abi.encode(Expressions.Expression)
}
```

`arguments` describes the callback's argument tuple. `constants` holds one canonical single-value envelope per slot, including placeholders for the slots that get substituted. Each application binds:

- `first` to the current element for map, filter, any, all and find; to the accumulator for fold; to the first value for comparison; to a retained value for unique; to the element for indexOf.
- `second` (binary operations only: fold, sort, unique, indexOf) to the element for fold, the second value for comparison, the candidate for unique, and the needle for indexOf.

The two slots of a binary callback must differ. Unary operations ignore `second`. Calldata is rebuilt from these values on every application, so variable-length strings and accumulators are safe. The non-substituted constants are validated against their declared types once per operation, substituted placeholders may be empty, and substituted values are validated when bound (skipped when the slot is declared with exactly the type the value was already validated as).

Calls use `staticcall`. Map and fold retain the complete return encoding and validate its declared type. A callback that returns several values should return one tuple or struct value when its result type is dynamic.

**Expression callbacks.** With a non-empty `expression`, the callback is `abi.encode(Expressions.Expression)`, `target` is an [Expressions](/docs/contracts/expressions) deployment, and `selector` is ignored. The slots are bound exactly as above and the application is `target.evaluateEncoded(expression, boundArguments)`. Inside the graph, `Parameter` nodes read the bound slots, so an element can be referenced any number of times, arguments may be dynamic and multi-word, and live reads compose without byte-offset substitution. Memoisation inside the graph lasts one application, not the whole traversal. Collections reaches Expressions through a locally declared interface at the address the callback names, not through a source import, so the two contracts version independently (a test pins the selector). Results are validated like a direct callback's: mapped values against `outputType`, predicate results as a canonical 0/1 word.

In EVML a callback is a named `def` that may compose helpers and ABI calls over typed values, including multiword ones:

```evml
load lang
set $vault 0x44fA8E6f47987339850636F88629646662444217
def @ge100! "$x: number -> bool" @bool!($x >= 100)
assert @any!($vault::!{caps()(uint256[])} @ge100!) == true "no cap at 100"
assert @len!(@unique!(["alice" "bob" "alice"])) == 2
```

## Value traversals

Every callback traversal obeys the same rules:

1. The `Callback` is checked once up front (`InvalidCallback`), and its constant slots are validated against their declared types.
2. Every visited input is validated as a canonical `inputType` (AbiCodec's `InvalidValue`).
3. The target's code is checked lazily before the first application (`InvalidCallbackTarget`), so an empty input never touches the target.
4. Each application is one `staticcall`. Exhaustion and exact `SubcallOutOfGas` signals propagate unchanged. Other reverts surface as `CallbackFailed` with the reason preserved. A result that is not a canonical `outputType` reverts with `InvalidCallbackResult`.
5. A predicate callback must return exactly one word holding a canonical 0 or 1, otherwise `InvalidCallbackResult`. This is stricter than the core's `cond`, which accepts any nonzero first word: a callback result is a declared bool, not a condition operand.

| Function | Behavior |
|---|---|
| `mapValues(inputType, outputType, values, cb)` | Map in input order; each result is validated as a canonical `outputType`. |
| `filterValues(inputType, values, cb)` | Stable filter, preserving the original encodings of the kept elements. |
| `foldValues(inputType, accumulatorType, values, initial, cb)` | Left fold: accumulator in `first`, element in `second`. The result of each application, validated as a canonical `accumulatorType`, becomes the next accumulator. `initial` is validated too. Empty input returns `initial`. There is no early exit: an arbitrary ABI accumulator has no implicit truth value, so every element is visited. |
| `sortValues(inputType, values, cb)` | Stable bottom-up merge sort, O(n log n) comparator calls. The comparator receives two elements in `first` and `second` and returns exactly one word read as a signed integer: at most zero keeps `first` ahead, positive puts `second` ahead. Any other return size reverts with `InvalidCallbackResult`. |
| `uniqueValues(inputType, values, cb, ordered)` | Keep each value unless the equality callback (a binary predicate: `first` a retained value, `second` the candidate) matches it to a retained one, preserving order. `ordered = true` compares only against the last retained value, O(n) calls; `false` against every retained value, O(n squared). Grouping is trusted, not validated. |
| `flattenValues(inputType, bytes[][] values)` | Flatten one level in order, validating every element. |
| `reverseValues(inputType, values)` | Reverse the order; each element is validated and otherwise untouched. |
| `sliceValues(inputType, values, int256 start, int256 end)` | JavaScript `Array.slice` semantics: signed indices, negative counting from the end, both clamped to the array bounds, `end` exclusive, empty when `end` does not exceed `start`. Never reverts on the range. Only the selected elements are validated. |
| `indexOfValues(inputType, values, needle, cb)` | Index of the first element for which the equality callback (`first` the element, `second` the needle) answers true, or `type(uint256).max`. Stops at the first match. The needle is validated as a canonical `inputType` too. |
| `anyValues(inputType, values, cb)` | Whether the unary predicate holds for at least one value; false on empty input; stops at the first true. |
| `allValues(inputType, values, cb)` | Whether it holds for every value; true on empty input; stops at the first false. |
| `findValues(inputType, values, cb)` | Index of the first value the predicate holds for, or `type(uint256).max`. |
| `zipValues(leftType, rightType, left, right)` | Pair equally sized arrays into canonical values of the tuple `(leftType, rightType)`. Different lengths revert with `LengthMismatch`. Every element is validated against its side's type. A pair with a dynamic side is a dynamic tuple and carries the 0x20 offset word; a static pair is its bare words. |
| `unzipValues(leftType, rightType, pairs, lane)` | Lane 0 (left) or 1 (right) of an array of canonical pairs. Other lanes revert with `InvalidLane`. Each pair is split against the tuple layout and BOTH sides are validated, so a malformed pair reverts with `InvalidValue` even when the requested lane is well-formed. |

`flattenValues`, `reverseValues`, `sliceValues`, `zipValues` and `unzipValues` call no callback and are `pure`; the others are `view`.

Comparators and equality predicates must be consistent. A comparator that is history-sensitive or inconsistent need not produce a globally sorted result, but a successful `sortValues` still returns every input occurrence exactly once. `uniqueValues` follows the callback's actual answers as a greedy scan, so first representatives of equality classes are guaranteed only for a consistent equivalence.

The values family has more validation overhead than the word family. The SDK uses the word family for eligible word-sized values and callbacks, and the values family for dynamic or multiword values and typed callbacks that need it. A word-template lambda reaches fixed-width windows in nested calldata, whereas typed callbacks rebuild complete argument slots when encoded sizes change.

```evml
load lang
set $vault 0x44fA8E6f47987339850636F88629646662444217
assert @len!(@slice!($vault::!{caps()(uint256[])} 0 -1)) >= 1
assert @len!(@flat!([[1 2] [3]])) == 3
assert @includes!($vault::!{caps()(uint256[])} 100) == true "100 is not a cap"
```

## Callback policy

- A target must contain EVM bytecode. A target without code, including a precompile, reverts with `InvalidCallbackTarget(target)`, because a `staticcall` there would succeed with empty returndata and surface as a silent wrong value.
- The target is checked only when a callback is needed, so empty inputs do not inspect it.
- Word lambdas must return exactly 32 bytes. Generic map and fold validate the complete declared ABI result. Predicates must return exactly one canonical boolean.
- An ordinary callback revert produces `CallbackFailed(operation, index, other, target, callData, reason)`: the selector of the Collections operation, the element index (`other` is the second element for binary callbacks, 0 otherwise), the callback contract, the calldata sent, and the raw revert data.
- Exhaustion, and an exact four-byte `SubcallOutOfGas()` signal from a nested call, propagate unchanged before any wrapping, so an outer probe cannot read exhaustion as a false result. The guard is conservative: an ordinary revert that leaves less than 1/63 of the gas available at the call can also be reported as `SubcallOutOfGas`. External callbacks that swallow failures or branch on gas are outside this guarantee. See [Assertions](/docs/contracts/assertions) for the core's guard.
- Early exits may avoid a later failing application.

## Failure modes and limits

| Error | Trigger |
|---|---|
| `LambdaOffsetOutOfBounds(offset, templateLength)` | A fold or word-map template shorter than one word, or an accumulator or element window that does not leave room for a 32-byte word. Checked before any call. |
| `UnalignedWords(length)` | A word payload that is not a whole number of 32-byte words. |
| `WordCountMismatch(aWords, bWords)` | `zipWords` with payloads of different word counts. |
| `LengthMismatch(left, right)` | `zipValues` with arrays of different lengths. |
| `InvalidLane(which)` | `unzipWords` or `unzipValues` with a lane other than 0 or 1. |
| `InvalidCallback()` | An inconsistent `Callback`: a slot index past the constants, a binary callback binding both elements to one slot, an argument descriptor that is well-formed but not a parenthesized tuple, or a constants count different from the descriptor's component count. |
| `InvalidCallbackTarget(target)` | A lambda or callback target without code. |
| `CallbackFailed(operation, index, other, target, callData, reason)` | A lambda or callback application reverted. |
| `SubcallOutOfGas()` | A failed application exhausted its gas, or propagated this signal. Shares the core's selector. |
| `InvalidCallbackResult(operation, index, other, target)` | A lambda result that is not one word, a predicate result that is not a canonical 0 or 1, or a callback result that is not a canonical value of its declared type. Declared in AbiCodec. |
| `InvalidValue(offset)` | A value that is not a canonical encoding of its declared type, at the offending offset. Declared in AbiCodec. |
| `InvalidTypeDescriptor(position)` | A malformed type or argument descriptor, at the offending byte. Declared in AbiCodec. |
| `Panic(0x11)` | `sumWords` overflow, or a `reduceWords` sum past `2^256 - 1`. |

The errors shared by every contract are on the [Errors](/docs/contracts/errors) page.

Limits:

- Gas is the loop bound. Every application pays real staticcall overhead, so domain sizes are limited by the block gas limit: fine for symbols, names and moderate arrays, wrong for megabyte scans. Prefer the `indexOf`/`byteLen` compositions where they express the same predicate, and let `Any`/`All` exit early.
- Unordered `uniqueWords` and `uniqueValues` perform quadratic comparisons in the worst case; sorts use O(n log n).
- `iotaWords` is unbounded by design (see above).
- Checked arithmetic, allocation limits and exhausted gas, stack or memory can still fail without a selector-bearing error.
- Silent truncation is always a bug here: `UnalignedWords`, `WordCountMismatch` and `LengthMismatch` exist so a partial word or a length mismatch reverts instead of producing a plausible answer.

## Why it lives here

Iteration needs a callback protocol, element validation on every visited value and a failure vocabulary that no scalar operation needs, and it only pays off when the loop runs inside one call instead of one core resolution per element. It therefore sits beside Operations and Expressions rather than on the core, which keeps only what needs operands to arrive unresolved. Collections versions by deploying at a new address like the other three.
