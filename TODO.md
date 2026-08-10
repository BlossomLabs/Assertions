# On-chain face work: plan, progress, findings

Lifting the restrictions the helper-description audit surfaced. Work happens in the
vendored checkout (`website/.evmcrispr`, branch `operators-1.0`); the main repo carries
`Operators.sol` and the pin.

Interleaved throughout with a second session working the fixed-point / lending / ENS
side of the same branch. Their commits are noted where they matter.

---

## Status

| phase | what | state |
|---|---|---|
| A0 | `@sort!` note points back at its recipe | done |
| A1 | `@reduce!` reducers + signedness | done |
| A2 | `@includes!` with a live element | done |
| A3a | `spliceLayout`, concat/zip family | done |
| A3b | `construct.ts`: N dynamic live arguments | done |
| A4 | live needles, replacements, delimiters | done |
| A5 | `@unzip!` lane optional | done |
| B1 | lambda target may be the core | done |
| B1r | review: word guard, any-staticcall lambdas, EVM-executed folds | done |
| C | `elemOffsets` + address roll | done (vanity re-mine deferred — see Landed) |
| B2 | `@it!` element placeholder | done, then **subsumed by D3** |
| D1 | `def @name!` is compile-only | done |
| D2 | DEF resolution + AST substitution on the compile path | done |
| D3 | array faces apply a definition by name; `@it!` retired | done |
| D4 | `@reduce!` folds with a named definition | done |

Every commit on `operators-1.0` desyncs the pin in `website/package.json` and must be
followed by a bump. See Hazards.

---

## Landed

| checkout | main repo | |
|---|---|---|
| `a9cb02c` | | `compileDescription` field; codegen extractor fix |
| `4e6cf83` | | 93 descriptions rewritten, 4 broken examples, 4 broken links |
| `108d55f` | | description lint in `validate-docs` |
| `2b1d2dd` | `0307c97` | module overviews (one bump covers the four description commits above) |
| `98c929e` | `5401dcf` | A0 |
| `4d17877` | `7f3e6dd` | A1 |
| `c97565f` | `1aabfc4` | A2 |
| `9b28c1b` | `f673bc0` | A3a |
| `37746cd` | `ae94476` | A3b |
| `91e6077` | `9009fa2` | A4 |
| `95559c6` | `cc32ec0` | A5 |
| `a32a96b` | `4dbf47a` | B1 |
| `6bfbd56` | `167dd90`, `2c7a87a` | B1 review: word-category guard, any-staticcall lambdas, EVM-executed core-target folds |
| `504d59d` | `ee3c94e` | C: `elemOffsets` array on fold/map/filter (SDK layout + Operators engine); vanity re-mine deferred |
| `2445ed9` | `dd80f75`, `fe250e1` | B2: `@it!` + multi-marker extraction (test + pin) |
| `aaca108` | `e523416` | D1: bang defs are compile-only, and must be fully typed |
| `7c2f026` | `c3dd462` | D2: a `def @name!` is inlined where it is used |
| `f8114cc` | `3f97df0` | D3: array faces apply a definition by name; `@it!` surface retired |
| `518e2e3` | `e82c07f` | D4: `@reduce!` takes a two-parameter definition |

