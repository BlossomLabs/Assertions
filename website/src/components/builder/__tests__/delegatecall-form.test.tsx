// @vitest-environment jsdom
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { beforeEach, describe, expect, it, vi } from "vitest";

import { AbiForm } from "../AbiForm";
import { clearContracts, registerContract } from "./helpers/fake-contracts";
import { resetWallet } from "./helpers/fake-wagmi";

vi.mock("wagmi", async (importOriginal) =>
  (await import("./helpers/fake-wagmi")).fakeWagmiModule(await importOriginal()),
);
vi.mock("../useContractFunctions", async (importOriginal) =>
  (await import("./helpers/fake-contracts")).fakeContractFunctionsModule(
    await importOriginal(),
  ),
);
vi.mock("../token-list", () => ({ tokenList: async () => [] }));

const LIB = "0x00000000000000000000000000000000000000bb";

async function fill(user: ReturnType<typeof userEvent.setup>) {
  await user.click(screen.getByPlaceholderText("0x… or mydao.eth"));
  await user.paste(LIB);
  await user.click(screen.getByRole("button", { name: "Select a function…" }));
  await user.click(screen.getByRole("option", { name: "signMessage(bytes)" }));
  await user.type(screen.getByLabelText(/_data/), "0x1234");
}

beforeEach(() => {
  resetWallet();
  clearContracts();
  registerContract(LIB, {
    name: "SignMessageLib",
    abi: ["function signMessage(bytes _data)"],
  });
});

describe("AbiForm: delegatecalls", () => {
  it("offers a delegatecall where a Safe executes, and writes it as the Safe's", async () => {
    const onAdd = vi.fn();
    const user = userEvent.setup();
    render(<AbiForm chainId={1} safeContext onAdd={onAdd} />);
    await fill(user);
    await user.click(screen.getByRole("checkbox", { name: /Delegatecall/ }));
    // What a delegatecall can do to the Safe is said before it is added.
    expect(screen.getByText(/owners, threshold, modules/)).toBeTruthy();
    await user.click(screen.getByRole("button", { name: "Add to batch" }));
    expect(onAdd).toHaveBeenCalledTimes(1);
    expect(onAdd.mock.calls[0][0]).toMatch(
      /^safe:delegate-exec \$_0 "signMessage\(bytes\)" 0x1234$/,
    );
  });

  it("writes a plain call when the box is left alone", async () => {
    const onAdd = vi.fn();
    const user = userEvent.setup();
    render(<AbiForm chainId={1} safeContext onAdd={onAdd} />);
    await fill(user);
    await user.click(screen.getByRole("button", { name: "Add to batch" }));
    expect(onAdd.mock.calls[0][0]).toMatch(/^exec \$_0 /);
  });

  it("does not offer one to an executor that is no Safe", async () => {
    const user = userEvent.setup();
    render(<AbiForm chainId={1} onAdd={vi.fn()} />);
    await fill(user);
    expect(screen.queryByRole("checkbox", { name: /Delegatecall/ })).toBeNull();
  });
});
