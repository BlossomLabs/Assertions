// Exact-runtime scalar helper fixtures. Expectations are independent ABI specs.
import {readFileSync,writeFileSync,mkdirSync} from 'node:fs';
import {resolve,dirname} from 'node:path';
import {fileURLToPath} from 'node:url';
import {createRequire} from 'node:module';
import {createHash} from 'node:crypto';
import {network} from 'hardhat';
import {encodeFunctionData,encodeErrorResult} from 'viem';
const options={};for(let i=2;i<process.argv.length;i+=2){if(!['--output','--root','--runtime','--case'].includes(process.argv[i])||!process.argv[i+1])throw Error('Bad arguments');options[process.argv[i]]=process.argv[i+1];}
const root=resolve(options['--root']??'.'),out=resolve(options['--output']);mkdirSync(out,{recursive:true});
const here=dirname(fileURLToPath(import.meta.url)),sha=x=>createHash('sha256').update(x).digest('hex');
const artifact=JSON.parse(readFileSync(resolve(root,'artifacts/contracts/Assertions.sol/Assertions.json'))),candidate=options['--runtime']??null,code=candidate?'0x'+readFileSync(candidate).toString('hex'):artifact.deployedBytecode,digest=sha(Buffer.from(code.slice(2),'hex'));
if(!candidate&&digest!==JSON.parse(readFileSync(resolve(root,'formal/bytecode/dispatch/inventory.json'))).Assertions.runtimeSha256)throw Error('Runtime drift');
const raw=b=>({paramType:2,fetcherType:0,paramData:b,constraints:[]}),word=n=>BigInt.asUintN(256,n).toString(16).padStart(64,'0'),error=(name,args)=>encodeErrorResult({abi:artifact.abi,errorName:name,args}).slice(2);
const fixtures=[];
for(const [label,bytes,index] of [
 ['empty-positive','',0n],['empty-negative','',-1n],['short-positive','a5'.repeat(31),0n],['first-positive',word(5n)+word(11n),0n],['last-positive',word(5n)+word(11n),1n],['last-negative',word(5n)+word(11n),-1n],['first-negative',word(5n)+word(11n),-2n],['positive-boundary',word(5n)+word(11n),2n],['negative-boundary',word(5n)+word(11n),-3n],['signed-minimum',word(5n)+word(11n),-(1n<<255n)],['signed-maximum',word(5n)+word(11n),(1n<<255n)-1n],['trailing-ignored',word(5n)+word(11n)+'af'.repeat(31),-1n],['many-words',Array.from({length:257},(_,i)=>word(BigInt(i*17+3))).join(''),-113n]
]){
 const n=BigInt(bytes.length/2),count=n/32n,wanted=index<0n?count+index:index,valid=wanted>=0n&&wanted<count,expected=valid?bytes.slice(Number(wanted)*64,Number(wanted+1n)*64):error('ReturnDataOutOfBounds',[index,n]);
 fixtures.push({name:label,fn:'pick',args:[raw('0x'+bytes),index],failed:!valid,expected,kernel:valid?(index<0n?'RawWordNegative':'RawWordPositive'):(index<0n?'RawWordNegativeOob':'RawWordPositiveOob')});
}
for(const n of [0,31,32,63]){
 const bytes=n<32?'5a'.repeat(n):word(0n)+'5a'.repeat(n-32),failed=n<32;
 fixtures.push({name:'condition-first-word-'+n,fn:'cond',args:[raw('0x'+bytes),raw('0xcafe'),raw('0xbeef')],failed,expected:failed?error('ReturnDataOutOfBounds',[0n,BigInt(n)]):'beef',kernel:failed?'FirstWordShort':'FirstWord'});
}
const address='0x0000000000000000000000000000000000005301',addressWord=BigInt(address);
for(const [name,v] of [['clean-address',addressWord],['dirty-address',addressWord+(1n<<160n)],['maximum-address-word',(1n<<256n)-1n]]){
 const valid=v<(1n<<160n);fixtures.push({name,fn:'read',args:[raw('0x'+word(v)),'0x00000000',[]],failed:!valid,expected:valid?word(42n):error('InvalidAddressWord',[0n,'0x'+word(v)]),kernel:valid?'AsAddress':'AsAddressDirty'});
}
const connection=await network.connect('hardhatMainnet'),provider=connection.provider,accounts=await provider.request({method:'eth_accounts'}),target='0x0000000000000000000000000000000000005300';
await provider.request({method:'hardhat_setCode',params:[target,code]});await provider.request({method:'hardhat_setCode',params:[address,'0x602a60005260206000f3']});
const results=[];
for(const f of fixtures){
 if(options['--case']&&options['--case']!==f.name)continue;
 const data=encodeFunctionData({abi:artifact.abi,functionName:f.fn,args:f.args}),trace=await provider.request({method:'debug_traceCall',params:[{from:accounts[0],to:target,gas:'0x989680',data,value:'0x0'},'latest',{enableMemory:true,disableStorage:true,disableStack:false}]}),actual=trace.returnValue.replace(/^0x/,''),mapping=JSON.parse(readFileSync(resolve(here,f.kernel+'.mapping.json'))),entry=mapping.entry,logs=trace.structLogs,at=logs.findIndex(x=>x.depth===1&&x.pc===entry),actualPcs=at<0?[]:logs.slice(at,at+mapping.states.length).map(x=>x.pc),expectedPcs=mapping.states.map(x=>x.pc),receiptPassed=trace.failed===f.failed&&actual===f.expected,kernelPassed=JSON.stringify(actualPcs)===JSON.stringify(expectedPcs),passed=receiptPassed&&kernelPassed;
 const name=f.name+'.json';writeFileSync(resolve(out,name),JSON.stringify({name:f.name,data,runtimeSha256:digest,candidate:Boolean(candidate),expectedFailed:f.failed,expectedBytes:f.expected,trace},null,2)+'\n');results.push({name:f.name,kernel:f.kernel,trace:name,expectedFailed:f.failed,actualFailed:trace.failed,expectedBytes:f.expected,actualBytes:actual,receiptPassed,kernelPassed,passed});
}
await connection.close();
const hh=fileURLToPath(import.meta.resolve('hardhat')),edr=createRequire(hh).resolve('@nomicfoundation/edr'),binding=createRequire(edr).resolve('@nomicfoundation/edr-linux-x64-gnu');
writeFileSync(resolve(out,'toolchain.json'),JSON.stringify({nodeVersion:process.version,nodeExecutable:process.execPath,nodeSha256:sha(readFileSync(process.execPath)),hardhatEntry:hh,hardhatEntrySha256:sha(readFileSync(hh)),edrEntry:edr,edrEntrySha256:sha(readFileSync(edr)),edrVersion:JSON.parse(readFileSync(resolve(dirname(edr),'package.json'))).version,nativeBinding:binding,nativeBindingSha256:sha(readFileSync(binding)),lockfileSha256:sha(readFileSync(resolve(root,'pnpm-lock.yaml')))},null,2)+'\n');
if(results.length!==(options['--case']?1:fixtures.length))throw Error('Wrong fixture inventory');writeFileSync(resolve(out,'results.json'),JSON.stringify(results,null,2)+'\n');console.log((results.every(x=>x.passed)?'PASS':'FAIL')+': '+results.length+' complete scalar-helper EVM fixtures');process.exitCode=results.every(x=>x.passed)?0:1;
