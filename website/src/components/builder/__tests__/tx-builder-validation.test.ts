import { describe, expect, it } from "vitest";
import { encodeFunctionData, parseAbi } from "viem";

import type { ComposeEnv } from "../compose-call";
import { evml } from "../evml";
import {
  type TxBuilderBatch,
  actionsToTxBuilderBatch,
  importTxBuilder,
  parseTxBuilderBatch,
  txBuilderToEvml,
} from "../safe-tx-builder";
import EXPORT from "./fixtures/tx-builder-export.json";

// The fixture is written in the shape the Safe Transaction Builder app
// saves (its `BatchFile`, with values as the text typed into its form:
// arrays and tuples as JSON), not captured from a session of the app.
const USDC = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48";
const DEAD = "0x000000000000000000000000000000000000dEaD";
const OWNED = "0x00000000000000000000000000000000000000bb";
const SAFE = "0x5Afe000000000000000000000000000000005afe";
const tag = evml.with({ chainId: 1, account: SAFE });

const env: ComposeEnv = {
  chainId: 1,
  nativeSymbol: "ETH",
  tokens: [{ symbol: "USDC", chainId: 1, address: USDC }],
  decimalsOf: async (address) => ({ [USDC]: 6 } as Record<string, number>)[address],
  ensToVar: async () => null,
};
const input = (name: string, type: string, components?: unknown) => ({ name, type, ...(components ? { components } : {}) });
const tx = (inputs: ReturnType<typeof input>[], values: Record<string, unknown>, extra: object = {}) => ({
  to: OWNED,
  value: "0",
  data: null,
  contractMethod: { name: "f", inputs, payable: false },
  contractInputsValues: values,
  ...extra,
});
const GOOD = tx([input("to", "address")], { to: DEAD });
const batchOf = (...transactions: unknown[]) => ({ chainId: "1", transactions }) as unknown as TxBuilderBatch;
const calls = async (script: string) =>
  actionsToTxBuilderBatch(await tag.script(script).interpret(), { chainId: 1 }).transactions.map(
    ({ to, value, data }) => ({ to, value, data }),
  );

/** Text that would add a command, close a block or smuggle a token if it
 *  reached a script as it is. */
const HOSTILE = [
  ["a line feed and a command", `1\nexec ${USDC} "drain()"`],
  ["a carriage return and line feed", `1\r\nexec ${USDC} "drain()"`],
  ["a line separator", `1\u2028exec ${USDC} "drain()"`],
  ["a closing parenthesis", "1)"],
  ["a comment", "1 # nothing"],
  ["a quote", '1" "2'],
  ["a variable", "$safe"],
  ["a helper", "@token:amount(USDC 1)"],
  ["a trailing option", "1 --value 1"],
  ["a second token", "1 2"],
] as const;

/** Every place of a transaction where the file's text could go. */
const FIELDS: [string, RegExp, (hostile: string) => unknown][] = [
  ["to", /"to"/, (h) => ({ ...GOOD, to: h })],
  ["to, after an address", /"to"/, (h) => ({ ...GOOD, to: `${DEAD} ${h}` })],
  ["value", /"value"/, (h) => ({ ...GOOD, value: h })],
  ["data", /"data"/, (h) => ({ to: OWNED, value: "0", data: `0xdeadbeef${h}` })],
  ["the method name", /method name/, (h) => ({ ...GOOD, contractMethod: { ...GOOD.contractMethod, name: `f${h}` } })],
  ["an input type", /type of input 1/, (h) => tx([input("to", `uint256${h}`)], { to: "1" })],
  ["an address", /input 1 \(address\)/, (h) => tx([input("a", "address")], { a: h })],
  ["a number", /input 1 \(uint256\)/, (h) => tx([input("a", "uint256")], { a: h })],
  ["a signed number", /input 1 \(int8\)/, (h) => tx([input("a", "int8")], { a: h })],
  ["a boolean", /input 1 \(bool\)/, (h) => tx([input("a", "bool")], { a: h })],
  ["bytes", /input 1 \(bytes\)/, (h) => tx([input("a", "bytes")], { a: `0x${h}` })],
  ["fixed bytes", /input 1 \(bytes4\)/, (h) => tx([input("a", "bytes4")], { a: h })],
  ["an array element", /input 1 \(uint256\[\]\)/, (h) => tx([input("a", "uint256[]")], { a: JSON.stringify(["1", h]) })],
  ["a nested array element", /input 2 \(address\[\]\[\]\)/, (h) => tx([input("n", "uint256"), input("a", "address[][]")], { n: "1", a: JSON.stringify([[DEAD], [h]]) })],
  [
    "a tuple member",
    /input 1 \(\(address,uint256\)\)/,
    (h) => tx([input("a", "tuple", [input("x", "address"), input("y", "uint256")])], { a: JSON.stringify([DEAD, h]) }),
  ],
];

