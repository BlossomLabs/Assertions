// Physical empty-revert receipts for the complete assigned account-environment boundary.
import {readFileSync,writeFileSync,mkdirSync} from 'node:fs';
import {resolve} from 'node:path';
import {network} from 'hardhat';
const out=resolve(process.argv[2]);mkdirSync(out,{recursive:true});
const runtime=JSON.parse(readFileSync('artifacts/contracts/Operations.sol/Operations.json')).deployedBytecode;
const c=await network.connect('hardhatMainnet');const p=c.provider;const target='0x0000000000000000000000000000000000002293';
await p.request({method:'hardhat_setCode',params:[target,runtime]});
const accounts=await p.request({method:'eth_accounts'});const results=[];
const fixtures=[...['','00','aabb','ffffff'].map((s,i)=>({name:'Short',data:'0x'+s,value:'0x0',ordinal:i})),...['','7598b508','b0229c96'+'00'.repeat(64),'496e22b8'+'ff'.repeat(511)].map((s,i)=>({name:'Nonzero',data:'0x'+s,value:'0x'+(i+1).toString(16),ordinal:i}))];
for(const [name,selector] of [['BalanceArgs','e3d670d7'],['CodeHashArgs','3dc44827']])for(const [ordinal,length] of [4,5,31,35].entries())fixtures.push({name,ordinal,data:'0x'+selector+'a5'.repeat(length-4),value:'0x0'});
for(const [name,selector] of [['BalanceBadAddress','e3d670d7'],['CodeHashBadAddress','3dc44827']])for(const [ordinal,account] of [1n<<160n,(1n<<160n)+123n,(1n<<255n),(1n<<256n)-1n].entries())fixtures.push({name,ordinal,data:'0x'+selector+account.toString(16).padStart(64,'0')+(ordinal%2===0?'ff'.repeat(211):''),value:'0x0'});
for(const f of fixtures){
 const trace=await p.request({method:'debug_traceCall',params:[{from:accounts[0],to:target,data:f.data,value:f.value,gas:'0x186a0'},'latest',{enableMemory:true,disableStorage:true,disableStack:false}]});
 const file=f.name+'-'+f.ordinal+'.json';writeFileSync(resolve(out,file),JSON.stringify({...f,trace},null,2)+'\n');
 const mapping=JSON.parse(readFileSync(new URL('../account-environment-repair-v2/rejections/'+f.name+'.mapping.json',import.meta.url)));
 if(!trace.failed||trace.returnValue.replace(/^0x/,'')!==''||trace.structLogs.at(-1).op!=='REVERT'||trace.structLogs.some(s=>s.depth!==1)||JSON.stringify(trace.structLogs.map(s=>s.pc))!==JSON.stringify(mapping.states.map(s=>s.pc))) throw new Error('Wrong physical raw rejection '+file);
 const ret=trace.structLogs.at(-1);if(BigInt('0x'+ret.stack.at(-1).replace(/^0x/,''))!==0n||BigInt('0x'+ret.stack.at(-2).replace(/^0x/,''))!==0n)throw new Error('Wrong empty REVERT frame');
 results.push({...f,trace:file,passed:true});
}
await c.close();writeFileSync(resolve(out,'results.json'),JSON.stringify(results,null,2)+'\n');console.log('PASS: '+results.length+' exact-runtime complete raw empty-revert receipts');
