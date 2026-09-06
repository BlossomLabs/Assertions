import assert from "node:assert/strict";
import { describe, it } from "node:test";
import { network } from "hardhat";
import { encodeAbiParameters, parseAbi, parseAbiParameters, type Hex } from "viem";

const codecAbi = parseAbi([
  "function packArray(string elementType, bytes[] values) pure returns (bytes)",
  "function encodeBytes(string types, bytes[] values) pure returns (bytes)",
  "function unpackArray(string elementType, bytes encoded) pure returns (bytes[])",
]);

async function deployCodec() {
  const { viem } = await network.connect();
  const { address } = await viem.deployContract("CollectionOperators");
  const { address: operators } = await viem.deployContract("Operators");
  const client = await viem.getPublicClient();
  return {
    encodeBytes: (args: [string, Hex[]]) => client.readContract({address: operators, abi: codecAbi, functionName: "encodeBytes", args}),
    packArray: (args: [string, Hex[]]) => client.readContract({address, abi: codecAbi, functionName: "packArray", args}),
    unpackArray: (args: [string, Hex]) => client.readContract({address, abi: codecAbi, functionName: "unpackArray", args}),
  };
}

// These fixtures come from viem rather than the Solidity codec's offset arithmetic.
describe("CollectionOperators independent ABI fixtures", () => {
  it("packs and extracts nested static and dynamic values exactly", async () => {
    const ops = await deployCodec();
    const cases: {type: string; values: any[]}[] = [
      {type: "uint256", values: [0n, (1n << 256n) - 1n]},
      {type: "(int256,bool)", values: [[-7n, true], [8n, false]]},
      {type: "string", values: ["", "a", "x".repeat(33), "é"]},
      {type: "bytes", values: ["0x", "0x010203", `0x${"ff".repeat(65)}`]},
      {type: "uint256[][]", values: [[[1n], [], [2n, 3n]], []]},
      {type: "string[2]", values: [["one", ""], ["", "thirty-three-characters-long-value"]]},
      {type: "(uint256,string,bytes[])", values: [[9n, "odd", ["0x00", "0x"]], [0n, "", []]]},
      {type: "(uint256[2],(string,bool)[])", values: [[[1n, 2n], [["hi", true], ["", false]]]]},
    ];
    for (const fixture of cases) {
      const single = parseAbiParameters(fixture.type);
      const values = fixture.values.map(value => encodeAbiParameters(single, [value]));
      const expected = encodeAbiParameters(parseAbiParameters(`${fixture.type}[]`), [fixture.values]);
      for (const value of values) assert.equal(await ops.encodeBytes([`(${fixture.type})`, [value]]), value);
      assert.equal(await ops.packArray([fixture.type, values]), expected, fixture.type);
      assert.deepEqual(await ops.unpackArray([fixture.type, expected]), values, fixture.type);
      const empty = encodeAbiParameters(parseAbiParameters(`${fixture.type}[]`), [[]]);
      assert.equal(await ops.packArray([fixture.type, []]), empty);
      assert.deepEqual(await ops.unpackArray([fixture.type, empty]), []);
    }
  });

  it("rejects malformed envelopes and noncanonical offsets", async () => {
    const ops = await deployCodec();
    const canonical = encodeAbiParameters(parseAbiParameters("string[]"), [["abc"]]);
    const replaceWord = (value: Hex, index: number, word: bigint): Hex =>
      `${value.slice(0, 2 + index * 64)}${word.toString(16).padStart(64, "0")}${value.slice(2 + (index + 1) * 64)}` as Hex;
    const malformed = [
      "0x" as Hex,
      canonical.slice(0, -2) as Hex,
      replaceWord(canonical, 0, 64n),
      replaceWord(canonical, 2, 0n),
      replaceWord(canonical, 2, 33n),
      replaceWord(canonical, 3, 500n),
      `${canonical.slice(0, -2)}01` as Hex,
    ];
    for (const encoded of malformed) await assert.rejects(ops.unpackArray(["string", encoded]));
  });
});
