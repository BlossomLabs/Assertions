# Collections input and callback-result validation

This package composes the exact codec source outcome proof with Collections'
`_validateResult`, the noncached `AbiCodec.validate` overloads, and the validation
requests used by the map/filter/fold model. It covers arbitrary finite descriptor
and value bytes under explicit representability and cursor-resource premises.

The restricted generator gates the complete compiler ASTs of `_validateResult`
and the two noncached validator overloads, including signatures, statement order,
default context and dispatch. It translates the callback operation/index/other/
target fields into the source adapter. The adapter invokes the completed source
parser and exact cached validator, then the completed context routing. This is a
trusted source translation, not a compiler-correctness theorem.

`Verdict` establishes acceptance exactly when the descriptor parses and the
independent canonical ABI validator accepts the bytes. The actual source parser
establishes descriptor admissibility and type well-formedness, rather than
requiring an accepted descriptor as input. Bad descriptors preserve their exact
parser position, and parser arithmetic failures preserve Panic(17). `Room`
excludes value cursor arithmetic exhaustion after successful parsing.

`Input` preserves the exact first `InvalidValue` offset from the independent
recursive codec specification. `Result` converts value errors into
`InvalidCallbackResult(operation,index,0,target)`, preserving malformed-descriptor
errors. Both use the concrete compiler-bound error encoder. Context integers and
source offsets must faithfully represent their Solidity widths; the encoding
package's round-trip theorem explicitly requires those bounds.

`Observe` produces the deterministic reply for Shape, Validate and ValidateResult
requests, preserving the supplied prepared-state token. It is a local observation
adapter, not the complete traversal environment. Preparation, binding, external
callback history/gas/context, and all public entry points still need final
composition. The total model's non-Good parser fallback is unreachable on every
certified source path; it is not an observed error behavior.

The retained driver checks source and generated-code gates, dependency source,
tool and artifact hashes, native proof coverage, zero audit findings, formatting,
and seven concrete EVM fixtures. The fixtures exercise a nonzero input offset,
map result operation/index/target, dynamic padding offsets and context routing,
malformed descriptor precedence, fold initial-value context, and accepted results.
No new source-fault campaign, compiled-bytecode, deployment or gas-performance
claim is made. Existing memory/resource and Dafny/Boogie/Z3 assumptions remain.

```sh
PATH=/home/sem/.foundry/bin:$PATH python3 formal/collections/validation/verify.py \
  --dafny /tmp/assertions-dafny-4.11.0/dafny/dafny \
  --solc /home/sem/.cache/hardhat-nodejs/compilers-v3/linux-amd64/solc-linux-amd64-v0.8.36+commit.8a079791 \
  --output formal/collections/validation/evidence/validation-receipts
```

See the retained manifest and `scripts/check-collections-validation-evidence.py`
for native results and the conditional claim ledger.
