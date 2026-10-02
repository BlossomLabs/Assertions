// Development only: exact current integer-power physical receipts and path inventory.
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
const panic='4e487b71'+word(17n);
// Unsigned expectation is an independent unbounded power, with a proved-later
// lower bound shortcut for b>=256 and a>=2; no VM outcome selects the oracle.
const unsigned=(a,b)=>a===0n?(b===0n?1n:0n):a===1n?1n:b>=256n?null:(a**b<M?a**b:null);
// Signed API declares checked intermediates. This integer oracle follows the
// independent source Outcome.Trace specification; successful ideal-power
// correspondence and all compiled steps remain proof obligations.
const signed=(a,b)=>{let r=1n;while(b!==0n){if(b%2n){r*=a;if(r < -H || r>=H)return null;}b/=2n;if(b){a*=a;if(a < -H || a>=H)return null;}}return r;};
const U=[[0n,0n],[0n,1n],[0n,MAX],[1n,MAX],[2n,0n],[2n,1n],[2n,254n],[2n,255n],[2n,256n],[2n,MAX],[3n,31n],[3n,161n],[3n,162n],[10n,77n],[10n,78n],[306n,31n],[306n,32n],[307n,31n],[1000n,25n],[1000n,26n],[MAX,0n],[MAX,1n],[MAX,2n],[H,1n],[H,2n]];
const S=[[0n,0n],[0n,1n],[0n,MAX],[1n,MAX],[-1n,MAX],[-1n,MAX-1n],[2n,254n],[2n,255n],[-2n,254n],[-2n,255n],[-2n,256n],[-H,0n],[-H,1n],[-H,2n],[H-1n,1n],[H-1n,2n],[3n,31n],[-3n,31n],[3n,161n],[-3n,161n],[3n,162n],[-3n,162n]];
const c=await network.connect('hardhatMainnet'),p=c.provider,target='0x0000000000000000000000000000000000002317';const accounts=await p.request({method:'eth_accounts'});await p.request({method:'hardhat_setCode',params:[target,runtime]});
const cases=[];
for(const [kind,signature,vectors,oracle] of [['Unsigned','exp(uint256,uint256)',U,unsigned],['Signed','exp(int256,uint256)',S,signed]]){
 const selector=inventory.compilerIdentity.methodIdentifiers[signature];if(!selector)throw Error('Missing compiler selector');
 for(const [ordinal,[a,b]] of vectors.entries()){const result=oracle(a,b);cases.push({name:kind+'-'+ordinal,kind,signature,selector,a:a.toString(),b:b.toString(),data:'0x'+selector+word(a)+word(b)+(ordinal%3===0?'a5'.repeat(17):''),value:'0x0',expected:result===null?panic:word(result),error:result===null});}
 for(const size of [0,1,2,3,4,5,35,36,67])cases.push({name:kind+'-short-'+size,kind,signature,selector,data:'0x'+(selector+word(1n)+word(2n)).slice(0,size*2),value:'0x0',expected:'',error:true});
 cases.push({name:kind+'-nonzero',kind,signature,selector,data:'0x'+selector+word(1n)+word(2n),value:'0x1',expected:'',error:true});
}
const results=[];let failures=0;
for(const [ordinal,item] of cases.entries()){
 const trace=await p.request({method:'debug_traceCall',params:[{from:accounts[0],to:target,data:item.data,value:item.value,gas:'0x989680'},'latest',{enableMemory:true,disableStorage:true,disableStack:false}]});
 const file=item.name+'.json',actual=trace.returnValue.replace(/^0x/,'');writeFileSync(resolve(out,file),JSON.stringify({...item,ordinal,runtimeSha256:digest,trace},null,2)+'\n');
 const last=trace.structLogs.at(-1),nat=x=>BigInt('0x'+x.replace(/^0x/,'')),offset=nat(last.stack.at(-1)),length=nat(last.stack.at(-2)),memory=last.memory.map(w=>w.replace(/^0x/,'')).join('');
 const physical=memory.slice(Number(offset*2n),Number((offset+length)*2n));
 const passed=trace.failed===item.error&&actual===item.expected&&physical===item.expected&&last.op===(item.error?'REVERT':'RETURN')&&trace.structLogs.every(s=>s.depth===1);
 if(!passed)failures++;
 results.push({...item,ordinal,trace:file,actual,passed,instructions:trace.structLogs.length,terminalPc:last.pc,physicalOffset:offset.toString(),physicalLength:length.toString(),reachedExpPcs:[...new Set(trace.structLogs.filter(s=>s.op==='EXP').map(s=>s.pc))],reachedMulPcs:[...new Set(trace.structLogs.filter(s=>s.op==='MUL').map(s=>s.pc))],reachedShrPcs:[...new Set(trace.structLogs.filter(s=>s.op==='SHR').map(s=>s.pc))]});
}
const hh=fileURLToPath(import.meta.resolve('hardhat')),edr=createRequire(hh).resolve('@nomicfoundation/edr'),binding=createRequire(edr).resolve('@nomicfoundation/edr-linux-x64-gnu');
writeFileSync(resolve(out,'toolchain.json'),JSON.stringify({nodeVersion:process.version,nodeExecutable:process.execPath,nodeSha256:sha(readFileSync(process.execPath)),hardhatEntry:hh,hardhatEntrySha256:sha(readFileSync(hh)),edrEntry:edr,edrEntrySha256:sha(readFileSync(edr)),edrVersion:JSON.parse(readFileSync(resolve(dirname(edr),'package.json'))).version,nativeBinding:binding,nativeBindingSha256:sha(readFileSync(binding)),lockfileSha256:sha(readFileSync('pnpm-lock.yaml'))},null,2)+'\n');
await c.close();writeFileSync(resolve(out,'results.json'),JSON.stringify(results,null,2)+'\n');
writeFileSync(resolve(out,'scope.json'),JSON.stringify({status:'development-concrete-only-no-public-credit',runtimeSha256:digest,receipts:results.length,scope:'Physical baseline integer power returns, exact Panic17 and raw empty rejections. Complete universal raw/opcode/loop proofs, independent full memory replay, matching mutation campaign and retained independent checker remain open. No bytecode public/gas/deployment/performance claim.'},null,2)+'\n');
if(failures)throw Error('Wrong power physical receipt '+failures);console.log('PASS development '+results.length+' power physical receipts; no public proof credit');
