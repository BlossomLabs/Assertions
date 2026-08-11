# Batch-as-operand: document the recovered wrapped judge

**Date:** 2026-08-11
**Status:** Approved
**Scope:** Documentation and one proving test. No Solidity surface changes, no salt re-mine, no SDK/EVMcrispr work.

## Background

The first ERC-8211 rewrite (`50f5615`) shipped a wrapped judge,
`assertComposable(address composable, ComposableExecution[] executions)`: a literal
staticcall to a deployed implementation's `executeComposable`, asserting "this account
would accept this batch right now" (the relayer's eth_call gate, on-chain). It was
removed in `900b5bc` as unused, and because its trust story never fit the frozen core.

The capability never actually left. `assertComposable` is a view function, so a whole
batch encodes into a STATIC_CALL operand pointed back at the core, and the resolution
control trio (`isValid`, `orElse`, `revertData`) turns that operand into a probe family
strictly richer than the original hard-assert-only mode. The same shape pointed at a
deployed `IComposableExecution` recovers the wrapped judge as composition. The decision
(this session) is to document the pattern rather than reinstate any surface.

## Deliverables

### 1. New section in `website/src/content/docs/docs/core/control.md`

Placed after the `revertData` section, titled "A batch as an operand" (final wording at
implementation time). Content:

- The self-call form: `callParam(address(assertions), abi.encodeCall(assertComposable,
  (executions)), noConstraints())` makes an entire ERC-8211 batch one operand. Then:
  - `isValid(batchProbe)` reads "would this batch pass, right now" as a 0/1 word
    (branch on it with `cond`, constrain it EQ 1 or EQ 0);
  - `orElse(batchProbe, fallback)` selects a fallback value when the batch would not hold;
  - `revertData(batchProbe, ConstraintFailed.selector)` asserts the batch fails for
    exactly a constraint, not for an unrelated reason.
- The wrapped form: the same operand shape pointed at a deployed
  `IComposableExecution.executeComposable`, recovering the v2.0-day-one wrapped judge
  ("this account would accept this batch right now"). Two caveats stated inline:
  - a staticcall boundary only passes state-neutral batches, so a 0 from `isValid`
    conflates "constraints fail" with "batch writes state";
  - real accounts may gate `executeComposable` by sender, so a rejection can be
    authorization rather than constraints; `revertData` with a selector is how the two
    are told apart.
- The existing OOG/63-64 caveat paragraph already on the page covers the probes; the new
  section must not duplicate it, at most reference it.

### 2. Cross-references

- One sentence in `website/src/content/docs/docs/solidity.md`, in the
  `assertComposable` paragraph (around line 203), linking to the new section: the judge
  is also an operand.
- The `assertComposable` row in `website/src/content/docs/docs/reference/core.md`
  gains the same link.

### 3. Proving test in `contracts/tests/Assertions.t.sol`

Self-call form only (needs no new mock):

- `isValid` over a STATIC_CALL operand encoding `assertComposable(executions)`:
  returns 1 for a passing batch, 0 for a batch with a violated constraint;
- `revertData(batchProbe, ConstraintFailed.selector)` succeeds on the failing batch
  (and the stripped return data decodes as ConstraintFailed's arguments).

The test pins the doc's central claim so it cannot rot. Follow the existing test file's
helper conventions (`callParam`, `eq`, `noConstraints`).

## Out of scope

- Reinstating `assertComposable(address, executions)` in Solidity (fails the core's
  admission test: executions arrive fully formed, nothing is lazily resolved).
- Carrying inner revert data in `CallFailed` (judged exotic; not wanted).
- An EVML helper face for the pattern (may come later if the pattern earns it).
- Testing the wrapped form against a mock `IComposableExecution` (the self-call test
  covers the mechanism; the wrapped form differs only in target).

## Risks

- Docs claims drifting from contract behavior: mitigated by deliverable 3.
- Website copy rules: no em dashes in any prose added (repo convention).
