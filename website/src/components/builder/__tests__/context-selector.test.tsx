// @vitest-environment jsdom
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { useState } from "react";
import { beforeEach, describe, expect, it, vi } from "vitest";

import type { ExecutionContext } from "../context";
import { ContextSelector } from "../ContextSelector";
import type { ChainSupport } from "../useChainSupport";
import type { AddressCheck } from "../useContextAddressCheck";
import { resetWallet, wallet } from "./helpers/fake-wagmi";

vi.mock("wagmi", async (importOriginal) =>
  (await import("./helpers/fake-wagmi")).fakeWagmiModule(await importOriginal()),
);

const ACCOUNT = "0x1234567890123456789012345678901234567890";
const LINK = "simulate as another account";
const FIELD = "Account to simulate as";

function Harness({
  initial,
  onContext,
  onChainChange,
  chainId = 1,
  chainSupport = { state: "official" } as ChainSupport,
  check = { state: "idle" } as AddressCheck,
  resolved = null,
}: {
  initial: ExecutionContext;
  onContext: (context: ExecutionContext) => void;
  onChainChange: (chainId: number) => void;
  chainId?: number;
  chainSupport?: ChainSupport;
  check?: AddressCheck;
  resolved?: `0x${string}` | null;
}) {
  const [context, setContext] = useState(initial);
  const [chain, setChain] = useState(chainId);
  onContext(context);
  return (
    <div>
      <ContextSelector
        context={context}
        onChange={setContext}
        resolved={resolved}
        check={check}
        chainId={chain}
        onChainChange={(id) => {
          setChain(id);
          onChainChange(id);
        }}
        chainSupport={chainSupport}
      />
      <button type="button">elsewhere</button>
    </div>
  );
}

function setup(
  initial: ExecutionContext = { kind: "eoa" },
  props: Partial<React.ComponentProps<typeof Harness>> = {},
) {
  const onContext = vi.fn();
  const onChainChange = vi.fn();
  const user = userEvent.setup();
  render(
    <Harness
      initial={initial}
      onContext={onContext}
      onChainChange={onChainChange}
      {...props}
    />,
  );
  return {
    user,
    onChainChange,
    context: () => onContext.mock.lastCall?.[0] as ExecutionContext,
  };
}

beforeEach(() => resetWallet());

describe("ContextSelector: simulating as another account", () => {
  it("keeps the account field behind a link for a wallet", () => {
    setup();
    expect(screen.getByRole("button", { name: LINK })).toBeTruthy();
    expect(screen.queryByRole("textbox", { name: FIELD })).toBeNull();
    expect(screen.getByRole("button", { name: "Connect wallet" })).toBeTruthy();
    expect(
      screen.getByText(/Simulations run as the connected wallet, or as another account/),
    ).toBeTruthy();
  });

  it("reveals the field from the link, with the cursor in it", async () => {
    const { user } = setup();
    await user.click(screen.getByRole("button", { name: LINK }));
    const field = screen.getByRole("textbox", { name: FIELD });
    expect(document.activeElement).toBe(field);
    expect(field.getAttribute("placeholder")).toBe("Simulate as 0x… or name.eth");
    expect(screen.queryByRole("button", { name: LINK })).toBeNull();
  });

  it("folds the field back into the link when it is left empty", async () => {
    const { user } = setup();
    await user.click(screen.getByRole("button", { name: LINK }));
    await user.click(screen.getByRole("button", { name: "elsewhere" }));
    expect(screen.queryByRole("textbox", { name: FIELD })).toBeNull();
    expect(screen.getByRole("button", { name: LINK })).toBeTruthy();
  });

  it("keeps the field once an account is typed", async () => {
    const { user, context } = setup();
    await user.click(screen.getByRole("button", { name: LINK }));
    await user.type(screen.getByRole("textbox", { name: FIELD }), ACCOUNT);
    await user.click(screen.getByRole("button", { name: "elsewhere" }));
    expect(context()).toEqual({ kind: "eoa", address: ACCOUNT });
    expect(
      (screen.getByRole("textbox", { name: FIELD }) as HTMLInputElement).value,
    ).toBe(ACCOUNT);
    expect(screen.queryByRole("button", { name: LINK })).toBeNull();
    expect(
      screen.getByText(
        "Simulations run as this account. Only this account can send the batch.",
      ),
    ).toBeTruthy();
  });

  it("folds back when the account is cleared and the field left", async () => {
    const { user, context } = setup();
    await user.click(screen.getByRole("button", { name: LINK }));
    await user.type(screen.getByRole("textbox", { name: FIELD }), ACCOUNT);
    await user.click(screen.getByRole("button", { name: "elsewhere" }));

    await user.clear(screen.getByRole("textbox", { name: FIELD }));
    // Still there while it has the cursor.
    expect(screen.getByRole("textbox", { name: FIELD })).toBeTruthy();
    await user.click(screen.getByRole("button", { name: "elsewhere" }));
    expect(context().address).toBe("");
    expect(screen.queryByRole("textbox", { name: FIELD })).toBeNull();
    expect(screen.getByRole("button", { name: LINK })).toBeTruthy();
  });

  it("shows the field at once for a batch already built for another account", () => {
    setup({ kind: "eoa", address: ACCOUNT });
    expect(
      (screen.getByRole("textbox", { name: FIELD }) as HTMLInputElement).value,
    ).toBe(ACCOUNT);
  });

  it("flags text that is neither an address nor a name", async () => {
    const { user } = setup();
    await user.click(screen.getByRole("button", { name: LINK }));
    await user.type(screen.getByRole("textbox", { name: FIELD }), "0x12");
    expect(screen.getByText("Not a valid address or ENS name.")).toBeTruthy();
  });

  it("does not flag an ENS name", async () => {
    const { user } = setup();
    await user.click(screen.getByRole("button", { name: LINK }));
    await user.type(screen.getByRole("textbox", { name: FIELD }), "vitalik.eth");
    expect(screen.queryByText("Not a valid address or ENS name.")).toBeNull();
  });
});

