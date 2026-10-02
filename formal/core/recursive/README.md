# Assertions recursive frame composition

The typed invocation model covers every public Assertions entrypoint and both
judge overloads: resolve, assertParam, assertBatch, gather, pick, read, chain,
cond, orElse, isValid, revertData, get and nav.

`Dispatch.Run` calls the existing source adapter for each case. Its postcondition
preserves the independent per-operation specification, exact structured error,
frame history and returned codec/navigation witness. `get` receipts come from
the actual proved encoder; their success is not supplied as an assumption.
`Ready` retains the original operation-specific resource premises.

This common receipt interface is the first part of recursive frame composition.
Finite child-frame construction, faithful ABI/error serialization at self-call
boundaries and complete coverage of actual self-call sites remain open. The
dispatcher alone does not prove those steps. External observations retain their
own frame histories; repeated calls are not assumed deterministic.

The existing source translations and their full dependency evidence are reused
by identical source/tool/artifact hashes. Native declaration coverage, audit,
formatting and unchanged-input checks are retained by `verify.py`. Dependency
closure discovery is memoized within one run; source contents and hashes are
still checked. No new EVM or production source-fault campaign is claimed.
Exact compiled bytecode and physical resource guarantees remain separate.
