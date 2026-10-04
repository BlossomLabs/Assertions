# AGENTS.md

What an agent needs to know to work in this repo without relearning it the hard way.
Learnings only: no status, no task lists. When something here stops being true,
fix it in the same change that falsified it.

## The two trees

- **Main repo**: `contracts/` (the `Assertions` core (currently open to changes), the versionable
  `Operations`, `Collections`, `Expressions`, `AbiCodec`, `ERC8211`), Solidity tests under
  `contracts/tests/*.t.sol` run by `pnpm test` (hardhat 3), and the Astro site in
  `website/` with hand-written docs at `website/src/content/docs/docs/`.
- **Vendored checkout**: `website/.evmcrispr` is an EVMcrispr monorepo checkout at a published commit
  (normally `next`, or a tested compatibility branch), pinned by `evmcrispr.commit` in `website/package.json`. The EVML
  language, SDK compiler, helper faces and parity harness all live there, not in
  `website/src`.
- Two sessions may share either tree at once. Never `checkout`/`restore`/`stash` a
  path carrying another session's uncommitted edits: working-tree-only edits never
  reach the object store, so that discard is unrecoverable. The husky pre-commit
  stashes the whole tree through lint-staged; while overlapping, use
  `git commit --only <paths> --no-verify` and run the checks by hand.

## Design doctrine

- **The core's admission test**: only what needs operands to arrive UNRESOLVED
  (ERC-8211 `InputParam`s) lives on the core. Scalar computation over resolved
  values belongs to Operations; iteration and collection processing belong to Collections; expression graphs belong to Expressions. All three version by deploying at new addresses. When
  a capability is requested, first check whether composition already expresses it:
  `hash(rawCall(target, data))` made both a `hashOf` primitive and a `HASH_EQ`
  constraint type unnecessary. Moving the primitives off the core was measured on
  2026-09-07 and refused: a branch put `pick`, `nav`, `chain`, `read`, `cond`,
  `orElse`, `isValid` and `revertData` on a separate contract bound to the core by an
  immutable, so every operand resolution became an extra staticcall hop into the
  core. The `OperationsGas` tables roughly doubled per element (the `bitSet` composed
  fold went from 16,572 to 35,708 gas per byte, `hashPairSorted` from 10,486 to
  22,510 gas per level, and even native-lambda folds rose about a third, `charset`
  from 30,080 to 41,830), so the primitives stay on the core.
- **Wire-format purity**: predicate constraints follow Biconomy's ERC-8211
  reference encoding and positional semantics. Enum IDs 0..8 are EQ, GTE,
  LTE, IN, GTE_SIGNED, LTE_SIGNED, OR, SKIP, IN_SIGNED; never add private
  extension IDs or reorder these. Constraint i checks resolved word i;
  SKIP still requires a complete word. OR leaves check the same word and
  nested OR is rejected before short-circuiting. Nested ORs stay refused: every
  leaf judges the same word, so OR of ORs flattens to one OR (the SDK can do it),
  and accepting them would break parity with the reference. Canonical encodings are
  tested against pinned deployed Biconomy bytecode offline; exact 64-byte
  range references remain a deliberate stricter rejection in Assertions.
- **Raw `InputParam` is a tree; `Expressions` adds a graph alternative.**
  Raw operands cannot name subterms: repeated expressions duplicate calldata and
  resolution. Resolve-once construction lives on the CORE, not on Expressions:
  `get(target, selector, argumentTypes, args)` resolves each argument in-frame
  and encodes the tuple through `AbiCodec.tuple`, and `gather(args)` resolves N
  operands once each into a canonical `bytes[]`. Both pass the admission test the
  way `read` does, and both keep the core as the destination's `msg.sender`
  (`MockTarget.caller` pins it). Expressions once had its own resolve-once entry
  points; they lost to `get` on gas because each paid an external hop per operand,
  and they are gone. Expressions is graphs only. Reach for a graph when a value is
  shared across several places, for `get`/`gather` when N operands feed one call.
  Repeated input entries are still independent; graph references share evaluated
  nodes. Graphs bind whole canonical ABI values, support lazy branches and guarded
  evaluation, and memoize per evaluation (per callback invocation in Collections),
  not across collection iterations. Failed guarded attempts discard cache changes,
  so their work may execute again. Replacing repeated external reads by sharing
  preserves values only when the reads are deterministic in their call context;
  even view targets can depend on gasleft or msg.sender. `Select` judges truth like the core's `cond`:
  the first word of the condition, nonzero selects `refs[1]`, zero `refs[2]`
  (every node validates against its type and no type is shorter than a word, so
  a condition is never short);
  `Collections._predicate` still demands a canonical 0/1 word from callback
  RESULTS, a different concern. Keep word-window folds for word-only workloads; a
  32-byte overwrite changes no dynamic ABI offsets. Specialized math such as
  `rpow` still avoids an impractically large composed expression.
