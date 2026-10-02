# Assertions runtime verification

The target is the entire current compiled `Assertions` runtime. Collections,
Operations and Expressions are excluded. AbiCodec and ERC8211 code compiled into
Assertions is in scope. External contracts are modeled through truthful,
context-sensitive observations; their implementations are not verification targets.

Whole-contract completion remains open. Source correspondence, compilation,
runtime hashes and concrete tests do not close bytecode semantics.

## Completion requirements

- Reproduce every runtime byte, including metadata, from the current canonical
  Hardhat compiler inputs with pinned solc 0.8.36.
- Cover every ABI entry, including both overloads of each judge and the constant
  getters. Bind each certificate to the current runtime and independent expected
  behavior, with no candidate-generated semantic oracle.
- Execute the real dispatcher, raw ABI decoders, body instructions, shared
  helpers, physical memory operations, exact return/error serializers and
  rejection paths. Prove loops by invariants and termination arguments rather
  than omitting paths beyond a symbolic execution bound.
- Connect resolver and constraint behavior, batch ordering, lazy guards, raw
  operand trees, call construction and ABI navigation to their independent
  specifications. Inlined codec behavior is part of this runtime obligation.
- State resource and external-world premises explicitly. Model gas-sensitive
  guards with matching observations; do not infer gas properties from a tool
  without a gas model. Account for recursive self-calls rather than assuming
  their successful returns.
- Retain complete native declaration results, zero audits, source/runtime/tool
  hashes, exact commands, concrete EVM checks and semantic mutation results.
  Missing, failed and inconclusive checks never count as passed.

## Current proof packages

`dispatch` proves routing and admission only; reaching a named wrapper does not
prove its body. `getters` covers complete successful LEN/PAYLOAD executions and
physical return bytes. `rejections` covers full physical short/nonpayable
rejection, and the Assertions-only `unknown/verify-assertions.py` covers full
physical unknown-selector rejection. Their retained manifests must all pass;
these rejection packages add no accepted-body coverage.

The other fifteen ABI entries still require complete runtime connections.
`assertions-resolution` develops resolver/constraint/judge paths,
`assertions-primitives` develops selection and primitive paths, and
`assertions-navigation` develops navigation and inlined codec paths. Individual
helper certificates are not whole public entries. `assertions-machine/verify.py`
retains fresh native evidence for the complete arithmetic/copy/external
instruction-model closure, but adds no public-entry coverage.

Assertions-only reproduction and runners:

```sh
python3 -B formal/bytecode/dispatch/identity.py \
  --contract Assertions --solc /path/to/solc-0.8.36 --output /tmp/assertions-identity
python3 -B formal/bytecode/dispatch/generate.py \
  --contract Assertions --solc /path/to/solc-0.8.36 --output formal/bytecode/dispatch
python3 -B formal/bytecode/getters/generate.py --output formal/bytecode/getters
python3 -B formal/bytecode/dispatch/verify.py --contract Assertions \
  --dafny /path/to/dafny --solc /path/to/solc-0.8.36 --output /tmp/assertions-dispatch
python3 -B formal/bytecode/getters/verify.py \
  --dafny /path/to/dafny --solc /path/to/solc-0.8.36 --output /tmp/assertions-getters
python3 -B formal/bytecode/rejections/generate.py \
  --contract Assertions --output formal/bytecode/rejections
python3 -B formal/bytecode/rejections/verify.py --contract Assertions \
  --getter-manifest /path/in/repository/to/passed/getter/manifest.json \
  --dafny /path/to/dafny --solc /path/to/solc-0.8.36 --output /tmp/assertions-rejections
DAFNY=/path/to/dafny python3 -B formal/bytecode/unknown/generate.py \
  --contract Assertions --output formal/bytecode/unknown
DAFNY=/path/to/dafny python3 -B formal/bytecode/unknown/generate-terminal.py \
  --contract Assertions --output formal/bytecode/unknown
python3 -B formal/bytecode/unknown/verify-assertions.py \
  --dafny /path/to/dafny --solc /path/to/solc-0.8.36 --output /tmp/assertions-unknown
python3 -B formal/bytecode/assertions-machine/verify.py \
  --dafny /path/to/dafny --cores 2 --output /tmp/assertions-machine
```

Each output directory must be new. The pinned Dafny distribution and solver are
specified in `formal/abi/toolchain.json`. Build the canonical artifacts and
restore locked Node dependencies before generation. Inspect each retained
manifest and all its required checks before reporting a package as passed.

Navigation development evidence (not retained completion packages):

