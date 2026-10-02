// Finite PC-zero exact-runtime word checks against independent ABI-word rules.
import { readFileSync, writeFileSync, mkdirSync } from 'node:fs';
import { resolve } from 'node:path';
import { createRequire } from 'node:module';
import { fileURLToPath } from 'node:url';
import { createHash } from 'node:crypto';
import { network } from 'hardhat';
import { encodeAbiParameters, encodeFunctionData, encodeErrorResult, parseAbiParameters } from 'viem';

const options = {};
for (let i = 2; i < process.argv.length; i += 2) {
  if (!['--root', '--output'].includes(process.argv[i]) || !process.argv[i + 1]) throw Error('Invalid arguments');
  options[process.argv[i]] = process.argv[i + 1];
}
const root = resolve(options['--root'] ?? '.'), out = resolve(options['--output']);
mkdirSync(out, { recursive: true });
const artifact = JSON.parse(readFileSync(resolve(root, 'artifacts/contracts/Collections.sol/Collections.json')));
const code = artifact.deployedBytecode, bytes = Buffer.from(code.slice(2), 'hex');
const sha = x => createHash('sha256').update(x).digest('hex');
const runtimeSha256 = sha(bytes);
if (runtimeSha256 !== JSON.parse(readFileSync(resolve(root, 'formal/bytecode/dispatch/inventory.json'))).Collections.runtimeSha256) throw Error('Runtime drift');
const MOD = 1n << 256n, hexWord = n => BigInt(n).toString(16).padStart(64, '0');
const nat = x => BigInt(x.startsWith('0x') ? x : '0x' + x);
function rule(name) {
  if (name === 'address') return { kind: 1, bits: 160 };
  if (name === 'bool') return { kind: 1, bits: 1 };
  if (name === 'function') return { kind: 3, bits: 192 };
  let m = /^(uint|int)([1-9][0-9]*)$/.exec(name);
  if (m && Number(m[2]) >= 8 && Number(m[2]) <= 248 && Number(m[2]) % 8 === 0) return { kind: m[1] === 'uint' ? 1 : 2, bits: Number(m[2]) };
  m = /^bytes([1-9][0-9]*)$/.exec(name);
  if (m && Number(m[1]) <= 31) return { kind: 3, bits: Number(m[1]) * 8 };
  return { kind: 0, bits: 0 };
}
function canonical(r, x) {
  if (x < 0n || x >= MOD) return false;
  if (r.kind === 0) return true;
  const limit = 1n << BigInt(r.bits);
  if (r.kind === 1) return x < limit;
  if (r.kind === 2) return x < limit / 2n || x >= MOD - limit / 2n;
  return x % (1n << BigInt(256 - r.bits)) === 0n;
}
const names = [];
for (let bits = 8; bits <= 248; bits += 8) names.push('uint' + bits, 'int' + bits);
for (let n = 1; n <= 31; n++) names.push('bytes' + n);
names.push('address', 'bool', 'function', 'uint256', 'int256', 'bytes32', 'uint', 'int', 'bytes0', 'uint7', 'uint08', 'int7', 'int08', 'foo', 'uint248x');
const fixtures = [];
function make(name, label, words, failed = false, bad = null) {
  const r = rule(name), singles = words.map(x => '0x' + hexWord(x));
  const array = '0x' + hexWord(32) + hexWord(words.length) + words.map(hexWord).join('');
  if (failed) {
    if (bad === null || words.findIndex(x => !canonical(r, x)) !== bad) throw Error('Wrong independent dirty-word fixture');
  } else if (!words.every(x => canonical(r, x))) throw Error('Wrong independent canonical fixture');
  for (const operation of ['packArray', 'unpackArray']) {
    const position = operation === 'packArray' ? 0 : 64 + 32 * bad;
    const expected = failed ? encodeErrorResult({ abi: artifact.abi, errorName: 'InvalidValue', args: [BigInt(position)] }).slice(2)
      : encodeAbiParameters(parseAbiParameters(operation === 'packArray' ? 'bytes' : 'bytes[]'), [operation === 'packArray' ? array : singles]).slice(2);
    fixtures.push({ name: operation + '-' + name + '-' + label, operation, descriptor: name, rule: r,
      words: words.map(String), badWordIndex: bad, invalidValuePosition: failed ? position : null,
      data: encodeFunctionData({ abi: artifact.abi, functionName: operation, args: [name, operation === 'packArray' ? singles : array] }),
      expected, failed });
  }
}
for (const name of names) {
  const r = rule(name), width = 1n << BigInt(r.bits);
  const good = r.kind === 0 ? [0n, 1n << 255n, MOD - 1n]
    : r.kind === 1 ? [0n, width - 1n]
      : r.kind === 2 ? [0n, width / 2n - 1n, MOD - width / 2n, MOD - 1n]
        : [0n, ((1n << BigInt(r.bits)) - 1n) << BigInt(256 - r.bits)];
  make(name, 'canonical-boundaries', good);
  if (r.kind !== 0) {
    const dirty = r.kind === 1 ? width : r.kind === 2 ? width / 2n : 1n;
    make(name, 'first-dirty-after-prefix', [good[0], dirty, good.at(-1)], true, 1);
    if (r.kind === 2) make(name, 'zero-extended-negative', [width - 1n], true, 0);
  }
}
const expectedInventory = JSON.parse(readFileSync(resolve(root, 'formal/bytecode/value-array/physical-canonical-words/fixtures.inventory.json')));
if (JSON.stringify(fixtures.map(f => f.name)) !== JSON.stringify(expectedInventory.map(f => f.name))) throw Error('Fixture inventory drift');
const starts = new Set();
for (let pc = 0; pc < bytes.length;) { starts.add(pc); const op = bytes[pc]; pc += 1 + (op >= 96 && op <= 127 ? op - 95 : 0); }
function replay(fixture, trace) {
  const logs = trace.structLogs, data = Buffer.from(fixture.data.slice(2), 'hex');
  let pc = 0, s = [], mem = Buffer.alloc(0), signs = 0, peak = 0;
  const grow = n => { const length = Math.ceil(n / 32) * 32; if (length > mem.length) mem = Buffer.concat([mem, Buffer.alloc(length - mem.length)]); };
  for (let i = 0; i < logs.length; i++) {
    const row = logs[i], observed = row.stack.map(nat), seen = Buffer.from(row.memory.map(w => w.replace(/^0x/, '')).join(''), 'hex');
    if (row.depth !== 1 || row.pc !== pc || JSON.stringify(observed.map(String)) !== JSON.stringify(s.map(String)) || !seen.equals(mem)) throw Error('Full reconstructed state mismatch ' + fixture.name + '/' + i + '/' + pc);
    const op = bytes[pc], width = op >= 96 && op <= 127 ? op - 95 : 0;
    let next = pc + 1 + width;
    const pop = () => { if (!s.length) throw Error('Underflow'); return s.pop(); };
    if (op === 0x5b) {}
    else if (op === 0x5f) s.push(0n);
    else if (width) s.push(BigInt('0x' + bytes.subarray(pc + 1, next).toString('hex')));
    else if (op >= 0x80 && op <= 0x8f) { const k = op - 0x7f; if (s.length < k) throw Error('DUP underflow'); s.push(s.at(-k)); }
    else if (op >= 0x90 && op <= 0x9f) { const k = op - 0x8f; if (s.length < k + 1) throw Error('SWAP underflow'); [s[s.length - 1], s[s.length - 1 - k]] = [s[s.length - 1 - k], s[s.length - 1]]; }
    else if (op === 0x50) pop();
    else if ([1, 2, 3, 4, 6, 0x0b, 0x10, 0x11, 0x12, 0x14, 0x16, 0x17, 0x1a, 0x1b, 0x1c].includes(op)) {
      const a = pop(), b = pop(); let x;
      if (op === 1) x = (a + b) % MOD;
      else if (op === 2) x = (a * b) % MOD;
      else if (op === 3) x = (a - b + MOD) % MOD;
      else if (op === 4) x = b === 0n ? 0n : a / b;
      else if (op === 6) x = b === 0n ? 0n : a % b;
      else if (op === 0x10) x = BigInt(a < b);
      else if (op === 0x11) x = BigInt(a > b);
      else if (op === 0x12) x = BigInt((a < MOD / 2n ? a : a - MOD) < (b < MOD / 2n ? b : b - MOD));
      else if (op === 0x14) x = BigInt(a === b);
      else if (op === 0x16) x = a & b;
      else if (op === 0x17) x = a | b;
      else if (op === 0x1a) x = a >= 32n ? 0n : (b >> (248n - 8n * a)) & 255n;
      else if (op === 0x1b) x = a >= 256n ? 0n : (b << a) % MOD;
      else if (op === 0x1c) x = a >= 256n ? 0n : b >> a;
      else { signs++; const power = a >= 32n ? MOD : 1n << (8n * (a + 1n)); const low = b % power; x = a >= 32n ? b : low < power / 2n ? low : MOD - power + low; }
      s.push(x);
    } else if (op === 0x15) s.push(BigInt(pop() === 0n));
    else if (op === 0x19) s.push(MOD - 1n - pop());
    else if (op === 0x34) s.push(0n);
    else if (op === 0x36) s.push(BigInt(data.length));
    else if (op === 0x35) { const off = Number(pop()), part = Buffer.alloc(32); if (off < data.length) data.copy(part, 0, off, Math.min(off + 32, data.length)); s.push(BigInt('0x' + part.toString('hex'))); }
    else if (op === 0x51) { const off = Number(pop()); grow(off + 32); s.push(BigInt('0x' + mem.subarray(off, off + 32).toString('hex'))); }
    else if (op === 0x52) { const off = Number(pop()), value = pop(); grow(off + 32); Buffer.from(hexWord(value), 'hex').copy(mem, off); }
    else if (op === 0x53) { const off = Number(pop()), value = pop(); grow(off + 1); mem[off] = Number(value & 255n); }
    else if (op === 0x37) { const dest = Number(pop()), off = Number(pop()), size = Number(pop()); grow(dest + size); mem.fill(0, dest, dest + size); if (off < data.length) data.copy(mem, dest, off, Math.min(off + size, data.length)); }
    else if (op === 0x5e) { const dest = Number(pop()), off = Number(pop()), size = Number(pop()); grow(Math.max(dest + size, off + size)); Buffer.from(mem.subarray(off, off + size)).copy(mem, dest); }
    else if (op === 0x56 || op === 0x57) { const dest = Number(pop()), taken = op === 0x56 || pop() !== 0n; if (taken) { if (!starts.has(dest) || bytes[dest] !== 0x5b) throw Error('Bad actual jump'); next = dest; } }
    else if (op === 0xf3 || op === 0xfd) { const off = Number(pop()), size = Number(pop()); grow(off + size); if (i !== logs.length - 1 || (op === 0xfd) !== fixture.failed || mem.subarray(off, off + size).toString('hex') !== fixture.expected) throw Error('Wrong physical terminal packet'); return { instructions: logs.length, signextendInstructions: signs, peakStack: peak }; }
    else throw Error('Unsupported reached opcode ' + pc + '/' + op.toString(16));
    if (s.length > 1024 || s.some(x => x < 0n || x >= MOD)) throw Error('Bad represented word/stack');
    peak = Math.max(peak, s.length); pc = next;
  }
  throw Error('Missing complete physical terminal');
}
const connection = await network.connect('hardhatMainnet');
const provider = connection.provider, accounts = await provider.request({ method: 'eth_accounts' });
const target = '0x0000000000000000000000000000000000003900';
await provider.request({ method: 'hardhat_setCode', params: [target, code] });
const rows = [];
for (const fixture of fixtures) {
  const trace = await provider.request({ method: 'debug_traceCall', params: [{ from: accounts[0], to: target, gas: '0x989680', data: fixture.data, value: '0x0' }, 'latest', { enableMemory: true, disableStorage: true, disableStack: false }] });
  writeFileSync(resolve(out, fixture.name + '.json'), JSON.stringify({ fixture, runtimeSha256, trace }, null, 2) + '\n');
  const errors = []; let replayResult = {};
  const receiptPassed = trace.failed === fixture.failed && trace.returnValue.replace(/^0x/, '') === fixture.expected;
  if (!receiptPassed) errors.push('Independent complete receipt differs');
  try { replayResult = replay(fixture, trace); } catch (e) { errors.push(e.message); }
  if (fixture.rule.kind === 2 && replayResult.signextendInstructions === 0) errors.push('Signed check not reached');
  rows.push({ name: fixture.name, passed: errors.length === 0, receiptPassed, ...replayResult, errors, trace: fixture.name + '.json' });
}
await connection.close();
const hh = fileURLToPath(import.meta.resolve('hardhat')), edr = createRequire(hh).resolve('@nomicfoundation/edr'), binding = createRequire(edr).resolve('@nomicfoundation/edr-linux-x64-gnu');
writeFileSync(resolve(out, 'toolchain.json'), JSON.stringify({ nodeVersion: process.version, nodeExecutable: process.execPath, nodeSha256: sha(readFileSync(process.execPath)), hardhatEntry: hh, hardhatEntrySha256: sha(readFileSync(hh)), edrEntry: edr, edrEntrySha256: sha(readFileSync(edr)), nativeBinding: binding, nativeBindingSha256: sha(readFileSync(binding)), lockfileSha256: sha(readFileSync(resolve(root, 'pnpm-lock.yaml'))) }, null, 2) + '\n');
writeFileSync(resolve(out, 'results.json'), JSON.stringify(rows, null, 2) + '\n');
console.log((rows.every(x => x.passed) ? 'PASS' : 'FAIL') + ': ' + rows.length + ' complete canonical-word physical receipts');
process.exitCode = rows.every(x => x.passed) ? 0 : 1;
