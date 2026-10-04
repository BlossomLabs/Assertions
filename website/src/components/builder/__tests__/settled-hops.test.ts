import { describe, expect, it } from "vitest";

import { buildAssertionLine, buildExprText } from "../assertion-codegen";
import {
  type CallArg,
  type CallHop,
  type CallNode,
  type ValueExpr,
  argFits,
  argText,
  canYield,
  inferCategory,
  isCallArgNode,
  producedType,
  settledHops,
} from "../assertion-model";
import { callTail } from "../expr/summarize";
import { wrapEntriesFor } from "../expr/catalog";

const T = "0x1234567890123456789012345678901234567890";
const U = "0xabcdefabcdefabcdefabcdefabcdefabcdef0001";

const hop = (partial: Partial<CallHop> & { fnName: string }): CallHop => ({
  inline: false,
  argTypes: [],
  returnTypes: ["uint256"],
  args: [],
  ...partial,
});
/** A chained call added from the strip, with no function chosen yet. */
const unchosen = (): CallHop => hop({ fnName: "", returnTypes: [] });
const call = (hops: CallHop[], target = T): CallNode => ({
  kind: "call",
  target,
  resolved: null,
  hops,
});
const owner = () => hop({ fnName: "owner", returnTypes: ["address"] });
const totalAssets = () => hop({ fnName: "totalAssets", inline: true });
const noEns = { resolveEns: async () => null, chainId: 1 };

describe("settledHops", () => {
  it("drops a trailing call with no function", () => {
    expect(settledHops([owner(), unchosen()])).toEqual([owner()]);
    expect(settledHops([owner(), totalAssets(), unchosen()])).toEqual([
      owner(),
      totalAssets(),
    ]);
  });

  it("drops every trailing call with no function", () => {
    expect(settledHops([owner(), unchosen(), unchosen()])).toEqual([owner()]);
  });

  it("keeps the chain as it is when every call has a function", () => {
    const hops = [owner(), totalAssets()];
    expect(settledHops(hops)).toEqual(hops);
  });

  it("keeps the first call even with no function: the call is incomplete, not shorter", () => {
    expect(settledHops([unchosen()])).toEqual([unchosen()]);
    expect(settledHops([unchosen(), unchosen()])).toEqual([unchosen()]);
  });

  it("does not skip an unchosen call in the middle", () => {
    const hops = [owner(), unchosen(), totalAssets()];
    expect(settledHops(hops)).toEqual(hops);
  });

  it("returns nothing for no calls", () => {
    expect(settledHops([])).toEqual([]);
  });
});

describe("a trailing chained call with no function", () => {
  it("is ignored by the category: the chain reads as it did before it was added", () => {
    expect(inferCategory(call([owner()]))).toBe("address");
    expect(inferCategory(call([owner(), unchosen()]))).toBe("address");
    expect(inferCategory(call([owner(), totalAssets(), unchosen()]))).toBe("uint");
  });

  it("so the value keeps the operations it could take", () => {
    const keys = (node: ValueExpr) => wrapEntriesFor(node, 0).map((e) => e.key);
    const settled = call([owner(), totalAssets()]);
    expect(keys(call([...settled.hops, unchosen()]))).toEqual(keys(settled));
    expect(keys(settled)).toContain("arith");
  });

  it("is ignored by the generated expression", async () => {
    const settled = await buildExprText(call([owner()]), noEns);
    expect(settled).toEqual({ line: `${T}::!{owner()(address)}`, sets: [] });
    expect(await buildExprText(call([owner(), unchosen()]), noEns)).toEqual(settled);
  });

  it("is ignored at the end of a longer chain", async () => {
    expect(
      await buildExprText(call([owner(), totalAssets(), unchosen()]), noEns),
    ).toEqual({
      line: `${T}::!{owner()(address)}::!{totalAssets()(uint256)}`,
      sets: [],
    });
  });

  it("is ignored by the whole assertion line", async () => {
    expect(
      await buildAssertionLine(
        {
          subject: call([owner(), unchosen()]),
          operator: "==",
          expected: { kind: "literal", value: U },
          delta: "",
          message: "",
        },
        noEns,
      ),
    ).toEqual({ line: `assert ${T}::!{owner()(address)} == ${U}`, sets: [] });
  });

  it("is ignored inside a live argument too", async () => {
    const outer = (inner: CallNode) =>
      call([hop({ fnName: "balanceOf", argTypes: ["address"], args: [inner] })]);
    expect(
      await buildExprText(outer(call([owner(), unchosen()], U)), noEns),
    ).toEqual({
      line: `${T}::!{balanceOf(address)(uint256) ${U}::!{owner()(address)}}`,
      sets: [],
    });
  });

  it("still leaves a call with no function at all incomplete", async () => {
    expect(await buildExprText(call([unchosen()]), noEns)).toBeNull();
    expect(inferCategory(call([unchosen()]))).toBe("unknown");
  });

  it("still leaves a chain with an unchosen call in the middle incomplete", async () => {
    expect(
      await buildExprText(call([owner(), unchosen(), totalAssets()]), noEns),
    ).toBeNull();
  });
});