- `assertions-navigation/development/passthrough-v2/proof.csv` records 626 native
  obligations for the complete 17-instruction post-resolver empty-path `nav`
  continuation, PC 1081 through physical RETURN. Its premises admit arbitrary
  fitting physical result buffers; it does not prove ABI decoding or `_resolve`.
- `assertions-navigation/development/frame-v1.csv` records 40 native obligations
  for lifting ordinary navigation instruction traces into the shared external
  frame model without changing the old returndata or observation cursor.
- `assertions-navigation/development/full-dest-v6/Positive.csv` records 1571
  native obligations for the complete positive `_normalizeIndex` success path
  using the full scanned runtime jump-destination set. Other paths are being
  rerun with the same model; earlier failed and timed-out runs are retained.
- The passthrough, index, and word EDR fixtures exercise complete physical public
  calls but finite receipts alone establish no universal public-body coverage.

These development results must still undergo fresh include-closure verification,
input snapshots, bytecode reproduction, audit, formatting, semantic mutation
checks, and complete caller composition before any additional ABI entry counts.

- `assertions-navigation/development/passthrough-v3/proof.csv` extends the
  passthrough continuation to the shared external frame and proves the complete
  lifted trace; 767 native obligations passed. The prior returndata and cursor
  remain unchanged.
- `assertions-navigation/development/setup-v1/proof.csv` records 998 native
  obligations for the 20-instruction nav setup, PC 1054 to resolver entry 3393.
  It establishes the exact prepared-memory image and child call stack.
- `assertions-navigation/development/passthrough-mutation-v1/native.csv` records
  the expected physical terminal-property failure for RETURN changed to REVERT
  at PC 1100 (23 other obligations passed, one proof failure, no timeout).
  Its full public EVM receipt also rejects this mutant. These are development
  checks, not a completed retained package or whole-entry verification.

- `assertions-navigation/development/decoder-v7/full.csv` records 8,825 native
  checks for all 229 instructions of the successful structural ABI decoder,
  PC 344 to PC 1054, for arbitrary admitted calldata.
- `assertions-navigation/development/decoded-raw-body-v5.csv` records 225 passed
  checks composing that decoder with setup, RAW resolution with no constraints,
  and the empty-path physical return. This covers one operand/path class and
  retains explicit helper admission preconditions; it does not cover all nav.
- `assertions-navigation/development/dispatch-v1/frame.csv` records 17 passed
  checks lifting the physical nav dispatcher route into the external frame.
- `assertions-navigation/verify-native.py` snapshots and remaps a complete Dafny
  include closure, checks every declaration, audits it, and pins input/tool
  hashes. Its native-only manifest deliberately has no runtime reproduction,
  semantic mutation, or public-entry completion claim.

- `assertions-navigation/evidence/decoder-native-v2/manifest.json` passed its
  immutable native include closure: 9,703 checks, ten zero-finding audits,
  format checks, and unchanged source/tool hashes. Its scope remains native
  decoder verification, without public-entry completion or mutation gates.
- `assertions-navigation/development/decoder-v7/frame.csv` passed 2,174
  checks lifting the full decoder trace into the external frame.
- `assertions-navigation/development/dispatch-v5/proof.csv` passed 1,111
  checks for the physical nav selector route, PC 0 through PC 344.
- `assertions-navigation/development/raw-case-admission-v4.csv` passed 248
  checks deriving setup and resolver admission from an independent calldata
  predicate. The public admitted method passed 82 development checks; its
  full, current dependency closure and all required completion gates remain open.

- `assertions-navigation/evidence/calldata-byte-native-v1/manifest.json` passed
  874 native checks over its immutable include closure, nine zero-finding audits,
  formatting, and unchanged source/tool hashes. It proves the universal calldata
  high-byte AND projection, including the padded word tail. This is a native
  foundation, without a runtime mutation or whole public-entry claim.
- `assertions-navigation/development/suffix-init-v1/proof-v2.csv` passed
  624 development checks for all 26 physical `suffixStart` initialization
  instructions, arbitrary representable `te >= 2`, and an unchanged physical
  memory frame. The arbitrary-length digit loop, exit, and caller admission
  are still open; finite EDR descriptor traces do not substitute for them.
- `assertions-navigation/development/suffix-init-v1/trace-v2.csv` passed
  840 development checks after adding the complete initialization trace and
  external-frame local-step preservation. The older immutable native snapshot
  remains historical evidence for its original instruction-only source; a
  fresh native v2 snapshot is running for the extended trace certificate.
- `assertions-navigation/evidence/suffix-init-native-v2/manifest.json`
  passed 2,085 native checks for the extended initialization trace, zero-finding
  audits, format checks, and unchanged source/tool hashes.
