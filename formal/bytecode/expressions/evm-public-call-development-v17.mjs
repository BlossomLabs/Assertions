// Exact-runtime scalar helper fixtures. Expectations are independent ABI specs.
import {readFileSync,writeFileSync,mkdirSync} from 'node:fs';
import {resolve,dirname} from 'node:path';
import {fileURLToPath} from 'node:url';
import {createRequire} from 'node:module';
import {createHash} from 'node:crypto';
import {network} from 'hardhat';
import {encodeFunctionData,encodeErrorResult,encodeAbiParameters} from 'viem';
const options={};for(let i=2;i<process.argv.length;i+=2){if(!['--output','--root','--runtime','--case','--mapping-dir'].includes(process.argv[i])||!process.argv[i+1])throw Error('Bad arguments');options[process.argv[i]]=process.argv[i+1];}
const root=resolve(options['--root']??'.'),out=resolve(options['--output']);mkdirSync(out,{recursive:true});
const here=resolve(dirname(fileURLToPath(import.meta.url)),'public-call-development-20261002-v1'),sha=x=>createHash('sha256').update(x).digest('hex');
const artifact=JSON.parse(readFileSync(resolve(root,'artifacts/contracts/Expressions.sol/Expressions.json'))),candidate=options['--runtime']??null,code=candidate?'0x'+readFileSync(candidate).toString('hex'):artifact.deployedBytecode,digest=sha(Buffer.from(code.slice(2),'hex'));
if(!candidate&&digest!==JSON.parse(readFileSync(resolve(root,'formal/bytecode/expressions/identity-20261002/identity.json')))[0].runtimeSha256)throw Error('Runtime drift');
const raw=b=>({paramType:2,fetcherType:0,paramData:b,constraints:[]}),word=n=>BigInt.asUintN(256,n).toString(16).padStart(64,'0'),error=(name,args)=>encodeErrorResult({abi:artifact.abi,errorName:name,args}).slice(2);
const zero='0x0000000000000000000000000000000000000000';
const literal=(valueType,data)=>({kind:0,valueType,data,refs:[],selector:'0x00000000',arguments:''});
const call=(refs)=>({kind:3,valueType:'uint256',data:'0x',refs,selector:'0x00000000',arguments:'()'});
const fixtures=[],selfTarget='0x0000000000000000000000000000000000005300',foreignTarget='0x0000000000000000000000000000000000005301';
const bytesValue=data=>encodeAbiParameters([{type:'bytes'}],[data]);
const probe=(refs)=>({kind:10,valueType:'bytes',data:'0x',refs,selector:'0x00000000',arguments:''});
fixtures.push({name:'foreign-call',fn:'evaluate',args:[{core:zero,nodes:[literal('uint256','0x'+word(BigInt(foreignTarget))),{...call([0n]),selector:'0xfdf54763'}],result:1n},[]],failed:false,expected:word(42n),kernel:'ForeignTarget'});
for(const data of ['0x','0x12','0x123456'])fixtures.push({name:'short-self-'+data.slice(2),fn:'evaluate',args:[{core:zero,nodes:[literal('uint256','0x'+word(BigInt(selfTarget))),literal('bytes',bytesValue(data)),probe([0n,1n])],result:2n},[]],failed:false,expected:bytesValue('0x').slice(2),kernel:'ShortSelfData'});
for(const data of ['0x12345678','0x1234567890'])fixtures.push({name:'other-self-'+data.slice(2),fn:'evaluate',args:[{core:zero,nodes:[literal('uint256','0x'+word(BigInt(selfTarget))),literal('bytes',bytesValue(data)),probe([0n,1n])],result:2n},[]],failed:false,expected:bytesValue('0x').slice(2),kernel:'OtherSelfSelector'});
fixtures.push({name:'forbidden-call',fn:'evaluate',args:[{core:zero,nodes:[literal('uint256','0x'+word(BigInt(selfTarget))),{...call([0n]),selector:'0xfdf54763'}],result:1n},[]],failed:true,expected:error('GuardedCallForbidden',[]),kernel:'GuardedSelfSelector'});
for(const data of ['0xfdf54763','0xfdf5476390'])fixtures.push({name:'forbidden-probe-'+data.slice(2),fn:'evaluate',args:[{core:zero,nodes:[literal('uint256','0x'+word(BigInt(selfTarget))),literal('bytes',bytesValue(data)),probe([0n,1n])],result:2n},[]],failed:true,expected:error('GuardedCallForbidden',[]),kernel:'GuardedSelfSelector'});
const connection=await network.connect('hardhatMainnet'),provider=connection.provider,accounts=await provider.request({method:'eth_accounts'}),target=selfTarget;
await provider.request({method:'hardhat_setCode',params:[target,code]});
await provider.request({method:'hardhat_setCode',params:[foreignTarget,'0x602a60005260206000f3']});
const MOD=1n<<256n;
function translateIf(src) {
 const begin=src.indexOf('(if ');if(begin<0)return src;
 let depth=1,end=begin+1;
 for(;end<src.length;end++){if(src[end]==='(')depth++;if(src[end]===')')depth--;if(depth===0)break;}
 const body=src.slice(begin+4,end);depth=0;let then=-1,otherwise=-1;
 for(let i=0;i<body.length;i++){if(body[i]==='(')depth++;if(body[i]===')')depth--;if(depth===0&&body.startsWith(' then ',i))then=i;if(depth===0&&body.startsWith(' else ',i))otherwise=i;}
 if(then<0||otherwise<then)throw Error('Invalid conditional '+src);
 const inner='(('+translateIf(body.slice(0,then))+')?('+translateIf(body.slice(then+6,otherwise))+'):('+translateIf(body.slice(otherwise+6))+'))';
 return translateIf(src.slice(0,begin)+inner+src.slice(end+1));
}
function expression(text,env) {
 let src=text.replace(/ as nat/g,'').replace(/ as bv256/g,'').replace(/G\.Modulus\(\)/g,'MOD').replace(/J\.Top32/g,'Top32');
 src=translateIf(src);
 if (!/^[a-zA-Z0-9_()+*%<>=!?&^| :.-]+$/.test(src)) throw Error('Unsupported expression '+text);
 const ids=src.match(/[a-zA-Z_]\w*/g)||[];
 if(ids.some(x=>x!=='MOD'&&!['BitNot','ShiftRight','Top32'].includes(x)&&!Object.hasOwn(env,x)))throw Error('Unexpected identifier '+text);
 src=src.replace(/\b[0-9]+\b/g,x=>x+'n');
 return Function(...Object.keys(env),'MOD','BitNot','ShiftRight','Top32','return '+src)(...Object.values(env),MOD,x=>(MOD-1n)^x,(x,n)=>n>=256n?0n:x>>n,x=>x&115792089210356248756420345214020892766250353992003419616917011526809519390720n);
}
function memory(log) { return Buffer.from(log.memory.map(x=>x.replace(/^0x/,'')).join(''),'hex'); }
function load(mem,off) { return BigInt('0x'+mem.subarray(Number(off),Number(off)+32).toString('hex')); }
function checkPhysical(logs,mapping) {
 const first=logs[0],stack=first.stack.map(x=>BigInt('0x'+x.replace(/^0x/,''))),prefix=stack.slice(0,-3),ret=stack.at(-3),targetValue=stack.at(-2),ptr=stack.at(-1);
 let mem=memory(first);const env={ret,ptr,target:targetValue,self:BigInt(target),caller:BigInt(accounts[0]),length:load(mem,ptr),free:load(mem,64n),word:0n};
 if(env.length>=4n)env.word=load(mem,ptr+32n);
 const failures=[];
 for(let i=0;i<mapping.states.length;i++) {
  const expected=mapping.states[i],actual=logs[i];
  if(!actual){failures.push({i,kind:'missing'});break;}
  const wantStack=prefix.concat(expected.stack.map(x=>expression(x,env))),gotStack=actual.stack.map(x=>BigInt('0x'+x.replace(/^0x/,'')));
  if(actual.pc!==expected.pc)failures.push({i,kind:'pc'});
  if(JSON.stringify(wantStack.map(String))!==JSON.stringify(gotStack.map(String)))failures.push({i,kind:'stack'});
  if(!memory(actual).equals(mem))failures.push({i,kind:'memory'});
  if(expected.op===0x52) {
   const off=wantStack.at(-1),value=wantStack.at(-2),end=Number(off)+32;
   if(end>mem.length){const grown=Buffer.alloc(Math.ceil(end/32)*32);mem.copy(grown);mem=grown;}
   Buffer.from(word(value),'hex').copy(mem,Number(off));
  }
 }
 return {passed:failures.length===0,states:mapping.states.length,failures,initial:{ptr:String(ptr),length:String(env.length),target:String(targetValue),self:String(env.self),caller:String(env.caller),free:String(env.free),ret:String(ret),prefix:prefix.map(String)}};
}
function semanticFrame(logs,at,mapping,kernel) {
 const first=logs[at],initial=memory(first),stack=first.stack.map(x=>BigInt('0x'+x.replace(/^0x/,''))),ret=stack.at(-3),prefix=stack.slice(0,-3),forbidden=kernel==='GuardedSelfSelector',finalLog=logs[at+mapping.states.length-(forbidden?1:0)],failures=[];
 if(forbidden){const image=memory(finalLog),free=load(initial,64n);if(!image.subarray(Number(free),Number(free)+4).equals(Buffer.from('b083953a','hex')))failures.push('forbidden-error');}
 else {const result=finalLog.stack.map(x=>BigInt('0x'+x.replace(/^0x/,'')));if(finalLog.pc!==Number(ret)||JSON.stringify(result.map(String))!==JSON.stringify(prefix.map(String)))failures.push('guard-return');if(!memory(finalLog).equals(initial))failures.push('memory-changed');}
 return {passed:failures.length===0,failures};
}
const results=[];
for(const f of fixtures){
 if(options['--case']&&options['--case']!==f.name)continue;
 const data=encodeFunctionData({abi:artifact.abi,functionName:f.fn,args:f.args}),trace=await provider.request({method:'debug_traceCall',params:[{from:accounts[0],to:target,gas:'0x989680',data,value:'0x0'},'latest',{enableMemory:true,disableStorage:true,disableStack:false}]}),actual=trace.returnValue.replace(/^0x/,''),mapping=JSON.parse(readFileSync(resolve(options['--mapping-dir']??here,f.kernel+'.mapping.json'))),entry=mapping.entry,logs=trace.structLogs,at=logs.findIndex(x=>x.depth===1&&x.pc===entry),actualPcs=at<0?[]:logs.slice(at,at+mapping.states.length).map(x=>x.pc),expectedPcs=mapping.states.map(x=>x.pc),receiptPassed=trace.failed===f.failed&&actual===f.expected,kernelPassed=JSON.stringify(actualPcs)===JSON.stringify(expectedPcs),physical=at<0?{passed:false,failures:[{kind:"unreached"}]}:checkPhysical(logs.slice(at,at+mapping.states.length),mapping),frame=at<0?{passed:false,failures:["unreached"]}:semanticFrame(logs,at,mapping,f.kernel),passed=receiptPassed&&kernelPassed&&physical.passed&&frame.passed;
 const name=f.name+'.json';writeFileSync(resolve(out,name),JSON.stringify({name:f.name,data,runtimeSha256:digest,candidate:Boolean(candidate),expectedFailed:f.failed,expectedBytes:f.expected,trace},null,2)+'\n');results.push({name:f.name,kernel:f.kernel,trace:name,expectedFailed:f.failed,actualFailed:trace.failed,expectedBytes:f.expected,actualBytes:actual,receiptPassed,kernelPassed,physical,frame,passed});
}
await connection.close();
const hh=fileURLToPath(import.meta.resolve('hardhat')),edr=createRequire(hh).resolve('@nomicfoundation/edr'),binding=createRequire(edr).resolve('@nomicfoundation/edr-linux-x64-gnu');
writeFileSync(resolve(out,'toolchain.json'),JSON.stringify({nodeVersion:process.version,nodeExecutable:process.execPath,nodeSha256:sha(readFileSync(process.execPath)),hardhatEntry:hh,hardhatEntrySha256:sha(readFileSync(hh)),edrEntry:edr,edrEntrySha256:sha(readFileSync(edr)),edrVersion:JSON.parse(readFileSync(resolve(dirname(edr),'package.json'))).version,nativeBinding:binding,nativeBindingSha256:sha(readFileSync(binding)),lockfileSha256:sha(readFileSync(resolve(root,'pnpm-lock.yaml')))},null,2)+'\n');
if(results.length!==(options['--case']?1:fixtures.length))throw Error('Wrong fixture inventory');writeFileSync(resolve(out,'results.json'),JSON.stringify(results,null,2)+'\n');console.log((results.every(x=>x.passed)?'PASS':'FAIL')+': '+results.length+' Expressions public-call guard EVM fixtures');process.exitCode=results.every(x=>x.passed)?0:1;
