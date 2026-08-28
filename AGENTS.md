# AGENTS.md

What an agent needs to know to work in this repo without relearning it the hard way.
Learnings only: no status, no task lists. When something here stops being true,
fix it in the same change that falsified it.

## The two trees

- **Main repo**: `contracts/` (the frozen `Assertions` core, the versionable
  `Operators` periphery, `AbiShape`, `ERC8211`), Solidity tests under
  `contracts/tests/*.t.sol` run by `pnpm test` (hardhat 3), and the Astro site in
  `website/` with hand-written docs at `website/src/content/docs/docs/`.
- **Vendored checkout**: `website/.evmcrispr` is the EVMcrispr monorepo on branch
  `next`, pinned by `evmcrispr.commit` in `website/package.json`. The EVML
  language, SDK compiler, helper faces and parity harness all live there, not in
  `website/src`.
- Two sessions may share either tree at once. Never `checkout`/`restore`/`stash` a
  path carrying another session's uncommitted edits: working-tree-only edits never
  reach the object store, so that discard is unrecoverable. The husky pre-commit
  stashes the whole tree through lint-staged; while overlapping, use
  `git commit --only <paths> --no-verify` and run the checks by hand.

## Design doctrine

- **The core's admission test**: only what needs operands to arrive UNRESOLVED
  (ERC-8211 `InputParam`s) lives on the frozen core. Computation over resolved
  values belongs to Operators, which versions by deploying at new addresses. When
  a capability is requested, first check whether composition already expresses it:
  `hash(rawCall(target, data))` made both a `hashOf` primitive and a `HASH_EQ`
  constraint type unnecessary.
- **Wire-format purity**: the judge consumes unmodified ERC-8211. Extending the
  constraint enum was refused because a batch carrying an extension value reverts
  on every other executor and squats on wire space a future revision could
  redefine. Portability breaks are one-way doors; refuse them.
- **`InputParam` is a tree, not a DAG**: there is no way to name a subterm, so a
  repeated operand duplicates calldata AND re-resolves at judge time. This is why
  `rpow` exists as a function (the composed form is 2^k copies), why `@includes!`
  keeps two compile paths, and why splice layouts cap their live parts. Word-sized
  reuse has a workaround: fold templates overwrite 32-byte windows, and a 32-byte
  overwrite shifts no ABI offsets, so a window works at any nesting depth inside
  encoded calldata.
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
  (`UnalignedWords`, `WordCountMismatch` exist for this). The known live footgun:
  splicing an ARRAY return directly into `hash`/`byteLen` compiles and silently
  digests N bytes of an N-element payload, because an array envelope's length word
  counts elements. `hash(rawCall(...))` is the correct whole-returndata spelling;
  the SDK-side refusal/rewrite of the bare splice is still unbuilt.
- **Errors identify the operand** (entry index, param index, hop index, binding
  index). Constraints judge only the first 32-byte word, unsigned, per the
  standard: anything richer (signedness, `!=`, string equality, tolerance) lowers
  to an Operators expression judged `EQ 1`, and tests must assert that op-judge
  shape.
- **Operators admission**: a new function must not be expressible as a few-node
  recipe at practical cost. Signed `sortWords` was refused (flip the sign bit,
  sort, flip back); a sort comparator was refused (sorting is not a reduction);
  `join` is composition over `concat`. What earns a slot: hot loops (one call per
  element otherwise) and calldata-exponential compositions (`rpow`, `log2`).
- **Signedness is a dimension in every word-level design.** Unsigned order and
  signed order disagree about which value absorbs, which element is minimal, and
  how a two's-complement word reads. One SDK path returning `elemType: "uint256"`
  unconditionally produced wrong answers over `int256[]` once already.

## The vendored checkout: how work lands

The landing order matters and is enforced by the vendor script's behavior:

1. Verify the checkout is on `next` and clean (`git -C website/.evmcrispr status -sb`).
2. Work, test, commit on `next`. Then **push** `origin/next`: the vendor script
   fetches the pinned SHA with `--depth 1`, so an unpushed pin is a broken pin.
3. Bump `evmcrispr.commit` in `website/package.json` to the pushed SHA. Verify the
   SHA resolves before writing it: `git -C website/.evmcrispr cat-file -e <sha>`.
4. `node website/scripts/vendor-evmcrispr.mjs` must print `ready` with NO
   fetch/checkout line. Commit the bump in the main repo.

Why the ceremony: whenever pin ≠ checkout HEAD, any `pnpm dev`/`pnpm build` in
`website/` runs `git checkout -qf --detach <pin>`, which discards every
uncommitted checkout change, leaves the checkout on a detached HEAD (the next
commit lands on no branch, silently), and reruns `bun install` + `turbo run
codegen` under you. The pin has also been ORPHANED once (a history rewrite left
the pinned SHA on no branch), which makes the trip destructive even with a clean
tree.

- **Contract bytecode changed → regenerate the fixture**: `pnpm compile` in the
  main repo, then `bun scripts/sync-assertions-bytecode.ts` in the checkout. The
  `ASSERTIONS_RUNTIME_HASH` staleness comparison described in that file is an
  intention, not a live gate: nothing in either repo checks it, so a stale
  fixture silently runs every parity case against the OLD core.
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
  a ledger, not decoration: one user-visible sentence, no Operators internals, no
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

- Both contracts sit on interim zero salts. Before any canonical deploy, re-mine
  the vanity salts (`website/scripts/mine-salt.mjs`, then update
  `hardhat.config.ts` and regenerate `website/src/lib/verification-inputs.ts`).
- Bytecode size: `(len(deployedBytecode) - 2) / 2` against 24,576, per artifact.
  Operators must stay byte-identical through core-only changes; any drift there is
  a red flag.
