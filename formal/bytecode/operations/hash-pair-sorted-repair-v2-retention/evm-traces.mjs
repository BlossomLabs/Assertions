// Exact sorted-word SHA3 input and serialized hash receipts; no cryptographic implementation proof.
import {readFileSync,writeFileSync,mkdirSync} from 'node:fs';
import {resolve,dirname} from 'node:path';
import {createRequire} from 'node:module';
import {fileURLToPath} from 'node:url';
import {createHash} from 'node:crypto';
import {keccak256} from 'viem';
import {network} from 'hardhat';
const out=resolve(process.argv[2]);mkdirSync(out,{recursive:true});const candidate=process.argv[3]??null;
const art=JSON.parse(readFileSync('artifacts/contracts/Operations.sol/Operations.json')),runtime=candidate?'0x'+readFileSync(candidate).toString('hex'):art.deployedBytecode;
const sha=x=>createHash('sha256').update(x).digest('hex'),digest=sha(Buffer.from(runtime.slice(2),'hex')),inv=JSON.parse(readFileSync(new URL('../inventory.json',import.meta.url)));
if(!candidate&&digest!==inv.runtimeSha256||inv.compilerIdentity.methodIdentifiers['hashPairSorted(bytes32,bytes32)']!=='c203edb3')throw new Error('Compiler/runtime/selector drift');
const M=1n<<256n,H=M>>1n,MAX=M-1n,word=x=>x.toString(16).padStart(64,'0');
const pairs=[[0n,0n],[1n,2n],[2n,1n],[123n,456n],[456n,123n],[MAX,MAX],[0n,MAX],[MAX,0n],[H,H-1n],[H-1n,H],[H,MAX],[MAX,H],[H+1n,H],[H,H+1n],[H,H],[1n,1n]];
const c=await network.connect('hardhatMainnet'),p=c.provider,target='0x00000000000000000000000000000000000022a2';const accounts=await p.request({method:'eth_accounts'});await p.request({method:'hardhat_setCode',params:[target,runtime]});
const results=[];let failures=0;
for(const [ordinal,[a,b]] of pairs.entries()){
 const preimage=word(a<=b?a:b)+word(a<=b?b:a),expected=keccak256('0x'+preimage).slice(2),data='0xc203edb3'+word(a)+word(b)+(ordinal%3===0?'a5'.repeat(111):'');
 const trace=await p.request({method:'debug_traceCall',params:[{from:accounts[0],to:target,data,value:'0x0',gas:'0x186a0'},'latest',{enableMemory:true,disableStorage:true,disableStack:false}]});
 const nat=x=>BigInt('0x'+x.replace(/^0x/,'')),hashes=trace.structLogs.filter(x=>x.op==='SHA3'||x.op==='KECCAK256');if(hashes.length!==1)throw new Error('Wrong SHA3 observation count');const hash=hashes[0],offset=nat(hash.stack.at(-1)),length=nat(hash.stack.at(-2)),memory=hash.memory.map(x=>x.replace(/^0x/,'')).join(''),actualPreimage=memory.slice(Number(offset*2n),Number((offset+length)*2n));
 const next=trace.structLogs[trace.structLogs.indexOf(hash)+1],observed=next.stack.at(-1).replace(/^0x/,'').padStart(64,'0'),actual=trace.returnValue.replace(/^0x/,'');
 const last=trace.structLogs.at(-1),lastMemory=last.memory.map(x=>x.replace(/^0x/,'')).join('');
 const passed=!trace.failed&&length===64n&&actualPreimage===preimage&&observed===expected&&actual===expected&&last.op==='RETURN'&&nat(last.stack.at(-1))===224n&&nat(last.stack.at(-2))===32n&&lastMemory.slice(448,512)===expected;
 if(!passed)failures++;
 const file='HashPairSorted-'+ordinal+'.json';writeFileSync(resolve(out,file),JSON.stringify({ordinal,data,expected,preimage,runtimeSha256:digest,candidate:Boolean(candidate),hashObservation:{pc:hash.pc,offset:offset.toString(),length:length.toString(),actualPreimage,observed},trace},null,2)+'\n');results.push({name:'HashPairSorted',ordinal,trace:file,expected,actual,expectedPreimage:preimage,actualPreimage,passed,instructions:trace.structLogs.length});
}
const hh=fileURLToPath(import.meta.resolve('hardhat')),edr=createRequire(hh).resolve('@nomicfoundation/edr'),binding=createRequire(edr).resolve('@nomicfoundation/edr-linux-x64-gnu'),viem=fileURLToPath(import.meta.resolve('viem'));
writeFileSync(resolve(out,'toolchain.json'),JSON.stringify({nodeVersion:process.version,nodeExecutable:process.execPath,nodeSha256:sha(readFileSync(process.execPath)),hardhatEntry:hh,hardhatEntrySha256:sha(readFileSync(hh)),edrEntry:edr,edrEntrySha256:sha(readFileSync(edr)),edrVersion:JSON.parse(readFileSync(resolve(dirname(edr),'package.json'))).version,nativeBinding:binding,nativeBindingSha256:sha(readFileSync(binding)),viemEntry:viem,viemEntrySha256:sha(readFileSync(viem)),lockfileSha256:sha(readFileSync('pnpm-lock.yaml'))},null,2)+'\n');
await c.close();writeFileSync(resolve(out,'results.json'),JSON.stringify(results,null,2)+'\n');if(failures)throw new Error('Wrong SHA3 sorted preimage or physical hash receipt: '+failures);console.log('PASS: '+results.length+' exact sorted64-byte SHA3 observations and physical RETURN receipts; cryptographic engine fidelity remains explicit');
