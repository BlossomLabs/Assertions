// Fresh PC0 witness for wide static tuple terminal byte return.
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
const descriptor='((uint256[4294967295],uint256),uint256[])';
const data=encodeFunctionData({abi:artifact.abi,functionName:'nav',args:[{paramType:0,fetcherType:0,paramData:payload,constraints:[]},descriptor,[-1n]]});
const trace=await provider.request({method:'debug_traceCall',params:[{from,to:target,gas:'0x989680',data},'latest',{enableMemory:true,disableStorage:true,disableStack:false}]});
const actual='0x'+trace.returnValue.replace(/^0x/,'');
writeFileSync(resolve(out,'trace.json'),JSON.stringify({runtimeSha256:digest,descriptor,data,actual,trace},null,2)+'\n');
if(!trace.failed)throw Error('negative tuple index must be rejected');
const rows=trace.structLogs.filter(r=>r.depth===1);let witness;
for(let i=0;i<rows.length;i++){
 const r=rows[i],stack=r.stack.map(x=>BigInt('0x'+x.replace(/^0x/,'')));
 if(r.pc!==8882||stack.at(-1)!==4294967296n||stack.at(-2)!==0n)continue;
 const q=stack.at(-3),limit=stack.at(-4),offset=stack.at(-7),ret=Number(stack.at(-8)),bytes=Buffer.from(data.slice(2),'hex');
 if(q>=limit||bytes[Number(offset+q)]===91)continue;
 const j=rows.findIndex((x,k)=>k>i&&x.pc===ret);if(j<0)throw Error('missing terminal return');
 const after=rows[j].stack.map(x=>BigInt('0x'+x.replace(/^0x/,'')));
 const expectedStack=stack.slice(0,-8).concat([q,0n,4294967296n]);
 if(JSON.stringify(after.map(String))!==JSON.stringify(expectedStack.map(String)))throw Error('incorrect full terminal stack');
 if(JSON.stringify(rows[j].memory)!==JSON.stringify(r.memory))throw Error('terminal mutated memory');
 if(j-i!==31)throw Error('terminal instruction count differs from native model');
 witness={beforeRow:i,afterRow:j,instructionCount:j-i,words:String(stack.at(-1)),delimiter:bytes[Number(offset+q)],returnPC:ret,fullBoundaryStackMatches:true,memoryPreserved:true};break;
}
await connection.close();
if(!witness)throw Error('no reached wide tuple byte terminal');
writeFileSync(resolve(out,'result.json'),JSON.stringify({status:'passed',scope:'One actual PC0 negative-index execution with exact wide tuple byte-return boundary; no universal or whole-entry completion claim.',runtimeSha256:digest,nodeVersion:process.version,nodeSha256:sha(readFileSync(process.execPath)),lockfileSha256:sha(readFileSync('pnpm-lock.yaml')),witness},null,2)+'\n');
console.log('PASS: wide static tuple byte terminal preserves footprint4294967296');