describe("an imported file is refused unless every piece is what it claims to be", () => {
  const cases = FIELDS.flatMap(([field, where, make]) =>
    HOSTILE.map(([what, hostile]) => [field, what, where, make(hostile), hostile] as const),
  );
  it.each(cases)("%s with %s", async (_field, _what, where, bad, hostile) => {
    const batch = batchOf(GOOD, bad);
    const parsed = parseTxBuilderBatch(batch);
    if (!("error" in parsed)) throw new Error(`accepted: ${JSON.stringify(bad)}`);
    // Which transaction, and which field.
    expect(parsed.error).toMatch(/^Transaction 2: /);
    expect(parsed.error).toMatch(where);
    // The message does not carry the text either.
    expect(parsed.error).not.toContain("drain");
    expect(parsed.error).not.toContain(hostile);
    // Neither path writes anything: a batch is taken whole or not at all.
    expect(() => txBuilderToEvml(batch)).toThrow(parsed.error);
    await expect(importTxBuilder(batch, env)).rejects.toThrow(parsed.error);
  });

  it.each([
    ["an address of the wrong length", tx([input("a", "address")], { a: DEAD.slice(0, -2) }), /input 1 \(address\)/],
    ["an address with a wrong checksum", tx([input("a", "address")], { a: DEAD.replace("dEaD", "DEaD") }), /input 1 \(address\)/],
    ["a number with a sign", tx([input("a", "uint8")], { a: "-1" }), /input 1 \(uint8\)/],
    ["a number with a plus", tx([input("a", "int8")], { a: "+1" }), /input 1 \(int8\)/],
    ["a number with an exponent", tx([input("a", "uint256")], { a: "1e18" }), /input 1 \(uint256\)/],
    ["a number too large for its type", tx([input("a", "uint8")], { a: "256" }), /input 1 \(uint8\)/],
    ["a signed number out of range", tx([input("a", "int8")], { a: "-129" }), /input 1 \(int8\)/],
    ["a hex number", tx([input("a", "uint256")], { a: "0x10" }), /input 1 \(uint256\)/],
    ["hex of odd length", tx([input("a", "bytes")], { a: "0xabc" }), /input 1 \(bytes\)/],
    ["fixed bytes of another length", tx([input("a", "bytes4")], { a: "0xdeadbeef00" }), /input 1 \(bytes4\)/],
    ["a tuple with an extra member", tx([input("a", "tuple", [input("x", "address")])], { a: JSON.stringify([DEAD, "1"]) }), /input 1 \(\(address\)\)/],
    ["a tuple with a member missing", tx([input("a", "tuple", [input("x", "address"), input("y", "bool")])], { a: JSON.stringify([DEAD]) }), /input 1/],
    ["a fixed array of another length", tx([input("a", "uint256[2]")], { a: "[1,2,3]" }), /input 1 \(uint256\[2\]\)/],
    ["an array that is no array", tx([input("a", "uint256[]")], { a: "1, 2" }), /input 1/],
    ["an object where a value goes", tx([input("a", "uint256[]")], { a: '[{"x":1}]' }), /input 1/],
    ["a value that is missing", tx([input("a", "uint256")], {}), /input 1/],
    ["a value that is no text", tx([input("a", "uint256")], { a: { toString: "1" } }), /input 1/],
    ["a type that is none", tx([input("a", "uint7")], { a: "1" }), /type of input 1/],
    ["a type with a size too large", tx([input("a", "bytes33")], { a: "0x00" }), /type of input 1/],
    ["a tuple without components", tx([input("a", "tuple")], { a: "[]" }), /type of input 1/],
    ["an array type that closes the signature", tx([input("a", 'uint256) \nexec')], { a: "1" }), /type of input 1/],
    ["a method name that is no identifier", { ...GOOD, contractMethod: { name: "f(uint256)", inputs: [] } }, /method name/],
    ["an empty method name", { ...GOOD, contractMethod: { name: "", inputs: [] } }, /method name/],
    ["a negative value", { ...GOOD, value: "-1" }, /"value"/],
    ["a value with a fraction", { ...GOOD, value: "1.5" }, /"value"/],
    ["a value in hex", { ...GOOD, value: "0x10" }, /"value"/],
    ["a value above uint256", { ...GOOD, value: (2n ** 256n).toString() }, /"value"/],
    ["data of odd length", { to: OWNED, value: "0", data: "0xabc" }, /"data"/],
    ["data without 0x", { to: OWNED, value: "0", data: "deadbeef" }, /"data"/],
    ["a transaction that is no object", "exec", /Transaction 2/],
    ["a method with inputs and no values, and no data", { ...GOOD, contractInputsValues: null }, /input 1/],
  ])("refuses %s", (_name, bad, where) => {
    const parsed = parseTxBuilderBatch(batchOf(GOOD, bad));
    if (!("error" in parsed)) throw new Error("accepted");
    expect(parsed.error).toMatch(/^Transaction 2: /);
    expect(parsed.error).toMatch(where);
  });

  it("refuses a file that is no batch, and a chain id that is none", () => {
    expect(parseTxBuilderBatch(null)).toHaveProperty("error");
    expect(parseTxBuilderBatch({ transactions: "none" })).toHaveProperty("error");
    expect(parseTxBuilderBatch({ transactions: [] })).toHaveProperty("error");
    expect(parseTxBuilderBatch({ chainId: "1\nexec", transactions: [GOOD] })).toEqual({
      error: 'The batch\'s "chainId" is not a chain id.',
    });
    expect(parseTxBuilderBatch({ meta: { name: 5 }, transactions: [GOOD] })).toHaveProperty("error");
  });

  it("a parameter's name never reaches the script: it only suggests a variable's name when it is a plain word", async () => {
    for (const name of ["to $safe", "a#b", "x\nexec 0x00 \"drain()\"", "$to", "a b", "", "to)"]) {
      const batch = batchOf(tx([input(name, "address"), input("n", "uint256")], { [name]: DEAD, n: "1" }));
      const out = await importTxBuilder(batch, env);
      expect(out.script.split("\n"), name).toEqual([
        `set $contract ${OWNED}`,
        `set $address ${DEAD}`,
        'exec $contract "f(address,uint256)" $address 1',
      ]);
      expect(txBuilderToEvml(batch).script).toBe(`exec ${OWNED} "f(address,uint256)" ${DEAD} 1`);
    }
  });

  it("an odd identifier is still only a word a variable may be named by", async () => {
    for (const [name, variable] of [["__proto__", "proto"], ["constructor", "constructor"], ["hasOwnProperty", "hasOwnProperty"]]) {
      const batch = batchOf(tx([input(name, "address"), input("n", "uint256")], { [name]: DEAD, n: "1" }));
      expect((await importTxBuilder(batch, env)).script.split("\n").slice(1)).toEqual([
        `set $${variable} ${DEAD}`,
        `exec $contract "f(address,uint256)" $${variable} 1`,
      ]);
    }
  });

  it("keeps the batch's name and description to one comment line each, whatever they hold", async () => {
    const batch = {
      ...batchOf(GOOD),
      meta: {
        name: `Payroll\nexec ${USDC} "drain()"\r\nmore\u2028and\u0085more\u0000`,
        description: `${"x".repeat(500)}\nexec`,
      },
    } as TxBuilderBatch;
    for (const script of [txBuilderToEvml(batch).script, (await importTxBuilder(batch, env)).script]) {
      const lines = script.split(/\r\n|[\n\r\u2028\u2029\u0085]/);
      const comments = lines.filter((l) => l.startsWith("#"));
      expect(comments).toHaveLength(2);
      expect(comments[0]).toBe(`# Payroll exec ${USDC} "drain()" more and more`);
      expect(comments[1].length).toBeLessThanOrEqual(122);
      // Everything that is not a comment is the one transaction.
      expect(lines.filter((l) => l.startsWith("exec"))).toHaveLength(1);
      const { diagnostics } = await tag.script(script).validate();
      expect(diagnostics.filter((d) => d.severity === "error")).toEqual([]);
      expect(await calls(script)).toHaveLength(1);
    }
    // Nothing left of a name that was only line breaks.
    expect(txBuilderToEvml({ ...batchOf(GOOD), meta: { name: "\n\r\n" } } as TxBuilderBatch).script).toBe(
      `exec ${OWNED} "f(address)" ${DEAD}`,
    );
  });
});

