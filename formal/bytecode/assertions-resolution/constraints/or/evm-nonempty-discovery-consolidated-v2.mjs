// Native runtime discovery and independent flat OR receipt policy; not a proof certificate.
import {readFileSync,writeFileSync,mkdirSync} from 'node:fs';
import {resolve} from 'node:path';
import {createHash} from 'node:crypto';
import {createRequire} from 'node:module';
import {fileURLToPath} from 'node:url';
import {network} from 'hardhat';
import {encodeAbiParameters,encodeFunctionData,toHex,toFunctionSelector} from 'viem';
const out=resolve(process.argv[2]);mkdirSync(out,{recursive:true});
const artifact=JSON.parse(readFileSync('artifacts/contracts/Assertions.sol/Assertions.json')),runtime=process.argv[3]?'0x'+readFileSync(resolve(process.argv[3])).toString('hex'):artifact.deployedBytecode;
const sha=x=>createHash('sha256').update(x).digest('hex'),digest=sha(Buffer.from(runtime.slice(2),'hex'));
const tuple={type:'tuple[]',components:[{name:'constraintType',type:'uint8'},{name:'referenceData',type:'bytes'}]};
const word=x=>toHex(BigInt(x),{size:32}),leaf=(kind,referenceData)=>({constraintType:kind,referenceData});
const pad=x=>x.slice(2).padEnd(Math.ceil((x.length-2)/64)*64,'0');
const invalidOr=toFunctionSelector('InvalidOrConstraint(uint256,uint256,uint256)')+word(0).slice(2).repeat(3);
const badData='0xe70ce766'+word(0).slice(2).repeat(3)+word(1).slice(2);
const cases=[0,1,31,32,33,63,64,65].map(n=>({name:'or-mixed-ref-'+n,alternatives:[leaf(0,word(7)),leaf(7,'0x'+'ab'.repeat(n))],result:'holds'}));
const connection=await network.connect('hardhatMainnet'),provider=connection.provider;
const [from]=await provider.request({method:'eth_accounts'}),target='0x0000000000000000000000000000000000006660';
await provider.request({method:'hardhat_setCode',params:[target,runtime]});
const results=[];
for(const c of cases){
 const reference=encodeAbiParameters([tuple],[c.alternatives]),value=word(7);
 const expected=c.result==='holds'?value:c.result==='invalid'?invalidOr:c.result==='bad-data'?badData:
 '0xdeb9f2af'+[224,0,0,0,6,7,256].map(x=>word(x).slice(2)).join('')+word(0).slice(2)+word((reference.length-2)/2).slice(2)+pad(reference);
 const data=encodeFunctionData({abi:artifact.abi,functionName:'resolve',args:[{paramType:0,fetcherType:0,paramData:value,constraints:[leaf(6,reference)]}]});
 const trace=await provider.request({method:'debug_traceCall',params:[{from,to:target,data,value:'0x0',gas:'0x989680'},'latest',{enableMemory:true,disableStorage:true,disableStack:false}]});
 const errors=[];
 if(trace.failed!==(c.result!=='holds')||'0x'+trace.returnValue.replace(/^0x/,'')!==expected)errors.push('Independent flat OR receipt differs');
 const logs=trace.structLogs.filter(x=>x.depth===1),boundaries=[19462,19590,14969,7723,10646,7993,8035];
 const calls=logs.map((r,i)=>({i,pc:r.pc,stack:r.stack,memory:r.memory})).filter(x=>boundaries.includes(x.pc));
 writeFileSync(resolve(out,c.name+'.json'),JSON.stringify({fixture:c,runtimeSha256:digest,data,expected,trace},null,2)+'\n');
 writeFileSync(resolve(out,c.name+'-boundaries.json'),JSON.stringify(calls,null,2)+'\n');
 results.push({name:c.name,passed:errors.length===0,errors,instructionCount:logs.length});
}
await connection.close();
const hh=fileURLToPath(import.meta.resolve('hardhat')),edr=createRequire(hh).resolve('@nomicfoundation/edr'),binding=createRequire(edr).resolve('@nomicfoundation/edr-linux-x64-gnu');
writeFileSync(resolve(out,'toolchain.json'),JSON.stringify({nodeVersion:process.version,nodeExecutable:process.execPath,nodeSha256:sha(readFileSync(process.execPath)),hardhatEntry:hh,hardhatEntrySha256:sha(readFileSync(hh)),edrEntry:edr,edrEntrySha256:sha(readFileSync(edr)),nativeBinding:binding,nativeBindingSha256:sha(readFileSync(binding)),lockfileSha256:sha(readFileSync('pnpm-lock.yaml'))},null,2)+'\n');
writeFileSync(resolve(out,'results.json'),JSON.stringify(results,null,2)+'\n');
console.log((results.every(x=>x.passed)?'PASS':'FAIL')+': '+results.length+' independent flat OR policies; discovery only');
process.exitCode=results.every(x=>x.passed)?0:1;
