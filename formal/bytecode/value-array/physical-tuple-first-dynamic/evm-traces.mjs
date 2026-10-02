// Finite development checks against an independent canonical ABI encoder.
import { readFileSync, writeFileSync, mkdirSync } from 'node:fs';
import { resolve, dirname } from 'node:path';
import { createRequire } from 'node:module';
import { fileURLToPath } from 'node:url';
import { createHash } from 'node:crypto';
import { network } from 'hardhat';
import { encodeAbiParameters, encodeFunctionData, parseAbiParameters } from 'viem';

const options = {};
for (let i = 2; i < process.argv.length; i += 2) {
  if (!['--root', '--output'].includes(process.argv[i]) || !process.argv[i + 1]) throw Error('Invalid arguments');
  options[process.argv[i]] = process.argv[i + 1];
}
const root = resolve(options['--root'] ?? '.'), out = resolve(options['--output']);
mkdirSync(out, { recursive: true });
const artifact = JSON.parse(readFileSync(resolve(root, 'artifacts/contracts/Collections.sol/Collections.json')));
const code = artifact.deployedBytecode;
const sha = x => createHash('sha256').update(x).digest('hex');
const runtimeSha256 = sha(Buffer.from(code.slice(2), 'hex'));
const pin = JSON.parse(readFileSync(resolve(root, 'formal/bytecode/dispatch/inventory.json'))).Collections;
if (runtimeSha256 !== pin.runtimeSha256) throw Error('Runtime drift');
const word = n => BigInt(n).toString(16).padStart(64, '0');
const geometries = [
  { name: 'tuple-first-dynamic', type: '(bytes,uint256,uint256)', canonical: '(bytes,uint256,uint256)', values: [['0x',1n,2n],['0x'+ '17'.repeat(33),0n,3n]] },
];
const fixtures = [];
for (const g of geometries) {
  // Both directions compare independently with the encoder; no round-trip oracle.
  const singles = g.values.map(v => encodeAbiParameters(parseAbiParameters(g.canonical), [v]));
  const array = encodeAbiParameters(parseAbiParameters(g.canonical + '[]'), [g.values]);
  for (const operation of ['packArray', 'unpackArray']) {
    fixtures.push({ name: operation + '-' + g.name, operation, descriptor: g.type,
      data: encodeFunctionData({ abi: artifact.abi, functionName: operation,
        args: [g.type, operation === 'packArray' ? singles : array] }),
      expected: encodeAbiParameters(parseAbiParameters(operation === 'packArray' ? 'bytes' : 'bytes[]'),
        [operation === 'packArray' ? array : singles]).slice(2), failed: false });
  }
}
const nat = x => BigInt(x.startsWith('0x') ? x : '0x' + x);
const MOD = 1n << 256n;
function projected(expression, data) {
  const bytes = Buffer.from(data.slice(2), 'hex');
  const dataWord = offset => {
    const p = Number(offset), raw = Buffer.alloc(32);
    if (p < bytes.length) bytes.copy(raw, 0, p, Math.min(p + 32, bytes.length));
    return BigInt('0x' + raw.toString('hex'));
  };
  const ha = dataWord(4), hb = dataWord(36), pa = (ha + 4n) % MOD, pb = (hb + 4n) % MOD;
  const expressions = { value: 0n, '|data|': BigInt(bytes.length), 'DataWord(data,0)': dataWord(0),
    'HeadA(data)': ha, 'HeadB(data)': hb, 'HeadPositionA(data)': pa, 'HeadPositionB(data)': pb,
    'LengthA(data)': dataWord(pa), 'LengthB(data)': dataWord(pb),
    'OffsetA(data)': (ha + 36n) % MOD, 'OffsetB(data)': (hb + 36n) % MOD,
    'ArrayBytes(data)': (dataWord(pb)*32n)%MOD };
  if (/^\d+$/.test(expression)) return BigInt(expression);
  if (expression in expressions) return expressions[expression];
  // Restrict the evaluator to generated addition/subtraction remainder expressions.
  let text = expression;
  for (const [name, value] of Object.entries(expressions)) text = text.replaceAll(name, value + 'n');
  text = text.replaceAll('G.Modulus()', MOD + 'n').replaceAll(' as nat', '');
  text = text.replace(/(?<![\w])\d+(?![\w])/g, x => x + 'n');
  if (!/^[0-9n()+\-%\s]+$/.test(text)) throw Error('Unrecognized projection ' + expression);
  return Function('"use strict"; return (' + text + ');')();
}
const load = (owner, name) => JSON.parse(readFileSync(resolve(root, 'formal/bytecode/value-array', owner, name + '.mapping.json')));
const connection = await network.connect('hardhatMainnet');
const provider = connection.provider, accounts = await provider.request({ method: 'eth_accounts' });
const target = '0x0000000000000000000000000000000000003900';
await provider.request({ method: 'hardhat_setCode', params: [target, code] });
const rows = [];
for (const fixture of fixtures) {
  const trace = await provider.request({ method: 'debug_traceCall', params: [
    { from: accounts[0], to: target, gas: '0x989680', data: fixture.data, value: '0x0' },
    'latest', { enableMemory: true, disableStorage: true, disableStack: false }] });
  writeFileSync(resolve(out, fixture.name + '.json'), JSON.stringify({ fixture, runtimeSha256, trace }, null, 2) + '\n');
  const errors = [], logs = trace.structLogs, actual = trace.returnValue.replace(/^0x/, '');
  if (trace.failed !== fixture.failed || actual !== fixture.expected) errors.push('Complete canonical receipt differs');
  if (!logs.length || logs[0].pc !== 0 || logs.some(x => x.depth !== 1)) errors.push('Incomplete physical frame');
  const last = logs.at(-1), off = Number(nat(last.stack.at(-1))), size = Number(nat(last.stack.at(-2)));
  const memory = log => log.memory.map(w => w.replace(/^0x/, '')).join('');
  if (last.op !== (fixture.failed ? 'REVERT' : 'RETURN') || size !== fixture.expected.length / 2 ||
      memory(last).slice(off * 2, (off + size) * 2) !== fixture.expected) errors.push('Physical returned memory differs');
  const prefix = load(fixture.operation === 'packArray' ? 'prefix-pack' : 'prefix-unpack', 'Prefix');
  const mappings = [prefix];
  if(fixture.failed) mappings.push(load('raw-pack','Raw'+fixture.kind));
  else mappings.push(load(fixture.operation==='packArray'?'decoder-pack':'decoder-unpack','Decoder'));
  const states = mappings.flatMap(m => m.states);
  for (const mapping of mappings) if (mapping.runtimeSha256 !== runtimeSha256) throw Error('Mapping runtime drift');
  for (let i = 0; i < states.length; i++) {
    const expected = states[i], observed = logs[i];
    if (observed.pc !== expected.pc) { errors.push('Reached mapping PC differs at ' + i); break; }
    if (JSON.stringify(observed.stack.map(x => nat(x).toString())) !==
        JSON.stringify(expected.stack.map(x => projected(x, fixture.data).toString()))) {
      errors.push('Reached mapping stack differs at PC' + expected.pc); break;
    }
    const expectedMemory = expected.memory === '[]' ? '' : '00'.repeat(64) + word(128);
    if (memory(observed) !== expectedMemory) { errors.push('Reached mapping memory differs at PC' + expected.pc); break; }
  }
  if (!fixture.failed) {
    const entry = logs[states.length], decoder = mappings[1];
    if (entry.pc !== (fixture.operation==='packArray'?5682:7262) || JSON.stringify(entry.stack.map(x => nat(x).toString())) !==
        JSON.stringify(decoder.finalStack.map(x => projected(x, fixture.data).toString()))) errors.push('Decoder terminal frame differs');
  }
  if(fixture.failed && logs.length!==states.length)errors.push('Complete rejection instruction path differs');
  rows.push({ name: fixture.name, passed: errors.length === 0, receiptPassed: trace.failed === fixture.failed && actual === fixture.expected,
    mappedInstructionCount: states.length, errors, trace: fixture.name + '.json' });
}
await connection.close();
const hh = fileURLToPath(import.meta.resolve('hardhat')), edr = createRequire(hh).resolve('@nomicfoundation/edr');
const binding = createRequire(edr).resolve('@nomicfoundation/edr-linux-x64-gnu');
writeFileSync(resolve(out, 'toolchain.json'), JSON.stringify({ nodeVersion: process.version,
  nodeExecutable: process.execPath, nodeSha256: sha(readFileSync(process.execPath)),
  hardhatEntry: hh, hardhatEntrySha256: sha(readFileSync(hh)), edrEntry: edr, edrEntrySha256: sha(readFileSync(edr)),
  nativeBinding: binding, nativeBindingSha256: sha(readFileSync(binding)),
  lockfileSha256: sha(readFileSync(resolve(root, 'pnpm-lock.yaml'))) }, null, 2) + '\n');
writeFileSync(resolve(out, 'results.json'), JSON.stringify(rows, null, 2) + '\n');
console.log((rows.every(x => x.passed) ? 'PASS' : 'FAIL') + ': ' + rows.length + ' complete physical development receipts');
process.exitCode = rows.every(x => x.passed) ? 0 : 1;
