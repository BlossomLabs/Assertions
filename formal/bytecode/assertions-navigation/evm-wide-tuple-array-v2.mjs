// Fresh whole-EVM witness for a static tuple width above uint32 followed by [].
import {readFileSync,writeFileSync,mkdirSync} from 'node:fs';
import {resolve} from 'node:path';
import {createHash} from 'node:crypto';
import {network} from 'hardhat';
import {encodeAbiParameters,encodeFunctionData} from 'viem';
const out=resolve(process.argv[2]);mkdirSync(out,{recursive:false});
const sha=b=>createHash('sha256').update(b).digest('hex');
const artifact=JSON.parse(readFileSync('artifacts/contracts/Assertions.sol/Assertions.json'));
const digest=sha(Buffer.from(artifact.deployedBytecode.slice(2),'hex'));
if(digest!==JSON.parse(readFileSync('formal/bytecode/dispatch/inventory.json')).Assertions.runtimeSha256)throw Error('runtime drift');
const connection=await network.connect('hardhatMainnet'),provider=connection.provider;
const [from]=await provider.request({method:'eth_accounts'}),target='0x0000000000000000000000000000000000003715';
await provider.request({method:'hardhat_setCode',params:[target,artifact.deployedBytecode]});
const payload=encodeAbiParameters([{type:'uint256[]'}],[[]]);
const descriptor='((uint256[4294967295],uint256)[])';
const data=encodeFunctionData({abi:artifact.abi,functionName:'nav',args:[{paramType:0,fetcherType:0,paramData:payload,constraints:[]},descriptor,[0n,-(1n<<255n)]]});
const trace=await provider.request({method:'debug_traceCall',params:[{from,to:target,gas:'0x989680',data},'latest',{enableMemory:true,disableStorage:true,disableStack:false}]});
const expected=encodeAbiParameters([{type:'uint256'}],[0n]),actual='0x'+trace.returnValue.replace(/^0x/,'');
writeFileSync(resolve(out,'trace.json'),JSON.stringify({runtimeSha256:digest,descriptor,data,expected,actual,trace},null,2)+'\n');
if(trace.failed||actual!==expected)throw Error('wide tuple empty array was rejected');
const rows=trace.structLogs.filter(r=>r.depth===1);let witness;
for(let i=0;i<rows.length;i++){
 const r=rows[i],stack=r.stack.map(x=>BigInt('0x'+x.replace(/^0x/,'')));
 if(r.pc!==8882||stack.at(-1)!==4294967296n||stack.at(-2)!==0n)continue;
 const end=stack.at(-3),limit=stack.at(-4),offset=stack.at(-7),bytes=Buffer.from(data.slice(2),'hex');
 if(bytes[Number(offset+end)]!==91||bytes[Number(offset+end+1n)]!==93)continue;
 const j=rows.findIndex((x,k)=>k>i&&x.pc===8882);if(j<0)throw Error('missing suffix return');
 const after=rows[j].stack.map(x=>BigInt('0x'+x.replace(/^0x/,'')));
 const expectedStack=stack.slice(0,-3).concat([end+2n,1n,1n]);
 if(JSON.stringify(after.map(String))!==JSON.stringify(expectedStack.map(String)))throw Error('incorrect physical reset');
 if(JSON.stringify(rows[j].memory)!==JSON.stringify(r.memory))throw Error('suffix mutated memory');
 witness={beforeRow:i,afterRow:j,oldWords:String(stack.at(-1)),newWords:String(after.at(-1)),newDynamic:String(after.at(-2)),fullBoundaryStackMatches:true,memoryPreserved:true,limit:String(limit)};break;
}
await connection.close();
if(!witness)throw Error('no reached wide tuple [] state');
writeFileSync(resolve(out,'result.json'),JSON.stringify({status:'passed',scope:'One actual PC0 empty-array LEN execution plus exact wide [] boundary reset; no universal or whole-entry completion claim.',runtimeSha256:digest,nodeVersion:process.version,nodeSha256:sha(readFileSync(process.execPath)),lockfileSha256:sha(readFileSync('pnpm-lock.yaml')),witness},null,2)+'\n');
console.log('PASS: actual wide static tuple footprint4294967296 resets through [] to dynamic one word');
