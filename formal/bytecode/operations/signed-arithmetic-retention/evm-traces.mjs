// Complete two-branch physical min/max fixtures; native correspondence is separate.
import {readFileSync,writeFileSync,mkdirSync} from 'node:fs';
import {resolve,dirname} from 'node:path';
import {createRequire} from 'node:module';
import {fileURLToPath} from 'node:url';
import {createHash} from 'node:crypto';
import {network} from 'hardhat';
const out=resolve(process.argv[2]);mkdirSync(out,{recursive:true});const candidate=process.argv[3]??null;const art=JSON.parse(readFileSync('artifacts/contracts/Operations.sol/Operations.json'));const runtime=candidate?'0x'+readFileSync(candidate).toString('hex'):art.deployedBytecode;
const sha=x=>createHash('sha256').update(x).digest('hex');const digest=sha(Buffer.from(runtime.slice(2),'hex'));const inv=JSON.parse(readFileSync(new URL('../inventory.json',import.meta.url)));if(!candidate&&digest!==inv.runtimeSha256)throw new Error('Runtime drift');
const c=await network.connect('hardhatMainnet'),p=c.provider,target='0x0000000000000000000000000000000000002296';const accounts=await p.request({method:'eth_accounts'});await p.request({method:'hardhat_setCode',params:[target,runtime]});
const M=1n<<256n,H=M>>1n,MAX=M-1n;const signed=x=>x<H?x:x-M;
const pairs=[[0n,0n],[1n,2n],[2n,1n],[123n,456n],[456n,123n],[MAX,MAX],[0n,MAX],[MAX,0n],[H,H-1n],[H-1n,H],[H,MAX],[MAX,H],[H+1n,H],[H,H+1n]];
const families=[['AddS','a5f3c23b',false],['SubS','adefc37b',true]];const results=[];let failures=0;
const panic='4e487b71'+(17n).toString(16).padStart(64,'0');const panicWord=0x4e487b71n<<224n;
for(const [name,selector,isMod] of families)for(const [ordinal,[a,b]] of pairs.entries()){
 const total=isMod?signed(a)-signed(b):signed(a)+signed(b);const error=total < -H || total>=H;const result=error?null:(total+M)%M;const expected=error?panic:result.toString(16).padStart(64,'0');const caseName=name+(error?'Overflow':'Ok');const mapping=JSON.parse(readFileSync(new URL('../signed-arithmetic/'+caseName+'.mapping.json',import.meta.url)));
 const data='0x'+selector+a.toString(16).padStart(64,'0')+b.toString(16).padStart(64,'0')+(ordinal%3===0?'a5'.repeat(111):'');
 const trace=await p.request({method:'debug_traceCall',params:[{from:accounts[0],to:target,data,value:'0x0',gas:'0x186a0'},'latest',{enableMemory:true,disableStorage:true,disableStack:false}]});
 const file=name+'-'+ordinal+'.json';writeFileSync(resolve(out,file),JSON.stringify({name,caseName,ordinal,data,expected,runtimeSha256:digest,candidate:Boolean(candidate),trace},null,2)+'\n');const actual=trace.returnValue.replace(/^0x/,'');if(trace.failed!==error||actual!==expected){failures++;results.push({name,caseName,ordinal,trace:file,expected,actual,passed:false});continue;}
 if(JSON.stringify(trace.structLogs.map(s=>s.pc))!==JSON.stringify(mapping.states.map(s=>s.pc))||trace.structLogs.some(s=>s.depth!==1))throw new Error('Wrong complete branch PC path');const ret=trace.structLogs.at(-1),nat=x=>BigInt('0x'+x.replace(/^0x/,''));const memory=ret.memory.map(w=>w.replace(/^0x/,'')).join('');if(ret.op!==(error?'REVERT':'RETURN')||nat(ret.stack.at(-1))!==(error?0n:128n)||nat(ret.stack.at(-2))!==(error?36n:32n)||memory.slice(error?0:256,error?72:320)!==expected)throw new Error('Wrong physical arithmetic receipt');
 const stores=trace.structLogs.filter(s=>s.op==='MSTORE');const expectedStores=error?[[64n,128n],[0n,panicWord],[4n,17n]]:[[64n,128n],[128n,result]];if(stores.length!==expectedStores.length||stores.some((s,i)=>nat(s.stack.at(-1))!==expectedStores[i][0]||nat(s.stack.at(-2))!==expectedStores[i][1]))throw new Error('Wrong actual arithmetic byte stores');results.push({name,caseName,ordinal,data,trace:file,instructions:trace.structLogs.length,passed:true});
}
const hh=fileURLToPath(import.meta.resolve('hardhat')),edr=createRequire(hh).resolve('@nomicfoundation/edr'),binding=createRequire(edr).resolve('@nomicfoundation/edr-linux-x64-gnu');writeFileSync(resolve(out,'toolchain.json'),JSON.stringify({nodeVersion:process.version,nodeExecutable:process.execPath,nodeSha256:sha(readFileSync(process.execPath)),hardhatEntry:hh,hardhatEntrySha256:sha(readFileSync(hh)),edrEntry:edr,edrEntrySha256:sha(readFileSync(edr)),edrVersion:JSON.parse(readFileSync(resolve(dirname(edr),'package.json'))).version,nativeBinding:binding,nativeBindingSha256:sha(readFileSync(binding)),lockfileSha256:sha(readFileSync('pnpm-lock.yaml'))},null,2)+'\n');
await c.close();writeFileSync(resolve(out,'results.json'),JSON.stringify(results,null,2)+'\n');if(failures)throw new Error('Wrong EVM signed checked arithmetic output: '+failures+' semantic failures');console.log('PASS: '+results.length+' complete physical signed checked arithmetic success and panic receipts');
