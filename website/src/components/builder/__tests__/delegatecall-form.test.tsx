// @vitest-environment jsdom
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { useEffect } from "react";
import { beforeEach, describe, expect, it, vi } from "vitest";

import { Composer } from "../Composer";
import { useScriptState } from "../useScriptState";
import { clearContracts, registerContract } from "./helpers/fake-contracts";
import { useFreshTag } from "./helpers/fake-tag";
import { resetWallet } from "./helpers/fake-wagmi";

vi.mock("@evmcrispr/editor", async () =>
  (await import("./helpers/fake-tag")).fakeEditorModule(),
);
vi.mock("wagmi", async (importOriginal) =>
  (await import("./helpers/fake-wagmi")).fakeWagmiModule(await importOriginal()),
);
vi.mock("../useContractFunctions", async (importOriginal) =>
  (await import("./helpers/fake-contracts")).fakeContractFunctionsModule(
    await importOriginal(),
  ),
);
vi.mock("../token-list", () => ({ tokenList: async () => [] }));

const ME = "0x1234567890123456789012345678901234567890" as const;
const LIB = "0x00000000000000000000000000000000000000Bb";
const CALL = 'exec $lib "signMessage(bytes)" 0x1234';
const DELEGATECALL = 'safe:delegate-exec $lib "signMessage(bytes)" 0x1234';

/** The composer over a batch, with the script it holds after each change. */
let current = "";
function Harness({ initial, safe }: { initial: string; safe: boolean }) {
  const scriptState = useScriptState(initial);
  useEffect(() => {
    current = scriptState.script;
  }, [scriptState.script]);
  return <Composer scriptState={scriptState} chainId={1} safeContext={safe} />;
}

beforeEach(() => {
  resetWallet();
  clearContracts();
  registerContract(LIB, {
    name: "SignMessageLib",
    abi: ["function signMessage(bytes _data)"],
  });
  useFreshTag(ME);
});

describe("Delegatecalls: switched on an action of the batch", () => {
  it("leaves the contract form to calls", () => {
    render(<Harness initial="" safe />);
    expect(screen.queryByRole("checkbox", { name: /Delegatecall/ })).toBeNull();
  });

  it("runs an action as the Safe, says so, and runs it as a call again", async () => {
    const user = userEvent.setup();
    render(<Harness initial={`set $lib ${LIB}\n${CALL}`} safe />);
    // A call: an icon with no word, offering the delegatecall.
    const call = screen.getByRole("button", { name: /^Run as delegatecall:/ });
    expect(call.textContent).toBe("");
    expect(call.getAttribute("aria-pressed")).toBe("false");
    await user.click(screen.getByRole("button", { name: /^Run as delegatecall:/ }));
    expect(current.split("\n")).toContain(DELEGATECALL);
    expect(current.split("\n")).toContain("load safe");
    // The same place now says it in a word, and why on hover.
    const delegate = screen.getByRole("button", { name: /^Runs as the Safe,/ });
    expect(delegate.textContent).toBe("delegatecall");
    expect(delegate.getAttribute("title")).toBe("Runs as the Safe");
    expect(delegate.getAttribute("aria-pressed")).toBe("true");
    // Beside edit and delete, in the action's own row.
    expect(delegate.parentElement?.querySelector('[aria-label^="Remove command:"]')).toBeTruthy();
    // What it can change, said once for the batch.
    expect(screen.getByText(/owners, threshold, modules/)).toBeTruthy();
    await user.click(screen.getByRole("button", { name: /^Runs as the Safe, run as a call instead:/ }));
    expect(current.split("\n")).toContain(CALL);
    expect(current).not.toContain("load safe");
    expect(screen.queryByText(/owners, threshold, modules/)).toBeNull();
  });

  it("offers no delegatecall to an executor that is no Safe, only the way back", async () => {
    const user = userEvent.setup();
    const { unmount } = render(<Harness initial={`set $lib ${LIB}\n${CALL}`} safe={false} />);
    expect(screen.queryByRole("button", { name: /^Run as delegatecall:/ })).toBeNull();
    unmount();
    render(<Harness initial={`load safe\nset $lib ${LIB}\n${DELEGATECALL}`} safe={false} />);
    expect(screen.getByRole("button", { name: /^Runs as the Safe,/ }).textContent).toBe("delegatecall");
    await user.click(screen.getByRole("button", { name: /^Runs as the Safe, run as a call instead:/ }));
    expect(current.split("\n")).toContain(CALL);
  });

  it("offers nothing on an action that sends value: a delegatecall cannot", () => {
    render(<Harness initial={`set $lib ${LIB}\n${CALL} --value 1`} safe />);
    expect(screen.queryByRole("button", { name: /^Run as|^Runs as/ })).toBeNull();
  });
});