describe("what the file may say, as a real export says it", () => {
  it.each([
    ["uint256", '"5"', "5"],
    ["uint256", " 007 ", "7"],
    ["int16", "-12", "-12"],
    ["bool", "True", "true"],
    ["bool", "0", "false"],
    ["bytes", "0x", "0x"],
    ["bytes2", "0xABcd", "0xABcd"],
    ["address", DEAD.toLowerCase(), DEAD],
    ["uint256[]", "[1, 2,3]", "[1 2 3]"],
    ["uint256[]", '["1","2"]', "[1 2]"],
    ["uint256[]", "[]", "[]"],
    ["uint8[][2]", "[[1,2],[3]]", "[[1 2] [3]]"],
    ["address[]", `[${DEAD}, "${USDC}"]`, `[${DEAD} ${USDC}]`],
    ["string[]", '["a, b","c] d"]', '["a, b" "c] d"]'],
    ["bool[]", "[true,false]", "[true false]"],
  ])("%s %s", (type, value, written) => {
    const script = txBuilderToEvml(batchOf(tx([input("a", type)], { a: value }))).script;
    expect(script).toBe(`exec ${OWNED} "f(${type})" ${written}`);
  });

  it("writes a string so that the script holds exactly that text", async () => {
    const text = 'q" b\\ n\nr\rt\t # $x @h(1) ) é 😀 \u2028\u2029 --value 1\nexec';
    const script = txBuilderToEvml(batchOf(tx([input("a", "string"), input("b", "string[]")], { a: text, b: JSON.stringify([text, ""]) }))).script;
    // One line of script, whatever the text holds: line feeds are escaped,
    // and EVML does not end a line at a Unicode line separator.
    expect(script.split(/[\n\r]/)).toHaveLength(1);
    expect((await tag.script(script).validate()).diagnostics).toEqual([]);
    expect(await calls(script)).toEqual([
      {
        to: OWNED,
        value: "0",
        data: encodeFunctionData({ abi: parseAbi(["function f(string,string[])"]), args: [text, [text, ""]] }),
      },
    ]);
  });

  it("takes a value of zero in the forms an export has, and a number", () => {
    for (const value of ["0", "", null, undefined, 0])
      expect(txBuilderToEvml(batchOf({ ...GOOD, value })).script).toBe(`exec ${OWNED} "f(address)" ${DEAD}`);
    expect(txBuilderToEvml(batchOf({ ...GOOD, value: " 0012 " })).script).toContain("--value 12");
    expect(txBuilderToEvml(batchOf({ ...GOOD, value: 12 })).script).toContain("--value 12");
  });
});