Current gates (re-measured after D4): type-check 99/99, lang 318, assertions 152,
std 510, ens 127, contracts 126, token 62, crypto 34, SDK unit 179, validate-docs
556 blocks / 1061 links / 1386 descriptions, all zero. Main-repo Solidity 261
passing (260 before B2's multi-window core-target square test).

**Counting basis, so the numbers reproduce:** lang and assertions are
`bun test ./test` in their module; ens, contracts, token and crypto are
`bun test ./test/integration` — their full `./test` trees run MORE (ens 161,
contracts 161, token 71, crypto 46), the extra being unit tests outside the gate.
SDK unit is `bun test ./test/unit` in `packages/sdk`. The `contracts` gate is the
CHECKOUT's `modules/contracts` EVML suite, NOT the main repo's Solidity tests: those
are a separate gate, `pnpm test` (hardhat 3, solidity tests) at the main-repo root —
and a static count of `function test…` declarations across `contracts/tests/*.t.sol`
matches what that runner executes.

---

## Remaining

### C leftovers (vanity + doctrine — not B2)

**Vanity re-mine: still deferred.** Both contracts remain on the interim zero salt in
`hardhat.config.ts`. `website/scripts/mine-salt.mjs` is ready (compile, then
`node scripts/mine-salt.mjs [artifact] [prefix]`), but no canonical address exists
yet for a signature change to break. Run the miner for both Assertions and Operators
when bytecode is frozen for publish, then update the salts and
`website/src/lib/verification-inputs.ts` (generated). Runtime still **17,042** /
**7,534** headroom after C; B2 is SDK-only so bytecode unchanged.

**Still owed to the other session (docs, MAIN repo):**
`website/src/content/docs/docs/operators/index.md` still claims a fold lambda "has a
single accumulator window and so cannot square". That claim is about the
*accumulator* window count (still one `accOffset`), not `elemOffsets` — but the
sentence will mislead now that multi-window element substitution is live via `@it!`.
Correct it when touching doctrine; B2 did not edit that file.

**Non-goal, unchanged:** `elemOffsets` does NOT unlock `@merkle.root`. Array
halving / one-to-one `mapWords` still binds.

### Option recorded, not scheduled

A second, distinct ACCUMULATOR marker (same technique as the element marker) would let
`@reduce!` accept arbitrary Operators-backed binary lambdas — `foldParam` already takes
`accOffset` independently. Not taken: `reduce.ts` excludes non-commutative reducers
DELIBERATELY, for readability of the source form. Record so the idea is weighed against
that choice rather than rediscovered as an oversight.

---

## The def series (D1-D4)

Inline bang lambdas are gone. A lambda was a partial application whose missing
first argument the face prepended, so `@map!(caps @num!(* 2))` read as an
expression with a hole nothing at the call site explained. It is now a named
definition applied by name:

```evml
def @dbl! "$x: number -> number" @num!($x * 2)
@map!(caps @dbl!)
```

**`def @name!` already bound before any of this** — the parser admits a trailing
`!` as part of a name and `def` never looked at it. What was broken is that the
interpreter checks DEF first and never inspects the name, so `@double!(3)`
INTERPRETED. Module `!` helpers are stopped by `defineHelper`'s guard; a def never
passes through it. D1 closed that and made a bang def require full types, since
`inferTypes` walks a body expecting helpers it can reason about off-chain.

**A def is inlined, not called.** Off-chain, `def` binds each `$param` to a VALUE
and interprets. On-chain there is no value at build time, only an operand — so the
body is copied with the call's argument NODES substituted for its parameters. That
is what lets the element marker land wherever the body names its parameter, and a
body naming it twice produce two windows with no extra machinery.

**The cycle guard was wrong the first time.** Tracking def names down the expansion
reported `@quad!` as recursive when its body is `@dbl!(@dbl!($x))`: two sibling
applications, each terminating, but the inner compiles while the outer is on the
stack. Recursion is a property of DEFINITIONS, not of one expansion, so the guard
asks whether a body can REACH itself through other bodies. Resolved at call time,
because mutual recursion is only visible once both halves exist.

**`@it!` was subsumed one commit after it landed.** Its plumbing is untouched and
load-bearing: `findWindows`, the `elemOffsets` array, and C's `uint256[]` Operators
signature are exactly what makes `@num!($x * $x)` compile to two windows and one
call. Only the surface went, plus `ctx.lambdaElemCat`, which lost its only reader.

**D4 answers an objection this file had recorded as declined.** The reducer
allowlist existed because a bare name cannot say which side the accumulator is on.
That argument is about the SPELLING, so a signature dissolves it: any two-parameter
def is accepted with no gate, and the bare names keep theirs. The accumulator may be
named at most once (the engine carries one `accOffset` against an array of element
offsets); a body that never names it parks on the first element window, the trick
`@all!`/`@any!` already use.

**A gate that cannot see this class of change:** `validate-docs` parses and
statically analyses but does not COMPILE, so every now-invalid lambda example in the
helper docs passed it silently. They were migrated by hand. Worth remembering before
trusting it on any future compile-face change.

---

## Findings

### Bugs found, not looked for

- **`@reduce!` returned wrong answers over `int256[]`.** `wordsArg` returns `elemType`
  and the compile face discarded it, so `min` used `min(uint256,uint256)` and read
  two's-complement negatives as huge positives, returning the largest-magnitude
  negative as the minimum. Fixed in A1.
- **19 helper descriptions were silently truncated in the registry.** `codegen.ts`
  extracted them with `["']([^"']+)["']`, which stops at the first apostrophe.
  `@giveth:stakable` hovered as "GIV in an account". The docs scanned properly, which
  is why nobody noticed. Fixed with a quote-aware scanner in `a9cb02c`.
- **`@lang:unzip`'s signature and its guard disagreed.** `lane` was already
  `optional: true` in the argDef, so the generated signature advertised
  `@lang:unzip(pairs lane?)` while the compile face rejected the one-arg form. A5
  closed the inconsistency rather than adding a feature.
- **`@token:symbol` was documented backwards.** `resolveToken` returns an address
  unchanged but looks a symbol up in the token list, so `@token:symbol(DAI)` is
  circular. The useful direction is address to symbol.
- **Four doc examples never compiled.** Three from one trap: plain helpers need their
  module prefix, and only the `!` faces resolve unqualified after a `load`. So
  `@math:sqrt(1e18)` works and `@sqrt(1e18)` does not, while `@sqrt!(...)` on the line
  above does.

### Things that turned out not to be true

- **`@bool!(> 0 and < 100)` does not work, and multi-window will not fix it.** The
  element is prepended once, so `evaluateTokens` throws `Missing operand for 'and'`;
  and even parsed it is `bitAnd(gt(e,0), lt(e,100))`, three Operators calls where a
  template hosts one. It needs B1 + B2 + C together, and even then costs ~4 staticcalls
  per element against 2 for `@all!(a @bool!(> 0)) and @all!(a @bool!(< 100))`. The
  decomposed form should stay the documented default.
- **Signed sorting is already expressible**, at three nodes: `@map!` xor the sign bit,
  `@sort!`, `@map!` back. Flipping the top bit maps signed order onto unsigned order
  exactly and, unlike adding 2^255, cannot overflow a checked add. So Operators should
  NOT grow a signed `sortWords` — it fails the first admission test, and the second and
  third are about hot loops it does not touch.
- **The multi-live-part technique already shipped.** `enumerateParam` splices two live
  values by computing the second offset as a live `add`. A3a generalized what was
  already there rather than inventing anything.

### One property behind three findings

`InputParam` is a **tree, not a DAG**: there is no way to name a subterm, so a repeated
operand is duplicated in calldata AND re-resolved at judge time, source calls included.

- `rpow`'s 2^k copies — the impossibility face, already in the doctrine.
- `@includes!`'s ~10-element crossover — `wordIndexOf` names the payload twice, so the
  fold stays cheaper on short arrays. Hence two paths, not one.
- `spliceLayout`'s N(N-1)/2 redundant resolutions — the reason for the hard cap of 4.

The other session has queued the doctrine edit that states this generally.

### B1, as landed

- `LambdaTemplate` now carries its `target`. The fast path is unchanged bytes: a
  predicate reducing to one Operators call with all-`RAW_BYTES` segments flattens to
  direct Operators calldata. Anything else keeps the WHOLE `read(...)` calldata as the
  template and targets the core — `Assertions.read` raw-returns (`return(add(result,
  32), mload(result))`, verified), so the first return word is still the value.
  `foldParam` / `applyWordsParam` take the target as a parameter, in the contract's own
  argument order (`s, target, template, …`).
- **The element window need not sit in a top-level `RAW_BYTES` segment.** In a
  composed lambda like `@num!(* 2 + 1)` the marker lands inside a NESTED read's
  encoded calldata, two decodes deep — and substitution still works, because
  InputParams are literal bytes in calldata and overwriting 32 bytes shifts no offsets.
  B2's `@it!` therefore composes anywhere a word operand goes.
- `@reduce!` keeps its restriction on purpose: its lambda carries an ACCUMULATOR
  window, which only the fixed binary-reducer table provides. Its note never said
  "single Operators call" and did not change.

### C, as landed (`504d59d` / `ee3c94e`)

- Contract + SDK selectors/layouts moved together; N=1 callers pass a one-element
  array. Fold engine uses a `FoldRun` memory struct to stay under the stack limit
  without enabling `viaIR` (bytecode-sensitive profiles stay as they were).
- Size +618 B (17,042 / 7,534 headroom). Vanity re-mine not run; zero salt remains.
- Realistic-B1 composed fold measured (20,914 gas / 3 elems on the 964-byte fixture).
- Doctrine doc sentence about "single accumulator window" left for the other session.

### B2, as landed (`2445ed9` / `dd80f75` + `fe250e1`)

- **`@it!`** is an on-chain-only lang helper compiling to
  `elementOperand(ctx.lambdaElemCat)`. `CompileCtx` now carries optional
  `lambdaElemCat`, set/restored by `compileLambdaTemplate`. Outside a lambda it
  errors.
- **Multi-marker extraction is live.** `extractLambdaTemplate` collects every
  aligned marker into ascending `elemOffsets` and zeros them all.
  `LambdaTemplate.elemOffset` is gone; callers pass `tpl.elemOffsets` (folds park
  `accOffset` on `elemOffsets[0]`).
- **Prepend kept, not suppressed.** `@num!(* @it!)` is `mul(elem, elem)` — naming
  the element twice in source is the point of `@it!`. Suppressing the prepend when
  the body mentions `@it!` would force the uglier `@num!(@it! * @it!)` for the same
  shape and break the partial-application convention. With multi-window extraction
  both windows are valid.
- **Nested outer-capture stays a safe rejection.** A precompiled outer-element
  marker smuggled into an inner lambda's AST is rejected before compile (same global
  marker would stamp the wrong binder). No per-binder markers. Ordinary `@it!` inside
  an inner lambda binds to the inner element via scoped `lambdaElemCat`.
