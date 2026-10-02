# Public word folds

This package composes the complete `_fold` engine and `foldRange`, `foldBytes`,
`foldWords` wrappers with the retained concrete word fold loop. Compiler-derived
selectors bind callback errors to the correct public operation. The generated
wrapper adapter fixes Range's empty subject and translates domain/count arguments.

`Model.Judge` independently specifies the complete order:

1. Reject non-word-aligned input for `foldWords`.
2. Validate accumulator and every element window, returning the exact first error.
3. Return the initial word for an empty domain without inspecting the target.
4. Check target code once and propagate its exact error.
5. Execute the proved loop with concrete stamping, full-history callbacks,
   accumulator feedback and first Full/Any/All failure or stopping semantics.

`Ready.Static` derives loop bounds from decoded fields, public counts and
successful window admission. `Budget` does not assume acceptance: memory-copy and
callback resources are required only when the admitted, nonempty, code-present
branch actually reaches the loop. `NoLoopBudget` proves the other branches need
none of those loop resources. Range/count and byte-subject fields unused by a
particular wrapper are synthetic model fields with no runtime effect.

`Connection.Run` proves the exact outcome, first-failure semantics, reached
indices/calldata/answers, ordered target/call history, successful complete Full
consumption and first Any/All stopping. The retained loop's `RowAt` theorem also
exposes each accumulator/history link. Returned words preserve all 256 bits.

Scope is conditional source semantics at the decoded ABI boundary: valid enum and
uint/address fields; faithful source/compiler/context/bytes/copy/allocation/memory
and ABI return/error projections; sufficient reached-call packet and execution
resources; faithful history-sensitive staticcall/gas/code observations; and
Dafny/Boogie/Z3. Invalid external ABI decoding, exact compiled bytecode and
performance claims remain separate.

`verify.py` snapshots and hashes inputs, regenerates both adapters/selectors,
checks complete retained evidence, freshly verifies local declarations and audits
proof escapes. It replays six admission/selector EVM tests and eight loop tests.
Three source mutations invert alignment, change the byte-domain count or invert
the empty shortcut, and must fail both native verification and EVM tests.