- **Descriptor parsing is the computation contracts' hot path**, and it is already
  optimised: assembly scanners, a one-parse `tupleLayout`, and a per-node shape
  cache in `Expressions.Cache.dynamic/words`. Do not reintroduce bounds-checked
  `t[i]` calldata indexing or parse a descriptor more than once per call. A graph
  carries real fixed overhead, so it only wins when the resolutions it saves cost
  more than the nodes it adds: over an expensive leaf a graph beats the equivalent
  tree, over a cheap one it loses badly. Loops in this inline assembly cost over
  100 gas per iteration (`scanName` was about 900 gas over `uint256` until it
  learned to skip `uint256`/`address`/`bytes32`/`string`/`bytes`/`bool` as one
  word, about 200 now; the loop still decides where the name ends), so the
  canonical-word check matches names as one word, returns loop-free for
  `uint256`/`bytes32`/`int256`, and walks each descriptor once with checking
  folded into the parse; a separate re-parse per component cost 4.6k more on
  `(uint256,uint256)`. The same rule holds one level up: `AbiCodec.validate(t, v)`
  re-parses `t`, so a loop over values must parse once and call the
  cached-shape overload (re-parsing per element cost about 1,400 gas each in
  every Collections `*Values` traversal and in `pack`). Outside assembly, a
  checked calldata slice (`bytes32(s[i * 32:i * 32 + 32])`) costs about 450 gas
  per word and a checked `data[i]` about 100 per byte: per-element loops read
  through `calldataload` helpers whose callers have already bounded the index.
  A value validated as a canonical `T` is a valid tuple component of type `T`
  by the same rules, so Collections skips the per-binding re-validation when
  the callback declares the slot with byte-identical descriptor text
  (`firstSame`/`secondSame`); any other spelling still validates.
  Every `AbiCodec.validate` overload without a context allocates a zeroed one
  (about 170 gas), so loops allocate one and pass it to the context overload.
  `evaluateEncoded` forwards the payload without decoding it, and puts it LAST
  in the forwarded call, after the head and the encoded parameters. With the
  payload first, an offset inside it could point past its end into the
  parameters, so a stub payload could take its node list from runtime data
  (an independent review reproduced that through `mapValues`: the element was
  the program). ABI offsets only point forward, so last means confined.
  `check_evaluateEncodedMatchesEvaluate` pins the calldata `NodeCallFailed`
  reports, and has to build the same layout.
  `scripts/test-claim-coverage-structure.py` pins the first two statements of
  the loop in `Expressions.evaluate`; new locals go after them. Measure with `forge test --decode-internal -vvvv`, which
  prints gas per internal library call. The thresholds live in `AbiCodecGas.t.sol`
  and `ExpressionsGas.t.sol`; read them there rather than quoting a number here.
  A full-word name match must fit inside the descriptor before selecting its
  rule: Solidity accepts nonzero calldata padding, and `bytes3` followed by an
  out-of-span ASCII `2` once matched `bytes32` and lost its narrow-word check.
- **No contract is frozen.** A release flag records SDK adoption; it does not
  prohibit source changes, and all four contracts version the same way. Any source
  edit, comments included, moves the CREATE2 address: regenerate addresses and
  artifacts in the same change, and never assume deployed code updates in place.