- `assertions-navigation/evidence/byte-read-native-v1/manifest.json` passed
  967 native checks, zero-finding audits, formatting, and unchanged source/tool
  hashes. It proves physical calldata-word SHR248/SHL248 byte projection for
  every fitting byte position. Digit-loop and exit instruction refinements
  are running separately and remain incomplete.
- `assertions-navigation/development/suffix-digit-v5/proof-v1.csv` passed
  2,805 development checks covering all 100 physical digit-iteration
  instructions for arbitrary admitted descriptor bytes and index. Its
  constants proof passed 35 checks; the complete immutable include closure
  is running. Full suffix-loop composition and caller admission remain open.
- `assertions-navigation/development/public-raw-gates-v1/development-manifest.json`
  records reproduced exact Assertions runtime identity, six independently
  admitted public RAW nav witnesses following the same 567 instructions, and
  a RETURN1100-to-REVERT native failure (23 passed checks, one intended
  postcondition failure) plus an actual EVM receipt failure. These development
  gates do not replace the still-running arbitrary-input public native closure
  or constitute whole-nav completion.
- `assertions-navigation/development/suffix-digit-v6/run-v1.csv` passed
  86 development checks composing the 100 instructions into an actual scan
  trace with preserved local external-frame eligibility. Its generic dispatch
  lemma and full extended include closure are still pending; this is not yet
  an accepted complete loop certificate.
- `assertions-navigation/evidence/suffix-digit-native-v1/manifest.json`
  passed 4,589 checks over its immutable native include
  closure, audits, format checks, and unchanged source/tool hashes. This
  certifies the physical one-digit iteration only, with admitted byte/index
  premises; the arbitrary-count descriptor loop and caller are still open.
- `assertions-navigation/development/suffix-exit-v5/proof-v1.csv` passed
  3,146 development checks for all 116 physical successful exit instructions
  and its actual return continuation. Its immutable full dependency closure
  and trace-composition proof are now running.
- `assertions-navigation/development/suffix-loop-v1.csv` passed 183
  development checks composing physical initialization, arbitrary many digit
  iterations, and the actual successful return. Its admitted domain is an
  independent valid bracketed descriptor suffix and fitting calldata; a
  decreasing index proves termination without a fixture length limit. The full
  immutable include closure is running. Caller grammar/error classes and whole
  nav/get entry completion remain open.
- `assertions-navigation/evidence/suffix-digit-trace-native-v1/manifest.json`
  passed 5,093 checks with the complete 100-instruction trace constructor,
  audits, formatting, and unchanged source/tool hashes.
- `assertions-navigation/evidence/suffix-exit-native-v1/manifest.json` passed
  4,930 checks for all 116 successful exit instructions, audits, formatting,
  and unchanged source/tool hashes. Both remain helper certificates.
- `assertions-navigation/development/suffix-connection-v1.csv` passed 38
  checks lifting the arbitrary-length scanner into the full external machine
  frame while preserving returndata and observation cursor. Its combined full
  include closure has not yet been retained.
- `assertions-navigation/evidence/suffix-loop-native-v1/manifest.json`
  passed 10,205 checks for the full arbitrary-length successful physical suffix
  scanner, with zero-finding audits, format checks, and unchanged source/tool
  hashes. The domain is the explicit independent valid suffix and fitting
  calldata premises. Full external-frame binding is being retained separately;
  invalid descriptor cases and whole public-entry callers remain open.
- `assertions-navigation/evidence/suffix-frame-native-v1/manifest.json`
  passed the complete external-frame include closure for the arbitrary-length
  successful scanner. Three complete public suffix receipts corroborate the
  path. The physical LT8288-to-GT mutant produces one genuine native semantic
  failure (21 passed checks, no timeout) and an actual public EVM error.
- `assertions-navigation/evidence/public-raw-native-v3/proof.log` retained
  33,558 successful checks and two trace-join timeouts; it is not accepted.
  An isolated associativity/boundary Stitch repair passed 176 development
  checks without changing Execute premises or return behavior. Fresh complete
  public RAW native closure v4 is running against that repaired snapshot.

