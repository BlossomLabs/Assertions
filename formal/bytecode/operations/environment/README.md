# Direct environment getter bytecode development

Eight current Operations direct getters have complete generated successful paths
from PC zero to physical 32-byte RETURN: baseFee, blobBaseFee, blockNumber, chainId,
gasLimit, gasPrice, prevRandao and timestamp. The opcode model binds the reached
single environment opcode to its truthful caller/context observation. The entire
uint256 observation is symbolic; adequate reached execution resources and fitting
calldata representation remain explicit. No source proof substitutes for actual
opcode/byte memory correspondence. Raw rejection composition, fresh native
closure, retained fixtures/faults and independent checking remain open. No public
coverage is recorded by these generated files.