- **`nav` returns every ABI terminal.** Static arrays and tuples return their full
  bounded static encoding, without an offset or length prefix. Scalars retain
  their one-word encoding. Dynamic terminals are re-encoded as follows. Since 2026-09-07 arrays of dynamic
  elements and dynamic tuples come back as `abi.encode(value)` (their extent from
  `AbiCodec.body`'s canonical-form walk, malformed data reverting `InvalidValue`);
  the earlier `InvalidNavigation` for them is gone. `PAYLOAD` is still string/bytes
  only, and `LEN` still refuses fixed arrays and tuples. Every word `nav` RETURNS
  is range-checked for its type like the codec's (static terminals, elements of
  static-element arrays, and nested words through `body`), reverting
  `InvalidValue` at the offset in the resolved data; siblings the path skips are
  not checked, since they never reach the consumer. A whole `bytes`/`string`
  terminal is returned canonical too: nonzero padding reverts `InvalidValue` at
  the first dirty byte (Halmos found `nav` copying dirty padding through), while
  `PAYLOAD` and `LEN`, which never emit the padding, are unaffected.
- **Sentinels ride the path**: `LEN` (`type(int256).min`) and `PAYLOAD` (min + 1)
  are nav path entries because no real index bound can ever admit them, and the
  path is where selection intent lives. This kept the descriptor grammar pure ABI
  syntax: a `bytes(T)` grammar production and an `unwrap` primitive were both
  refused in its favor (non-ABI descriptors are unparseable by viem; a primitive
  costs a selector and an extra frame where the sentinel appends to the reaching
  nav's own path).
- **Descriptors and type lists are the author's claim** about an encoder, like an
  inline ABI. A wrong claim reverts loudly in almost all cases, but a
  shape-compatible wrong claim reads the wrong value. This class is documented,
  not defended against. What a claim CAN be held to, `AbiCodec` enforces the way
  solc's decoder does: every static word must be in range for its base name
  (uintN/address/bool high bits clear, intN sign-extended, bytesN/function low
  bits clear), so `unpackArray("uint8", ...)` no longer passes `0x1234` through
  as a uint8. The 256-bit names and anything that is not a well-formed narrow
  ABI type (`uint7`, `uint08`, `foo`) still admit every word. Fixed lengths
  and static fixed-array footprints are capped at 2^32 - 1 (InvalidTypeDescriptor
  at the length), since no real encoding is that long and an unbounded multiply
  panicked. Bare static tuples retain the sum of their component widths.
  `T[0]` is refused too, as solc refuses to declare it: a zero-width
  type let `unpackArray` materialise 2^40 empty values from a count word, and
  every value now spans at least one word, which retired the zero-width guards
  in `body`, `unpack` and `nav`'s `LEN` and `Select`'s short-condition check.
  The grammar has no empty-tuple production: `AbiCodec.tupleLayout("()")`
  reverts `InvalidTypeDescriptor(1)`, and the
  core's `get` and Expressions' `_arguments` special-case `"()"` with no values
  before ever calling it.
- **Validate what is read** (since 2026-10-03): every byte that can influence a
  result is validated, and malformed input that cannot influence it is not an
  error. `nav` already treated DATA this way (skipped siblings); it now treats
  its DESCRIPTOR the same, parsing along the path, and `evaluateEncoded` no
  longer decodes the graph before forwarding it. The price is early diagnosis:
  a malformed branch nobody takes passes until it is taken, and then fails
  closed. Three things stay eager on purpose: constraint and OR structure
  (parity with the reference decides), graph admission (references, counts and
  every `valueType`, which E42's structural evidence depends on), and anything
  whose unread part would change how the read part is located: a top-level
  array of tuples is parsed whole, and a tuple descriptor has its parentheses
  counted so the one opened at byte 0 closes at the last byte. Requiring only
  a final `)` was not enough: `(a,b)junk)` was read as the tuple `(a,b)` and
  returned a word from the wrong position until a review caught it. A test
  that asserts "unread text cannot matter" must not fuzz the text that decides
  where the read part ends, or it blesses exactly that hole. A claim of this kind is
  relational ("the result does not depend on the unread bytes"), so its test
  mutates the unread region and requires the same result. In `docs/claims.md`
  a claim text starting with `\*` changed after the rc1 snapshot; the ID cell
  stays bare because the evidence checkers match `| ID |` exactly.
- **No wrong-answer machines**: silent truncation is always a bug
  (`UnalignedWords`, `WordCountMismatch` exist for this). At the raw Solidity boundary,
  splicing an ARRAY return directly into `hash`/`byteLen` silently digests N bytes
  of an N-element payload: its length word counts elements. The SDK now rejects
  non-string/non-bytes operands through `requireBytesLike`; the builder mirrors
  that guard. `hash(rawCall(...))` is the raw whole-returndata spelling.
- **Errors identify the operand** (entry index, param index, hop index, binding
  index). Constraint i judges word i. Scalar ranges use IN/IN_SIGNED;
  two constraints do not mean two tests on word 0. Signed constraints and
  OR are supported at the wire boundary. The SDK may still lower signed
  comparisons through Operations; `!=`, string equality and live-vs-live
  tolerance also use expression composition, with tests pinning that shape.
- **Operations admission is a demand test**: a function earns a slot only when
  BOTH (i) it is not expressible as a few-node recipe at practical cost AND (ii) a
  concrete assertion workload needs it (a script in `docs/` or the tests, or an SDK
  helper face that would call it). Signed `sortWords` was refused (flip the sign
  bit, sort, flip back); generic comparator sorting lives in Collections (sorting
  is not a reduction); `join` is composition over `concat`. What passes (i): hot
  loops (one call per element otherwise) and calldata-exponential compositions
  (`rpow`, `log2`). Specialist families go to optional contracts. All fourteen
  Collections `*Values` traversals have SDK consumers through `modules/lang`;
  eligible word-sized workloads retain the word fast path. When Collections needs more
  bytecode space, split `*Values` into a fourth computation contract.
- **One entry point per engine in Collections** (since 2026-10-03): the three
  word folds are `fold(domain, n, s, ...)` and the word map and filter are
  `applyWords(..., filter)`. The siblings already shared one loop, so merging
  them only recovered dispatcher and decoder stubs (about 260 bytes) for a few
  hundred gas per call. A merged signature carries
  an argument one domain does not use, and it is refused, not ignored
  (`UnusedFoldArgument`): a Range fold given a subject, or a Words fold given a
  count, would otherwise run a different fold than the caller wrote.
  `anyValues`/`allValues` were NOT merged into `findValues`: turning the index
  back into a boolean costs about 15,000 gas whenever the result feeds another
  expression.
- **Signedness is a dimension in every word-level design.** Unsigned order and
  signed order disagree about which value absorbs, which element is minimal, and
  how a two's-complement word reads. One SDK path returning `elemType: "uint256"`
  unconditionally produced wrong answers over `int256[]` once already.

## The vendored checkout: how work lands

For an upstream pin update, verify the published `origin/next` SHA, check the
vendor tree is clean, fetch it, and move to that commit without forcing checkout.
Verify it with `git cat-file -e`, then set `evmcrispr.commit` in
`website/package.json`. Run `pnpm prepare:evmcrispr` and
`pnpm check:integration` from `website/`.

If developing upstream changes, switch the clean vendor checkout to a working
branch, test, commit and push before pinning: the vendor script fetches the SHA
with `--depth 1`, so an unpushed pin is broken. Never discard another session's
changes to make a checkout clean.

The vendor script refuses to change commits with local tracked or untracked
changes and never force-checks out. A stamp under `node_modules` records the SHA
only after dependency installation AND codegen succeed; an interrupted preparation
is retried even if HEAD already equals the pin. `dev`, `build` and `deploy:ipfs`
explicitly run preparation: pnpm may not run implicit pre/post hooks.

- **Contract bytecode changed → regenerate the fixture**: `pnpm compile` in the
  main repo, then `bun scripts/sync-assertions-bytecode.ts` in the checkout. The website
  `pnpm check:integration` gate compares both runtime fixtures with compiled
  artifacts, and both deployment bytecodes/CREATE2 addresses with the SDK.
- **Codegen is regex-based**: `defineHelper` configs must keep `name`,
  `description`, `compileDescription`, `returnType`, `args` before `run`/`compile`
  at two-space indentation. `src/_generated.ts` is uncommitted output; rerun
  `bun run codegen` after any face change (a helper's `name!` key does not exist
  until you do), and note bare `bun test` inside a module does NOT rerun it.
- **SDK types resolve against `dist/`**: after SDK source changes, downstream
  `type-check` needs rebuilt declarations (`bun scripts/build.ts --types` with
  `node_modules/.bin` on PATH; plain `--bundle` builds delete stale `.d.ts`
  without regenerating them).

## Faces and parity

- Every both-faced helper's run and compile faces must agree, or declare the
  divergence: a parity case with `diverges` fails unless the helper carries a
  `compileDescription`, and fails again if the faces secretly agree. That field is
  a ledger, not decoration: one user-visible sentence, no Operations internals, no
  compiler vocabulary (the description lint enforces this).
- Parity `compile` strings are spelled out, never derived from `run` by adding
  `!`. An undeclared compile failure fails the case rather than skipping.
- The off-chain face re-runs the compile face's validation (`walkNavPath` etc.) so
  the two faces reject identically.
- Adding a `compile:` face makes `parity-coverage.test.ts` demand a
  `## On-chain face` section in the helper's `.md`, below the `<!-- HAND-WRITTEN -->`
  marker. Everything above the marker is regenerated by
  `bun scripts/generate-docs.ts` from the config; never hand-edit it.
- `validate-docs` parses and statically analyses every ` ```evml ` block but does
  NOT compile, so a compile-face-invalid example passes it silently. Trust it for
  links, grammar and descriptions, not for on-chain behavior.
- Helper nodes cannot carry return lenses (only `::` calls parse
  `returnDestructure`); a helper that needs one takes it as an ordinary
  array-literal argument through the SDK's `lensSlots`.

## Testing law

- **Assert decoded structure, never re-derived numbers.** Offsets in fixtures are
  found by SCANNING for sentinel words, not recomputed with the compiler's own
  formula: a shared misconception otherwise passes both sides. The one time a
  hand-computed offset (192) disagreed with the compiler (160), the compiler was
  right.
- **At least one test per geometry must execute on a real EVM** (the checkout
  installs the fixture bytecode at the canonical addresses via `anvil_setCode`;
  the main repo has hardhat Solidity tests). Decoder-level tests alone once let a
  shared layout misconception pass everywhere.
- **Check that a test has teeth** by deleting the code it guards and watching
  which cases fail. Every word-aligned fixture in existence once made a `ceil32`
  deletion invisible.
- **forge-std `expectRevert` arms on the NEXT external call**: a constant accessor
  like `assertions.PAYLOAD()` inlined in the asserted call's arguments disarms the
  check. Hoist such calls above the cheatcode.
- Gates and where they run: main repo `pnpm test` (the runner executes exactly the
  static count of `function test` declarations across `contracts/tests/*.t.sol`);
  checkout modules `bun test ./test/integration` (anvil auto-starts, Gnosis fork,
  needs `VITE_DRPC_API_KEY` in `.env`), `packages/sdk` `bun test ./test/unit`,
  root `bun run validate-docs`. `pnpm test:forge` runs the same `test*` suites
  under Foundry; Hardhat stays the build of record (forge's executable code is
  byte-identical, its metadata trailer is not, so never deploy from `out/`).
  Foundry's cache is `cache_forge/` because Hardhat owns `cache/`.
- **Halmos** (`uv tool install halmos`, then `pnpm halmos`) explores `check_*`
  functions, which neither test runner executes. Three traps, all hit once:
  Halmos DISCARDS reverting paths, so an oracle that reverts must be caught and
  turned into an explicit assertion failure or the property passes vacuously,
  and the same holds for the code under test: a direct call expected to succeed
  hides any bug that makes it revert on valid input (an unzip lane bug survived
  exactly this way), so route such calls through `staticcall` + `assertTrue(ok)`;
  a symbolic ABI offset or length ends in `NotConcreteError`, so case-split head
  words into literal candidates (returning the case argument itself stays
  symbolic) and keep body words symbolic; and the oracle is solc's
  `abi.encode`/`abi.decode`, never a pack/unpack round-trip, since both share
  AbiCodec's validation. The default loop bound (2) silently cuts paths: the
  script passes `--loop 70`, and a run must show no `loop-bound` warning. A
  command-line `--loop` OVERRIDES per-function `@custom:halmos` annotations, so
  raise the global bound rather than annotating. Completeness against solc
  ("solc decodes it, so nav must too") holds only on CANONICAL data (equal to
  `abi.encode` of what solc decoded): solc tolerates dirty bytes padding and loose
  offsets that this repo rejects by doctrine. Case-split offsets must land on a
  concrete length word, never on a symbolic content word, and restrict each case
  variable to its distinct candidates: an unconstrained uint8 multiplied one
  property past ten minutes. Indexing a memory array by a symbolic case is a
  symbolic offset too: select per case with a literal if-chain. A
  symbolic word that some decoder reads as an ABI offset (an OR payload) is the
  same `NotConcreteError`: give that case its own property with concrete
  structure. `ERC8211Symbolic.t.sol` proves constraint verdicts against the
  pinned Biconomy bytecode, inlined in `BiconomyERC8211Runtime.sol` because Halmos
  cannot read files; a test pins that copy to the fixture's `runtimeHash`, so
  regenerate it from `test/fixtures/biconomy-erc8211.json`. Planted bugs in
  `_checkConstraints` were each caught; a mutant that only changes WHICH error
  rejects is invisible there, because the properties compare verdicts. Halmos
  does not decide Operations' arithmetic: value properties of `mulDiv`, signed
  `addMod`/`mulMod`, signed `exp`, `sqrt` and `powMod` all hit the 300s solver
  limit even with int16/uint64 operands (measured 2026-09-25, `halmos --contract
  OperationsSymbolicTest --function <name> --solver-timeout-assertion 300000`),
  because the code multiplies, divides and reduces at 256/512 bits whatever the
  operand width. That arithmetic stays with `test/math-fuzz.test.ts`. Halmos
  also prefixes `^` to `--function`, so an anchored `^name$` matches nothing
  and reports "No tests" rather than failing loudly. Halmos has no gas model
  either: `gasleft()` is a fresh symbol each time, so the core's out-of-gas
  guard (`SubcallOutOfGas`) can fire on any failed subcall, a path no real
  execution takes. Properties over failing subcalls discard that outcome
  (`outOfGasArtifact` in `ControlSymbolic`, `ExpressionsSymbolic` and
  `ExpressionsCallsSymbolic`); the concrete sweeps in `CoreReads`, `Expressions.t.sol` and
  `GasPropagation.t.sol` pin the guard at real gas values. Every cooperating
  wrapper, including Operations.rawCall and both Collections callback paths,
  must detect exhaustion and rethrow the exact signal BEFORE wrapping ordinary
  errors. External targets that swallow failures or branch on gas are outside
  this guarantee. Adding a wrapper without that guard once made EQ 0 pass by
  lowering gas alone. Unbounded recursion is
  out of reach too (a path Halmos cannot finish is dropped, not failed): an
  Expressions self-reference is pinned by the concrete `Expressions.t.sol` test. A
  property over `uint256`/`bytes32` elements cannot see missing type
  validation, because every word is valid there: a flatten mutant that
  skipped validation survived exactly this way. Exercise validation through a
  narrow type (`uint8`) whose dirty words must be refused. Symbolic LENGTHS
  belong in the parser only (`NoPanicSymbolic`): a walker that consumes an
  accepted length copies and iterates by it, so a symbolic one there is a
  NotConcreteError or a loop past the bound, and two symbolic lengths multiply
  nonlinearly (nine minutes for one configuration). Sweep the walkers
  concretely instead (`NoPanic.t.sol`), with a fixed gas budget per call, since
  Halmos does not model gas and an out-of-gas revert is empty data. Keep every
  digit run under the loop bound: a path past it is dropped, not failed. State
  a numeric reference with constant multiplications, not a symbolic division:
  `parseUnits` rounding as "N * 10^d / 1000" ran past eleven minutes, the same
  claim as bracketing inequalities (`m * 1000 <= scaled < (m + 1) * 1000`)
  proves in four. A property that still needs more than the default solver
  limit takes a per-function `@custom:halmos --solver-timeout-assertion`: the
  script sets no solver timeout, so nothing overrides it (unlike `--loop`). The
  same split holds in Operations: index arithmetic is proved
  (`OperationsNoPanicSymbolic`, each index either symbolic and out of range or
  a literal boundary, since an in-range symbolic index is a symbolic copy
  offset), byte scanners are fuzzed with a gas budget (`OperationsNoPanic`).
  That budget found search at 170 gas per compared byte (a near-miss 32-byte
  needle cost 5.3M gas over 964 bytes); `_matchesAt` now compares words. A
  budget judges the algorithm, not the output: skip inputs whose OUTPUT alone
  exhausts it (concat of 1.66 MB costs 28.6M in memory expansion). An
  out-of-range enum argument (`Rounding`, `FoldExit`, `FoldDomain`) never
  reaches the code:
  solc's ABI decoder reverts with empty data, not Panic(0x21). Collections
  follows the same split (`CollectionsNoPanic`), with a target per way a lambda
  or callback can misbehave; each fails declared, a gas burner included
  (SubcallOutOfGas, never an ordinary CallbackFailed). `iotaWords(n)` is the
  deliberate exception: its cost is its output's, so an absurd n panics or runs
  out of gas, documented rather than bounded (a cap would not stop the
  out-of-gas and costs Collections bytes). Encode a raw-enum call whole with
  `abi.encodeWithSelector`: a head spliced onto a separately encoded tail
  shifts every offset, and the decoder's bare revert then looks like a finding.
  `forge fmt` expands a one-line `/** @dev ... */` and drops the text before
  any ` * ` inside it (`n * 32`): write such comments multi-line.
  The core and Expressions (`CoreNoPanic`, `ExpressionsNoPanic`) fuzz through
  uint8-enum mirror structs, which encode identically to the real ones. Wire
  bytes solc cannot decode (a STATIC_CALL paramData, an OR referenceData, a
  Resolve node's data, an out-of-range enum)
  can revert without data (an evaluateEncoded payload is forwarded undecoded,
  so what `evaluate` cannot read fails inside the self-call and arrives as
  NodeCallFailed with an empty reason; only a payload shorter than a word is
  bare); nested STATIC_CALL/OR allocation requests can
  instead raise Panic(0x41), and resource exhaustion can return empty data.
  These are documented, not pre-validated: a canonical check would reject
  what the reference accepts and tax every STATIC_CALL. Core reads/batches
  fuzz canonical nested encodings with bounded payloads; explicit regressions
  assert impossible-allocation panics. Operations search bounds inputs and
  replacement expansion, requires success or exact EmptyNeedle, and separately
  asserts exhaustion for a large replacement output. The suites accept a bare revert only when
  they injected such bytes, and half their runs inject none: with junk in
  most runs a real bare revert hides behind the excuse. A WELL-TYPED graph
  must never reach a bare decode: ProbeCall once decoded any calldata
  operand as bytes, so a `uint256` operand reverted without data; `evaluate`
  now requires that node typed `bytes` (InvalidNode).
- **Mutation testing** (`docs/mutation-testing.md`): Gambit 0.2.1 (`cargo install
  --git https://github.com/Certora/gambit.git`) against forge tests, then the
  Halmos suites and Node fuzzers, then `MutationGaps.t.sol`; every survivor is
  killed or recorded as equivalent with its reason. What the pass taught: tests
  and properties over `uint256` alone cannot see missing type validation; pick
  test numbers that no operator swap maps onto each other (`2 * 2 == 2 ** 2` hid
  a mutant); a revert-only test does not pin WHICH error or offset, and dozens of
  error-detail mutants survived until the exact revert data was asserted; and a
  test only counts once the mutant it targets fails it. Run mutants in scratch
  worktrees, never in a shared tree.
- Claims require run provenance: a check_* declaration alone is not a proof.
  Keep property inventory, source hashes, tool versions, commands, exclusions
  and pass/fail/incomplete results with the ledger. Halmos has no gas model.
  The baseline (`scripts/verify-claims.py`, then `scripts/refresh-claims.py`)
  hashes every `contracts/**/*.sol`, tests and comments included, and the
  refresh refuses any drift, so finish every edit before starting the run
  (a comment fix afterwards costs the whole rerun) and run the concrete gates
  first: `foundry.toml` sets no fuzz seed, so a `forge test` that passed once
  can still surface a counterexample later (a 284-element fold over 253
  windows exhausted the no-panic budget honestly on 2026-09-29), and a fix
  to that test invalidates a baseline already running.
  Atomic rollback requires a mandatory assertion in the same transaction and
  an executor that propagates its failure; a caught failure cannot promise it.
- Record measured numbers with the command that produced them; never state an
  a-priori estimate with a measurement's confidence (gas multipliers have been
  misquoted exactly this way).
- Before claiming something is absent, search for it case-insensitively; a
  working pointer was once deleted on the strength of a case-sensitive grep.

## Release

- Finish Solidity formatting and review comment preservation before compilation,
  salt mining and a fresh proof baseline; require the full `forge fmt --check`
  to pass. Formatting may add braces around single-statement control bodies;
  review those changes as well as whitespace and comments.
- Canonical salts are 32-byte values mined with `cast create2` for a vanity prefix
  (a55e47, 09e4a7e, c011ec7, e5594e55: the contract names in hex; see
  `website/scripts/mine-salt.mjs`) and live in `website/scripts/export-deploy-artifact.mjs`. The zero salt in Ignition
  is not the canonical deployment path. `pnpm sync:artifact` (from `website/`)
  regenerates the per-contract `src/lib/*-deployment.ts` and `*-abi.ts` modules AND
  `website/src/lib/deployments.json`, the one manifest every website consumer and
  `check:integration` read. ANY contract source change moves the CREATE2 address,
  comments and NatSpec included: they reach the metadata hash appended to the
  bytecode, so `@custom:version` and a typo fix cost the same re-mine. An edit to
  an IMPORTED source moves the importer's address too, which is why Collections
  and Expressions declare their callback/core interfaces locally: only `AbiCodec`
  is still compiled into all four, so an edit there moves all four. `ERC8211`
  is also imported by Expressions: changing its enums moves both Assertions and
  Expressions, including the latter's `InputParam` ABI decoder. Budget the
  re-mine before editing a comment: a55e47/09e4a7e/c011ec7 take seconds to a
  minute, e5594e55 is 32 bits and takes minutes. Regenerate and verify deployment
  artifacts, fixtures and SDK addresses together; the SDK lives in the vendored
  checkout, so an address move is not finished until the pin is bumped.
- Mine salts from `hardhat compile --force`, never from an incremental build
  (measured 2026-10-04). Hardhat's metadata records the solc job's remappings,
  so the same source hashes differently depending on which job it lands in:
  the forced build compiles the four contracts in one job carrying the
  OpenZeppelin remapping, while an incremental build after editing one
  contract compiles it alone, without it. Collections and Expressions were
  once mined from incremental artifacts, `sync:artifact` accepted them, and a
  clean checkout predicted two other addresses. Run the forced build again
  before `sync:artifact` and before believing its check.
- Operations' `mulDiv`, `sqrt`, `log2` (also inside `lnWad`) and the inverse behind
  negative `powMod` exponents call OpenZeppelin's `Math`, pinned to an exact
  `@openzeppelin/contracts` version in `package.json` (and remapped in
  `foundry.toml`). A bump of that pin changes the imported source, so it moves the
  Operations address like any edit and needs the same re-mine. `Math.modExp` is
  deliberately not used: it trusts a successful call to `0x05` without checking
  the return size, so on a chain without the precompile it returns stale memory;
  `_powMod` checks `returndatasize` and falls back to its loop.
- Bytecode size: `test/bytecode-size.test.ts` checks `(len(deployedBytecode) - 2) / 2`
  against 24,576 for every production artifact under `pnpm test` and pins the
  artifact set.
- The manifest's history carries the prior PUBLIC release only (Assertions v1.0).
  Development artifact candidates are not recorded: they were never deployed, and
  listing them taught readers that a candidate address meant something.

- When running tests in a restricted sandbox, verify the nodejs test count: a
  sandboxed run has reported success with zero fuzz tests. Run outside that
  environment before treating the fuzz suites as passed.

- Format production Solidity consistently with `forge fmt contracts/Assertions.sol contracts/Collections.sol contracts/Expressions.sol contracts/Operations.sol contracts/lib/AbiCodec.sol contracts/lib/ERC8211.sol`; use `--check` to verify. Public NatSpec describes rounding and rejection behavior; implementation helpers document caller preconditions.
