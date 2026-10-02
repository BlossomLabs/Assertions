// Concrete complete receipt/routing regression; no formal bytecode claim.
import {readFileSync,writeFileSync,mkdirSync} from 'node:fs';
import {resolve} from 'node:path';
import {createHash} from 'node:crypto';
import {network} from 'hardhat';
import {encodeFunctionData,parseAbi} from 'viem';
const opts={};for(let i=2;i<process.argv.length;i+=2){if(!['--output','--runtime'].includes(process.argv[i])||!process.argv[i+1])throw Error('Bad argument');opts[process.argv[i]]=process.argv[i+1];}
const out=resolve(opts['--output']);mkdirSync(out,{recursive:true});
const source=readFileSync('contracts/Operations.sol'),artifact=JSON.parse(readFileSync('artifacts/contracts/Operations.sol/Operations.json'));
const code=opts['--runtime']?'0x'+readFileSync(opts['--runtime']).toString('hex'):artifact.deployedBytecode;
const sha=x=>createHash('sha256').update(x).digest('hex'),word=x=>((x+(1n<<256n))%(1n<<256n)).toString(16).padStart(64,'0');
const exponent=1n<<32n,fixtures=[
 ['unsigned-unsigned','function powMod(uint256,uint256,uint256) view returns (uint256)',[2n,exponent,3n],exponent,1n],
 ['signed-unsigned','function powMod(int256,uint256,int256) view returns (int256)',[-2n,exponent+1n,3n],exponent+1n,-2n],
 ['unsigned-signed','function powMod(uint256,int256,uint256) view returns (uint256)',[2n,-exponent,3n],exponent,1n],
 ['signed-signed','function powMod(int256,int256,int256) view returns (int256)',[-2n,-(exponent+1n),3n],exponent+1n,-2n]
];
const c=await network.connect('hardhatMainnet'),p=c.provider,accounts=await p.request({method:'eth_accounts'}),target='0x0000000000000000000000000000000000003700';
await p.request({method:'hardhat_setCode',params:[target,code]});
const nat=x=>BigInt(x.startsWith('0x')?x:'0x'+x),memory=x=>x.memory.map(w=>w.replace(/^0x/,'')).join(''),results=[];
for(const [name,signature,args,exp,expected] of fixtures){
 const data=encodeFunctionData({abi:parseAbi([signature]),functionName:'powMod',args});
 const trace=await p.request({method:'debug_traceCall',params:[{from:accounts[0],to:target,gas:'0x989680',data},'latest',{enableMemory:true,disableStorage:true,disableStack:false}]});
 const logs=trace.structLogs,errors=[],callIndices=logs.flatMap((s,i)=>s.op==='STATICCALL'&&nat(s.stack.at(-2))===5n?[i]:[]);
 if(trace.failed||trace.returnValue.replace(/^0x/,'')!==word(expected))errors.push('Incorrect complete mathematical result');
 if(!logs.length||logs[0].pc!==0||logs.some(s=>s.depth!==1))errors.push('Incomplete caller trace');
 if(callIndices.length!==1)errors.push('Expected one MODEXP call');
 for(const index of callIndices){
  const s=logs[index],offset=Number(nat(s.stack.at(-3))),size=Number(nat(s.stack.at(-4)));
  if(size!==192||memory(s).slice(offset*2,(offset+size)*2)!==[32n,32n,32n,2n,exp,3n].map(word).join(''))errors.push('Incorrect exact precompile inputs');
  if(logs.slice(index+1).some(s=>s.op==='MULMOD'))errors.push('Accepted fresh precompile result discarded into fallback');
  if(!logs.slice(index+1).some(s=>s.op==='RETURNDATASIZE'))errors.push('Fresh receipt size not observed after call');
 }
 const last=logs.at(-1);
 if(last.op!=='RETURN'||nat(last.stack.at(-2))!==32n||memory(last).slice(Number(nat(last.stack.at(-1)))*2,Number(nat(last.stack.at(-1))+32n)*2)!==word(expected))errors.push('Incorrect physical return slice');
 const record={name,passed:!errors.length,errors,runtimeSha256:sha(Buffer.from(code.slice(2),'hex')),sourceSha256:sha(source),trace:name+'.json'};
 writeFileSync(resolve(out,record.trace),JSON.stringify({signature,data,expectedBytes:word(expected),candidate:Boolean(opts['--runtime']),trace},null,2)+'\n');results.push(record);
}
await c.close();writeFileSync(resolve(out,'results.json'),JSON.stringify(results,null,2)+'\n');console.log((results.every(r=>r.passed)?'PASS':'FAIL')+': '+results.length+' complete powMod fresh-receipt regressions');process.exitCode=results.every(r=>r.passed)?0:1;