describe("live values as call arguments", () => {
  const allPairs = (arg: CallArg) =>
    call([
      hop({
        fnName: "allPairs",
        argTypes: ["uint256"],
        returnTypes: ["address"],
        args: [arg],
      }),
    ]);
  const line = async (arg: CallArg) => (await buildExprText(allPairs(arg), noEns))?.line;

  it("tells plain text from a live value", () => {
    expect(argText("7")).toBe("7");
    expect(argText(undefined)).toBe("");
    // A literal node is its text: what a live value unwraps down to.
    expect(argText({ kind: "literal", value: "7" })).toBe("7");
    expect(argText({ kind: "chainId" })).toBeNull();
    expect(argText(call([owner()]))).toBeNull();

    expect(isCallArgNode("7")).toBe(false);
    expect(isCallArgNode(undefined)).toBe(false);
    expect(isCallArgNode({ kind: "literal", value: "7" })).toBe(false);
    expect(isCallArgNode({ kind: "chainId" })).toBe(true);
    expect(isCallArgNode(call([owner()]))).toBe(true);
  });

  it("renders plain text as it is typed", async () => {
    expect(await line("7")).toBe(`${T}::!{allPairs(uint256)(address) 7}`);
  });

  it("renders a literal node as its text", async () => {
    expect(await line({ kind: "literal", value: "7" })).toBe(
      `${T}::!{allPairs(uint256)(address) 7}`,
    );
  });

  it("renders the chain id as an argument", async () => {
    expect(await line({ kind: "chainId" })).toBe(
      `${T}::!{allPairs(uint256)(address) @chainId!}`,
    );
  });

  it("renders a call as an argument", async () => {
    expect(await line(call([hop({ fnName: "count" })], U))).toBe(
      `${T}::!{allPairs(uint256)(address) ${U}::!{count()(uint256)}}`,
    );
  });

  it("renders a balance as an argument", async () => {
    expect(
      await line({
        kind: "balance",
        token: "ETH",
        account: { kind: "literal", value: "@me" },
      }),
    ).toBe(`${T}::!{allPairs(uint256)(address) @balance!(ETH @me)}`);
  });

  it("wraps arithmetic used as an argument in its helper", async () => {
    expect(
      await line({
        kind: "arith",
        op: "-",
        left: call([hop({ fnName: "count" })], U),
        right: { kind: "literal", value: "1" },
      }),
    ).toBe(
      `${T}::!{allPairs(uint256)(address) @calc!(${U}::!{count()(uint256)} - 1)}`,
    );
  });

  it("leaves the call incomplete while an argument is", async () => {
    expect(await line("")).toBeUndefined();
    expect(await line({ kind: "literal", value: " " })).toBeUndefined();
    expect(await line(call([unchosen()], U))).toBeUndefined();
  });
});

