// Development capability probe; never retained entry coverage.
import {network} from 'hardhat';
import {readFileSync,writeFileSync,mkdirSync} from 'node:fs';
import {resolve} from 'node:path';
const out=resolve(process.argv[2]);mkdirSync(out,{recursive:true});const c=await network.connect('hardhatMainnet');const p=c.provider;const accounts=await p.request({method:'eth_accounts'});const target='0x0000000000000000000000000000000000002295';
await p.request({method:'hardhat_setCode',params:[target,JSON.parse(readFileSync('artifacts/contracts/Operations.sol/Operations.json')).deployedBytecode]});
const hashes=['0x01'+'23'.repeat(31),'0x01'+'45'.repeat(31)];const rows=[];
for(const extra of [{blobVersionedHashes:hashes},{type:'0x3',blobVersionedHashes:hashes,maxFeePerBlobGas:'0x77359400'}]){
 try{const t=await p.request({method:'debug_traceCall',params:[{from:accounts[0],to:target,data:'0x0ba54e32'+'0'.repeat(64),gas:'0x186a0',...extra},'latest',{enableMemory:true,disableStorage:true,disableStack:false}]});rows.push({extra,trace:t});}catch(e){rows.push({extra,error:String(e)});}
}
writeFileSync(resolve(out,'results.json'),JSON.stringify(rows,null,2)+'\n');await c.close();console.log(rows.map(r=>r.error??r.trace.returnValue));
