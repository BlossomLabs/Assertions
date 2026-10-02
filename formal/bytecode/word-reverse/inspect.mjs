// Development observations only; no retained public-entry evidence.
import {readFileSync,writeFileSync,mkdirSync} from 'node:fs';
import {resolve} from 'node:path';
import {network} from 'hardhat';
const root=resolve('.'),out=resolve(process.argv[2]);mkdirSync(out,{recursive:true});
const code=JSON.parse(readFileSync(resolve(root,'artifacts/contracts/Collections.sol/Collections.json'))).deployedBytecode;
const word=n=>BigInt(n).toString(16).padStart(64,'0');
const cases=[{name:'empty',payload:''},{name:'three',payload:[3,7,11].map(word).join('')},{name:'unaligned',payload:'ff'}];
const c=await network.connect('hardhatMainnet'),p=c.provider,a=await p.request({method:'eth_accounts'}),target='0x0000000000000000000000000000000000003800';await p.request({method:'hardhat_setCode',params:[target,code]});
for(const item of cases){
 const data='0xab590638'+word(32)+word(item.payload.length/2)+item.payload;
 const trace=await p.request({method:'debug_traceCall',params:[{from:a[0],to:target,gas:'0x989680',data},'latest',{enableMemory:true,disableStorage:true,disableStack:false}]});
 writeFileSync(resolve(out,item.name+'.json'),JSON.stringify({case:item,data,trace},null,2)+'\n');
 console.log(item.name,'failed',trace.failed,'bytes',trace.returnValue.replace(/^0x/,''));
 console.log(trace.structLogs.map(s=>s.pc+':'+s.op).join(' '));
}
await c.close();
