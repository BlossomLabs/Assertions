// This is a concrete independent-oracle check, not an implementation proof.
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { encodeAbiParameters } from 'viem';

const fixture = JSON.parse(readFileSync(new URL('./fixtures.json', import.meta.url)));
const viem = JSON.parse(readFileSync(new URL('../../node_modules/viem/package.json', import.meta.url)));
assert.equal(viem.version, fixture.oracle.version, 'fixture oracle version drift');
assert.equal(fixture.cases.length, 1);
const example = fixture.cases[0];
assert.equal(encodeAbiParameters(example.parameters, example.args), example.encoded);

// Link the actual Dafny expected vector to viem. Refuse unknown syntax rather
// than evaluating code or duplicating the recursive model encoder in JavaScript.
const source = readFileSync(new URL('./Examples.dfy', import.meta.url), 'utf8');
const equation = source.match(/function ExpectedNestedTuple\(\): seq<Byte>\s*\{([^}]+)\}/);
assert(equation, 'missing Dafny reference vector');
const fragments = equation[1].trim().split('+').map(part => {
  const token = part.trim();
  let m;
  if ((m = /^Word\((\d+)\)$/.exec(token))) {
    const hex = BigInt(m[1]).toString(16);
    assert(hex.length <= 64);
    return hex.padStart(64, '0');
  }
  if ((m = /^Zeros\((\d+)\)$/.exec(token))) return '00'.repeat(Number(m[1]));
  if ((m = /^\[([\d,\s]*)\]$/.exec(token))) {
    return m[1].split(',').filter(s => s.trim()).map(s => {
      const n = Number(s.trim());
      assert(Number.isInteger(n) && n >= 0 && n < 256);
      return n.toString(16).padStart(2, '0');
    }).join('');
  }
  throw new Error(`Unsupported fixture expression: ${token}`);
});
assert.equal('0x'+fragments.join(''), example.encoded);
const solidity = readFileSync(new URL('./EncodingOracle.t.sol', import.meta.url), 'utf8');
const literal = solidity.match(/bytes memory expected\s*=\s*hex"([0-9a-f]+)";/);
assert(literal, 'missing solc oracle fixture');
assert.equal('0x'+literal[1], example.encoded);
console.log(`PASS: 1 viem ${viem.version} fixture equals the Dafny reference vector (${fragments.join('').length / 2} bytes)`);
