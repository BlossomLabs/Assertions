# Resolver-to-navigation composition

This package connects the public `nav` entry point to the resolver/constraint
proof and the completed navigation proof. The [baseline](evidence/resolved-navigation/manifest.json)
and [actual-source fault campaign](evidence/composition-faults/manifest.json)
retain executed results. Production Solidity is unchanged.

`CompositionSource.Nav` proves that resolution executes first, with empty
assertion text and entry/operand index zero. Any resolver failure propagates
unchanged, with its actual history; descriptor parsing, path dispatch and value
validation do not precede resolution. Successful resolution supplies exactly its
returned bytes to `NavigationSource.NavResolved`. Navigation adds no external
requests. `CompositionModel.NavPost` connects this to the navigation contract:
empty-path passthrough, independent LEN/PAYLOAD semantics, static-value errors,
and canonical acceptance/returned bytes for dynamically selected values. The
existing navigation package supplies exact source-connected codec error receipts;
this package does not invent an independent recursive error-offset oracle.

`CanonicalNav` specializes the same wrapper to producer bytes that match a
canonical ABI body. For any finite descriptor, path and mode satisfying the
existing arithmetic budget, successful resolution then agrees with the
independent recursive `NavigationModel.Query`. Failed resolution still escapes
before navigation. Canonical encoding is a condition on the actual fetched
bytes, not an assumption that all producers always return canonical data.
`Nav` separately covers noncanonical and malformed data through the navigation
postcondition. Empty paths can return arbitrary raw bytes without parsing the
descriptor, but still cannot bypass fetch or constraint failures.

## Source and evidence boundary

`generate.py` pins the full normalized public `nav` AST, error declarations and
wire types. It extracts the actual resolver context indices into the source
template. The remainder of `nav` is implemented by the source-connected
`NavResolved` summary, whose complete gate and evidence are audited as a
dependency. `CanonicalQuery` calls that same summary and supplies the independent
canonical theorem. Both template instantiations preserve source evaluation order.
The template/translator, solc AST and helper-summary composition are trusted.

New Composition declarations run afresh. The entire included dependency closure
is matched against retained navigation and resolution baselines using transitive
source hashes and identical Dafny, assembly, Z3 and solc binaries. Every retained
artifact hash and successful native result is checked, and every method/lemma
must have passed result rows. Copied dependency manifests preserve original
commands and link to the retained logs/artifacts; the evidence checker audits
those linked artifacts again. Reuse is explicit and does not claim a fresh run
of every dependency. Failed or missing results never count as proof.

Premises remain valid typed inputs, actual decoder/external observations,
nonwrapping disjoint memory and adequate local gas, stack and allocation. The
resolved length plus 32, descriptor and path lengths must fit uint256; path
entries must fit int256. Canonical navigation uses the existing sufficient
arithmetic budget `|data| + 32 * 2^32 * |descriptor| < 2^256`. Errors in the
model's sum types are namespaces, not additional on-chain wrappers. Physical
error serialization and compiler correctness are separate premises. There is no
claim of universal gas exhaustion diagnosis, deterministic repeated calls,
recursive self-call tree equivalence or exact compiled bytecode.

Six EVM tests cover exact failure context/precedence, malformed fetch decoding,
producer failures, staticcall-to-canonical values and all modes, arbitrary
empty-path passthrough and narrow-value rejection. Two actual Solidity index
faults must pass translation, fail the semantic theorem without timeout, and
fail the designated exact-error test. The broader navigation dispatch faults
remain covered by the separately retained navigation campaign.

```sh
python3 -B formal/composition/verify.py \
  --dafny /path/to/dafny --solc /path/to/solc-0.8.36 \
  --output /tmp/resolved-navigation
python3 -B formal/composition/mutations.py \
  --dafny /path/to/dafny --solc /path/to/solc-0.8.36 \
  --output /tmp/composition-faults
```

The full objective remains in `../verification-plan.json`. Codec-backed `get`,
recursive trees, Expressions, Collections and exact-bytecode proofs are separate
obligations.