describe("a Transaction Builder export", () => {
  const batch = EXPORT as unknown as TxBuilderBatch;
  const ABI = parseAbi([
    "function transfer(address to, uint256 value)",
    "function disperse(address[] recipients, uint256[] amounts)",
    "function place((address token, uint256 amount, string memo) order, bool urgent) payable",
  ]);
  const EXPECTED = [
    { to: USDC, value: "0", data: encodeFunctionData({ abi: ABI, functionName: "transfer", args: [DEAD, 1500000n] }) },
    { to: OWNED, value: "0", data: encodeFunctionData({ abi: ABI, functionName: "disperse", args: [[DEAD, USDC], [1n, 2n]] }) },
    {
      to: OWNED,
      value: "7",
      data: encodeFunctionData({ abi: ABI, functionName: "place", args: [{ token: USDC, amount: 1000000n, memo: "rent, October" }, true] }),
    },
    { to: DEAD, value: "1000", data: "0x" },
    { to: OWNED, value: "0", data: "0xdeadbeef" },
  ];

  it("converts to the calls the file lists, arrays and tuples in valid EVML", async () => {
    const { script, chainId, name } = txBuilderToEvml(batch);
    expect(script.split("\n")).toEqual([
      "# Transactions Batch",
      `exec ${USDC} "transfer(address,uint256)" ${DEAD} 1500000`,
      `exec ${OWNED} "disperse(address[],uint256[])" [${DEAD} ${USDC}] [1 2]`,
      `exec ${OWNED} "place((address,uint256,string),bool)" [${USDC} 1000000 "rent, October"] true --value 7`,
      `send ${DEAD} --value 1000`,
      `send ${OWNED} --data 0xdeadbeef`,
    ]);
    expect(chainId).toBe(1);
    expect(name).toBe("Transactions Batch");
    const { diagnostics } = await tag.script(script).validate();
    expect(diagnostics.filter((d) => d.severity === "error")).toEqual([]);
    expect(await calls(script)).toEqual(EXPECTED);
  });

  it("imports through the form's path to the same calls, over named addresses", async () => {
    const { script } = await importTxBuilder(batch, env, { context: [{ name: "safe", address: SAFE }] });
    expect(script.split("\n")).toEqual([
      "load token",
      `set $usdc ${USDC}`,
      // A recipient, then one of a list: no single part names it.
      `set $address ${DEAD}`,
      `set $contract ${OWNED}`,
      "# Transactions Batch",
      'exec $usdc "transfer(address,uint256)" $address @token:amount($usdc 1.5)',
      'exec $contract "disperse(address[],uint256[])" [$address $usdc] [1 2]',
      'exec $contract "place((address,uint256,string),bool)" [$usdc 1000000 "rent, October"] true --value 7',
      `send ${DEAD} --value 1000`,
      `send ${OWNED} --data 0xdeadbeef`,
    ]);
    const { diagnostics } = await tag.script(script).validate();
    expect(diagnostics.filter((d) => d.severity === "error")).toEqual([]);
    // The addresses are variables now; the calls are the same but for
    // the token amount, which needs the chain to read its decimals.
    const withoutAmount = script.replace("@token:amount($usdc 1.5)", "1500000");
    expect(await calls(withoutAmount)).toEqual(EXPECTED);
  });

  it("the calldata of a decoded call is the file's own data when it has one, or the file is refused", () => {
    const withData = (data: string) => batchOf({ ...batch.transactions[1], data });
    expect(txBuilderToEvml(withData(EXPECTED[1].data)).script).toContain("disperse");
    const lying = parseTxBuilderBatch(withData(EXPECTED[0].data));
    expect(lying).toEqual({ error: 'Transaction 1: "data" is not the call its method and values describe.' });
  });

  it("what the builder exports imports again to the same calls", async () => {
    const script = txBuilderToEvml(batch).script;
    const exported = actionsToTxBuilderBatch(await tag.script(script).interpret(), { chainId: 1, safeAddress: SAFE });
    const parsed = parseTxBuilderBatch(JSON.parse(JSON.stringify(exported)));
    expect(parsed).not.toHaveProperty("error");
    const again = (await importTxBuilder(exported, env)).script;
    expect(await calls(again)).toEqual(EXPECTED);
  });
});