Navigation descriptor-scanner development (2026-10-02):
`assertions-navigation/evidence/byte-opcode-native-v1` retains a full five-file
native include closure with 574 passing obligations and zero proof errors. It
proves the universal `BYTE(0, CALLDATALOAD(offset))` projection, including zero
padding beyond calldata, through an independently proved encode/decode inverse.
Its manifest includes source/tool hashes and zero-assumption audits; it is a
native helper package, without runtime reproduction or mutation binding and
without a whole-public-entry claim. Independent lowercase-letter/decimal-digit
name-prefix semantics passed 51 development obligations, and lifting ordinary
scanner instructions plus BYTE to the full external frame passed 17. Physical
36-instruction arbitrary-character iteration is still in development; its first
run retained eight PUSH-decoding assertion failures (853 passes), and the second
run moves the constructive PUSH decoding lemmas before those assertions. These
helper results do not change the accepted 2/17 whole-entry count.
The scanner frame bridge subsequently completed its immutable full native
closure (`name-frame-native-v1`: 1,262 obligations, all manifest gates passed).
The physical character iteration v2 passed 861 development checks. Its first
retained closure passed 2,212 native obligations but failed the source-drift gate
because the independent name specification was extended during that run; that
package remains explicitly failed. The v3 generic dispatcher passed 832 checks,
its exact 36-step trace loop passed 79, and the BYTE-overlay trace-composition
lemmas passed 84. The extended independent name specification, including maximal
prefix uniqueness, passed 65. A fresh retained v3 closure is running at
`name-character-native-v2`; neither its outcome nor whole scanner completion is
assumed here.

Descriptor-name scanner progress (2026-10-02): `name-character-native-v2`
passed all 2,542 native obligations with full include-closure audits and source
hashes rechecked against the current tree. Exact scanner initialization passed
40 development checks; non-name-byte exit passed 1,304, limit exit passed 435,
arbitrary-length scanner composition passed 204, and its full external-frame
connection passed 37. The scanner specification permits empty names and all
lowercase-letter/digit names, including nonstandard names; typeShape caller
rejections and interpretation remain separate. `name-scanner-native-v1` is the
fresh full native closure currently running and is not yet accepted.

Ten complete public nav receipts (ordinary and nonstandard names, a 257-byte
name, uppercase, punctuation, and empty names) returned the exact expected
result or InvalidTypeDescriptor payload. `check-name-fixtures.py` independently
checked all 23 actual scanner invocations: fitting calldata admissions, maximal
name endpoints, every physical PC, full terminal stack, and memory preservation.
GT→LT at PC12553 produced a genuine native postcondition failure (20 passes,
one error, no timeout) and a wrong complete public receipt for `(a)`. These are
retained development gates in `development/name-gates-v1`; they do not claim
whole descriptor-parser or public-nav verification.
The complete arbitrary-length name-scanner native package subsequently passed:
`name-scanner-native-v1` retains 4,562 passing obligations, all full-closure
audits/format gates, and exact current source hashes. It covers PC12520 through
actual return for every admitted fitting calldata span, lowercase-letter/digit
prefix length (including zero), and both scanner exits, preserving the full
external frame's memory, returndata, and observation cursor. There is no fixed
iteration bound. This remains a native helper package; the development public
receipts and mutant are separate evidence, and full descriptor parsing and
public-nav completion remain open. Whole-entry coverage is unchanged at 2/17.

Base descriptor-name classification (2026-10-02): `name-class-native-v1`
retains 730 passing native obligations, all nine audit/format/hash gates, and
exact live source hashes. Decode injectivity proves that only the exact lexical
names `bytes` and `string` are dynamic; other admitted names remain static.
Four additional complete public receipts cover those two dynamic names and
same-length unknown static names, with ten exact admitted scanner segments.
`NameWord.dfy` separately develops the actual five/six-byte CALLDATALOAD+SHR
projection: constructive 40/216- and 48/208-bit packing facts and arbitrary
word prefix splitting. Failed/time-out development runs remain retained; the
repaired two projection bridges passed 54 checks after intermediate bitvectors
were made explicit and packing definitions hidden. Its fresh full native
closure is running at `name-word-native-v1`. These are helper proofs, not a
whole typeShape or public-nav completion claim.

