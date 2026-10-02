// Independent complete public empty-array receipts and every physical PC from entry to RETURN.
import {readFileSync,writeFileSync,mkdirSync} from 'node:fs';
import {resolve,dirname} from 'node:path';
import {fileURLToPath} from 'node:url';
import {network} from 'hardhat';
import {encodeAbiParameters} from 'viem';
import {createHash} from 'node:crypto';
const options={};for(let i=2;i<process.argv.length;i+=2){if(!['--output','--root','--runtime','--case'].includes(process.argv[i])||!process.argv[i+1])throw Error('Bad args');options[process.argv[i]]=process.argv[i+1];}
const root=resolve(options['--root']??'.'),out=resolve(options['--output']),here=dirname(fileURLToPath(import.meta.url));mkdirSync(out,{recursive:true});
const artifact=JSON.parse(readFileSync(resolve(root,'artifacts/contracts/Assertions.sol/Assertions.json'))),runtime=options['--runtime']?'0x'+readFileSync(options['--runtime']).toString('hex'):artifact.deployedBytecode,digest=createHash('sha256').update(Buffer.from(runtime.slice(2),'hex')).digest('hex');
const expected=encodeAbiParameters([{type:'bytes[]'}],[[]]).slice(2),put=(buf,off,val)=>Buffer.from(BigInt(val).toString(16).padStart(64,'0'),'hex').copy(buf,off),fixtures=[];
for(const [name,relative,tail] of [['canonical',32,0],['zero-offset-alias',0,0],['long-offset',196,0],['trailing',64,97]]){const buf=Buffer.alloc(4+relative+32+tail,0xa7);Buffer.from('6db7211f','hex').copy(buf);put(buf,4,relative);put(buf,4+relative,0);fixtures.push({name,data:'0x'+buf.toString('hex'),relative});}
const parts=[['Dispatch',here],['Decoder',here],['GatherStartZero',resolve(here,'..')],['GatherDoneExit',resolve(here,'..')],['EmptySerializer',here]],pcs=parts.flatMap(([name,dir])=>JSON.parse(readFileSync(resolve(dir,name+'.mapping.json'))).states.map(s=>s.pc));
const connection=await network.connect('hardhatMainnet'),provider=connection.provider,accounts=await provider.request({method:'eth_accounts'}),address='0x0000000000000000000000000000000000005810';await provider.request({method:'hardhat_setCode',params:[address,runtime]});
const results=[];
for(const f of fixtures){if(options['--case']&&f.name!==options['--case'])continue;const trace=await provider.request({method:'debug_traceCall',params:[{from:accounts[0],to:address,gas:'0x989680',data:f.data,value:'0x0'},'latest',{enableMemory:true,disableStorage:true,disableStack:false}]}),logs=trace.structLogs.filter(x=>x.depth===1),actual=trace.returnValue.replace(/^0x/,''),receiptPassed=!trace.failed&&actual===expected,pathPassed=JSON.stringify(logs.map(s=>s.pc))===JSON.stringify(pcs),passed=receiptPassed&&pathPassed;writeFileSync(resolve(out,f.name+'.json'),JSON.stringify({name:f.name,runtimeSha256:digest,data:f.data,relative:f.relative,expectedBytes:expected,expectedFailed:false,expectedPCs:pcs,trace},null,2)+'\n');results.push({name:f.name,expectedBytes:expected,actualBytes:actual,actualFailed:trace.failed,receiptPassed,pathPassed,physicalInstructions:logs.length,passed});}
await connection.close();writeFileSync(resolve(out,'results.json'),JSON.stringify(results,null,2)+'\n');console.log(results.every(x=>x.passed)?'PASS':'FAIL',results.length,'complete empty gather receipts and exact full traces');process.exitCode=results.every(x=>x.passed)?0:1;
