# Least word index and checked sum

This package targets the public `wordIndexOf` and `sumWords` bodies at the decoded
ABI boundary. No coverage is added before retained evidence passes.

Independent `Model.Find` specifies the first matching word or the complete word
count sentinel. `FindFacts` proves no earlier word matches. `Model.Total` specifies
checked addition and the first overflow; `TotalFacts` proves that success equals
the unbounded mathematical sum if and only if that sum is below 2^256. Nonnegative
words ensure a prefix overflows exactly when the final mathematical sum does.
Overflow emits exactly `Panic(0x11)`. Alignment rejects before any element read.

`generate.py` gates both complete public compiler ASTs and every word-slice AST.
It lowers alignment, count, loop, word equality and checked-addition expressions
into `Control.generated.dfy` from `Control.template.dfy`. Do not edit generated
files. Word-slice geometry remains structurally fixed even when equality or the
summand changes in a semantic mutation.

`Source` follows those controls. It proves every 32-byte slice, count/index
increment and unsigned-word bound, and preserves the independent recursive
specification as a loop invariant. `Connection.Index` derives least-match and
sentinel properties; `Connection.SumWords` derives exact mathematical total or
overflow and successful uint256 width.

Source-translation premises are explicit: decoded ABI uint256/finite bytes fields,
faithful compiler/calldata word-slice and checked-arithmetic interpretation,
adequate local execution resources, outer ABI return/error serialization and
Dafny/Boogie/Z3. These bodies allocate no output memory or invoke external targets.
Malformed external ABI, exact compiled bytecode, gas/deployment/performance and
allocator behavior of other operations are outside this package.

`verify.py` finishes with input snapshots/hashes, generated-source equality,
complete retained dependency checks, fresh native verification and escape audit,
format gates, six real EVM fixtures and two isolated semantic source mutations.
Fixtures cover exact alignment errors, empty results, least duplicate/full-width
matches, count sentinels, maximum successful sum and exact overflow panic bytes.
Inverted comparison and an extra unit per summand must translate successfully and
fail both native semantics and the EVM; timeout never counts as fault detection.
