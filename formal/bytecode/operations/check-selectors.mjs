// Independently compare current compiler IDs to canonical signature Keccak selectors.
import {readFileSync,writeFileSync,mkdirSync} from 'node:fs';
import {resolve,dirname} from 'node:path';
import {fileURLToPath} from 'node:url';
import {createHash} from 'node:crypto';
import {toFunctionSelector} from 'viem';
const out=resolve(process.argv[2]);mkdirSync(out,{recursive:true});
const inventory=JSON.parse(readFileSync(new URL('./inventory.json',import.meta.url)));const results=[];
for(const entry of inventory.publicEntries){
 const canonical=toFunctionSelector(entry.signature).slice(2);
 if(canonical!==entry.selector||inventory.compilerIdentity.methodIdentifiers[entry.signature]!==canonical)throw new Error('Canonical signature selector drift '+entry.signature);
 results.push({signature:entry.signature,selector:canonical,entryPc:entry.entryPc,passed:true});
}
if(results.length!==92||new Set(results.map(x=>x.selector)).size!==92)throw new Error('Wrong public selector inventory');
const file=fileURLToPath(import.meta.resolve('viem'));const sha=b=>createHash('sha256').update(b).digest('hex');
writeFileSync(resolve(out,'results.json'),JSON.stringify({scope:'Independent canonical signature/selector consistency check only; no opcode correctness, hash implementation proof or public bytecode coverage.',viemEntry:file,viemEntrySha256:sha(readFileSync(file)),nodeExecutable:process.execPath,nodeVersion:process.version,nodeSha256:sha(readFileSync(process.execPath)),lockfileSha256:sha(readFileSync('pnpm-lock.yaml')),results},null,2)+'\n');
console.log('PASS: all 92 compiler selectors match canonical signature Keccak selectors');
