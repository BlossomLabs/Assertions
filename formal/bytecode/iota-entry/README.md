# iotaWords full bytecode entry development

`Body.dfy` composes actual checked multiplication/allocation guards, physical
header allocation and zero-padding copy, arbitrary finite loop execution, and
physical dynamic ABI serialization. Every input Word is classified: arithmetic
overflow emits Panic(0x11), compiler allocation-length rejection emits
Panic(0x41), and fitting successful execution emits the exact ABI bytes for
words 0 through n-1. The accepted count bound is derived from compiler guards.

Raw calldata, PC-zero dispatcher/decoder connection, complete retained proof
inventory, audits, physical EVM fixtures, semantic-fault campaign and independent
current-source checker are required before public coverage increases. Faithful
instruction scanning/interpreter semantics, representable input/state, truthful
physical observation and adequate reached execution resources remain explicit.
This does not establish physical gas sufficiency, deployment or performance.

`Root.dfy` connects the raw PC-zero route and scalar decoder to `Body.Run`.
The admitted domain is zero call value, the assigned selector and calldata size
from four through 2^64-1; trailing bytes are arbitrary. Nonpayable and shorter
calldata classes inherit the separate immutable physical rejection evidence.
The body and raw connection development checks passed 74 and 63 obligations;
these counts do not certify the complete include graph by themselves.

`verify.py` snapshots the complete package and include graph, reproduces every
generator group and canonical runtime, checks every native declaration/CSV row
and zero audit, then runs 53 complete physical EVM fixtures and three semantic
single-byte faults. The faults skip an output word, corrupt the dynamic ABI head
or replace RETURN with REVERT. Their independent postconditions and expected
receipts stay fixed; generation rejection, typing errors, timeouts and failed
preconditions are not semantic detections. `check-evidence.py` is the independent
retained-evidence/current-source checker, activated by a ledger only after the
retained run passes. The preflight EVM and fault checks passed; retained full
closure and the ledger/checker gate remain open.
