# Public word map/filter source composition

This package targets complete public `mapWords` and `filterWords` semantics at
the decoded ABI boundary. Coverage is added only after retained native proof,
audit, dependency closure, real EVM fixtures and source mutations pass.

`Model.Tail` is an independent recursive traversal over arbitrary finite aligned
word payloads with full-history-sensitive callback observations. Each reached
callback receives a fresh logical patch of the original template. Mapping emits
the callback word. Filtering emits the original element for canonical one,
skips zero and rejects other words. Callback failure precedes predicate checking.
Failure retains exact index, reason, history and rows without a successful output.

`Properties` proves reached-row bounds, full successful consumption, exact
callback history, consecutive indices and first failure. `Output` proves exact
selection membership, original-word preservation, strict selected-index order
and positional map results, including duplicate original words.

`Memory` composes actual repeated element stamping and output-word writes.
`Engine.Run` composes the source loop over disjoint persistent call/output frames,
refines `Tail` and establishes the exact successful physical output frame. The
actual filter-header write uses compiler-derived modular multiplication; its
no-wrap proof and memory lemma preserve payload and outside-header bytes.
`LoopConnection.Run/Facts` apply output and trace properties to this engine.

`EntryModel.Judge` independently specifies raw admission order:

1. Reject non-word-aligned input.
2. Validate every element window, including on empty input. Templates shorter
   than 32 bytes fail even with no offsets; otherwise the first invalid offset
   supplies the exact error.
3. Allocate zero-filled output bytes of the original subject length.
4. For nonempty input, check target code, copy the template and run the loop.
5. Shrink successful filter output, including the empty case.

`EntryReady.Static` derives loop bounds from alignment/window admission.
`Budget` requires output allocation only after admission, including empty and
code-less-target paths. Call-template copy, disjointness and callback budgets
are required only on the admitted nonempty positive-code branch. The two
`No*Budget` lemmas discharge unreached resource premises without assuming
acceptance. Allocation/copy are explicit compiler memory projections, not proved
allocator bytecode. Invalid external ABI decoding remains outside this boundary.

`Source.Run` follows compiler-derived controls and actual helper proofs.
`Connection.Run` composes exact outcomes, first failures, complete successful
consumption, map/filter output properties and physical output. `Connection.RowAt`
exposes every history/answer link and the absence of failures before the final
reached row.

`generate.py` gates the complete `_applyWords`, `mapWords` and `filterWords` ASTs
against `structure.json`. It derives controls and public/error selectors from
the compiler and generates `Control.generated.dfy` from `Control.template.dfy`.
Never hand-edit generated files or weaken the structural gate to admit a fault.

`verify.py` snapshots/hashes the complete input closure, regenerates controls,
checks retained dependency source/tool/artifact/native/declaration evidence,
freshly verifies all local declarations, audits proof escapes and checks format.
Fourteen real EVM fixtures cover admission priority, empty/target behavior,
full-width map positions, stable duplicate filter output, all/none selection,
noncanonical/short/failed callbacks with exact operation/index errors, no-offset
and unaligned/overlapping/duplicate-window geometry. Four isolated mutations
invert alignment or filter selection, emit original words from map, or halve
the filter output length. Each must pass translation and fail native semantics
and EVM fixtures; timeout is not mutation evidence. The mutation runner records
the selected source-adapter assertion and verifies it with `--filter-position`;
each selected assertion is included in the complete fresh baseline proof.

Scope remains conditional source semantics: decoded ABI, faithful source/compiler/
context/memory/allocation/copy/serialization projections, sufficient reached
execution/error-packet resources, faithful full-history code/staticcall/gas
observations, and Dafny/Boogie/Z3. Exact compiled bytecode, gas, deployment and
performance verification are separate tracks. Initial development logs and
hashes under `development/` are not completed public-source evidence.