describe("ContextSelector: the executor", () => {
  it.each([
    ["Safe", "safe", "Safe address"],
    ["Governor", "governor", "Governor address"],
    ["Aragon OSx DAO", "aragonosx", "DAO address"],
  ])("always asks a %s for its address, with no link", async (button, kind, label) => {
    const { user, context } = setup();
    await user.click(screen.getByRole("button", { name: button }));
    expect(context()).toEqual({ kind });
    expect(screen.getByText(label)).toBeTruthy();
    expect(screen.getByPlaceholderText("0x… or name.eth")).toBeTruthy();
    expect(screen.queryByRole("button", { name: LINK })).toBeNull();
    expect(screen.queryByRole("button", { name: "Connect wallet" })).toBeNull();
  });

  it("drops the previous executor's address when the kind changes", async () => {
    const { user, context } = setup({ kind: "safe", address: ACCOUNT });
    await user.click(screen.getByRole("button", { name: "A wallet" }));
    expect(context()).toEqual({ kind: "eoa" });
    expect(screen.getByRole("button", { name: LINK })).toBeTruthy();
  });

  it("asks a DAO for its plugin and a proposal for its description", async () => {
    const { user, context } = setup({ kind: "aragonosx" });
    await user.type(
      screen.getByPlaceholderText("token-voting, multisig, or plugin address"),
      "multisig",
    );
    await user.type(
      screen.getByPlaceholderText("What does this proposal do?"),
      "Pay the grant",
    );
    expect(context()).toEqual({
      kind: "aragonosx",
      plugin: "multisig",
      description: "Pay the grant",
    });
  });

  it("shows what the address check found", () => {
    setup(
      { kind: "safe", address: "dao.eth" },
      { check: { state: "ok", message: "Safe with 3 owners" } as AddressCheck, resolved: ACCOUNT },
    );
    expect(screen.getByText("Safe with 3 owners")).toBeTruthy();
    expect(screen.getByText(`· ${ACCOUNT}`, { exact: false })).toBeTruthy();
  });

  it("shows why the address check failed", () => {
    setup(
      { kind: "safe", address: ACCOUNT },
      { check: { state: "error", message: "Not a Safe on this network." } as AddressCheck },
    );
    expect(screen.getByText("Not a Safe on this network.")).toBeTruthy();
  });
});

describe("ContextSelector: the network", () => {
  it("picks a listed network", async () => {
    const { user, onChainChange } = setup();
    await user.click(screen.getByRole("button", { name: "Gnosis" }));
    expect(onChainChange).toHaveBeenCalledExactlyOnceWith(100);
  });

  it("takes any other network by its chain id", async () => {
    const { user, onChainChange } = setup({ kind: "eoa" }, {
      chainSupport: { state: "ok", chainName: "Linea" } as ChainSupport,
    });
    await user.type(
      screen.getByRole("textbox", { name: "Another network, by chain ID" }),
      "59144",
    );
    expect(onChainChange).toHaveBeenLastCalledWith(59144);
    expect(screen.getByText(/found on Linea\. The builder works here\./)).toBeTruthy();
  });

  it("ignores a chain id that is not a number", async () => {
    const { user, onChainChange } = setup();
    await user.type(
      screen.getByRole("textbox", { name: "Another network, by chain ID" }),
      "abc",
    );
    expect(onChainChange).not.toHaveBeenCalled();
  });

  it("says which contracts a custom network is missing", () => {
    setup({ kind: "eoa" }, {
      chainId: 59144,
      chainSupport: {
        state: "missing",
        chainName: "Linea",
        missing: ["Assertions", "Operations"],
      } as ChainSupport,
    });
    expect(
      screen.getByText(/Assertions and Operations are not deployed on/),
    ).toBeTruthy();
    expect(
      screen.getByRole("link", { name: "Deploy the canonical contracts" }),
    ).toBeTruthy();
  });

  it("warns when the wallet is on another network and offers to switch it", async () => {
    wallet.address = ACCOUNT;
    wallet.chain = { id: 100, name: "Gnosis" };
    const { user } = setup();
    expect(screen.getByText(/Your wallet is connected to/).textContent).toMatch(
      /Your wallet is connected to Gnosis,\s+but this batch targets Ethereum\./,
    );
    await user.click(
      screen.getByRole("button", { name: "Switch wallet to Ethereum" }),
    );
    expect(wallet.switchChain).toHaveBeenCalledExactlyOnceWith({ chainId: 1 });
  });

  it("does not warn when the wallet is on the batch's network", () => {
    wallet.address = ACCOUNT;
    wallet.chain = { id: 1, name: "Ethereum" };
    setup();
    expect(screen.queryByText(/Your wallet is connected to/)).toBeNull();
    // The connected wallet shows in place of the connect button.
    expect(screen.getByText("0x1234…7890")).toBeTruthy();
    expect(screen.getByRole("button", { name: "Disconnect" })).toBeTruthy();
  });
});
