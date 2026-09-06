import { network } from "hardhat";
import { encodeAbiParameters, parseAbiParameters, toFunctionSelector } from "viem";
const {viem}=await network.connect();
const core=await viem.deployContract("Assertions");
const resolver=await viem.deployContract("ExpressionResolver");
const operations=await viem.deployContract("Operations");
const client=await viem.getPublicClient();
const [wallet]=await viem.getWalletClients();
const word=(v:bigint)=>encodeAbiParameters(parseAbiParameters("uint256"),[v]);
for(const count of [1,4,16]) {
 const args=Array.from({length:count},(_,i)=>({paramType:0,fetcherType:0,paramData:encodeAbiParameters(parseAbiParameters("string"),["x".repeat(33+i)]),constraints:[]}));
 const types=`(${Array(count).fill("string").join(",")})`;
 console.log(`resolveArguments ${count} dynamic values: ${await client.estimateContractGas({address:resolver.address,abi:resolver.abi,functionName:"resolveArguments",args:[core.address,types,args],account:wallet.account})}`);
}
const nodes=[
 {kind:0,valueType:"address",data:encodeAbiParameters(parseAbiParameters("address"),[operations.address]),refs:[],selector:"0x00000000",arguments:""},
 {kind:1,valueType:"uint256",data:word(0n),refs:[],selector:"0x00000000",arguments:""},
 {kind:3,valueType:"uint256",data:"0x",refs:[0n,1n,1n],selector:toFunctionSelector("add(uint256,uint256)"),arguments:"(uint256,uint256)"},
 {kind:3,valueType:"uint256",data:"0x",refs:[0n,2n,2n],selector:toFunctionSelector("mul(uint256,uint256)"),arguments:"(uint256,uint256)"},
] as const;
console.log(`evaluate shared graph: ${await client.estimateContractGas({address:resolver.address,abi:resolver.abi,functionName:"evaluate",args:[{core:core.address,nodes,result:3n},[word(7n)]],account:wallet.account})}`);
