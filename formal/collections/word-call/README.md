# Word domain and callback helpers

The complete `_domainElem`, `_checkTarget`, `_callWord` bodies and `FoldDomain`
enum are compiler-AST gated. `Source.DomainElement` refines the independent
range/byte/word specification for valid internal indices, including complete
unsigned 256-bit word values and safe slice-address arithmetic.

`Source.CallWord` makes one explicit full-history external observation. Failure
first applies the retained actual exhaustion/signal rejection proof; ordinary
failure preserves the source operation, current index, other=0, target, calldata
and raw reason in the exact callback error. Successful data must be exactly 32
bytes; both shorter and longer data fail with the exact result context. Success
returns the full decoded word, whose encoding equals the complete returndata.

`Source.CheckTarget` separately records the target-code observation and exact
code-less-target rejection. This does not establish when a public caller invokes
that check. `Connection.Run` packages domain and call facts but intentionally
accepts already-stamped calldata: it does not claim that domain extraction stamps
that data or that a full fold loop has been proved.

Trust/resource premises: decoded calldata and faithful compiler cast/slice,
context and memory projections; representable lengths/indices/gas/address fields;
sufficient error-packet and local execution resources; faithful staticcall/gas
observations; existing source translations and Dafny/Boogie/Z3. The environment
may depend on the complete prior history; no cross-call determinism is inferred.

The retained driver snapshots and hashes inputs, regenerates source adapters,
checks dependency/native/declaration evidence, runs fresh proofs and a proof-escape
audit, and replays eight EVM fixtures. Three mutations test byte indexing, failure
indices and acceptance of oversized results. Public word loop/admission/exit
composition, exact compiled bytecode and performance evidence remain open.
