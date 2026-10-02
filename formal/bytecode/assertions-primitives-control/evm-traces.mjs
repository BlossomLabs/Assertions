// Exact-runtime primitive orchestration fixtures with independent ABI outcomes.
import {readFileSync,writeFileSync,mkdirSync} from 'node:fs';
import {resolve,dirname} from 'node:path';
import {fileURLToPath} from 'node:url';
import {createRequire} from 'node:module';
import {createHash} from 'node:crypto';
import {network} from 'hardhat';
import {encodeFunctionData,encodeErrorResult,encodeAbiParameters} from 'viem';
const options={};for(let i=2;i<process.argv.length;i+=2){if(!['--output','--root','--runtime','--case'].includes(process.argv[i])||!process.argv[i+1])throw Error('Bad arguments');options[process.argv[i]]=process.argv[i+1];}
const root=resolve(options['--root']??'.'),out=resolve(options['--output']);mkdirSync(out,{recursive:true});
const here=dirname(fileURLToPath(import.meta.url)),sha=x=>createHash('sha256').update(x).digest('hex');
const artifact=JSON.parse(readFileSync(resolve(root,'artifacts/contracts/Assertions.sol/Assertions.json'))),candidate=options['--runtime']??null,code=candidate?'0x'+readFileSync(candidate).toString('hex'):artifact.deployedBytecode,digest=sha(Buffer.from(code.slice(2),'hex'));
if(!candidate&&digest!==JSON.parse(readFileSync(resolve(root,'formal/bytecode/dispatch/inventory.json'))).Assertions.runtimeSha256)throw Error('Runtime drift');
const raw=b=>({paramType:2,fetcherType:0,paramData:b,constraints:[]}),word=n=>BigInt.asUintN(256,n).toString(16).padStart(64,'0'),error=(name,args)=>encodeErrorResult({abi:artifact.abi,errorName:name,args}).slice(2);
const target='0x0000000000000000000000000000000000005300',a='0x0000000000000000000000000000000000005301',b='0x0000000000000000000000000000000000005302',c='0x0000000000000000000000000000000000005303',bad='0x0000000000000000000000000000000000005304',empty='0x0000000000000000000000000000000000005305';
const call=(address,bytes='0x')=>({paramType:2,fetcherType:1,paramData:encodeAbiParameters([{type:'address'},{type:'bytes'}],[address,bytes]),constraints:[]});
const fixtures=[],add=(name,fn,args,expected,segments=[],failed=false)=>fixtures.push({name,fn,args,expected:expected.replace(/^0x/,''),segments,failed});
for(const n of [0,1,33,257]){const bytes='af'.repeat(n);add('resolve-'+n,'resolve',[raw('0x'+bytes)],bytes,['ResolveStart','RawReturn']);}
for(const truth of [0n,1n])add('condition-'+truth,'cond',[raw('0x'+word(truth)),raw('0xcafe'),raw('0xbeef')],truth===0n?'beef':'cafe',['CondStart','CondFirstWord',truth===0n?'CondFalse':'CondTrue','RawReturn']);
add('condition-short','cond',[raw('0x11'),raw('0xcafe'),raw('0xbeef')],error('ReturnDataOutOfBounds',[0n,1n]),['CondStart','CondFirstWord'],true);
add('pick-last','pick',[raw('0x'+word(5n)+word(11n)),-1n],word(11n),['PickStart','PickWord','PickExit']);
for(const n of [0,1,2,17,130]){const bytes=Array.from({length:n},(_,i)=>'0x'+(i%4===0?'':(i%4===1?'a5'.repeat(31):i%4===2?word(BigInt(i+3)):'c3'.repeat(65))));const segments=n===0?['GatherStartZero','GatherDoneExit']:['GatherStart','GatherFillLast','GatherHeaderExit','GatherNext','GatherParam','GatherValueStore','GatherDoneExit'];if(n>1)segments.push('GatherFill');add('gather-'+n,'gather',[bytes.map(raw)],encodeAbiParameters([{type:'bytes[]'}],[bytes]),segments);}
add('read-selector','read',[raw('0x'+word(BigInt(c))),'0x11223344',[]],word(42n),['ReadStart','FirstWordRelay','AddressRelay','RawReturn']);
add('read-segments','read',[raw('0x'+word(BigInt(c))),'0x11223344',[raw('0xaa'),raw('0x'+word(17n)),raw('0xbbcc')]],word(42n),['ReadStart','FirstWordRelay','AddressRelay','RawReturn']);
add('chain-empty','chain',[raw('0x'+word(BigInt(c))),[]],error('EmptyCallChain',[]),['ChainEmpty'],true);
add('chain-one','chain',[raw('0x'+word(BigInt(c))),['0x11223344']],word(42n),['ChainStart','FirstWordRelay','AddressRelay','ChainAfterAddress','ChainAfterLast','RawReturn']);
add('chain-three','chain',[raw('0x'+word(BigInt(a))),['0x11223344','0x55667788','0x90abcdef']],word(42n),['ChainStart','FirstWordRelay','AddressRelay','ChainAfterAddress','ChainAfterLast','RawReturn']);
add('orElse-success','orElse',[raw('0xaabb'),raw('0xface')],'aabb',['OrElseRouteSuccess','OrElseReturn']);
add('orElse-fallback','orElse',[call(bad),raw('0xface')],'face',['OrElseRouteFailure','OrElseFallback','RawReturn']);
add('orElse-fallback-constraint','orElse',[call(bad),{...raw('0x'+word(5n)),constraints:[{constraintType:0,referenceData:'0x'+word(7n)}]}],error('ConstraintFailed',['',0n,1n,0n,0,'0x'+word(5n),'0x'+word(7n)]),['OrElseRouteFailure','OrElseFallback'],true);
add('isValid-false-value','isValid',[raw('0x'+word(0n))],word(1n),['IsValidRouteSuccess','IsValidFinishTrue']);
add('isValid-failure','isValid',[call(bad)],word(0n),['IsValidRouteFailure','IsValidFinishFalse']);
add('revertData-whole','revertData',[call(bad),'0x00000000'],'deadbeef');
add('revertData-strip','revertData',[call(bad),'0xdeadbeef'],'');
add('revertData-mismatch','revertData',[call(bad),'0xfeedface'],error('UnexpectedRevertData',['0xfeedface','0xdeadbeef']),[],true);
add('revertData-empty','revertData',[call(empty),'0x00000000'],'');
add('revertData-literal','revertData',[raw('0xdeadbeef'),'0x00000000'],error('RevertProbeNotACall',[0]),[],true);
const connection=await network.connect('hardhatMainnet'),provider=connection.provider,accounts=await provider.request({method:'eth_accounts'});
for(const [address,runtime] of [[target,code],[a,'0x73'+b.slice(2)+'60005260206000f3'],[b,'0x73'+c.slice(2)+'60005260206000f3'],[c,'0x602a60005260206000f3'],[bad,'0x63deadbeef6000526004601cfd']])await provider.request({method:'hardhat_setCode',params:[address,runtime]});
const results=[];
for(const f of fixtures){if(options['--case']&&options['--case']!==f.name)continue;
 const data=encodeFunctionData({abi:artifact.abi,functionName:f.fn,args:f.args}),trace=await provider.request({method:'debug_traceCall',params:[{from:accounts[0],to:target,gas:'0x989680',data,value:'0x0'},'latest',{enableMemory:f.name!=='gather-130',disableStorage:true,disableStack:false}]}),actual=trace.returnValue.replace(/^0x/,''),receiptPassed=trace.failed===f.failed&&actual===f.expected;
 const logs=trace.structLogs.filter(x=>x.depth===1),segmentResults=f.segments.map(name=>{const m=JSON.parse(readFileSync(resolve(here,name+'.mapping.json'))),expected=m.states.map(s=>s.pc),at=logs.findIndex((x,i)=>x.pc===expected[0]&&JSON.stringify(logs.slice(i,i+expected.length).map(s=>s.pc))===JSON.stringify(expected));return {name,passed:at>=0};}),passed=receiptPassed&&segmentResults.every(x=>x.passed),name=f.name+'.json';
 writeFileSync(resolve(out,name),JSON.stringify({name:f.name,data,runtimeSha256:digest,candidate:Boolean(candidate),expectedFailed:f.failed,expectedBytes:f.expected,trace},null,2)+'\n');results.push({name:f.name,trace:name,expectedFailed:f.failed,actualFailed:trace.failed,expectedBytes:f.expected,actualBytes:actual,receiptPassed,segmentResults,passed});
}
await connection.close();
const hh=fileURLToPath(import.meta.resolve('hardhat')),edr=createRequire(hh).resolve('@nomicfoundation/edr'),binding=createRequire(edr).resolve('@nomicfoundation/edr-linux-x64-gnu');
writeFileSync(resolve(out,'toolchain.json'),JSON.stringify({nodeVersion:process.version,nodeExecutable:process.execPath,nodeSha256:sha(readFileSync(process.execPath)),hardhatEntry:hh,hardhatEntrySha256:sha(readFileSync(hh)),edrEntry:edr,edrEntrySha256:sha(readFileSync(edr)),edrVersion:JSON.parse(readFileSync(resolve(dirname(edr),'package.json'))).version,nativeBinding:binding,nativeBindingSha256:sha(readFileSync(binding)),lockfileSha256:sha(readFileSync(resolve(root,'pnpm-lock.yaml')))},null,2)+'\n');
if(results.length!==(options['--case']?1:fixtures.length))throw Error('Wrong fixture inventory');writeFileSync(resolve(out,'results.json'),JSON.stringify(results,null,2)+'\n');console.log((results.every(x=>x.passed)?'PASS':'FAIL')+': '+results.length+' primitive-orchestration EVM fixtures');process.exitCode=results.every(x=>x.passed)?0:1;
