// Concrete independent ABI fixtures corroborate complete physical helper paths.
import {readFileSync,writeFileSync,mkdirSync} from 'node:fs';
import {resolve,dirname} from 'node:path';
import {createRequire} from 'node:module';
import {fileURLToPath} from 'node:url';
import {createHash} from 'node:crypto';
import {network} from 'hardhat';
import {encodeFunctionData,encodeErrorResult,toHex} from 'viem';
const out=resolve(process.argv[2]);mkdirSync(out,{recursive:true});
const candidate=process.argv[3]??null;
const artifact=JSON.parse(readFileSync('artifacts/contracts/Assertions.sol/Assertions.json'));
const runtime=candidate?'0x'+readFileSync(candidate).toString('hex'):artifact.deployedBytecode;
const sha=x=>createHash('sha256').update(x).digest('hex');
const digest=sha(Buffer.from(runtime.slice(2),'hex'));
const inventory=JSON.parse(readFileSync(new URL('./inventory.json',import.meta.url)));
if(!candidate&&inventory.runtimeSha256!==digest)throw new Error('Exact runtime drift');
const modulo=1n<<256n,word=x=>toHex((BigInt(x)%modulo+modulo)%modulo,{size:32});
const cases=[];
for(const kind of [0,1,2,3,4,5,7,8]){
 cases.push({name:`Kind${kind}BadData`,kind,reference:'0xa5',actual:7n,verdict:'BadData'});
 if(kind===3||kind===8){
  for(const [label,actual,lower,upper,verdict] of [['BadRange',7n,10n,5n,'BadRange'],['Below',4n,5n,10n,'Fails'],['Inside',7n,5n,10n,'Holds'],['Above',12n,5n,10n,'Fails']])
   cases.push({name:`Kind${kind}${label}`,kind,actual,reference:word(lower)+word(upper).slice(2),verdict});
 }else cases.push({name:`Kind${kind}Valid`,kind,actual:7n,reference:kind===7?'0x':word(5n),verdict:kind===0||kind===2||kind===5?'Fails':'Holds'});
}
// Additional two's-complement extremes do not generate or bound the theorem.
for(const [label,kind,actual,lower,upper,verdict] of [
 ['signed-lower-extreme',8,modulo/2n,modulo/2n,modulo/2n+1n,'Holds'],
 ['signed-upper-extreme',8,modulo/2n-1n,modulo/2n-2n,modulo/2n-1n,'Holds'],
 ['signed-wrap-bad-range',8,0n,modulo/2n-1n,modulo/2n,'BadRange'],
 ['unsigned-wrap-outside',3,modulo-1n,0n,modulo-2n,'Fails'],
 ['signed-negative-gte',4,modulo-1n,modulo-2n,0n,'Holds'],
 ['signed-negative-lte',5,modulo-2n,modulo-1n,0n,'Holds']])
 cases.push({name:label,kind,actual,reference:kind===3||kind===8?word(lower)+word(upper).slice(2):word(lower),verdict});
