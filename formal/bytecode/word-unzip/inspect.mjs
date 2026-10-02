// Development observations only; no retained public-entry evidence.
import {readFileSync,writeFileSync,mkdirSync} from 'node:fs';
import {resolve} from 'node:path';
import {network} from 'hardhat';
const root=resolve('.'),out=resolve(process.argv[2]);mkdirSync(out,{recursive:true});
const code=JSON.parse(readFileSync(resolve(root,'artifacts/contracts/Collections.sol/Collections.json'))).deployedBytecode;
const word=n=>BigInt(n).toString(16).padStart(64,'0');
const cases=[...[0,1].flatMap(lane=>[0,1,3,4].map(n=>({name:'n'+n+'-lane'+lane,lane,payload:Array.from({length:n},(_,i)=>3+4*i).map(word).join('')}))),{name:'unaligned',lane:0,payload:'ff'},{name:'invalid-lane',lane:2,payload:''}];
const c=await network.connect('hardhatMainnet'),p=c.provider,a=await p.request({method:'eth_accounts'}),target='0x0000000000000000000000000000000000003800';await p.request({method:'hardhat_setCode',params:[target,code]});
for(const item of cases){
 const data='0xb2303db4'+word(64)+word(item.lane)+word(item.payload.length/2)+item.payload;
 const trace=await p.request({method:'debug_traceCall',params:[{from:a[0],to:target,gas:'0x989680',data},'latest',{enableMemory:true,disableStorage:true,disableStack:false}]});
 writeFileSync(resolve(out,item.name+'.json'),JSON.stringify({case:item,data,trace},null,2)+'\n');
 console.log(item.name,'failed',trace.failed,'bytes',trace.returnValue.replace(/^0x/,''));
 console.log(trace.structLogs.map(s=>s.pc+':'+s.op).join(' '));
}
await c.close();
