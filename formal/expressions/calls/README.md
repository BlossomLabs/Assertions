# Expression external-call control

This package proves `_call`, `_probe`, and `_checkPublicCall` against independent
functional specifications with arbitrary byte sequences and history-dependent
external outcomes. The model retains exact typed error fields, first-failure
order, success bytes, code-less target behavior, wildcard selectors, first-four
selector matching, and safe stripping. Forbidden self-dispatch occurs before
any environment observation. Each permitted attempt appends exactly one request;
that request includes its code-presence lookup and does not assert an EVM call
occurred when there is no code.

`generate.py` gates the entire normalized AST of the three methods plus all
contract types and errors. Three source slots permit semantic fault campaigns:
call success inversion, probe success inversion, and selector comparison
inversion. The scalar package supplies the proved sampled-gas/marker classifier.
`verify.py` audits dependency closure, native proof results and declaration
coverage, source hashes, formatting and concrete EVM tests. `mutations.py`
requires every fault to translate and fail both a named proof and a named test.

The source lowering assumes faithful memory and standard in-range slice
projection, representable Solidity sizes and sufficient local resources. An
observation must reflect the actual target, caller/static context, code state,
return bytes and sampled gas; equal requests need not have equal outcomes. The
selector parameter must be the actual evaluateGuarded selector. Gas classification
proves the implemented predicate, not a complete diagnosis of EVM failure.

This is **typed control correspondence**. Formal serialization of these errors
into recursive `E.Raw` receipts, the `_evaluate` call/probe adapters, and full
entrypoint composition are still outstanding. Concrete exact-byte tests do not
substitute for that missing bridge. This is not compiled-bytecode verification.
