# Direct environment getter retained evidence owner

The full raw graph targets baseFee, blobBaseFee, blockNumber, chainId, gasLimit,
gasPrice, prevRandao and timestamp. The native World datatype has distinct
uint256 observation fields. The exact reached opcode selects its corresponding
field; the expected function independently identifies the public getter's field.
An opcode swap to another observation is a semantic fault, even where one
concrete context happens to give equal values. World observations must be faithful
to actual execution context; there is no unproved header/RPC equivalence premise.

The local physical fixtures pin debug_traceCall BASEFEE to zero while preserving
the separately queried RPC header's different base fee. Zero-excess-blob genesis
pins a single concrete BLOBBASEFEE value of one; general fee economics, Ethereum
header calculation and chain consensus remain outside the observation premise.
Twenty-four complete successful physical receipts and eight full nonpayable/
short-selector empty-revert receipts are required. Each of eight single-byte
opcode swaps must retranslate, fail a baseline-proved semantic native assertion
without timeout/type/parser failures and produce real EVM counterexamples.

Complete package files precede snapshots. Every included module/declaration is
freshly verified with full assertions, regenerated files are byte-identical and
audits have zero findings. Input/tool/runtime/dependency stability and independent
retained checking precede any public ledger count. Failed/live graphs are
preserved; a polling timeout never authorizes restarting a live verification.
Fitting finite representation, reviewed interpreter/extraction, faithful external
observations and sufficient reached resources remain explicit. No gas,
deployment, performance or source-to-whole-bytecode inference is made.
