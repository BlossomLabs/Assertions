// Development only: exact current integer-modular power physical receipts and path inventory.
import {readFileSync,writeFileSync,mkdirSync} from 'node:fs';
import {resolve,dirname} from 'node:path';
import {createRequire} from 'node:module';
import {fileURLToPath} from 'node:url';
import {createHash} from 'node:crypto';
import {network} from 'hardhat';
const out=resolve(process.argv[2]);mkdirSync(out,{recursive:true});
const artifact=JSON.parse(readFileSync('artifacts/contracts/Operations.sol/Operations.json'));
const inventory=JSON.parse(readFileSync(new URL('../inventory.json',import.meta.url)));
const runtime=artifact.deployedBytecode,sha=x=>createHash('sha256').update(x).digest('hex');
const digest=sha(Buffer.from(runtime.slice(2),'hex'));if(digest!==inventory.runtimeSha256)throw Error('Runtime drift');
const M=1n<<256n,H=M/2n,MAX=M-1n,word=x=>((x%M+M)%M).toString(16).padStart(64,'0');
const panic='4e487b71'+word(18n),threshold=1n<<32n;
const gate=JSON.parse(readFileSync(new URL('../modexp-entry-preparation/source-gate.json',import.meta.url)));
const inverseError=gate.errorSelectors.ModularInverseDoesNotExist;
if(inverseError!=='1bba72ee')throw Error('Compiler error selector drift');
const magnitude=x=>x<0n?-x:x;
const modularPower=(a,b,m)=>{let result=1n%m;a%=m;while(b){if(b&1n)result=result*a%m;b>>=1n;if(b)a=a*a%m;}return result;};
const inverse=(a,m)=>{let old=m,next=a%m,x=0n,y=1n;while(next){let q=old/next;[old,next]=[next,old-q*next];[x,y]=[y,x-q*y];}return old===1n?(x%m+m)%m:null;};
const oracle=(a,e,m,signedBase,signedExponent)=>{
 const base=magnitude(a),modulus=signedBase?magnitude(m):m;
 if(modulus===0n)return {expected:panic,error:true,reason:'ZeroModulus'};
 let factor=signedBase?base:a;
 if(signedExponent&&e<0n){factor=modulus===1n?0n:inverse(factor,modulus);if(factor===null)return {expected:inverseError+word(signedBase?base:a)+word(modulus),error:true,reason:'NoInverse'};}
 let result=modularPower(factor,magnitude(e),modulus);
 if(signedBase&&a<0n&&(magnitude(e)&1n))result=-result;
 return {expected:word(result),error:false,reason:'Success'};
};
const common=[[0n,0n,0n],[0n,0n,1n],[0n,1n,17n],[1n,MAX,17n],[2n,0n,17n],[2n,1n,17n],[2n,31n,17n],[2n,threshold-1n,17n],[2n,threshold,17n],[2n,MAX,17n],[MAX,255n,MAX],[MAX,threshold,MAX],[H,2n,H],[1234567n,17n,1000000007n],[6n,7n,9n]];
const families=[['UU','powMod(uint256,uint256,uint256)',false,false],['SU','powMod(int256,uint256,int256)',true,false],['US','powMod(uint256,int256,uint256)',false,true],['SS','powMod(int256,int256,int256)',true,true]];
const c=await network.connect('hardhatMainnet'),p=c.provider,target='0x0000000000000000000000000000000000002318';const accounts=await p.request({method:'eth_accounts'});await p.request({method:'hardhat_setCode',params:[target,runtime]});
const cases=[];
for(const [kind,signature,signedBase,signedExponent] of families){
 const selector=inventory.compilerIdentity.methodIdentifiers[signature];if(!selector)throw Error('Missing compiler selector');
 const vectors=common.map(([a,e,m])=>[signedBase&&a>=H?a-M:a,signedExponent&&e>=H?e-M:e,signedBase&&m>=H?m-M:m]);
 if(signedBase)vectors.push([-3n,3n,-17n],[-H,1n,-H],[-H,threshold,-H]);
 if(kind==='SU')vectors.push([3n,3n,-17n],[-3n,3n,17n],[-3n,2n,17n],[-3n,0n,17n],[-3n,3n,0n],[3n,3n,0n]);
 if(signedExponent)vectors.push([2n,-1n,17n],[2n,-3n,17n],[6n,-1n,9n],[0n,-1n,1n],[2n,-H,17n],[2n,-1n,0n]);
 for(const [ordinal,[a,e,m]] of vectors.entries()){const result=oracle(a,e,m,signedBase,signedExponent);cases.push({name:kind+'-'+ordinal,kind,signature,selector,a:a.toString(),exponent:e.toString(),modulus:m.toString(),data:'0x'+selector+word(a)+word(e)+word(m)+(ordinal%3===0?'a5'.repeat(17):''),value:'0x0',...result});}
 for(const size of [0,1,2,3,4,5,35,36,67,99])cases.push({name:kind+'-short-'+size,kind,signature,selector,data:'0x'+(selector+word(2n)+word(3n)+word(17n)).slice(0,size*2),value:'0x0',expected:'',error:true,reason:'RawRejection'});
 cases.push({name:kind+'-nonzero',kind,signature,selector,data:'0x'+selector+word(2n)+word(3n)+word(17n),value:'0x1',expected:'',error:true,reason:'RawRejection'});
}
const results=[];let failures=0;
for(const [ordinal,item] of cases.entries()){
 const trace=await p.request({method:'debug_traceCall',params:[{from:accounts[0],to:target,data:item.data,value:item.value,gas:'0x989680'},'latest',{enableMemory:true,disableStorage:true,disableStack:false}]});
 const file=item.name+'.json',actual=trace.returnValue.replace(/^0x/,'');writeFileSync(resolve(out,file),JSON.stringify({...item,ordinal,runtimeSha256:digest,trace},null,2)+'\n');
 const last=trace.structLogs.at(-1),nat=x=>BigInt('0x'+x.replace(/^0x/,'')),offset=nat(last.stack.at(-1)),length=nat(last.stack.at(-2)),memory=last.memory.map(w=>w.replace(/^0x/,'')).join('');
 const physical=memory.slice(Number(offset*2n),Number((offset+length)*2n));
 const passed=trace.failed===item.error&&actual===item.expected&&physical===item.expected&&last.op===(item.error?'REVERT':'RETURN')&&trace.structLogs.every(s=>s.depth===1);
 if(!passed)failures++;
 results.push({...item,ordinal,trace:file,actual,passed,instructions:trace.structLogs.length,terminalPc:last.pc,physicalOffset:offset.toString(),physicalLength:length.toString(),staticCalls:trace.structLogs.filter(s=>s.op==='STATICCALL').map(s=>({pc:s.pc,target:nat(s.stack.at(-2)).toString(),inputOffset:nat(s.stack.at(-3)).toString(),inputLength:nat(s.stack.at(-4)).toString(),outputOffset:nat(s.stack.at(-5)).toString(),outputLength:nat(s.stack.at(-6)).toString(),input:s.memory.map(x=>x.replace(/^0x/,'')).join('').slice(Number(nat(s.stack.at(-3))*2n),Number((nat(s.stack.at(-3))+nat(s.stack.at(-4)))*2n))})),reachedExpPcs:[...new Set(trace.structLogs.filter(s=>s.op==='EXP').map(s=>s.pc))],reachedMulPcs:[...new Set(trace.structLogs.filter(s=>s.op==='MUL').map(s=>s.pc))],reachedShrPcs:[...new Set(trace.structLogs.filter(s=>s.op==='SHR').map(s=>s.pc))]});
}
const hh=fileURLToPath(import.meta.resolve('hardhat')),edr=createRequire(hh).resolve('@nomicfoundation/edr'),binding=createRequire(edr).resolve('@nomicfoundation/edr-linux-x64-gnu');
writeFileSync(resolve(out,'toolchain.json'),JSON.stringify({nodeVersion:process.version,nodeExecutable:process.execPath,nodeSha256:sha(readFileSync(process.execPath)),hardhatEntry:hh,hardhatEntrySha256:sha(readFileSync(hh)),edrEntry:edr,edrEntrySha256:sha(readFileSync(edr)),edrVersion:JSON.parse(readFileSync(resolve(dirname(edr),'package.json'))).version,nativeBinding:binding,nativeBindingSha256:sha(readFileSync(binding)),lockfileSha256:sha(readFileSync('pnpm-lock.yaml'))},null,2)+'\n');
await c.close();writeFileSync(resolve(out,'results.json'),JSON.stringify(results,null,2)+'\n');
writeFileSync(resolve(out,'scope.json'),JSON.stringify({status:'development-concrete-only-no-public-credit',runtimeSha256:digest,receipts:results.length,scope:'Physical baseline modular-power integer outcomes, exact Panic18/custom inverse errors, explicit MODEXP observations and raw empty rejections. Complete universal raw/opcode/loop proofs, independent full memory replay, matching mutation campaign and retained independent checker remain open. No bytecode public/gas/deployment/performance claim.'},null,2)+'\n');
if(failures)throw Error('Wrong modular power physical receipt '+failures);console.log('PASS development '+results.length+' modular power physical receipts; no public proof credit');