const connection=await network.connect('hardhatMainnet'),provider=connection.provider;
const [from]=await provider.request({method:'eth_accounts'}),target='0x0000000000000000000000000000000000006600';
await provider.request({method:'hardhat_setCode',params:[target,runtime]});
const nat=x=>BigInt('0x'+x.replace(/^0x/,'')),mem=r=>Buffer.from(r.memory.map(w=>w.replace(/^0x/,'')).join(''),'hex');
const read=(bytes,offset)=>BigInt('0x'+bytes.subarray(Number(offset),Number(offset)+32).toString('hex'));
const results=[];
for(const c of cases){
 const value=word(c.actual),param={paramType:0,fetcherType:0,paramData:value,constraints:[{constraintType:c.kind,referenceData:c.reference}]};
 const data=encodeFunctionData({abi:artifact.abi,functionName:'resolve',args:[param]});
 const referenceLength=(c.reference.length-2)/2;
 const expected=c.verdict==='Holds'?value:
  c.verdict==='BadData'?'0xe70ce766'+word(0).slice(2).repeat(3)+word(referenceLength).slice(2):
  c.verdict==='BadRange'?'0x295a41c5'+word(0).slice(2).repeat(3):
  encodeErrorResult({abi:artifact.abi,errorName:'ConstraintFailed',args:['',0n,0n,0n,c.kind,value,c.reference]});
 const trace=await provider.request({method:'debug_traceCall',params:[{from,to:target,data,value:'0x0',gas:'0x989680'},'latest',{enableMemory:true,disableStorage:true,disableStack:false}]});
 const parent=trace.structLogs.filter(r=>r.depth===1),start=parent.findIndex(r=>r.pc===10646),errors=[];
 if(trace.failed!==(c.verdict!=='Holds')||'0x'+trace.returnValue.replace(/^0x/,'')!==expected)errors.push('Exact physical public receipt differs');
 if(start<0)errors.push('Physical leaf helper not reached');
 else{
  const initial=parent[start],stack=initial.stack.map(nat),[ret,actual,constraint,entry,paramIndex,index]=stack.slice(-6),bytes=mem(initial),reference=read(bytes,constraint+32n),free=read(bytes,64n);
  if(actual!==c.actual||entry!==0n||paramIndex!==0n||index!==0n||read(bytes,constraint)!==BigInt(c.kind)||read(bytes,reference)!==BigInt(referenceLength)||free<128n)errors.push('Caller representation boundary differs');
  const end=(c.verdict==='BadData'||c.verdict==='BadRange')?parent.length-1:parent.findIndex((r,i)=>i>start&&r.pc===Number(ret));
  if(end<start)errors.push('Complete physical helper terminal missing');
  if(c.verdict==='BadData'||c.verdict==='BadRange'){
   const final=parent.at(-1),output=mem(final),offset=nat(final.stack.at(-1)),length=nat(final.stack.at(-2));
   if(final.op!=='REVERT'||'0x'+output.subarray(Number(offset),Number(offset+length)).toString('hex')!==expected)errors.push('Physical error serialization differs');
  }else{
   const final=parent[end],s=final.stack.map(nat),truth=c.verdict==='Holds'?1n:0n;
   if(s.length!==stack.length-5||s.at(-1)!==truth||!mem(final).equals(bytes))errors.push('Complete helper return stack or memory differs');
  }
  if(inventory.cases.some(item=>item.name===c.name)){
   const mapping=JSON.parse(readFileSync(new URL('./'+c.name+'.mapping.json',import.meta.url)));
   const actualPcs=parent.slice(start,start+mapping.states.length).map(r=>r.pc);
   if(JSON.stringify(actualPcs)!==JSON.stringify(mapping.states.map(s=>s.pc)))errors.push('Complete instruction PC path differs from generated certificate');
  }
 }
 const path=c.name+'.json';writeFileSync(resolve(out,path),JSON.stringify({fixture:c,runtimeSha256:digest,candidate:Boolean(candidate),data,expected,trace},(_,v)=>typeof v==='bigint'?v.toString():v,2)+'\n');
 results.push({name:c.name,passed:errors.length===0,errors,trace:path,verdict:c.verdict});
}
await connection.close();
const hh=fileURLToPath(import.meta.resolve('hardhat')),edr=createRequire(hh).resolve('@nomicfoundation/edr'),binding=createRequire(edr).resolve('@nomicfoundation/edr-linux-x64-gnu');
writeFileSync(resolve(out,'toolchain.json'),JSON.stringify({nodeVersion:process.version,nodeExecutable:process.execPath,nodeSha256:sha(readFileSync(process.execPath)),hardhatEntry:hh,hardhatEntrySha256:sha(readFileSync(hh)),edrEntry:edr,edrEntrySha256:sha(readFileSync(edr)),nativeBinding:binding,nativeBindingSha256:sha(readFileSync(binding)),lockfileSha256:sha(readFileSync('pnpm-lock.yaml'))},null,2)+'\n');
writeFileSync(resolve(out,'results.json'),JSON.stringify(results,null,2)+'\n');
console.log((results.every(r=>r.passed)?'PASS':'FAIL')+': '+results.length+' physical leaf helper fixtures');
process.exitCode=results.every(r=>r.passed)?0:1;
