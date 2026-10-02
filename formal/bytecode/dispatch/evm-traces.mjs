// Real in-process EDR execution of the exact runtimes, stopping observations at entry.
import { readFileSync, mkdirSync, writeFileSync } from 'node:fs';
import { resolve, dirname } from 'node:path';
import { createRequire } from 'node:module';
import { fileURLToPath } from 'node:url';
import { createHash } from 'node:crypto';
import { network } from 'hardhat';
const candidateName = process.argv[3] ?? null;
const candidateRuntime = process.argv[4] ?? null;
if (candidateRuntime && !candidateName) throw new Error('Candidate runtime requires a contract name');
if (candidateName && !['Assertions','Expressions','Collections'].includes(candidateName)) throw new Error('Unknown contract');
const out = resolve(process.argv[2] ?? '/tmp/bytecode-dispatch-evm-traces');
mkdirSync(out, { recursive: true });
const inventory = JSON.parse(readFileSync(new URL('./inventory.json', import.meta.url), 'utf8'));
const connection = await network.connect('hardhatMainnet');
const provider = connection.provider;
const accounts = await provider.request({ method: 'eth_accounts' });
const results = [];
const stackNat = value => BigInt(value.startsWith('0x') ? value : '0x'+value);
for (const [ordinal, name] of ['Assertions','Expressions','Collections'].entries()) {
  const artifact = JSON.parse(readFileSync(`artifacts/contracts/${name}.sol/${name}.json`, 'utf8'));
  if (candidateName && candidateName !== name) continue;
  const runtime = candidateRuntime ? '0x'+readFileSync(candidateRuntime).toString('hex') : artifact.deployedBytecode;
  const digest = createHash('sha256').update(Buffer.from(runtime.slice(2), 'hex')).digest('hex');
  if (!candidateRuntime && digest !== inventory[name].runtimeSha256) throw new Error(`Runtime drift ${name}`);
  const target = '0x' + (0x1100 + ordinal).toString(16).padStart(40, '0');
  await provider.request({ method: 'hardhat_setCode', params: [target, runtime] });
  const entrySet = new Set(Object.values(inventory[name].selectorToDeclaredEntryPc));
  const cases = [];
  for (const [signature, selector] of Object.entries(inventory[name].methodIdentifiers)) {
    const entry = inventory[name].selectorToDeclaredEntryPc[Number.parseInt(selector,16)];
    cases.push({ name: signature, data: '0x'+selector, value: '0x0', expected: entry });
    cases.push({ name: signature+'-tail', data: '0x'+selector+'ff'.repeat(28)+'00'.repeat(128), value: '0x0', expected: entry });
    cases.push({ name: signature+'-nonzero-value', data: '0x'+selector+'00'.repeat(128), value: '0x1', expected: -1 });
  }
  for (let size=0;size<4;size++) cases.push({ name: 'short-'+size, data:'0x'+'ff'.repeat(size), value:'0x0', expected:-1 });
  for (const selector of ['00000000','ffffffff','12345678']) {
    if (inventory[name].selectorToDeclaredEntryPc[Number.parseInt(selector,16)] !== undefined) throw new Error('Assigned unknown fixture');
    cases.push({name:'unknown-'+selector,data:'0x'+selector+'ff'.repeat(28),value:'0x0',expected:-1});
  }
  cases.sort((a,b) => Number(b.name.startsWith('short-'))-Number(a.name.startsWith('short-')));
  for (const item of cases) {
    const trace = await provider.request({ method: 'debug_traceCall', params: [{ from: accounts[0], to: target, gas:'0x186a0', data:item.data, value:item.value },'latest',{disableMemory:true,disableStorage:true,disableStack:false}] });
    const logs = trace.structLogs;
    if (!Array.isArray(logs) || !logs.length) throw new Error('Missing native EVM trace');
    const prefix=[];let reached=-1;
    for (const row of logs) {
      if (row.depth!==1) throw new Error('External observation before dispatch completion');
      prefix.push({pc:row.pc,op:row.op,stack:row.stack});
      if (entrySet.has(row.pc)) { reached=row.pc;break; }
    }
    const filename=`${name}-${cases.indexOf(item)}.json`;
    writeFileSync(resolve(out,filename),JSON.stringify({contract:name,runtimeSha256:digest,candidate:Boolean(candidateRuntime),case:item,prefix,failedAfterDispatch:trace.failed,returnValueAfterDispatch:trace.returnValue},null,2)+'\n');
    if (reached !== item.expected) throw new Error(`Wrong EVM entry ${name}/${item.name}: ${reached} vs ${item.expected}`);
    const store=prefix.find(row=>row.pc===4 && row.op==='MSTORE');
    if (!store || stackNat(store.stack.at(-1))!==64n || stackNat(store.stack.at(-2))!==128n) throw new Error('Initial MSTORE trace differs');
    if (reached>=0) {
      const selector=BigInt('0x'+item.data.slice(2,10));
      if (prefix.at(-1).stack.length!==1 || stackNat(prefix.at(-1).stack[0])!==selector) throw new Error('Routed selector stack differs');
    } else if (!trace.failed || !['','0x'].includes(trace.returnValue) || prefix.at(-1).op!=='REVERT') throw new Error('Expected exact empty rejection');

    results.push({contract:name,name:item.name,expected:item.expected,reached,trace:filename,prefixInstructions:prefix.length,passed:true});
  }
}
await connection.close();
const hardhatPath = fileURLToPath(import.meta.resolve('hardhat'));
const hardhatRequire = createRequire(hardhatPath);
const edrPath = hardhatRequire.resolve('@nomicfoundation/edr');
const edrRequire = createRequire(edrPath);
const nativePath = edrRequire.resolve('@nomicfoundation/edr-linux-x64-gnu');
const sha = path => createHash('sha256').update(readFileSync(path)).digest('hex');
writeFileSync(resolve(out,'toolchain.json'),JSON.stringify({nodeVersion:process.version,nodeExecutable:process.execPath,nodeSha256:sha(process.execPath),hardhatEntry:hardhatPath,hardhatEntrySha256:sha(hardhatPath),edrEntry:edrPath,edrEntrySha256:sha(edrPath),edrVersion:JSON.parse(readFileSync(resolve(dirname(edrPath),'package.json'))).version,nativeBinding:nativePath,nativeBindingSha256:sha(nativePath),lockfileSha256:sha('pnpm-lock.yaml')},null,2)+'\n');
writeFileSync(resolve(out,'results.json'),JSON.stringify(results,null,2)+'\n');
console.log(`PASS: ${results.length} exact-runtime EDR dispatcher traces; body outcomes beyond entry are not certified`);
