// @vitest-environment jsdom
import { fireEvent, render, screen, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { describe, expect, it, vi } from "vitest";

import { BatchList } from "../BatchList";
import { isAssertSpan } from "../script-ops";

const T = "0x00000000000000000000000000000000000000aa";
const ACTION = `exec ${T} "transfer(address,uint256)" ${T} 1000000`;
const CHECK = `assert @balance!(${T} ${T}) >= 51950298220`;

describe("BatchList", () => {
  it("shows each command whole in a narrow row, the bin beside a check", () => {
    render(
      <BatchList
        script={`${ACTION}\n${CHECK}`}
        onRemove={vi.fn()}
        canRemove={isAssertSpan}
      />,
    );
    for (const text of [ACTION, CHECK]) {
      const pre = screen.getByText(text);
      expect(pre.tagName).toBe("PRE");
      // Wraps at spaces; may shrink below its longest token, which then
      // breaks instead of pushing the row wider than the screen.
      for (const cls of ["whitespace-pre-wrap", "min-w-0", "wrap-anywhere"])
        expect(pre.className).toContain(cls);
    }
    const bin = screen.getByRole("button", { name: `Remove command: ${CHECK}` });
    expect(bin.className).toContain("shrink-0");
    expect(screen.queryByRole("button", { name: `Remove command: ${ACTION}` })).toBeNull();
  });
});

describe("BatchList: which addresses are drawn in full", () => {
  const A = "0x00000000000000000000000000000000000000aa";
  const B = "0x00000000000000000000000000000000000000bb";
  const C = "0x00000000000000000000000000000000000000cc";
  // $usdc is used by the action and the check, $to by the action only,
  // $router by the check only.
  const SCRIPT = [
    `set $usdc ${A}`,
    `set $to ${B}`,
    `set $router ${C}`,
    'exec $usdc "transfer(address,uint256)" $to 5',
    "assert @balance!($usdc $router) >= 5  # base units of $to",
  ].join("\n");
  const used = () =>
    [...screen.getByRole("group", { name: "Addresses" }).children].map((row) => [
      row.textContent?.split(" ")[1],
      row.hasAttribute("data-used"),
    ]);

  it("in step 1, those its actions use; a check's alone is dimmed", () => {
    render(
      <BatchList
        script={SCRIPT}
        chainId={1}
        onRemove={vi.fn()}
        onRename={() => ({})}
        canRemove={(span) => !isAssertSpan(span)}
      />,
    );
    expect(used()).toEqual([
      ["$usdc", true],
      ["$to", true],
      ["$router", false],
    ]);
    const dimmed = screen.getByRole("button", { name: "Rename $router" });
    expect(dimmed.className).toContain("text-[var(--color-ink-3)]");
    expect(screen.getByRole("button", { name: "Rename $usdc" }).className).toContain(
      "text-[var(--color-ink)]",
    );
  });

  it("in step 2, those its checks use; an action's alone, or one named in a comment, is dimmed", () => {
    render(
      <BatchList
        script={SCRIPT}
        chainId={1}
        onRemove={vi.fn()}
        onRename={() => ({})}
        canRemove={isAssertSpan}
      />,
    );
    expect(used()).toEqual([
      ["$usdc", true],
      ["$to", false],
      ["$router", true],
    ]);
  });
});

describe("BatchList: renaming a variable", () => {
  const SCRIPT = `set $usdc ${T}\nset $to ${T.replace("aa", "bb")}\nexec $usdc "transfer(address,uint256)" $to 5`;

  it("writes the addresses as the script does, first, without a title, and with no bin", () => {
    render(<BatchList script={SCRIPT} chainId={1} onRemove={vi.fn()} onRename={() => ({})} />);
    const group = screen.getByRole("group", { name: "Addresses" });
    expect(group.textContent).toBe("set $usdc 0x0000…00aaset $to 0x0000…00bb");
    expect(screen.queryByText("Addresses")).toBeNull();
    // Before the commands.
    const action = screen.getByText('exec $usdc "transfer(address,uint256)" $to 5');
    expect(group.compareDocumentPosition(action) & Node.DOCUMENT_POSITION_FOLLOWING).toBeTruthy();
    // The name is still changeable, the address still linked, and a set
    // line goes with the last command using it, not from a bin.
    expect(within(group).getByRole("button", { name: "Rename $usdc" })).toBeTruthy();
    expect(within(group).getByRole("link", { name: "0x0000…00aa" }).getAttribute("href")).toBe(
      `https://etherscan.io/address/${T}`,
    );
    expect(within(group).queryByRole("button", { name: /^Remove command:/ })).toBeNull();
  });

  it("shows the names as plain text when nothing can rename them", () => {
    render(<BatchList script={SCRIPT} onRemove={vi.fn()} />);
    const addresses = within(screen.getByRole("group", { name: "Addresses" }));
    expect(addresses.getByText("$to").tagName).toBe("SPAN");
    expect(addresses.queryByRole("button")).toBeNull();
  });

  it("turns a name into a field on a click and renames on Enter", async () => {
    const user = userEvent.setup();
    const onRename = vi.fn(() => ({}));
    render(<BatchList script={SCRIPT} onRemove={vi.fn()} onRename={onRename} />);
    await user.click(screen.getByRole("button", { name: "Rename $to" }));
    const field = screen.getByRole("textbox", { name: "New name for $to" }) as HTMLInputElement;
    expect(field.value).toBe("to");
    await user.clear(field);
    await user.type(field, "burn{Enter}");
    expect(onRename).toHaveBeenCalledExactlyOnceWith("to", "burn");
    // Done: the field is gone.
    expect(screen.queryByRole("textbox")).toBeNull();
  });

  it("keeps the field open with the reason when the name is refused, and Escape gives up", async () => {
    const user = userEvent.setup();
    const onRename = vi.fn(() => ({ error: "$usdc is already used." }));
    render(<BatchList script={SCRIPT} onRemove={vi.fn()} onRename={onRename} />);
    await user.click(screen.getByRole("button", { name: "Rename $to" }));
    const field = screen.getByRole("textbox", { name: "New name for $to" });
    await user.clear(field);
    await user.type(field, "usdc{Enter}");
    expect(screen.getByRole("alert").textContent).toContain("$usdc is already used.");
    expect(field.getAttribute("aria-invalid")).toBe("true");
    // Typing again clears the reason.
    await user.type(field, "x");
    expect(screen.queryByRole("alert")).toBeNull();
    fireEvent.keyDown(field, { key: "Escape" });
    expect(screen.queryByRole("textbox")).toBeNull();
    expect(screen.getByRole("button", { name: "Rename $to" })).toBeTruthy();
    expect(onRename).toHaveBeenCalledTimes(1);
  });
});

describe("BatchList: editing an action", () => {
  const SEND = `send ${T} --value 1`;

  it("offers the form for an action it can hold, the EVML editor for one it cannot, and nothing for a check", async () => {
    const user = userEvent.setup();
    const onEdit = vi.fn();
    render(
      <BatchList
        script={`${ACTION}\n${SEND}\n${CHECK}`}
        onRemove={vi.fn()}
        editable={(span) => (span.name === "assert" ? null : span.name === "exec" ? "form" : "editor")}
        onEdit={onEdit}
      />,
    );
    await user.click(screen.getByRole("button", { name: `Edit action: ${ACTION}` }));
    expect(onEdit).toHaveBeenLastCalledWith(1, "form");
    const inEditor = screen.getByRole("button", { name: `Edit in the EVML editor: ${SEND}` });
    expect(inEditor.textContent).toBe("EVML editor");
    await user.click(inEditor);
    expect(onEdit).toHaveBeenLastCalledWith(2, "editor");
    expect(screen.queryByRole("button", { name: new RegExp(`Edit.*${CHECK.slice(0, 12)}`) })).toBeNull();
  });

  it("offers no edit without a way to edit", () => {
    render(<BatchList script={ACTION} onRemove={vi.fn()} />);
    expect(screen.queryByRole("button", { name: /^Edit/ })).toBeNull();
  });
});
