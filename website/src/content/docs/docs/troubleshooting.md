---
title: Troubleshooting
description: "What to do when an assertion fails or behaves unexpectedly: reading the revert, the common errors, and mistakes to avoid."
---

An assertion that reverts is doing its job. The question is whether it reverted for the reason you expect. This page helps you read the failure, find the cause and fix it.

## Reading a failed assertion

A violated condition reverts with `ConstraintFailed`. In the builder's simulation it appears as the error text. In a block explorer or a Safe interface it appears as decoded revert data. It carries seven fields:

| Field | What it tells you |
|-------|-------------------|
| `assertion` | The message you wrote after the condition. Empty if the failing check sits inside another assertion's operand rather than at the top. |
| `entryIndex` | Which entry of the batch the check belongs to. It is 0 for a plain `assertParam`. |
| `paramIndex` | Which operand inside the entry. For a read built from other reads, this is the operand's position in that read. |
| `constraintIndex` | Which constraint on that operand failed. Constraint `i` judges word `i` of the value. |
| `constraintType` | The kind of check that failed: `EQ`, `GTE`, `LTE`, `IN`, their signed forms, `OR` or `SKIP`. |
| `actual` | The value that was read, as a 32-byte word. This is the number to look at first. |
| `referenceData` | The limit you set, echoed as given. |

Compare `actual` with `referenceData` and you know by how much the check failed. If the value looks wrong rather than too low, suspect the read before the limit: see [Common mistakes](#common-mistakes). To read the same calldata in a batch you are about to sign, see [Reviewing an assertion](/docs/reviewing).

## Common failures

| What you see | What it means | What to do |
|--------------|---------------|------------|
| `ConstraintFailed` | The value was read and judged, and it did not satisfy the condition. | Compare `actual` with `referenceData`. If the condition is right, the batch is correctly stopped. If not, fix the limit or the read. |
| `CallFailed(target, data)` | The call the assertion makes reverted, or the target has no code at that address. | Check the address on the chain you are running on, and that the function exists there. See [the contract reference](/docs/contracts/assertions). |
| `ReturnDataOutOfBounds(index, length)` | The data read is shorter than the check needs: a function returned fewer than 32 bytes, or a word index lies outside the data. | Check the declared return type has the right number of values, and the word you pick exists. |
| `InvalidAddressWord(index, word)` | A value used as an address has nonzero upper bytes, so it is not an address. | You are probably reading the wrong word, or declared an `address` where the function returns something else. Check the signature in [EVML](/docs/evml). |
| `InvalidValue(offset)` | The returned data is not a valid encoding of the type you declared, for example a number above 255 read as `uint8`. | Correct the declared return type to match the function. |
| `InvalidTypeDescriptor(position)` | The type written in the signature cannot be parsed, such as a malformed array or tuple. | Fix the type at the position given. |
| `SubcallOutOfGas()` | A read failed after using all the gas it was given. The contracts refuse to treat that as an ordinary failure, so a fallback or an "is this read valid" check cannot pass because gas ran out. | Raise the gas limit of the transaction and run again. See [the gas caveat](/docs/contracts/assertions#the-staticcall-boundary-and-the-oog-caveat). |
| `EmptyNeedle()` | A text `replace` or `split` was given an empty search string. | Give a non-empty string. Searching with `indexOf` or `contains` is not affected. |
| `Panic(0x11)` | Arithmetic overflowed or underflowed, or a parsed number does not fit its type. | Check the operands, or reorder the arithmetic. Combined multiply-and-divide is safer than a bare product, see [Operations](/docs/contracts/operations). |
| `Panic(0x12)` | Division or modulo by zero. | Check the divisor can never be zero, or assert that first. |

Some malformed inputs revert with no data at all. If you wrote the call by hand, compare it with what the builder or EVML produces.

## Common mistakes

- **Wrong signedness.** A value declared `int256` compares signed, and a `uint256` compares unsigned. A negative number judged as unsigned reads as huge and positive. Declare the type the function returns, as in `assert $oracle::!{drift()(int256)} <= -5 "drifted"`. See [EVML](/docs/evml).
- **Wrong word of a multi-value return.** A function returning several values needs a lens to pick one. Check the position:

  ```evml
  assert $pool::!{poolInfo()(uint112,uint112,address)}[_ $ _] > 0 "reserve1 empty"
  ```

  Picking the wrong word can pass trivially, see check 5 in [Reviewing an assertion](/docs/reviewing).
- **A precondition placed after the action.** An assertion judges the state at the point where it runs. See [placement](/docs/guides/executors#placement).
- **A captured value in a delayed proposal.** A value captured when the script is built is fixed at that moment. If the batch executes a week later, the number may be stale. Prefer an absolute limit or a live calculation. See [Assert that something changed](/docs/evml#assert-that-something-changed).
- **A read on an address with no code on the target chain.** The same address can hold a contract on one chain and nothing on another. A read of it reverts with `CallFailed`. Check the address on the chain you execute on.
- **A chain without the contracts.** Assertions only work where the four contracts are deployed. Check your chain on [Deployments](/docs/contracts/deployments).
- **Not checking the executor's behavior.** An executor that tolerates failed calls can keep the earlier actions. See [Executors](/docs/guides/executors).

## Next

- [Test an assertion](/docs/test-an-assertion): make a check fail on purpose before you rely on it.
- [Errors](/docs/contracts/errors): every error the contracts raise, with its arguments.
