// @vitest-environment jsdom
import { cleanup, render, screen, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { useState } from "react";
import { beforeEach, describe, expect, it, vi } from "vitest";

import type { CallHop, CallNode } from "../assertion-model";
import {
  CallAddressContext,
  type CallAddressResolver,
  CallEditor,
  callSummary,
  lensText,
} from "../expr/CallEditor";
import { clearContracts, registerContract } from "./helpers/fake-contracts";

vi.mock("../useContractFunctions", async (importOriginal) =>
  (await import("./helpers/fake-contracts")).fakeContractFunctionsModule(
    await importOriginal(),
  ),
);

const T = "0x1234567890123456789012345678901234567890";
const U = "0xabcdefabcdefabcdefabcdefabcdefabcdef0001";
const UNVERIFIED = "0x00000000000000000000000000000000000000bb";

const REGISTRY_ABI = [
  "function balanceOf(address account) view returns (uint256)",
  "function getOwners() view returns (address[])",
  "function getReserves() view returns (uint112, uint112, uint32)",
  "function info() view returns ((address owner, uint256 amount))",
  "function name() view returns (string)",
  "function owner() view returns (address)",
  "function ownerOf(uint256 id) view returns (address)",
  "function pair() view returns (address token, uint256 amount)",
  "function transfer(address to, uint256 amount) returns (bool)",
];
const VAULT_ABI = [
  "function asset() view returns (address)",
  "function totalAssets() view returns (uint256)",
];

const hop = (partial: Partial<CallHop> & { fnName: string }): CallHop => ({
  inline: false,
  argTypes: [],
  returnTypes: ["uint256"],
  args: [],
  ...partial,
});
const emptyHop = (): CallHop => hop({ fnName: "", returnTypes: [] });
const call = (target: string, hops: CallHop[] = [emptyHop()]): CallNode => ({
  kind: "call",
  target,
  resolved: null,
  hops,
});
const OWNER = () => hop({ fnName: "owner", returnTypes: ["address"] });

const PLACEHOLDER = "Select a view function…";
const ADD_CALL = "+ call on the result";

function Harness({
  initial,
  onNode,
  onOpenArg,
  resolver = null,
  ...props
}: {
  initial: CallNode;
  onNode: (node: CallNode) => void;
  onOpenArg?: (hop: number, arg: number) => void;
  resolver?: CallAddressResolver | null;
} & Partial<React.ComponentProps<typeof CallEditor>>) {
  const [node, setNode] = useState(initial);
  onNode(node);
  return (
    <CallAddressContext.Provider value={resolver}>
      <CallEditor
        node={node}
        onChange={(updater) => setNode(updater)}
        chainId={1}
        onOpenArg={onOpenArg}
        {...props}
      />
    </CallAddressContext.Provider>
  );
}

function setup(
  initial: CallNode,
  options: Omit<React.ComponentProps<typeof Harness>, "initial" | "onNode"> = {},
) {
  const onNode = vi.fn();
  const user = userEvent.setup();
  render(<Harness initial={initial} onNode={onNode} {...options} />);
  return { user, node: () => onNode.mock.lastCall?.[0] as CallNode };
}

const optionLabels = () =>
  screen.queryAllByRole("option").map((o) => o.textContent);
const pressed = (name: string | RegExp) =>
  screen.getByRole("button", { name }).getAttribute("aria-pressed");

beforeEach(() => {
  clearContracts();
  registerContract(T, { name: "Registry", abi: REGISTRY_ABI });
  registerContract(U, { name: "Vault", abi: VAULT_ABI });
  registerContract(UNVERIFIED, { name: null, abi: [] });
});

describe("lensText and callSummary", () => {
  it("writes nothing when the whole return is used", () => {
    expect(lensText(hop({ fnName: "totalSupply" }))).toBe("");
    expect(lensText(hop({ fnName: "getOwners", returnTypes: ["address[]"] }))).toBe("");
  });

  it("writes the picked indices after the call", () => {
    const owners = (lensPath: string[]) =>
      hop({ fnName: "getOwners", returnTypes: ["address[]"], lensPath });
    expect(lensText(owners(["-1"]))).toBe("[-1]");
    expect(lensText(owners(["0"]))).toBe("[0]");
    expect(lensText(owners([" 7 "]))).toBe("[7]");
    // An index not typed yet is not written.
    expect(lensText(owners([""]))).toBe("");
  });

  it("writes which return value is picked, then what is picked inside it", () => {
    const reserves = hop({
      fnName: "positions",
      returnTypes: ["uint256", "(address,uint256)[]"],
      lensIndex: 1,
      lensPath: ["3", "0"],
    });
    expect(lensText(reserves)).toBe("[1][3][0]");
    // A single return value has no index of its own.
    expect(lensText(hop({ fnName: "f", returnTypes: ["uint256"], lensIndex: 0 }))).toBe("");
  });

  it("summarises a call as its contract, its functions and what is picked", () => {
    expect(callSummary(call("", []))).toBe("empty call");
    expect(callSummary(call(T))).toBe("0x1234…7890");
    expect(callSummary(call("mydao.eth", [OWNER()]))).toBe("mydao.eth.owner()");
    expect(
      callSummary(
        call(T, [hop({ fnName: "getOwners", returnTypes: ["address[]"], lensPath: ["-1"] })]),
      ),
    ).toBe("0x1234…7890.getOwners()[-1]");
    expect(
      callSummary(
        call(T, [
          hop({ fnName: "pair", returnTypes: ["address", "uint256"], lensIndex: 0 }),
          hop({ fnName: "totalAssets" }),
          emptyHop(),
        ]),
      ),
    ).toBe("0x1234…7890.pair()[0].totalAssets()");
  });
});

describe("CallEditor: the contract", () => {
  it("has an address field unless the address is typed elsewhere", () => {
    setup(call(T));
    expect(
      (screen.getByRole("textbox", {
        name: "Contract address or ENS name",
      }) as HTMLInputElement).value,
    ).toBe(T);
  });

  it("leaves the address field out when asked", () => {
    setup(call(T), { hideTarget: true });
    expect(
      screen.queryByRole("textbox", { name: "Contract address or ENS name" }),
    ).toBeNull();
    expect(screen.getByText("Verified: Registry")).toBeTruthy();
  });

  it("drops the function when the address changes", async () => {
    const { user, node } = setup(call(T, [OWNER()]));
    await user.type(
      screen.getByRole("textbox", { name: "Contract address or ENS name" }),
      "0",
    );
    expect(node().target).toBe(`${T}0`);
    expect(node().hops).toEqual([emptyHop()]);
  });

  it("records the address the contract resolved to on the call", () => {
    const { node } = setup(call(T));
    expect(node().resolved).toBe(T);
  });

  it("asks for a typed signature when the contract is not verified", async () => {
    const { user, node } = setup(call(UNVERIFIED));
    expect(screen.queryByRole("button", { name: PLACEHOLDER })).toBeNull();
    await user.type(screen.getByPlaceholderText("balanceOf(address)"), "decimals()");
    await user.type(screen.getByPlaceholderText("uint256"), "uint8");
    expect(node().hops[0]).toEqual({
      fnName: "decimals",
      inline: true,
      argTypes: [],
      returnTypes: ["uint8"],
      args: [],
    });
  });
});

describe("CallEditor: the function selector", () => {
  it("lists the contract's view functions with what they return", async () => {
    const { user } = setup(call(T));
    await user.click(screen.getByRole("button", { name: PLACEHOLDER }));
    expect(optionLabels()).toEqual([
      "balanceOf(address) → uint256",
      "getOwners() → address[]",
      "getReserves() → (uint112,uint112,uint32)",
      "info() → (address,uint256)",
      "name() → string",
      "owner() → address",
      "ownerOf(uint256) → address",
      "pair() → (address,uint256)",
      "Custom signature (not in the ABI)…",
    ]);
  });

  it("is a combobox: typing filters, Enter picks, the focus returns to the trigger", async () => {
    const { user, node } = setup(call(T));
    const trigger = screen.getByRole("button", { name: PLACEHOLDER });
    await user.click(trigger);
    expect(document.activeElement).toBe(screen.getByRole("combobox"));

    await user.keyboard("own");
    expect(optionLabels()).toEqual([
      "getOwners() → address[]",
      "owner() → address",
      "ownerOf(uint256) → address",
    ]);
    await user.keyboard("er(");
    expect(optionLabels()).toEqual(["owner() → address"]);

    await user.keyboard("{Enter}");
    expect(node().hops).toEqual([
      { fnName: "owner", inline: false, argTypes: [], returnTypes: ["address"], args: [] },
    ]);
    expect(screen.queryByRole("listbox")).toBeNull();
    expect(document.activeElement).toBe(trigger);
    expect(trigger.textContent).toBe("owner() → address");
  });

  it("picks with the mouse too, giving each argument an empty field", async () => {
    const { user, node } = setup(call(T));
    await user.click(screen.getByRole("button", { name: PLACEHOLDER }));
    await user.click(screen.getByRole("option", { name: "balanceOf(address) → uint256" }));
    expect(node().hops[0]).toEqual({
      fnName: "balanceOf",
      inline: false,
      argTypes: ["address"],
      returnTypes: ["uint256"],
      args: [""],
    });
    expect(screen.getByText("account")).toBeTruthy();
    await user.type(screen.getByRole("textbox", { name: "" }), "@me");
    expect(node().hops[0].args).toEqual(["@me"]);
  });

  it("switches to a typed signature on 'Custom signature'", async () => {
    const { user, node } = setup(call(T, [OWNER()]));
    await user.click(screen.getByRole("button", { name: "owner() → address" }));
    await user.click(
      screen.getByRole("option", { name: "Custom signature (not in the ABI)…" }),
    );
    expect(node().hops).toEqual([emptyHop()]);
    await user.type(screen.getByPlaceholderText("balanceOf(address)"), "cap()");
    await user.type(screen.getByPlaceholderText("uint256"), "uint256");
    expect(node().hops[0]).toMatchObject({ fnName: "cap", inline: true });
  });
});

describe("CallEditor: arguments", () => {
  const balanceOf = (arg: CallHop["args"][number] = "") =>
    call(T, [hop({ fnName: "balanceOf", argTypes: ["address"], args: [arg] })]);
  const ARG_MENU = "Change what this argument is";

  it("are plain text only without a tray to edit live values in", () => {
    setup(balanceOf());
    expect(screen.queryByRole("button", { name: ARG_MENU })).toBeNull();
  });

  it("are plain text only when live values are turned off", () => {
    setup(balanceOf(), { onOpenArg: vi.fn(), allowCallArgs: false });
    expect(screen.queryByRole("button", { name: ARG_MENU })).toBeNull();
  });

  it("become a live value from the argument's menu, which is then opened", async () => {
    const onOpenArg = vi.fn();
    const { user, node } = setup(balanceOf("@me"), { onOpenArg });
    await user.click(screen.getByRole("button", { name: ARG_MENU }));
    await user.click(screen.getByRole("option", { name: "contract call" }));
    expect(node().hops[0].args[0]).toMatchObject({ kind: "call", target: "" });
    expect(onOpenArg).toHaveBeenCalledExactlyOnceWith(0, 0);
    // The argument is now a pill, and its menu is still on its field.
    const pill = screen.getByTitle("Edit this value");
    expect(pill.textContent).toBe("empty call");
    expect(
      (pill.parentElement as HTMLElement).contains(
        screen.getByRole("button", { name: ARG_MENU }),
      ),
    ).toBe(true);
  });

  it("open their live value again from the pill", async () => {
    const onOpenArg = vi.fn();
    const { user } = setup(balanceOf(call(U, [OWNER()])), { onOpenArg });
    const pill = screen.getByTitle("Edit this value");
    expect(pill.textContent).toBe("0xabcd…0001.owner()");
    await user.click(pill);
    expect(onOpenArg).toHaveBeenCalledExactlyOnceWith(0, 0);
  });

  it("go back to plain text without opening anything", async () => {
    const onOpenArg = vi.fn();
    const { user, node } = setup(balanceOf({ kind: "chainId" }), { onOpenArg });
    await user.click(screen.getByRole("button", { name: ARG_MENU }));
    await user.click(screen.getByRole("option", { name: "value" }));
    expect(node().hops[0].args[0]).toBe("");
    expect(onOpenArg).not.toHaveBeenCalled();
  });

  it("explain @me on an address argument typed as text", () => {
    setup(balanceOf(), { onOpenArg: vi.fn() });
    expect(screen.getByText("(@me = the executor)")).toBeTruthy();
  });
});

describe("CallEditor: arguments that must be of a type", () => {
  const ARG_MENU = "Change what this argument is";
  const withArg = (type: string, arg: CallHop["args"][number]) =>
    call(T, [hop({ fnName: "f", inline: true, argTypes: [type], args: [arg] })]);
  const offered = async (type: string) => {
    const { user } = setup(withArg(type, ""), { onOpenArg: vi.fn() });
    await user.click(screen.getByRole("button", { name: ARG_MENU }));
    const labels = optionLabels();
    cleanup();
    return labels;
  };

  it("offers only the kinds that can produce the argument's type", async () => {
    const ALWAYS = ["value", "contract call"];
    const NUMBER = [
      "balance",
      "timestamp",
      "block number",
      "chain id",
    ];
    expect(await offered("address")).toEqual(ALWAYS);
    expect(await offered("uint256")).toEqual([...ALWAYS, ...NUMBER]);
    expect(await offered("bool")).toEqual(ALWAYS);
    expect(await offered("string")).toEqual(ALWAYS);
    expect(await offered("bytes32")).toEqual([...ALWAYS, "code hash"]);
    expect(await offered("bytes")).toEqual([...ALWAYS, "deployed code"]);
  });

  it("says so under an argument whose live value is of another type", () => {
    setup(withArg("uint256", call(U, [OWNER()])), { onOpenArg: vi.fn() });
    expect(screen.getByRole("alert").textContent).toBe(
      "This argument takes uint256, but the value is address. Call a function on that address that returns it, or pick another value.",
    );
  });

  it("words the alert by what the value is", () => {
    const alert = (type: string, arg: CallHop["args"][number]) => {
      setup(withArg(type, arg), { onOpenArg: vi.fn() });
      const text = screen.queryByRole("alert")?.textContent ?? null;
      cleanup();
      return text;
    };
    expect(alert("address", call(U, [hop({ fnName: "totalAssets" })]))).toBe(
      "This argument takes address, but the value is uint256. Pick the part of the result that is, or another function.",
    );
    expect(alert("address", { kind: "chainId" })).toBe(
      "This argument takes address, but the value is uint256. Pick another value.",
    );
    expect(
      alert("uint256", call(U, [hop({ fnName: "pair", returnTypes: ["address", "uint256"] })])),
    ).toBe(
      "This argument takes uint256, but the value is not one yet. Pick the part of the result that is, or another function.",
    );
  });

  it("says nothing when the value fits, is plain text, or is still being filled in", () => {
    for (const arg of [
      { kind: "chainId" } as const,
      call(U, [hop({ fnName: "totalAssets" })]),
      "12",
      call(U),
    ]) {
      setup(withArg("uint256", arg), { onOpenArg: vi.fn() });
      expect(screen.queryByRole("alert")).toBeNull();
      cleanup();
    }
  });
});

describe("CallEditor: a call that must produce a type", () => {
  const disabledOptions = () =>
    screen
      .getAllByRole("option")
      .filter((o) => o.getAttribute("aria-disabled") === "true")
      .map((o) => o.textContent);

  it("greys out the functions that cannot lead to it, keeping those that return an address", async () => {
    const { user } = setup(call(T), { wants: "uint256" });
    await user.click(screen.getByRole("button", { name: PLACEHOLDER }));
    expect(disabledOptions()).toEqual(["name() → string"]);
    expect(
      screen.getByRole("option", { name: "name() → string" }).getAttribute("title"),
    ).toBe("Does not return uint256, nor an address to call on");
    // An address can be called on to get the type: these stay.
    for (const name of [
      "owner() → address",
      "getOwners() → address[]",
      "info() → (address,uint256)",
    ])
      expect(
        screen.getByRole("option", { name }).getAttribute("aria-disabled"),
      ).toBeNull();
  });

  it("judges each return by the type wanted", async () => {
    const { user } = setup(call(T), { wants: "bool" });
    await user.click(screen.getByRole("button", { name: PLACEHOLDER }));
    expect(disabledOptions()).toEqual([
      "balanceOf(address) → uint256",
      "getReserves() → (uint112,uint112,uint32)",
      "name() → string",
    ]);
  });

  it("does not pick a greyed out function", async () => {
    const { user, node } = setup(call(T), { wants: "uint256" });
    await user.click(screen.getByRole("button", { name: PLACEHOLDER }));
    await user.click(screen.getByRole("option", { name: "name() → string" }));
    expect(node().hops[0].fnName).toBe("");
    expect(screen.getByRole("listbox")).toBeTruthy();
  });

  it("greys nothing out when no type is asked for", async () => {
    const { user } = setup(call(T));
    await user.click(screen.getByRole("button", { name: PLACEHOLDER }));
    expect(disabledOptions()).toEqual([]);
  });

  it("applies to a chained call's functions too", async () => {
    registerContract(U, {
      name: "Vault",
      abi: [...VAULT_ABI, "function name() view returns (string)"],
    });
    const resolver: CallAddressResolver = async () => ({ address: U });
    const { user } = setup(call(T, [OWNER(), emptyHop()]), {
      resolver,
      wants: "uint256",
    });
    await user.click(await screen.findByRole("button", { name: PLACEHOLDER }));
    expect(disabledOptions()).toEqual(["name() → string"]);
  });

  it("greys out the parts of a return that cannot lead to it, keeping addresses", () => {
    setup(
      call(T, [hop({ fnName: "pair", returnTypes: ["address", "uint256", "string"] })]),
      { wants: "bool" },
    );
    const part = (name: string) =>
      screen.getByRole("button", { name }) as HTMLButtonElement;
    expect(part("[0] address").disabled).toBe(false);
    expect(part("[1] uint256").disabled).toBe(true);
    expect(part("[2] string").disabled).toBe(true);
    expect(part("[1] uint256").getAttribute("title")).toBe(
      "Cannot become the type needed here",
    );
  });
});

describe("CallEditor: the chain strip", () => {
  it("is not shown for a call that does not return an address", () => {
    setup(call(T, [hop({ fnName: "name", returnTypes: ["string"] })]));
    expect(screen.queryByText("Chain")).toBeNull();
    expect(screen.queryByRole("button", { name: ADD_CALL })).toBeNull();
  });

  it("is not shown when chains are turned off", () => {
    setup(call(T, [OWNER()]), { allowChain: false });
    expect(screen.queryByRole("button", { name: ADD_CALL })).toBeNull();
  });

  it("adds a call on the result and edits it", async () => {
    const { user, node } = setup(call(T, [OWNER()]));
    expect(pressed("owner()")).toBe("true");
    await user.click(screen.getByRole("button", { name: ADD_CALL }));

    expect(node().hops).toEqual([OWNER(), emptyHop()]);
    expect(pressed("owner()")).toBe("false");
    expect(pressed("function…")).toBe("true");
    expect(screen.getByText("the address owner() returns")).toBeTruthy();
    // The first call's selector gives way to the chained call's editor.
    expect(screen.queryByRole("button", { name: "owner() → address" })).toBeNull();
    // No further call until this one has a function.
    expect(screen.queryByRole("button", { name: ADD_CALL })).toBeNull();
  });

  it("switches the edited call from its pills", async () => {
    const { user } = setup(call(T, [OWNER(), emptyHop()]));
    expect(pressed("function…")).toBe("true");
    await user.click(screen.getByRole("button", { name: "owner()" }));
    expect(pressed("owner()")).toBe("true");
    expect(pressed("function…")).toBe("false");
    expect(screen.getByRole("button", { name: "owner() → address" })).toBeTruthy();
    expect(screen.queryByText("the address owner() returns")).toBeNull();

    await user.click(screen.getByRole("button", { name: "function…" }));
    expect(pressed("function…")).toBe("true");
    expect(screen.getByText("the address owner() returns")).toBeTruthy();
  });

  it("removes the last call, going back to the one before", async () => {
    const { user, node } = setup(call(T, [OWNER(), emptyHop()]));
    await user.click(screen.getByRole("button", { name: "remove this call" }));
    expect(node().hops).toEqual([OWNER()]);
    expect(pressed("owner()")).toBe("true");
    expect(screen.queryByRole("button", { name: "function…" })).toBeNull();
    expect(screen.getByRole("button", { name: ADD_CALL })).toBeTruthy();
  });

  it("only removes from the end of the chain", async () => {
    const asset = hop({ fnName: "asset", inline: true, returnTypes: ["address"] });
    const { user } = setup(call(T, [OWNER(), asset, emptyHop()]));
    expect(screen.getByRole("button", { name: "remove this call" })).toBeTruthy();
    await user.click(screen.getByRole("button", { name: "asset()" }));
    expect(screen.queryByRole("button", { name: "remove this call" })).toBeNull();
  });

  it("anchors the chain to the first address among several return values", async () => {
    const pair = hop({ fnName: "pair", returnTypes: ["address", "uint256"] });
    const { user, node } = setup(call(T, [pair]));
    await user.click(screen.getByRole("button", { name: ADD_CALL }));
    expect(node().hops[0].lensIndex).toBe(0);
    expect(screen.getByRole("button", { name: "pair()[0]" })).toBeTruthy();
    expect(
      screen.getByRole("button", { name: "return value #1 (address)" }),
    ).toBeTruthy();
  });

  it("does not chain on a picked value that is not an address", () => {
    const pair = hop({ fnName: "pair", returnTypes: ["address", "uint256"], lensIndex: 1 });
    setup(call(T, [pair]));
    expect(screen.queryByRole("button", { name: ADD_CALL })).toBeNull();
  });

  it("chains on an address picked out of a list", () => {
    setup(
      call(T, [hop({ fnName: "getOwners", returnTypes: ["address[]"], lensPath: ["0"] })]),
    );
    expect(screen.getByRole("button", { name: ADD_CALL })).toBeTruthy();
  });
});

describe("CallEditor: a chained call", () => {
  const chained = () => call(T, [OWNER(), emptyHop()]);

  it("lists the functions of the contract the resolver finds", async () => {
    const resolver = vi.fn<CallAddressResolver>(async () => ({ address: U }));
    const { user, node } = setup(chained(), { resolver });
    expect(
      screen.getByText("Simulating the batch to find that address…"),
    ).toBeTruthy();

    expect(await screen.findByText("Verified: Vault")).toBeTruthy();
    expect(screen.getByText(`· ${U}`, { exact: false })).toBeTruthy();
    // The resolver is asked about the chain up to the previous call.
    expect(resolver).toHaveBeenCalledExactlyOnceWith(
      expect.objectContaining({ target: T, hops: [OWNER()] }),
    );

    await user.click(screen.getByRole("button", { name: PLACEHOLDER }));
    expect(optionLabels()).toEqual([
      "asset() → address",
      "totalAssets() → uint256",
      "Custom signature (not in the ABI)…",
    ]);
    await user.click(screen.getByRole("option", { name: "totalAssets() → uint256" }));
    expect(node().hops[1]).toEqual({
      fnName: "totalAssets",
      inline: false,
      argTypes: [],
      returnTypes: ["uint256"],
      args: [],
    });
    expect(screen.getByRole("button", { name: "totalAssets()" })).toBeTruthy();
    // No signature fields: the function came from the list.
    expect(screen.queryByPlaceholderText("balanceOf(address)")).toBeNull();
  });

  it("falls back to typed signature fields when the resolver fails", async () => {
    const resolver: CallAddressResolver = async () => ({ error: "it reverted" });
    const { user, node } = setup(chained(), { resolver });
    expect(
      await screen.findByText(
        "Could not read that address from a simulation (it reverted). Type the function to call.",
      ),
    ).toBeTruthy();
    expect(screen.queryByRole("button", { name: PLACEHOLDER })).toBeNull();

    await user.type(screen.getByPlaceholderText("balanceOf(address)"), "totalAssets()");
    await user.type(screen.getByPlaceholderText("uint256"), "uint256");
    expect(node().hops[1]).toEqual({
      fnName: "totalAssets",
      inline: true,
      argTypes: [],
      returnTypes: ["uint256"],
      args: [],
    });
  });

  it("falls back the same way when the resolver throws", async () => {
    const resolver: CallAddressResolver = async () => {
      throw new Error("no fork");
    };
    setup(chained(), { resolver });
    expect(
      await screen.findByText(/Could not read that address from a simulation \(no fork\)/),
    ).toBeTruthy();
    expect(screen.getByPlaceholderText("balanceOf(address)")).toBeTruthy();
  });

  it("asks for a typed signature at once when there is no resolver", () => {
    setup(chained());
    expect(screen.queryByText(/Simulating the batch/)).toBeNull();
    expect(screen.getByPlaceholderText("balanceOf(address)")).toBeTruthy();
    expect(screen.getByPlaceholderText("uint256")).toBeTruthy();
  });

  it("asks for a typed signature when the contract found is not verified", async () => {
    const resolver: CallAddressResolver = async () => ({ address: UNVERIFIED });
    setup(chained(), { resolver });
    expect(await screen.findByPlaceholderText("balanceOf(address)")).toBeTruthy();
    expect(screen.queryByRole("button", { name: PLACEHOLDER })).toBeNull();
  });

  it("gives a typed call's arguments their fields", async () => {
    const { user, node } = setup(chained());
    await user.type(
      screen.getByPlaceholderText("balanceOf(address)"),
      "balanceOf(address who)",
    );
    await user.type(screen.getByPlaceholderText("uint256"), "uint256");
    expect(node().hops[1]).toMatchObject({
      fnName: "balanceOf",
      argTypes: ["address"],
      args: [""],
    });
    // The hop keeps types only, so the field is named by its position.
    expect(screen.getByText("arg0")).toBeTruthy();
  });
});

describe("CallEditor: which part to use", () => {
  const withFn = (partial: Partial<CallHop> & { fnName: string }) =>
    call(T, [hop(partial)]);

  it("is not asked for a call that returns one plain value", () => {
    setup(withFn({ fnName: "owner", returnTypes: ["address"] }));
    expect(screen.queryByText("Which part to use.")).toBeNull();
  });

  it("offers the first, the last or any index of a list", async () => {
    const { user, node } = setup(
      withFn({ fnName: "getOwners", returnTypes: ["address[]"] }),
    );
    expect(screen.getByText("Which part to use.")).toBeTruthy();
    expect(screen.getByText("Element of address[]")).toBeTruthy();
    expect(pressed("[0] first")).toBe("false");
    expect(pressed("[-1] last")).toBe("false");
    expect(screen.getByText("pick one")).toBeTruthy();

    await user.click(screen.getByRole("button", { name: "[-1] last" }));
    expect(node().hops[0].lensPath).toEqual(["-1"]);
    expect(pressed("[-1] last")).toBe("true");
    expect(pressed("[0] first")).toBe("false");
    expect(screen.queryByText("pick one")).toBeNull();
    expect(screen.getByText(/^uses/).textContent).toBe("uses getOwners()[-1] → address");

    await user.click(screen.getByRole("button", { name: "[0] first" }));
    expect(node().hops[0].lensPath).toEqual(["0"]);
    expect(pressed("[0] first")).toBe("true");
    expect(pressed("[-1] last")).toBe("false");
  });

  it("takes any other index from the index field", async () => {
    const { user, node } = setup(
      withFn({ fnName: "getOwners", returnTypes: ["address[]"] }),
    );
    const index = screen.getByRole("textbox", { name: "index" }) as HTMLInputElement;
    await user.type(index, "12");
    expect(node().hops[0].lensPath).toEqual(["12"]);
    expect(index.value).toBe("12");
    expect(pressed("[0] first")).toBe("false");
    expect(pressed("[-1] last")).toBe("false");
    expect(screen.getByText(/^uses/).textContent).toBe("uses getOwners()[12] → address");

    await user.clear(index);
    expect(node().hops[0].lensPath).toBeUndefined();
    expect(screen.getByText("pick one")).toBeTruthy();
  });

  it("counts negative indices from the end", async () => {
    const { user, node } = setup(
      withFn({ fnName: "getOwners", returnTypes: ["address[]"] }),
    );
    await user.type(screen.getByRole("textbox", { name: "index" }), "-2");
    expect(node().hops[0].lensPath).toEqual(["-2"]);
    expect(screen.getByText(/^uses/).textContent).toBe("uses getOwners()[-2] → address");
  });

  // KNOWN BUG, reported and not fixed here (tests only): the index field
  // empties itself whenever what is typed so far reads "0" or "-1" (those
  // two light up their buttons instead), so the next digit starts over.
  // The field once emptied itself whenever the text so far read 0 or -1,
  // so typing -12 picked index 2 and -10 picked 0.
  it("takes an index that starts like -1 or 0, such as -12", async () => {
    const { user, node } = setup(
      withFn({ fnName: "getOwners", returnTypes: ["address[]"] }),
    );
    await user.type(screen.getByRole("textbox", { name: "index" }), "-12");
    expect(node().hops[0].lensPath).toEqual(["-12"]);
  });

  it("has one button per return value", async () => {
    const { user, node } = setup(
      withFn({ fnName: "getReserves", returnTypes: ["uint112", "uint112", "uint32"] }),
    );
    expect(screen.getByText("Return value")).toBeTruthy();
    const picker = screen.getByText("Return value").parentElement as HTMLElement;
    expect(within(picker).getAllByRole("button").map((b) => b.textContent)).toEqual([
      "[0] uint112",
      "[1] uint112",
      "[2] uint32",
    ]);
    expect(within(picker).getByText("pick one")).toBeTruthy();

    await user.click(screen.getByRole("button", { name: "[2] uint32" }));
    expect(node().hops[0].lensIndex).toBe(2);
    expect(pressed("[2] uint32")).toBe("true");
    expect(pressed("[0] uint112")).toBe("false");
    expect(screen.getByText(/^uses/).textContent).toBe("uses getReserves()[2] → uint32");
  });

  it("has one button per value of a struct", async () => {
    const { user, node } = setup(
      withFn({ fnName: "info", returnTypes: ["(address,uint256)"] }),
    );
    const picker = screen.getByText("Value of the struct").parentElement as HTMLElement;
    expect(within(picker).getAllByRole("button").map((b) => b.textContent)).toEqual([
      "[0] address",
      "[1] uint256",
    ]);
    await user.click(screen.getByRole("button", { name: "[1] uint256" }));
    expect(node().hops[0].lensPath).toEqual(["1"]);
    expect(screen.getByText(/^uses/).textContent).toBe("uses info()[1] → uint256");
  });

  it("picks level by level: a return value, then inside it", async () => {
    const { user, node } = setup(
      withFn({ fnName: "positions", returnTypes: ["uint256", "(address,uint256)[]"] }),
    );
    expect(screen.queryByText(/^Element of/)).toBeNull();
    await user.click(screen.getByRole("button", { name: "[1] (address,uint256)[]" }));
    expect(screen.getByText("Element of (address,uint256)[]")).toBeTruthy();
    expect(screen.queryByText("Value of the struct")).toBeNull();

    await user.click(screen.getByRole("button", { name: "[-1] last" }));
    await user.click(screen.getByRole("button", { name: "[0] address" }));
    expect(node().hops[0]).toMatchObject({ lensIndex: 1, lensPath: ["-1", "0"] });
    expect(screen.getByText(/^uses/).textContent).toBe(
      "uses positions()[1][-1][0] → address",
    );
  });

  it("forgets what was picked inside when another return value is picked", async () => {
    const { user, node } = setup(
      withFn({
        fnName: "positions",
        returnTypes: ["uint256", "(address,uint256)[]"],
        lensIndex: 1,
        lensPath: ["-1", "0"],
      }),
    );
    await user.click(screen.getByRole("button", { name: "[0] uint256" }));
    expect(node().hops[0].lensIndex).toBe(0);
    expect(node().hops[0].lensPath).toBeUndefined();
  });

  it("offers a button per element of a fixed-length list", async () => {
    const { user, node } = setup(
      withFn({ fnName: "coins", returnTypes: ["address[3]"] }),
    );
    const picker = screen.getByText("Element of address[3]").parentElement as HTMLElement;
    expect(within(picker).getAllByRole("button").map((b) => b.textContent)).toEqual([
      "[0] address",
      "[1] address",
      "[2] address",
    ]);
    await user.click(screen.getByRole("button", { name: "[2] address" }));
    expect(node().hops[0].lensPath).toEqual(["2"]);
  });
});