The name word-read helper's first retained closure failed with two timeouts in
constant-shift normalization. The nine-bit shift-amount conversion is now proved
explicitly; all 59 cold packing/shift checks passed. The fresh
`name-word-native-v2` full include closure passed 1,289 obligations with all 14
audit/format/hash gates, and exact live source hashes were rechecked.
`TypeConstants.Not39` constructively proves the compiler's '(' comparison
constant and passed 23 development checks. The exact 37-instruction non-tuple
valid-name parser prefix PC8442→scanName PC12520 passed 1,227 development checks,
including its actual bounds guards, modular ASCII comparison and complete
physical trace. It admits arbitrary fitting descriptor offsets/lengths/limits
and nonempty scanner names, rather than a fixed name fixture. Its new retained
full include closure is running at `base-prefix-native-v1`; full typeShape
classification/suffix handling and invalid descriptor classes remain open.
The non-tuple valid-name parser prefix is now composed with the unbounded name
scanner in `BaseName.dfy`: actual typeShape PC8442→caller continuation PC8760,
independent maximal name endpoint, and full external-frame preservation. This
composition passed 95 development checks. It includes actual physical bounds
checks and ASCII '(' branch selection for arbitrary fitting nonempty names;
base classification and array suffix parsing still follow this continuation and
are not claimed complete by this result.

The parser-entry/name-scan retained package `base-name-native-v1` passed 6,312
native obligations with all 36 audit/format/hash gates and exact live hashes.
The base-name classification body passed 2,307 development checks for five-byte
names, 2,532 for six-byte names, and 1,722 for other arbitrary positive lengths.
Both no-array-suffix returns passed: 941 checks for a following non-'[' byte,
and 678 when the name reaches the descriptor limit. Exact PUSH5/PUSH6 literal
decoding passed 34. `BasePlain.dfy` composes actual typeShape PC8442 through
actual return for arbitrary admitted nonempty names without array suffixes,
with independent maximal endpoint, exact bytes/string dynamic classification,
and full external-frame preservation; this complete admitted helper class passed
183 development checks. Tuple/array constructors and descriptor error classes
remain open.

Public RAW-navigation's v4 monolithic run finished with 33,625 passing checks,
zero proof errors and two timeouts in unchanged RAW Advance196/Advance224;
all repaired root joins passed. The package is failed and retained. A fresh
`navigation-modular-v1` union run verifies every file's own declarations in its
exact minimal dependency context, covering both PublicRawCase and BasePlain,
with immutable hashes, all native CSVs and audits. Its outcome is pending.
Imported contracts require passing native proofs of every dependency file;
no new source assumptions, axioms or narrower semantic postconditions are used.
This change of proof organization does not count either input class or any
whole entry as accepted before all native and binding gates pass.

The complete navigation union native closure is now accepted at
`assertions-navigation/evidence/navigation-complete-native-v1`: all 69 files,
5,004 native checks, every own declaration and dependency audited. The original
`navigation-modular-v1` remains failed (six normal-context timeout files); exact
frozen isolated retries passed all six and a separate acceptance runner rechecks
evidence hashes, source/tool identity, native CSV coverage and include closure.
No failed package was relabeled or source specification weakened.

`public-raw-class-v1` now passes native-closure, fresh canonical solc/runtime
reproduction, every reached Matches byte/immediate and PUSH-aware legal jump
destination binding, six independently admitted complete 567-instruction public
receipts, pinned concrete tools, and fresh native/EDR RETURN-to-REVERT mutation
gates. It accepts the symbolic RAW/no-constraints/empty-path nav calldata class
only; other nav cases and whole entry remain open.

`base-plain-class-v1` binds all nine reached physical leaf Matches predicates
of the 46-file BasePlain closure to that reproduced runtime. Fourteen public
fixtures contain 23 independently admitted complete helper executions with
maximal scanner endpoint, exact bytes/string dynamic classification, one-word
footprint, full stack/memory preservation, and exact composed PC sequences. The
retained GT-to-LT native and public scanner mutation is exact-source checked.
Tuple, array and descriptor error classes remain open. Full ABI entries remain
2/17 (the two getters); input-class/helper acceptance does not change that count.

Array suffix parsing now has two fully bound admitted helper packages:
`array-fixed-class-v1` (38-file native closure, 1,552 checks) and
`array-suffix-class-v1` (40-file native closure, 1,950 checks). The latter
covers successful empty [], static [k], and fixed arrays of dynamic elements,
including arbitrary-length leading-zero numerals. Ten complete public receipts
contain 20 independently admitted full physical suffix executions; the
radix-immediate 10-to-9 mutation fails an unchanged native step postcondition
and the complete public uint256[12] receipt. Exact runtime Matches bytes,
compiler/runtime certificate, captured concrete tool hashes and source identity
are bound. No whole descriptor or entry completion claim follows from these.

The independent recursive `ArrayChainSpec` declarative grammar and footprint
passed seven development checks, including uniqueness of suffix boundaries.
`ArrayChain` passed two checks for arbitrarily many suffixes. General final
returns passed 69/51 checks; `BaseHead` passed two. `BaseArrays` now composes
actual typeShape PC8442 through actual return, with arbitrary nonempty base
names, arbitrarily many successful array suffixes, exact bytes/string
classification and uint32 head footprint, full external-frame preservation, and
an independent grammar/result specification. Its three development checks
passed. The complete retained `base-arrays-native-v1` closure is running;
accepted status awaits complete native coverage and matching physical binding.
Tuple constructors and descriptor rejection classes remain open.

The retained successful non-tuple parser package is now accepted:
`base-arrays-native-v1` passed all 61 files and 3,016 native checks;
`base-arrays-class-v2` passed runtime byte/immediate guard coverage for every
reached instruction, independent complete physical PC/stack/memory matching for
45 full helper executions from 24 complete public receipts, pinned tool/source
identity and native/full-public-call decimal radix mutation gates. The earlier
class-v1 binder rejected missing nonopaque NameInit guard coverage before
acceptance and remains failed, with its original binder archived. The explicit
NameInit and aggregate guards are included in v2. The same additional guard
binding strengthens plain-name retention at `base-plain-class-v2`; original
proof sources and native certificates are unchanged.

Successful non-tuple names plus arbitrary array suffix chains are now physically
closed under the declared fitting input/uint32 footprint/resource premises.
Tuple parsing and all unaccepted descriptor rejection paths remain open;
this is a helper class, not whole nav/get or Assertions verification. Work
has begun on the actual 65-instruction tuple initialization/recursive-call
prefix. Full ABI-entry progress remains 2/17.

Tuple parsing development now has complete native closure evidence for tuple initialization, recursive child-call setup, and static-child comma continuation: `assertions-navigation/evidence/tuple-boundaries-complete-native-v1` selects 29 files / 968 native checks. The original matrix failed the cold `BytecodeCopyMemory.MemoryCopiedWord` obligation; its frozen isolated retry passed and is retained separately, with hashes and declaration coverage rechecked by `accept-modular.py`. Five fresh public tuple receipts cover multiple fields, nested tuples, dynamic fields, and tuple arrays. `check-tuple-boundary-fixtures.py` independently checks admitted physical PC sequences, exact boundary stacks and unchanged complete memory. These are boundary/helper results, not a complete tuple parser, nav ABI entry, or public mutation-bound class. Static-child tuple closing passed 221 development checks; its complete dependency closure is pending. The earlier failed closing runs remain in their distinct development logs; the generator now models the comma comparison using uint256 modular subtraction, including the closing-parenthesis branch.

Static-child tuple closing complete dependency verification is now accepted at `assertions-navigation/evidence/tuple-close-native-v1`: 28 files / 740 native checks, with audits and source/tool identity gates passed. This models arbitrary admitted aggregate footprint below uint256 overflow, including footprints larger than uint32; whole parser composition and runtime mutation binding remain outstanding.

Dynamic-child tuple closing passed 225 development checks and now has complete native dependency coverage at `assertions-navigation/evidence/tuple-dynamic-close-complete-native-v1`. The original matrix's cold MemoryCopiedWord failure and exact frozen isolated retry are separately retained. `check-tuple-boundary-fixtures-v3.py` checks all five direct generated runtime guards, every reached opcode/immediate byte, and exact full stacks/memory for 51 admitted boundary executions across five public receipts (11 prefixes, 20 child-call setups, 9 static-child commas, 5 static-child closes, 6 dynamic-child closes). This remains helper evidence: arbitrary recursive tuple composition, the other field-merge branches, public admission and mutation binding are still open.

All five successful field-merge/close combinations are now composed by `assertions-navigation/TupleField.dfy`, including dynamic-child comma continuation and static-child closing an already-dynamic tuple. Complete native closure `assertions-navigation/evidence/tuple-field-native-v1` passed 33 files / 1543 checks with audits, exact source/tool identity, and full own-declaration coverage. Independent checker v4 covers all seven physical boundary classes in seven public receipts (61 admitted executions), including opcode/immediate guard coverage and exact full stack/memory. `TupleSpec.dfy` independently specifies aggregate footprint as the static-field sum or one word for any dynamic field; its 12 development checks passed. Arbitrary recursive parser composition and whole-entry coverage remain open.

## Consolidated OR structural helper acceptance (2026-10-02)

The exact nonempty in-memory OR structural scan is accepted at its explicit
supplied-child-table and resource premises. Candidate receipt:
`assertions-resolution/constraints/or/evidence/structure-bound-consolidated-v1/manifest.json`.
Independent coordinator review:
`proof-workspace/work/coordinator-reviews-20261002/or-review-v2.json` (repository-relative).
The commands recorded in that review and candidate retain 828 native checks
across the complete 25-file scan closure, plus 84 checks across the seven-file
branch-witness closure. The coordinator rechecked all own declaration inventories,
passed module logs/CSVs, zero-finding audits, current include-source and tool
hashes, and retained evidence hashes. Independent full stack/memory replay reran
539 instructions across 19 segment executions. The same SUB-at-7889 to ADD fault
fails the native branch postcondition and makes the actual EVM accept a nested
OR after a true leaf. Canonical current Assertions runtime, including metadata,
was freshly reproduced with the active compiler.

This helper proves scanning before verdict evaluation: either every child is
non-OR at PC 7943, or the first nested child raises the exact InvalidOrConstraint
error. Its decoded child table is supplied, not constructively decoded here.
Nonempty decoder, verdict composition, public admission, and whole-entry
acceptance remain open. Assertions whole-entry credit remains **2/17**.

## Current tuple-loop native closure (2026-10-02)

`TupleLoop.dfy` now derives the machine-word cursor, child-word and prefix-sum
bounds from the original geometric tuple admission using `GeometryBounds`.
This preserves static tuple widths above uint32; it does not impose the fixed
array suffix cap on a bare tuple. The fresh current 37-file native closure
`assertions-navigation/evidence/tuple-loop-native-consolidated-v1` passed
19,150 obligations, 779 inventoried declarations and 40 proof/audit/format gates.
Independent coordinator receipt recheck:
`proof-workspace/work/coordinator-reviews-20261002/tuple-loop-native-review.json`.

`DescriptorSpec.dfy` defines an independent recursive name/tuple/fixed-array/
dynamic-array grammar and footprint. `DescriptorEncoding.dfy` constructs its
text, proves nonempty encoding and byte bounds. The latter's included-spec
native development run passed 160 checks with zero errors at
`assertions-navigation/development/descriptor-encoding-v1`; this is semantic
construction evidence, not a physical parsing certificate. Current-tool seven
public tuple examples and 61 independent boundary executions passed at
`assertions-navigation/development/tuple-shape-consolidated-v1`.

The tuple-loop theorem still consumes supplied verified child traces. Producing
those traces constructively from the encoded recursive grammar, recursive suffix
composition, whole-entry composition, and complete matching fault/replay gates
remain open. These results add no whole public-entry credit.

## Constructive tuple geometry and wide dynamic suffix (2026-10-02)

`TupleGrammar.dfy` constructs child endpoints, dynamic flags and word counts from
independently encoded types, and proves tuple delimiter positions and aggregate
semantics. `TupleGrammarInput.dfy` discharges `TupleLoop.Geometry` and `Admitted`
from that concrete encoded descriptor, without an independent byte-bound premise.
Complete current minimal-context closure
`assertions-navigation/evidence/tuple-grammar-native-consolidated-v1` passed
41 files / 1919 native checks / 802 inventoried declarations with audits and
unchanged source/tool identities. Whole-union isolated counts and modular native
counts are different measures; these are the latter's recorded CSV counts.

`ArrayEmptyWide.dfy` and its three private physical kernels retain arbitrary
positive incoming Word footprints. The exact empty suffix resets the footprint
to one before the uint32 result guard. Existing narrow kernels were not changed.
Current complete closure
`assertions-navigation/evidence/array-empty-wide-native-consolidated-v3` passed
35 files / 1256 checks / 573 declarations. Earlier wrapper failure was a missing
9147 destination premise and is retained in v2; the private kernel premises were
not narrowed. An actual current-node PC0 nav call with descriptor
`((uint256[4294967295],uint256)[])` and path `[0,LEN]` passed, observing incoming
static width 4294967296 reset to dynamic width one with unchanged boundary memory
and exact stack at `assertions-navigation/development/wide-tuple-array-physical-v2`.
V1's omitted selection step correctly raised InvalidNavigation and is retained.

These results are native/constructive development evidence, not new entry or
exact-bytecode public-class acceptance. Physical recursive child construction,
wide no-suffix returns, complete accepted descriptor spellings (including leading
zeroes in fixed lengths), and whole parser/navigation composition remain open.

## Canonical ConstraintFailed false helper acceptance (2026-10-02)

The admitted false non-OR caller at PC8035 through exact canonical
`ConstraintFailed` REVERT is accepted as a helper, retaining its decoded record,
input heap and resource premises. Candidate:
`assertions-resolution/constraints/failed/evidence/false-bound-consolidated-v1/manifest.json`.
Independent coordinator review:
`proof-workspace/work/coordinator-reviews-20261002/false-review-v2.json`.
The coordinator rechecked 2240 native CSV results and complete own declarations
across the 48-file caller/serializer closure, the 10-file/102-check selector
witness closure, all zero-finding audits, current minimal source/tool identities,
and retained evidence hashes. Independent full instruction/stack/byte-memory
replay reran 2943 instructions over 15 complete actual EVM error fixtures.
Changing only selector byte8058 from AF to AE fails the native specified-selector
postcondition and changes all15 canonical physical error returns. Start/Heads/
End/Caller generation reproduces; the 40-step Blob adapter is explicitly
inventoried as authored, not attributed to a nonexistent generator.

The independently specified error contains arbitrary admitted assertion and
reference byte lengths and all positional fields; serialization no longer stops
at a merely computed image. Its physical world frame is preserved. Decoder and
predicate admission, arbitrary successful validator prefixes, constrained/raw
resolver and PC0 public false composition remain separate obligations. This
helper acceptance adds no whole-entry credit; Assertions remains2/17.


## Public RAW first-false class acceptance (2026-10-02)

The public `resolve` RAW first-false non-OR class is accepted from the empty
PC0 frame through canonical `ConstraintFailed` REVERT, after arbitrary admitted
successful non-OR prefixes. The public constructor discharges the input heap and
caller-frame premises; the independent constraint verdict and canonical error
specifications remain separate from their physical implementations.
Candidate: `assertions-resolution/constrained-raw/public/evidence/false-bound-consolidated-v1/manifest.json`.
Independent coordinator review:
`proof-workspace/work/coordinator-reviews-20261002/public-false-review.json`.

The review reparsed 12,428 native checks, 4,617 declarations and zero-finding
audits across all 107 minimal-context dependency files, current source/tool hashes
and all retained evidence hashes. Fresh regeneration reproduced the 138-instruction
public prefix exactly. Independent instruction/stack/byte-memory replay passed
25,668 instructions across 12 PC0 fixtures. The already independently accepted
native selector fault at byte8058 AF to AE has the identical one-byte physical
meaning; all 12 same-calldata public error fixtures produce incorrect canonical
bytes under it. Complete ABI spans, resolved words, independent non-OR layout,
first-false policy and explicit finite resource limits define the admitted class.
There is no gas-model claim. OR, other fetchers, malformed layouts, other public
resolve outcomes and the entire resolve entry remain open. Assertions remains
2/17 whole entries; accepting this public class adds no whole-entry credit.

The earlier helper review was stored under the OR review filename accidentally.
That file remains preserved; separate current independent reviews are now
`or-review-v2.json` and `false-review-v2.json` in the coordinator review directory.
Both reparse unchanged current sources, native inventories, audits and retained
evidence; the public class review uses the corrected failure-helper record.

## Constructive name children and tuple composition (2026-10-02)

Complete modular native development closure
`assertions-navigation/evidence/name-constructors-native-consolidated-v3` passed
71 files, 4,085 native checks and 1,444 inventoried declarations, with unchanged
source/tool identities and zero-finding audits. The run reuses 69 exact minimal
passed dependency proofs and checks the remaining owners freshly. Private pure
name constructors return actual step traces; the lexical grammar bridge proves
scanner endpoints. `NameChildren` constructs the tuple loop's name-leaf child
traces, and `TupleNames` composes the initializer, arbitrary field-count tuple
loop and wide terminal return. `GrammarSlices` separately derives each actual
child span from the independent encoded recursive grammar. Its previous missing
span bounds and explicit concatenation slices are retained as a failed run;
the new owner passed 94 checks. Earlier child-loop timeout is retained; its opaque
proved child relation removes repeated invariant expansion without narrowing
admission or raising the 30-second limit.

These are native development components. General recursive child construction,
fixed/dynamic array suffixes, all accepted descriptor spellings, independent
physical replay/fault acceptance and complete navigation/get public entries
remain open. No additional public class or whole entry is accepted here.

### Constructive nested tuple/name parsing (2026-10-02)

The recursive no-suffix constructor now builds physical child traces directly
from the independent descriptor grammar for arbitrary nested tuple/name trees,
under explicit stack-depth and finite calldata premises. The complete 70-file
minimal native closure passed 4,071 verification batches, including 374 isolated
constructor batches; zero-finding audits and independent native evidence reparse
passed. Evidence: `assertions-navigation/evidence/recursive-plain-native-v2`;
review: `assertions-navigation/coordinator-reviews-20261002/recursive-plain-v2-native-review.json`.
Fixed/dynamic array suffix construction, malformed recursive descriptors and
whole public entry composition remain open. This grants no new public entry credit.
The failed v1 run is retained.

### Recursive canonical parser constructor, consolidated suffix v4

`assertions-navigation/evidence/recursive-suffix-native-v4` passes the complete
86-file minimal dependency closure (6,060 native checks), independently reparsed
in `coordinator-reviews-20261002/recursive-suffix-v4-native-review.json`.
Constructive traces cover recursive Name/Tuple/Fixed/Array canonical encodings
under the original DescriptorSpec.Valid, finite calldata and explicit stack Room
premises. Four fresh PC0 executions exercise 6,839 full-state parser steps.
Alternative accepted spellings, malformed outcomes, matching native fault binding
and complete public navigation/get composition remain open; no entry credit.