describe("canYield", () => {
  it("is true for a return of the wanted category", () => {
    expect(canYield(["uint256"], "uint")).toBe(true);
    expect(canYield(["uint112"], "uint")).toBe(true);
    expect(canYield(["bool"], "bool")).toBe(true);
    expect(canYield(["string"], "string")).toBe(true);
  });

  it("is false for a return of another category", () => {
    expect(canYield(["string"], "uint")).toBe(false);
    expect(canYield(["uint256"], "bool")).toBe(false);
    expect(canYield(["int256"], "uint")).toBe(false);
    expect(canYield(["bytes32"], "bytes")).toBe(false);
    expect(canYield([], "uint")).toBe(false);
  });

  it("is true for any wanted category when the return is an address: it can be called on", () => {
    for (const wanted of ["uint", "bool", "string", "bytes32", "address"] as const)
      expect(canYield(["address"], wanted)).toBe(true);
  });

  it("looks at every return value", () => {
    expect(canYield(["string", "uint256"], "uint")).toBe(true);
    expect(canYield(["string", "bytes"], "uint")).toBe(false);
    expect(canYield(["string", "address"], "uint")).toBe(true);
  });

  it("reaches into list elements", () => {
    expect(canYield(["uint256[]"], "uint")).toBe(true);
    expect(canYield(["string[]"], "uint")).toBe(false);
    expect(canYield(["address[]"], "uint")).toBe(true);
    expect(canYield(["address[3]"], "bool")).toBe(true);
    expect(canYield(["uint256[][]"], "uint")).toBe(true);
  });

  it("reaches into struct values", () => {
    expect(canYield(["(string,uint256)"], "uint")).toBe(true);
    expect(canYield(["(string,bytes)"], "uint")).toBe(false);
    // A struct containing an address can lead anywhere.
    expect(canYield(["(string,address)"], "bool")).toBe(true);
    expect(canYield(["(string,(bytes,address))[]"], "bool")).toBe(true);
    expect(canYield(["(string,(bytes,int8))[]"], "bool")).toBe(false);
  });
});

describe("producedType and argFits", () => {
  const owner1 = () => call([owner()], U);
  const owners = (lensPath?: string[]) =>
    call([hop({ fnName: "getOwners", returnTypes: ["address[]"], lensPath })], U);
  const pair = (lensIndex?: number) =>
    call([hop({ fnName: "pair", returnTypes: ["address", "uint256"], lensIndex })], U);

  it("names the type a value ends up as", () => {
    expect(producedType({ kind: "chainId" })).toBe("uint256");
    expect(producedType({ kind: "codeHash", address: { kind: "literal", value: T } })).toBe("bytes32");
    expect(producedType({ kind: "literal", value: "true" })).toBe("bool");
    expect(producedType(owner1())).toBe("address");
    expect(producedType(call([hop({ fnName: "f", returnTypes: ["uint112"] })]))).toBe("uint112");
    // What is picked out of the return, not the whole return.
    expect(producedType(owners())).toBe("address[]");
    expect(producedType(owners(["-1"]))).toBe("address");
    expect(producedType(pair(1))).toBe("uint256");
    // A trailing call with no function does not count.
    expect(producedType(call([owner(), unchosen()]))).toBe("address");
  });

  it("names nothing while the value is undecided", () => {
    expect(producedType({ kind: "literal", value: "" })).toBeNull();
    expect(producedType(call([unchosen()]))).toBeNull();
    expect(producedType(pair())).toBeNull();
  });

  it("accepts a value of the argument's category", () => {
    expect(argFits({ kind: "chainId" }, "uint256")).toBe(true);
    expect(argFits({ kind: "chainId" }, "uint64")).toBe(true);
    expect(argFits(owner1(), "address")).toBe(true);
    expect(argFits(owners(["0"]), "address")).toBe(true);
    expect(argFits(pair(1), "uint256")).toBe(true);
  });

  it("refuses a value of another category", () => {
    expect(argFits(owner1(), "uint256")).toBe(false);
    expect(argFits(owners(["0"]), "uint256")).toBe(false);
    expect(argFits({ kind: "chainId" }, "address")).toBe(false);
    expect(argFits(pair(0), "uint256")).toBe(false);
    // A whole list, or several values with none picked, is not one value.
    expect(argFits(owners(), "address")).toBe(false);
    expect(argFits(pair(), "address")).toBe(false);
  });

  it("does not judge a value with no category yet", () => {
    expect(argFits(call([unchosen()]), "uint256")).toBe(true);
    expect(argFits({ kind: "literal", value: "" }, "uint256")).toBe(true);
  });
});

