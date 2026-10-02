# Recursive static tuple traversal

This milestone connects the actual `checkWords` recursion and copy schedule to
an independent flattened sequence of word rules. It covers static names,
arbitrarily nested nonempty tuples and fixed arrays, arbitrary finite copy
counts and zero copies, under explicit arithmetic/data-span premises.

## Established properties

`Rules` recursively flattens a parsed descriptor. Names use the independently
SMT-checked 96-name whitelist; all other names map to the unrestricted `Opaque`
rule. Tuples concatenate their children's rules and fixed arrays repeat them.
`Scan` checks that sequence in byte order and returns the first invalid offset.
It is independent of `checkWords`' first-pass/repeated-copy control flow.

The source-derived `CheckWords` equals `Scan(Repeat(Rules(syntax),count),v,p)`.
On success its returned descriptor end and word footprint are exact. On failure
it returns the first invalid word's byte offset, preserving earlier-component
and earlier-copy precedence. `ParsedWords` calls the source-derived parser to
supply the syntax witness and proves success iff every selected word is
canonical. The theorem includes unrestricted leaf names and arbitrary bytes
outside the descriptor subspan through the prior classifier interface.

With **zero copies**, traversal still parses tuple components and suffixes but
reads no value words. The data origin may lie outside the allocation, and dirty
or empty data is accepted. Checked cursor arithmetic still executes: the theorem
requires `p + 32 * Width(syntax) < 2^256`, even for zero copies. This is a
conservative sufficient bound, not a characterization of every permissible
zero-copy origin. A direct helper call with `(bool,bool)`, zero copies and an
origin near uint256 maximum is separately tested to panic with code `0x11`.
That internal-helper test does not demonstrate a reachable public API bug.

For positive counts the entire selected value span must fit in the supplied
byte sequence. Dynamic descriptors are handled by the separate `body` walker
and are outside this static traversal theorem.

## Source connection and trust

`generate.py` compares the complete `checkWords`, `checkRule` and `suffixes`
solc AST against checked structural fingerprints. It translates the first-copy
count, first and subsequent copy cursors, loop start and final footprint from
the actual source. Small arithmetic proof methods establish those expressions;
the full recursive proof uses their contracts. Checked representability remains
a call-site obligation. `TupleOnce` factors the source's initial do/while pass;
recursive reverts are explicit outcomes, and the zero-count `checkRule` loop is
specialized with its memory-load body unreachable.

The prior word baseline's 107 SMT obligations bind the whitelist and word masks
to the source. This runner checks its source/evidence hashes and the exact
96-name mapping, and rechecks all included Dafny proofs. The translator, loop
factoring, memory/calldata projection, solc AST and Dafny/Boogie/Z3 are trusted.
Physical gas, stack and allocation limits and compiler correctness are not
proved. No axioms, assumed lemmas or termination escapes are introduced.

`Outcome.Invalid(offset)` models the default `ContextKind.Value` error.
Component and callback selector/context routing remain separate. This closes
recursive static traversal. The [connection successor](../connection/README.md)
now proves its equivalence to the independent static validator and obtains the
value-span bounds from `validateStatic` itself. The recursive dynamic-body
connection and arbitrary bytecode geometries remain open.

## EVM oracle and fault sensitivity

Ten tests exercise solc-encoded arrays of tuples and nested tuples, every word
in every repeated copy, first-error precedence, descriptor subspans, opaque
names, maximum uint32 footprints, zero-count grammar validation, dirty/empty
data at out-of-allocation origins and overflowing zero-count cursors. Expected
offsets use independent word indices or scanned sentinels.

Five isolated Solidity mutations turn zero copies into one, skip the second
tuple copy, corrupt either cursor stride, or replace the final footprint
product with addition. A mutation counts only when its named source-derived
arithmetic obligation fails semantically and the EVM test inventory contains
an observed failure. Timeouts and translation rejection remain incomplete.

```sh
python3 -B formal/abi/tuples/verify.py \
  --dafny /path/to/dafny/dafny --solc /path/to/solc-0.8.36 \
  --parser-evidence /tmp/abi-parser-baseline/manifest.json \
  --word-evidence formal/abi/evidence/abi-codec-words-complete/manifest.json \
  --output /tmp/abi-tuple-baseline

python3 -B formal/abi/tuples/mutations.py \
  --dafny /path/to/dafny/dafny --solc /path/to/solc-0.8.36 \
  --baseline /tmp/abi-tuple-baseline/manifest.json \
  --output /tmp/abi-tuple-mutations
```

Use new output directories. The manifests retain declaration/batch inventories,
hashes, exact commands, versions, bounds, assumptions, EVM test names/counts,
audit and formatting results. Counts include earlier milestones and overlap;
they must not be added to earlier baseline totals.

Verification is modular: each file is checked as an entrypoint, while every file
in the include graph is inventoried and checked exactly once. Included method
contracts therefore have their own checked bodies in the same baseline. This
avoids unrelated later modules changing older SMT trigger contexts; it does not
trust unchecked dependencies or remove assertions. Native per-module CSV/logs
and the combined inventory are retained under one 900-second outer budget.

## Retained baseline

The [current baseline](../evidence/tuple-traversal-complete/manifest.json) passes
**135 lemmas, 47 proof methods and 2,711 verification batches** across all 27
files in the proof dependency graph, with zero errors, timeouts or audit
findings. All ten EVM tests and the source-generation, whitelist mapping,
prior-evidence integrity, bitvector and formatting gates pass. Its production
source hash matches the existing ABI/Halmos release candidate; this milestone
changes proof/test/documentation files only.

The [mutation campaign](../evidence/tuple-traversal-mutations/mutations.json)
passes **5/5** with semantic proof failures and observed EVM failures for every
fault. All ten tests per mutant are accounted for; there are no timeouts or
source drift. Together with the parser's six mutations, eleven actual-source
faults are detected across the two new milestones.
