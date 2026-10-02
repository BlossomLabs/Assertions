# One concrete interleaved map/filter/fold iteration

This package instantiates the traversal model's `Step` with actual source helper
receipts in execution order: input validation, callback/predicate processing, then
value-result validation when applicable. It does not start from a precomputed
sequence of successful callback observations.

`Step` first calls the source-connected input validator. Rejection yields one
high-level request and leaves concrete prepared state and low-level history
unchanged. Otherwise it selects callback operands exactly as the traversal model
does: map/filter bind the element; fold binds accumulator first and element second.
The callback context uses the supplied iteration index and `other = 0`.

Actual component receipts, binding and encoders produce the source callback
outcome. The completed result adapter supplies the call reply and, for a returned
value in map/fold, its independent result-check reply. Callback/predicate rejection
stops after two requests; result rejection stops after three. Success emits one
map result, the original filter element or nothing, or the next fold accumulator.
A successful map/fold result passed canonical result validation. Every successful
iteration leaves canonical callback arguments and a checked target cache.

The generated-in-memory traversal environment matches these exact requests and
contexts. Its unrelated Error([]) defaults are not observed. A logical state token
advances once when a callback helper is invoked; separate returned fields retain
the concrete prepared state and low-level callback history that must be threaded
into the next iteration. The returned callback environment preserves the supplied
code/call functions and certifies the exact source invocation. Input/result
validation does not advance that token.

The theorem begins with an admitted tuple and canonical constants outside binding
slots, supplied by preparation. It retains explicit Uint/width/CursorRoom and
argument/expression packet resources, including sufficient bounds on some
unreached work. `AfterRoom` constrains only resource properties of possible modeled
callback outcomes in the fixed external environment; it assumes neither success
nor return validity. Its validity guards are discharged by the actual call proof.
An outer host must faithfully supply external code/call/gas observations, carrying
the relevant high-level context as well as the low-level history; no context-free
external determinism is inferred.

This proves exact equality to the traversal `Step` reference. Whole-loop
construction must combine successive environments without changing earlier
observations, connect admission, and then apply the separately proved source loop
correspondence. It is not yet a full public map/filter/fold theorem. Remaining
public families and exact bytecode also remain open. Source translation, compiler
ABI, context/offset projections, physical memory/resources and Dafny/Boogie/Z3
remain trusted.

The retained proof-only driver verifies dependency source/tool/artifact hashes and
native results, local proof coverage, formatting and a zero-finding audit. No new
EVM fixture, mutation campaign, deployment or performance claim is made.

```sh
PATH=/home/sem/.foundry/bin:$PATH python3 formal/collections/iteration/verify.py \
  --dafny /tmp/assertions-dafny-4.11.0/dafny/dafny \
  --solc /home/sem/.cache/hardhat-nodejs/compilers-v3/linux-amd64/solc-linux-amd64-v0.8.36+commit.8a079791 \
  --output formal/collections/iteration/evidence/concrete-interleaved-step
```
