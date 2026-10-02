// Development opcode receipts only; these are synthetic programs, no body claims.
import {readFileSync,writeFileSync,mkdirSync} from 'node:fs';
import {resolve,dirname} from 'node:path';
import {createHash} from 'node:crypto';
import {createRequire} from 'node:module';
import {fileURLToPath} from 'node:url';
import {network} from 'hardhat';
const out=resolve(process.argv[2]);mkdirSync(out,{recursive:true});
const sha=x=>createHash('sha256').update(x).digest('hex');
const push=n=>{if(BigInt(n)===0n)return '5f';let s=BigInt(n).toString(16);if(s.length%2)s='0'+s;return (0x5f+s.length/2).toString(16)+s;};
const max=(1n<<256n)-1n,pattern=Buffer.from(Array.from({length:96},(_,i)=>i));
const initial=Array.from({length:3},(_,i)=>push(BigInt('0x'+pattern.subarray(i*32,(i+1)*32).toString('hex')))+push(i*32)+'52').join('');
const cases=[
 {name:'memory-forward-overlap',op:'5e',dst:1n,src:0n,length:63n},
 {name:'memory-backward-overlap',op:'5e',dst:0n,src:1n,length:63n},
 {name:'memory-identical-span',op:'5e',dst:17n,src:17n,length:47n},
 {name:'memory-both-spans-expand',op:'5e',dst:129n,src:89n,length:47n},
 {name:'memory-unallocated-source',op:'5e',dst:7n,src:193n,length:33n},
 {name:'memory-zero-full-width-offsets',op:'5e',dst:max,src:max,length:0n},
 {name:'calldata-offset-padding',op:'37',dst:21n,src:2n,length:47n,data:'0x01020304ff'},
 {name:'calldata-full-width-source',op:'37',dst:33n,src:max,length:32n,data:'0x01020304'},
 {name:'calldata-zero-full-width-offsets',op:'37',dst:max,src:max,length:0n,data:'0xffff'}
];
const connection=await network.connect('hardhatMainnet'),provider=connection.provider,accounts=await provider.request({method:'eth_accounts'}),target='0x0000000000000000000000000000000000003603',results=[];
for(const item of cases){
 const positive=item.length>0n,dst=positive?Number(item.dst):0,src=item.src<=BigInt(Number.MAX_SAFE_INTEGER)?Number(item.src):null,len=Number(item.length);
 const end=positive?Math.max(dst+len,item.op==='5e'?src+len:0):0,extent=Math.max(96,Math.ceil(end/32)*32),expected=Buffer.alloc(extent);pattern.copy(expected);
 const original=Buffer.from(expected),data=Buffer.from((item.data??'0x').slice(2),'hex');
 for(let i=0;i<len;i++)expected[dst+i]=src===null?0:item.op==='5e'?(original[src+i]??0):(data[src+i]??0);
 const code='0x'+initial+push(item.length)+push(item.src)+push(item.dst)+item.op+push(extent)+push(0)+'f3';
 await provider.request({method:'hardhat_setCode',params:[target,code]});
 const trace=await provider.request({method:'debug_traceCall',params:[{from:accounts[0],to:target,data:item.data??'0x',gas:'0x989680'},'latest',{enableMemory:true,disableStorage:true,disableStack:false}]});
 const copyIndex=trace.structLogs.findIndex(s=>s.op===(item.op==='5e'?'MCOPY':'CALLDATACOPY')),before=trace.structLogs[copyIndex],after=trace.structLogs[copyIndex+1],mem=after?.memory.map(x=>x.replace(/^0x/,'')).join('');
 const passed=!trace.failed&&trace.returnValue.replace(/^0x/,'')===expected.toString('hex')&&copyIndex>=0&&before.stack.length===3&&after.stack.length===0&&mem===expected.toString('hex')&&trace.structLogs.every(s=>s.depth===1);
 writeFileSync(resolve(out,item.name+'.json'),JSON.stringify({scope:'Synthetic copy-opcode development receipt only',case:item,code,codeSha256:sha(Buffer.from(code.slice(2),'hex')),expected:expected.toString('hex'),trace},(_,v)=>typeof v==='bigint'?v.toString():v,2)+'\n');
 results.push({name:item.name,trace:item.name+'.json',passed});
}
await connection.close();const hh=fileURLToPath(import.meta.resolve('hardhat')),edr=createRequire(hh).resolve('@nomicfoundation/edr'),binding=createRequire(edr).resolve('@nomicfoundation/edr-linux-x64-gnu');
writeFileSync(resolve(out,'toolchain.json'),JSON.stringify({nodeVersion:process.version,nodeExecutable:process.execPath,nodeSha256:sha(readFileSync(process.execPath)),hardhatEntry:hh,hardhatEntrySha256:sha(readFileSync(hh)),edrEntry:edr,edrEntrySha256:sha(readFileSync(edr)),nativeBinding:binding,nativeBindingSha256:sha(readFileSync(binding)),lockfileSha256:sha(readFileSync(resolve('pnpm-lock.yaml')))},null,2)+'\n');
writeFileSync(resolve(out,'results.json'),JSON.stringify(results,null,2)+'\n');console.log((results.every(r=>r.passed)?'PASS':'FAIL')+': '+results.length+' synthetic copy-opcode development receipts');process.exitCode=results.every(r=>r.passed)?0:1;
