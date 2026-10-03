// Independent calldata oracle: viem's tuple encoder, not the Dafny layout.
import { encodeFunctionData, parseAbi } from "viem";

const abi = parseAbi([
  "function resolve((uint8 paramType, uint8 fetcherType, bytes paramData, (uint8 constraintType, bytes referenceData)[] constraints) param) view",
]);
let input = "";
for await (const chunk of process.stdin) input += chunk;
const cases = JSON.parse(input);
process.stdout.write(JSON.stringify(cases.map(({ route, payload }) =>
  encodeFunctionData({ abi, functionName: "resolve", args: [{
    paramType: route, fetcherType: 0, paramData: payload, constraints: [],
  }] })
)));