describe("a live argument must fit its parameter", () => {
  const SAFE = T;
  const modules = (pageSize: CallArg) =>
    call(
      [
        hop({
          fnName: "getModulesPaginated",
          argTypes: ["address", "uint256"],
          returnTypes: ["address[]", "address"],
          args: ["@me", pageSize],
          lensIndex: 1,
        }),
      ],
      SAFE,
    );
  /** A call resolving to an address element: `getOwners()[0]`. */
  const anOwner = () =>
    call(
      [hop({ fnName: "getOwners", returnTypes: ["address[]"], lensPath: ["0"] })],
      U,
    );

  it("produces no text when an address fills a uint256 argument", async () => {
    expect(await buildExprText(modules(anOwner()), noEns)).toBeNull();
  });

  it("produces the call when the chain id fills it", async () => {
    expect(await buildExprText(modules({ kind: "chainId" }), noEns)).toEqual({
      line: `${SAFE}::!{getModulesPaginated(address,uint256)(address[],address) @me @chainId!}[_ $]`,
      sets: [],
    });
  });

  it("produces the call when a call of the right type fills it", async () => {
    const count = call([hop({ fnName: "count" })], U);
    expect((await buildExprText(modules(count), noEns))?.line).toBe(
      `${SAFE}::!{getModulesPaginated(address,uint256)(address[],address) @me ${U}::!{count()(uint256)}}[_ $]`,
    );
  });

  it("leaves the whole assertion incomplete on a mismatch", async () => {
    expect(
      await buildAssertionLine(
        {
          subject: modules(anOwner()),
          operator: "==",
          expected: { kind: "literal", value: U },
          delta: "",
          message: "",
        },
        noEns,
      ),
    ).toBeNull();
  });

  it("refuses a mismatch nested inside another argument", async () => {
    const outer = call([
      hop({ fnName: "balanceOf", argTypes: ["address"], args: [modules(anOwner())] }),
    ]);
    expect(await buildExprText(outer, noEns)).toBeNull();
  });
});

describe("callTail", () => {
  const A = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48";
  it("is empty until a function is chosen", () => {
    expect(callTail(call([unchosen()]))).toBe("");
    expect(callTail(call([]))).toBe("");
  });

  it("writes a call with no arguments", () => {
    expect(callTail(call([hop({ fnName: "factory", returnTypes: ["address"] })]))).toBe(
      ".factory()",
    );
  });

  it("writes plain arguments as their text, an empty one as '…'", () => {
    expect(
      callTail(
        call([
          hop({
            fnName: "getPair",
            argTypes: ["address", "address"],
            returnTypes: ["address"],
            args: [` ${A} `, ""],
          }),
        ]),
      ),
    ).toBe(`.getPair(${A}, …)`);
  });

  it("writes a live argument by its summary", () => {
    const arg = (a: CallArg) =>
      callTail(call([hop({ fnName: "allPairs", argTypes: ["uint256"], args: [a] })]));
    expect(arg({ kind: "chainId" })).toBe(".allPairs(@chainId!)");
    expect(arg(call([hop({ fnName: "count" })], U))).toBe(
      ".allPairs(0xabcd…0001.count())",
    );
    expect(arg({ kind: "literal", value: "7" })).toBe(".allPairs(7)");
  });

  it("writes what is picked out of the return", () => {
    expect(
      callTail(
        call([hop({ fnName: "getOwners", returnTypes: ["address[]"], lensPath: ["-1"] })]),
      ),
    ).toBe(".getOwners()[-1]");
  });

  it("writes every chained call, leaving out a trailing one with no function", () => {
    const factory = hop({ fnName: "factory", returnTypes: ["address"] });
    const setter = hop({ fnName: "feeToSetter", returnTypes: ["address"] });
    expect(callTail(call([factory, setter]))).toBe(".factory().feeToSetter()");
    expect(callTail(call([factory, setter, unchosen()]))).toBe(
      ".factory().feeToSetter()",
    );
  });
});
