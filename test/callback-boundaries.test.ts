import assert from "node:assert/strict";
import { describe, it } from "node:test";
import { network } from "hardhat";
import {
  concatHex, encodeAbiParameters, encodeErrorResult, encodeFunctionData,
  parseAbi, parseAbiParameters, type Hex,
} from "viem";

const addAbi = parseAbi(["function add(uint256,uint256) pure returns (uint256)"]);
const errors = parseAbi([
  "error InvalidValue(uint256)",
  "error InvalidComponentValue(uint256,uint256)",
  "error InvalidCallbackResult(bytes4,uint256,uint256,address)",
]);
const word = (value: bigint): Hex => encodeAbiParameters(parseAbiParameters("uint256"), [value]);
const zero = word(0n);
const add = encodeFunctionData({ abi: addAbi, functionName: "add", args: [0n, 0n] });
const addSelector = add.slice(0, 10) as Hex;

async function fixture() {
  const { viem } = await network.connect();
  const collections = await viem.deployContract("Collections");
  const operations = await viem.deployContract("Operations");
  const expressions = await viem.deployContract("Expressions");
  const target = await viem.deployContract("MockTarget");
  return { collections, operations, expressions, target };
}

async function exactRevert(promise: Promise<unknown>, expected: Hex) {
  await assert.rejects(promise, (error: any) => {
    for (let cause = error; cause; cause = cause.cause) {
      const data = typeof cause.data === "string" ? cause.data : cause.data?.data;
      if (typeof data === "string" && data.startsWith("0x")) {
        assert.equal(data.toLowerCase(), expected.toLowerCase());
        return true;
      }
    }
    throw error;
  });
}

describe("claim callback boundaries", () => {
  it("L74: direct lambdas and value callbacks observe Collections; graph calls observe Expressions", async () => {
    const { collections, expressions, target } = await fixture();
    const values = [word(7n), word(9n)];
    const payload = concatHex(values);
    // Solidity accepts trailing arguments on caller(); its returned word is an independent caller oracle.
    const selector = encodeFunctionData({ abi: target.abi, functionName: "caller" });
    const template = concatHex([selector, zero, zero]);
    const callerWord = encodeAbiParameters(parseAbiParameters("address"), [collections.address]);
    assert.equal((await collections.read.mapWords([payload, target.address, template, [4n]])).toLowerCase(), concatHex([callerWord, callerWord]).toLowerCase());
    assert.equal(await collections.read.reduceWords([payload, target.address, template, [4n], 0, 0, callerWord]), 1n);
    assert.equal((await collections.read.foldWords([payload, target.address, template, 4n, [36n], zero, 0])).toLowerCase(), callerWord.toLowerCase());
    const callback = { target: target.address, selector, arguments: "(uint256)", constants: ["0x" as Hex], first: 0n, second: 0n, expression: "0x" as Hex };
    assert.deepEqual((await collections.read.mapValues(["uint256", "address", values, callback])).map(v => v.toLowerCase()), [callerWord, callerWord].map(v => v.toLowerCase()));
    const expression = {
      core: target.address,
      nodes: [
        { kind: 0, valueType: "address", data: encodeAbiParameters(parseAbiParameters("address"), [target.address]), refs: [], selector: "0x00000000", arguments: "" },
        { kind: 3, valueType: "address", data: "0x", refs: [0n], selector, arguments: "()" },
      ],
      result: 1n,
    } as const;
    const encoded = encodeAbiParameters(parseAbiParameters("(address core,(uint8 kind,string valueType,bytes data,uint256[] refs,bytes4 selector,string arguments)[] nodes,uint256 result)"), [expression]);
    const graphCallback = { ...callback, target: expressions.address, expression: encoded };
    const graphCaller = encodeAbiParameters(parseAbiParameters("address"), [expressions.address]);
    assert.deepEqual((await collections.read.mapValues(["uint256", "address", values, graphCallback])).map(v => v.toLowerCase()), [graphCaller, graphCaller].map(v => v.toLowerCase()));
    assert.notEqual(callerWord, graphCaller);
  });

  it("L75: raw word mapping/reduction accepts dirty narrow words while typed values reject them", async () => {
    const { collections, operations } = await fixture();
    const callback = { target: operations.address, selector: addSelector, arguments: "(uint256,uint256)", constants: ["0x" as Hex, zero], first: 0n, second: 0n, expression: "0x" as Hex };
    const mapSelector = encodeFunctionData({ abi: collections.abi, functionName: "mapValues", args: ["uint256", "bool", [], callback] }).slice(0, 10) as Hex;
    for (const [type, value] of [["bool", 2n], ["uint8", 256n], ["address", 1n << 160n]] as const) {
      const payload = word(value);
      assert.equal(await collections.read.mapWords([payload, operations.address, add, [4n]]), payload);
      assert.equal(await collections.read.reduceWords([payload, operations.address, add, [4n], 0, 0, payload]), 1n);
      assert.equal(await collections.read.reduceWords([payload, operations.address, add, [4n], 3, 0, zero]), value);
      await exactRevert(collections.read.mapValues(["uint256", type, [payload], callback]), encodeErrorResult({ abi: errors, errorName: "InvalidCallbackResult", args: [mapSelector, 0n, 0n, operations.address] }));
    }
    const filterSelector = encodeFunctionData({ abi: collections.abi, functionName: "filterWords", args: ["0x", operations.address, add, [4n]] }).slice(0, 10) as Hex;
    await exactRevert(collections.read.filterWords([word(2n), operations.address, add, [4n]]), encodeErrorResult({ abi: errors, errorName: "InvalidCallbackResult", args: [filterSelector, 0n, 0n, operations.address] }));
  });

  it("L70: constants and bound arguments must fit their declared slot types, including matching-type bindings", async () => {
    const { collections, operations } = await fixture();
    const callback = { target: operations.address, selector: addSelector, arguments: "(uint8,uint8)", constants: ["0x" as Hex, word(1n)], first: 0n, second: 0n, expression: "0x" as Hex };
    for (const inputType of ["uint8", "uint256"]) {
      assert.deepEqual(await collections.read.mapValues([inputType, "uint256", [word(7n)], callback]), [word(8n)]);
      await exactRevert(collections.read.mapValues([inputType, "uint256", [word(256n)], callback]), encodeErrorResult({ abi: errors, errorName: inputType === "uint8" ? "InvalidValue" : "InvalidComponentValue", args: inputType === "uint8" ? [0n] : [0n, 0n] }));
    }
    await exactRevert(collections.read.mapValues(["uint8", "uint256", [], { ...callback, constants: ["0x", word(256n)] }]), encodeErrorResult({ abi: errors, errorName: "InvalidComponentValue", args: [1n, 0n] }));
  });

  it("L73: invalid reduction/comparison enums revert empty even when Sum ignores the comparison", async () => {
    const { collections, operations } = await fixture();
    for (const mode of [4, 255]) {
      await exactRevert(collections.read.reduceWords(["0x", operations.address, add, [4n], mode, 0, zero]), "0x");
    }
    for (const mode of [0, 1, 2, 3]) {
      for (const cmp of [10, 255]) {
        await exactRevert(collections.read.reduceWords(["0x", operations.address, add, [4n], mode, cmp, zero]), "0x");
      }
    }
  });
});
