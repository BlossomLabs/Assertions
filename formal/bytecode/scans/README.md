# Exact word scan runtime semantics — development

Collections.sumWords(bytes) and Collections.wordIndexOf(bytes,bytes32) are the
next exact-bytecode targets. Their completed conditional source proofs remain
separate. **No public bytecode coverage is counted by this directory yet.**

The current sumWords certificates execute the actual pinned Collections runtime:
PC zero, wrapper PC 585, bytes decoder 0x53f1 and its subdecoder, body 0x0acf,
loop 0x0b0c, reached checked arithmetic/slice/read helpers, physical RETURN or
UnalignedWords/Panic(0x11) REVERT. Source maps only helped locate instructions;
no compiler decoder, allocator or serializer correctness premise replaces them.
wordIndexOf's observed wrapper PC 998, decoder 0x58f7 and body 0x202b remain
locators; its actual bytecode body proof is still open.

`Machine.dfy` imports the exact retained getter byte/word helpers and models the
reached calldata-aware EVM subset. Arbitrary-offset zero-padded calldata loads,
all PUSH widths, unsigned arithmetic, shifts, stack operations and rounded
physical memory expansion are explicit. Unsupported reached operations produce
Bad. `Representation`, `Fetch`, `Push`, `ErrorBytes` and `Scalar` prove physical
byte projections, instruction immediates and exact overlapping error stores.
The explicit 32-bit `Narrow` lemma resolves the integer-to-bv256 conversion for
the two error selectors; the old timed-out attempts remain under development.
The shift model retains unsigned operand order and saturation at 256 as specified
by [EIP-145](https://eips.ethereum.org/EIPS/eip-145).

`Execution.dfy` composes finite actual Step traces and widens only already
successful reached jump-destination sets. The loop uses count-index as its rank,
not execution fuel or a fixture bound. Its invariant connects every actual
calldata word and successful partial sum to recursive Prefix. `CheckedLoop.dfy`
selects the exact first overflowing addition and physical Panic error; otherwise
it completes every admitted word. `CheckedConnection.dfy` composes actual
calldata decoding, alignment, count setup, loop and physical return/error frames.
`CheckedEntry.dfy` connects that result to PC-zero physical routing.

The current **development admission** is explicit: zero call value, the assigned
selector after SHR of CALLDATALOAD(0), calldata size below 2^64, the actual decoded
offset head below 2^64 and the complete head/payload span fitting calldata. Loose
accepted offsets, trailing bytes and absent bytes padding are allowed. Length
alignment and sum fitting are outcomes, not admissions, in CheckedEntry. Raw
malformed decoder frames are covered by five development path proofs and the
raw-decoder connection. Generalizing
representation restrictions must be tracked separately rather than implied.

Successful component checks include machine 159, byte projections 100, PUSH1/2
41, PUSH4 48, trace composition 74, scalar conversion/selectors 57, six helper
traces, eleven loop segments, accepted decoder, routing, successful/overflow-aware
loops, physical scalar return, and exact unaligned/overflow error traces. Eight
local EDR fixtures check actual decoder stacks/memory and complete sum/error
receipts. These component checks are **development**, not retained public evidence.
Snapshots/logs/CSV/hashes preserve failed, timed-out and passed attempts. In
particular decoder-v4's native job passed 3,192 rows but its package run failed
input stability when the unrelated Loop source changed; it is not a complete
stable package pass. Fresh closure must replace that gap.

`development-run.py` snapshots selected checks. `closure-development.py` snapshots
the complete include graph of CheckedEntry, regenerates every direct generated
file, verifies every native declaration in that graph, requires zero audit and
unchanged package inputs. It still does not provide retained public evidence.

All five malformed decoder paths passed 9,459 development obligations. The first
complete accepted closure had zero audit findings but five shift-step timeouts;
its failed result remains preserved. Isolating the identical shift behind a
proved opaque definition gave stable error/selectors checks in `errors-v7`
(3,122 obligations). The retained package in `../word-sum` now combines all
raw classes, accepted body paths, 24 EVM fixtures and three semantic byte faults.
No retained evidence or public coverage is inferred from those preflight checks.

Remaining work:
- Complete a fresh native/audit/regeneration/dependency closure without source
  drift; retain exact proof and tool inventories.
- Retain the proved malformed bytes classes and raw entry composition within
  the explicitly stated 64-bit size representation.
- Finish retained verifier, current runtime identity/dependency closure, EVM
  fixtures and semantic bytecode fault campaigns before a ledger/coverage update.
- Prove wordIndexOf's decoder, least-match/count-sentinel loop and physical return.
- Continue all other outstanding public runtime bodies and whole-contract audit.

Reviewed reached EVM interpretation and instruction-boundary scanning, faithful
calldata/environment observations, fresh call memory and adequate reached
execution/allocation/stack resources remain trusted premises. No whole-contract,
source-to-bytecode, gas, deployment, complexity, performance or unconditional
resource-availability claim is inferred from these development results.