- Decoder-level unit tests stamp a sentinel at every offset; lang wave-5 covers
  `@map!(… @num!(* @it!))` → `[4n, 36n]`; Solidity
  `test_mapWords_coreTargetTemplate_multiWindowSquare` executes the square through
  the core with offsets found by scanning.

### B1 review, as landed (`6bfbd56` / `167dd90` + `2c7a87a`)

- **Word-category guard.** Nothing had checked that a lambda's result is a single
  word: `map.ts` ignores `tpl.operand.cat` and the predicate faces only check `Bool`.
  A bytes/string-returning lambda's first return word is its ABI offset (0x20) — a
  silent wrong answer, widened by B1's bigger funnel. `extractLambdaTemplate` now
  rejects `Bytes`/`String` categories before any shape inspection, protecting every
  caller through the one funnel. No EVML-expressible lambda currently reaches it
  (the faces' own arg lenses reject the word element first, with better messages) —
  the same below-the-lens pattern as the guard recorded under Testing; coverage is a
  unit test.
- **The composed rule is now target-agnostic.** The reviewer was right that
  core-read-only was an artificial restriction: the operand's `staticCallParam`
  already carries the exact `(target, calldata)` its fetcher would call, and
  `_fold`/`_applyWords` rewrite a window at any offset of any template for any
  target. Any single staticcall whose calldata carries the marker is now a lambda
  (B2: at least once; B1r required exactly once), its pair kept verbatim.
- **The `wordsArg` signedness wart, recorded not fixed.** The nested-face path in
  `packages/sdk/src/onchain/arrays.ts` returns `elemType: "uint256"` unconditionally,
  so faces nested over an `int256[]` (e.g. `@all!` over a `@map!` of one) lose
  signedness. Adjacent to the A1 bug class; the direct (non-nested) path threads the
  real element type.
- **Core-target security, reasoned through, no action.** Pointing a lambda at the core
  grants no new capability — every composed shape was already expressible as a
  top-level operand; the fold just repeats it N times, inside a view-only staticcall
  tree bounded by call depth (1024) and the 63/64 gas rule.
- **Inline constraints would drop silently; a defensive assert is owed.**
  `extractLambdaTemplate` never inspects `o.param.constraints` — a lambda operand
  carrying them would lose them without an error, since the fold calls the target
  directly and nothing resolves the InputParam. No current path attaches constraints
  mid-expression, so this is one assert, not a bug.

### Testing

- **A lambda template's window is checked by substitution, not arithmetic.** The B1
  tests write a sentinel word at `elemOffset`, hand the template to a real ABI
  decoder, and assert the sentinel surfaces exactly on the element segment (through
  both decode layers in the nested case). The fold/map literal is parsed by the head
  words IT carries — `offset_template` locates the tail — so nothing re-derives the
  layout. (`packages/sdk/test/unit/lambda-template.test.ts`, onchain.test.ts wave 5.)
- **Every on-chain test re-derived offsets with the compiler's own formula**, and
  nothing in the suite executes the EVM — so a shared misconception passed both sides.
  `packages/sdk/test/unit/splice-layout.test.ts` resolves the operand tree the way the
  chain would and hands the result to a real ABI decoder.
- **The core-target fold now executes on a real EVM.** The B1 decoder-level tests had
  the same geometry gap: no test anywhere ran `foldWords`/`mapWords`/`filterWords`
  with `target = core` and full `read(...)` calldata. `contracts/tests/
  CoreTargetLambda.t.sol` (main repo, `167dd90`) executes fold, map and filter through
  the core with marker offsets found by SCANNING the encoded bytes (never recomputed
  from the layout), windows one and two ABI layers deep, a pick template, and an
  SDK-compiled 964-byte fixture run byte-for-byte at `vm.etch`ed addresses — which
  also pins viem's encoding to `abi.encodeCall`'s, byte for byte. B2 adds
  `test_mapWords_coreTargetTemplate_multiWindowSquare` for N=2 markers.
- **It has teeth, checked deliberately.** Deleting the `ceil32` rounding failed exactly
  1/1, 31/33, 33/31 and the three-part case while every 32-aligned length still passed
  — because every existing fixture happens to be word-aligned. Without that test the
  rounding could have been dropped with the suite green.
- **An ordering comparison over an `Int` operand does not ride a constraint.** ERC-8211
  inline constraints are unsigned, so it lowers to `le(int256,int256)` judged `Eq 1`.
  Tests must assert the op-judge shape.
- **One guard is unreachable from EVML.** A live value with no derivable size must come
  last, but the value lens rejects dynamic-element arrays first, with a better message.
  Its coverage lives in a unit test; the guard stays for callers below the lens.

---

## Hazards

### The pin will eat uncommitted work

`website/package.json`'s `evmcrispr.commit` must equal checkout HEAD. When it does not,
`website/scripts/vendor-evmcrispr.mjs` runs `git checkout -qf --detach <pin>` on
pre-dev/pre-build, and `-f` discards every uncommitted change in the checkout.

Currently masked: `operators-1.0` is unpushed, so the `git fetch` fails first and the
build merely errors. **The mask disappears the moment the branch is pushed.**

Verify a SHA resolves before writing it:
`git -C website/.evmcrispr cat-file -e <sha>`. A plausible-looking full-length SHA (a
short hash padded out, for instance) points the vendor script at nothing.

Two more edges of the same trip, verified in `vendor-evmcrispr.mjs`:

- **A post-push trip leaves the checkout on a DETACHED HEAD** at the pin
  (`git checkout -qf --detach <pin>`, line 58). The next `git commit` in the checkout
  then lands off-branch silently — no error, just a commit no branch points to. After
  any vendor-script run, check `git -C website/.evmcrispr status` says
  `On branch operators-1.0` before committing.
- **A trip also reruns `bun install` and `turbo run codegen`** (lines 61–72),
  rewriting every module's `src/_generated.ts` under whichever session is working.
  Codegen output is not committed, so this is silent churn rather than data loss, but
  it can invalidate a session's in-flight expectations mid-edit.

### TODO.md itself is unprotected

This file is untracked (`?? TODO.md` in `git status`) — no clobber protection, no
history, and `git stash -u` or a `clean -fd` would take it. Both sessions edit it.
Copy it aside before risky tree operations; consider it the one file a `git` command
cannot bring back.

### Two sessions, one working tree

- The husky pre-commit hook runs lint-staged, which **stashes the whole working tree**,
  so either session's commit puts the other's uncommitted work through a stash cycle.
  Use `git commit --only <paths> --no-verify` and run the checks by hand while
  overlapping.
- **Never `git checkout` / `restore` / `stash` a path carrying another session's
  uncommitted edits.** `checkout -- <path>` restores from the index and cannot separate
  two authors: it discards both, unrecoverably, since working-tree-only edits never
  reach the object store. Commit and rebase, or `git diff -- <path> > patch` first.
  This cost 37 lines of test code once already.

---

## Corrections made along the way

Recorded because each was believed and acted on before being caught.

- Claimed the signed-sort recipe "is written nowhere" and removed a working pointer to
  it. A case-sensitive grep for `signed` missed `Signed recipe:` in `sort.md`. Restored
  in A0.
- Wrote a pin by padding the short hash `4d17877` into a full-length SHA. Caught on the
  next line; verification now precedes the write.
- Asserted a computed offset base of 192 in a test; the compiler said 160 and was right.
  These tests assert decoded structure, not re-derived numbers, for this reason.
- Tabled the absorbing accumulator without regard to signedness, so the guard rejected
  a legitimate signed `min 0`. Nothing is below 0 in unsigned order, but in signed
  order only the most negative word absorbs.
- The gate line said "SDK unit 57"; `bun test ./test/unit` in `packages/sdk` ran 169
  tests at `95559c6` (177 after B1's 8 new ones, 178 after the B1 review). The 57
  matched nothing reproducible — the module gates are the `test:integration` counts
  and were all exact, so only this figure was off. Recorded as measured now; the full
  counting basis for every gate is now written under Landed.
- The B1 report claimed a composed lambda costs "roughly 9x per element by the
  doctrine's own measurements". The doctrine's measurements (`OperatorsGas.t.sol`)
  say ~5x (bitSet) and ~3x (Merkle step); 9x was the a-priori argument those
  measurements CORRECTED. Stated the wrong number with the confidence of the right
  provenance — the correction and the re-measure caveat now live in the C section.
