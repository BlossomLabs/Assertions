// Independent canonical ConstraintFailed receipts; no public proof credit by themselves.
import {readFileSync,writeFileSync,mkdirSync} from 'node:fs';
import {resolve} from 'node:path';
import {createHash} from 'node:crypto';
import {createRequire} from 'node:module';
import {fileURLToPath} from 'node:url';
import {network} from 'hardhat';
import {encodeAbiParameters,encodeFunctionData,toHex} from 'viem';
const out=resolve(process.argv[2]);mkdirSync(out,{recursive:true});
const artifact=JSON.parse(readFileSync('artifacts/contracts/Assertions.sol/Assertions.json'));
const runtime=process.argv[3]?'0x'+readFileSync(resolve(process.argv[3])).toString('hex'):artifact.deployedBytecode;
const sha=x=>createHash('sha256').update(x).digest('hex'),digest=sha(Buffer.from(runtime.slice(2),'hex'));
const word=x=>toHex(BigInt(x),{size:32}),pad=x=>x.slice(2).padEnd(Math.ceil((x.length-2)/64)*64,'');
const blob=x=>word((x.length-2)/2).slice(2)+x.slice(2).padEnd(Math.ceil((x.length-2)/64)*64,'0');
const tuple={type:'tuple[]',components:[{name:'constraintType',type:'uint8'},{name:'referenceData',type:'bytes'}]};
const cases=[];
for(const n of [0,1,4,5,31,32,33,63,64,65,96])cases.push({name:'leaf-message-'+n,kind:0,reference:word(5),message:'m'.repeat(n)});
cases.push({name:'range-message-33',kind:3,reference:word(8)+word(9).slice(2),message:'r'.repeat(33)});
for(const n of [1,2,5])cases.push({name:'or-'+n+'-message-31',kind:6,reference:encodeAbiParameters([tuple],[Array.from({length:n},()=>({constraintType:0,referenceData:word(5)}))]),message:'o'.repeat(31)});
const connection=await network.connect('hardhatMainnet'),provider=connection.provider;
const [from]=await provider.request({method:'eth_accounts'}),target='0x0000000000000000000000000000000000006660';
await provider.request({method:'hardhat_setCode',params:[target,runtime]});
const results=[];
for(const c of cases){
 const message=toHex(c.message),messageLength=(message.length-2)/2;
 const expected='0xdeb9f2af'+[224,0,0,0,c.kind,7,256+Math.ceil(messageLength/32)*32].map(x=>word(x).slice(2)).join('')+blob(message)+blob(c.reference);
 const data=encodeFunctionData({abi:artifact.abi,functionName:'assertParam',args:[{paramType:0,fetcherType:0,paramData:word(7),constraints:[{constraintType:c.kind,referenceData:c.reference}]},c.message]});
 const trace=await provider.request({method:'debug_traceCall',params:[{from,to:target,data,value:'0x0',gas:'0x989680'},'latest',{enableMemory:true,disableStorage:true,disableStack:false}]});
 const errors=[];if(!trace.failed||'0x'+trace.returnValue.replace(/^0x/,'')!==expected)errors.push('Independent canonical ConstraintFailed bytes differ');
 writeFileSync(resolve(out,c.name+'.json'),JSON.stringify({fixture:c,runtimeSha256:digest,data,expected,trace},null,2)+'\n');
 results.push({name:c.name,passed:errors.length===0,errors,instructionCount:trace.structLogs.filter(x=>x.depth===1).length});
}
await connection.close();
const hh=fileURLToPath(import.meta.resolve('hardhat')),edr=createRequire(hh).resolve('@nomicfoundation/edr'),binding=createRequire(edr).resolve('@nomicfoundation/edr-linux-x64-gnu');
writeFileSync(resolve(out,'toolchain.json'),JSON.stringify({nodeVersion:process.version,nodeExecutable:process.execPath,nodeSha256:sha(readFileSync(process.execPath)),hardhatEntry:hh,hardhatEntrySha256:sha(readFileSync(hh)),edrEntry:edr,edrEntrySha256:sha(readFileSync(edr)),nativeBinding:binding,nativeBindingSha256:sha(readFileSync(binding)),lockfileSha256:sha(readFileSync('pnpm-lock.yaml'))},null,2)+'\n');
writeFileSync(resolve(out,'results.json'),JSON.stringify(results,null,2)+'\n');
console.log((results.every(x=>x.passed)?'PASS':'FAIL')+': '+results.length+' independent canonical ConstraintFailed receipts');process.exitCode=results.every(x=>x.passed)?0:1;
