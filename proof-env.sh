# Source this file from bash to select the consolidated proof environment.
ASSERTIONS_PROOF_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
export PATH="$ASSERTIONS_PROOF_ROOT/proof-tools/bin:$PATH"
export DAFNY="$ASSERTIONS_PROOF_ROOT/proof-tools/assertions/dafny/dafny"
export SOLC="$ASSERTIONS_PROOF_ROOT/proof-tools/assertions/solc-0.8.36"
