# Concrete bindings through callback execution

This composition replaces the callback environment's supplied codec and encoder
observations with actual source component receipts and the proved ABI encoders.
The base environment contributes only history-sensitive code-existence and
external-call/gas observations. It need not claim anything about codec validation
or calldata encoding.

`Receipt` invokes the actual source component validator under representability and
CursorRoom premises, preserving its typed error and canonical-value equivalence.
`Bound` connects a matching receipt to the proved source `_bindValue`. A successful
binding assigns only its selected slot; a failed binding preserves its incoming
prepared arguments. The one-event codec history carries the exact request.

`Bindings` constructs an admitted environment for the two selected requests and
preserves source order. First failure retains the original arguments. Second
failure retains the successful first assignment. After accepted bindings, all
arguments are canonical and direct encoding is ready, including when the later
external call fails. The unmatched codec fallback is never a reached observation.
Pure receipts computed ahead of an early failure are ghost evidence, not claims
that the source executes later validations.

`Encode` uses the actual ABI assembly proof for direct calls and the compiler-bound
canonical expression packet for expression callbacks. It identifies the exact
calldata and encoding event passed to the history-sensitive external observation.
The direct encoder's fallback cannot occur after accepted bindings.

`Run` connects these constructions to source `_callValue`. It preserves lazy target
checking, cached target reuse, failure precedence, prepared arguments and plan,
and at most one external call. Missing code fails before binding; otherwise exact
codec error bytes propagate as helper failures. Successful calls retain canonical
arguments and the checked target flag. The external observation itself supplies
success, returndata and gas; it may depend on the complete event history.

This entry point starts from an accepted tuple and partially canonical prepared
state. Arbitrary preparation admission and whole traversal composition remain to
be connected. The resource premises include uint256 lengths, layout sizes and
slots, CursorRoom, final argument extent, expression packet bounds and faithful
context/offset projections. Some are sufficient bounds on unvisited ghost values.
Outer error-packet resource bounds, compiler ABI, source translation and physical
memory/resources remain explicit premises. This is not an exact-bytecode theorem.

The proof-only retained run rechecks identical dependency source/tool/artifact
hashes and native declaration coverage, local proof obligations, formatting and a
zero-finding audit. There is no new EVM fixture, mutation campaign, deployment or
performance claim; existing concrete and mutation evidence remains linked through
the dependency manifests.

```sh
PATH=/home/sem/.foundry/bin:$PATH python3 formal/collections/bound-call/verify.py \
  --dafny /tmp/assertions-dafny-4.11.0/dafny/dafny \
  --solc /home/sem/.cache/hardhat-nodejs/compilers-v3/linux-amd64/solc-linux-amd64-v0.8.36+commit.8a079791 \
  --output formal/collections/bound-call/evidence/concrete-bound-callback
```
