# AGENTS.md

What an agent needs to know to work in this repo without relearning it the hard way.
Learnings only: no status, no task lists. When something here stops being true,
fix it in the same change that falsified it.

## The two trees

- **Main repo**: `contracts/` (the frozen `Assertions` core, the versionable
  `Operations` periphery, `Collections`, `Expressions`, `AbiCodec`, `ERC8211`), Solidity tests under
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
  (ERC-8211 `InputParam`s) lives on the frozen core. Scalar computation over resolved
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
- **Wire-format purity**: the judge consumes unmodified ERC-8211. Extending the
  constraint enum was refused because a batch carrying an extension value reverts
  on every other executor and squats on wire space a future revision could
  redefine. Portability breaks are one-way doors; refuse them.
- **Raw `InputParam` is a tree; `Expressions` adds a graph alternative.**
  Raw operands cannot name subterms: repeated expressions duplicate calldata and
  resolution. Prefer resolver `resolveArguments` / `resolveValues` for dynamic ABI
  construction: each supplied input resolves once, with no four-live-input cap.
  Repeated input entries are still independent; graph references share evaluated
  nodes. Graphs bind whole canonical ABI values, support lazy branches and guarded
  evaluation, and memoize per evaluation (per callback invocation in Collections),
  not across collection iterations. Keep word-window folds for efficient word-only
  workloads; a 32-byte overwrite changes no dynamic ABI offsets. Specialized math
  such as `rpow` still avoids an impractically large composed expression.
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
  not defended against.
- **No wrong-answer machines**: silent truncation is always a bug
  (`UnalignedWords`, `WordCountMismatch` exist for this). At the raw Solidity boundary,
  splicing an ARRAY return directly into `hash`/`byteLen` silently digests N bytes
  of an N-element payload: its length word counts elements. The SDK now rejects
  non-string/non-bytes operands through `requireBytesLike`; the builder mirrors
  that guard. `hash(rawCall(...))` is the raw whole-returndata spelling.
- **Errors identify the operand** (entry index, param index, hop index, binding
  index). Constraints judge only the first 32-byte word, unsigned, per the
  standard: anything richer (signedness, `!=`, string equality, tolerance) lowers
  to an Operations expression judged `EQ 1`, and tests must assert that op-judge
  shape.
- **Operations admission**: a new function must not be expressible as a few-node
  recipe at practical cost. Signed `sortWords` was refused (flip the sign bit,
  sort, flip back); generic comparator sorting lives in Collections (sorting is not a reduction);
  `join` is composition over `concat`. What earns a slot: hot loops (one call per
  element otherwise) and calldata-exponential compositions (`rpow`, `log2`).
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
  root `bun run validate-docs`.
- Record measured numbers with the command that produced them; never state an
  a-priori estimate with a measurement's confidence (gas multipliers have been
  misquoted exactly this way).
- Before claiming something is absent, search for it case-insensitively; a
  working pointer was once deleted on the strength of a case-sensitive grep.

## Release

- Canonical vanity salts live in `website/scripts/export-deploy-artifact.mjs`.
  The zero salt in Ignition is not the canonical deployment path. Contract source
  changes (including comments in compiler metadata) may change CREATE2 addresses;
  regenerate and verify deployment artifacts, fixtures and SDK addresses together.
- Bytecode size: `(len(deployedBytecode) - 2) / 2` against 24,576, per artifact.
  Operations must stay byte-identical through core-only changes; any drift there is
  a red flag.

- When running tests in a restricted sandbox, verify the nodejs test count: a
  sandboxed run has reported success with zero fuzz tests. Run outside that
  environment before treating the fuzz suites as passed.

- Format production Solidity consistently with `forge fmt contracts/AbiCodec.sol contracts/Assertions.sol contracts/Collections.sol contracts/ERC8211.sol contracts/Expressions.sol contracts/Operations.sol`; use `--check` to verify. Public NatSpec describes rounding and rejection behavior; implementation helpers document caller preconditions.
