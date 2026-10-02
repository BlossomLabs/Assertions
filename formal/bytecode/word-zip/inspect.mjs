// Development physical observations; retained evidence remains separate.
import {readFileSync,writeFileSync,mkdirSync} from 'node:fs';
import {resolve} from 'node:path';
import {network} from 'hardhat';
import {toFunctionSelector} from 'viem';
const root=resolve('.'),out=resolve(process.argv[2]);mkdirSync(out,{recursive:true});
const code=JSON.parse(readFileSync(resolve(root,'artifacts/contracts/Collections.sol/Collections.json'))).deployedBytecode;
const word=n=>BigInt(n).toString(16).padStart(64,'0');
const cases=[...[0,1,2,3].map(n=>({name:'n'+n,a:Array.from({length:n},(_,i)=>3+4*i).map(word).join(''),b:Array.from({length:n},(_,i)=>11+6*i).map(word).join('')})),{name:'a-unaligned',a:'ff',b:''},{name:'b-unaligned',a:'',b:'aa'},{name:'count-mismatch',a:word(7),b:''}];
const c=await network.connect('hardhatMainnet'),p=c.provider,a=await p.request({method:'eth_accounts'}),target='0x'+(0x3900).toString(16).padStart(40,'0');await p.request({method:'hardhat_setCode',params:[target,code]});
for(const item of cases){
 const data=toFunctionSelector('zipWords(bytes,bytes)')+word(64)+word(96+item.a.length/2)+word(item.a.length/2)+item.a+word(item.b.length/2)+item.b;
 const trace=await p.request({method:'debug_traceCall',params:[{from:a[0],to:target,gas:'0x989680',data},'latest',{enableMemory:true,disableStorage:true,disableStack:false}]});
 writeFileSync(resolve(out,item.name+'.json'),JSON.stringify({case:item,data,trace},null,2)+'\n');
 console.log(item.name,'failed',trace.failed,'bytes',trace.returnValue.replace(/^0x/,''));
 console.log(trace.structLogs.map(s=>s.pc+':'+s.op).join(' '));
}
await c.close();
