# Public word layouts

This package targets `iotaWords`, `reverseWords`, `zipWords` and `unzipWords` at
the decoded ABI source boundary. Coverage is added only after retained native,
audit, dependency, EVM and semantic source-fault evidence passes.

Independent `Model.Values` describes the full-width index sequence, reversal,
interleaving and lane extraction over arbitrary finite inputs. Zip checks left
alignment before right alignment and count equality; unzip checks alignment
before lane 0/1 admission. Odd counts place the final word in lane zero. Empty
and duplicate words retain their exact positional semantics.

`generate.py` structurally gates all four complete compiler ASTs, including fixed
word slices, store values, helper arguments and increments. It extracts checked
allocation arithmetic, admission/loop controls, lane-count expressions, iota
values and actual inline-assembly addresses into `Control.generated.dfy` from
`Control.template.dfy`. Do not hand-edit generated files.

`Source` follows these controls and proves every loop index/slice bound. Iota's
`n * 32` and zip's `a.length * 2` report exactly `Panic(0x11)` on checked overflow.
`Memory` proves generated modular add/mul/sub addresses equal the intended
bounded physical destinations. Its store bridge applies the actual retained
`_setWord` store/frame theorem to the identical memory-store semantics. All
successful writes preserve the output header and outside memory.

`Connection.Reconstruction` proves any aligned physical byte payload equals the
concatenation of its decoded word encodings. `Connection.Run` applies all four
source methods, establishes exact outcomes and physical bytes, and exposes every
specified position without restricting word widths or input lengths.

The conditional allocation premise applies only after admission and checked
size multiplication succeeds: faithful successful zero-filled compiler allocation
in finite memory and sufficient execution resources. Compiler allocation guards,
`Panic(0x41)` and resource/OOG outcomes remain outside this theorem. The concrete
fixture `iotaWords(2^59)` observes `Panic(0x41)` separately; it does not establish a
formal allocator threshold or gas claim. Other premises are decoded ABI, faithful
source/compiler/calldata/context/memory/allocator and outer ABI return/error
projections, trusted EVM load/store interpretation and Dafny/Boogie/Z3.

`verify.py` snapshots/hashes all inputs, regenerates controls, checks complete
retained dependency hashes and native/declaration evidence, verifies all local
native declarations, audits escapes and checks format. Ten EVM fixtures cover
layouts, empty/full-width/duplicate/odd-lane geometry, exact admission errors,
checked multiplication and the separate allocator observation. Four semantic
source mutations shift iota values, misplace reverse or zip stores, or lose the
odd lane word. Each must translate and fail both a recorded semantic assertion
covered by the full fresh native baseline and the real EVM fixtures. Timeouts
never count as mutation evidence. Exact compiled bytecode, gas, deployment and
performance verification remain separate.
