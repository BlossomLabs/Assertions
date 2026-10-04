// @vitest-environment jsdom
import { render, screen, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { useState } from "react";
import { describe, expect, it, vi } from "vitest";

import { Select, type SelectItem } from "../Select";

const FRUIT: SelectItem[] = [
  { value: "apple", label: "Apple" },
  { value: "apricot", label: "Apricot" },
  { value: "banana", label: "Banana" },
  { value: "cherry", label: "Cherry", disabled: true },
  { value: "damson", label: "Damson" },
];

const optionLabels = () =>
  screen.queryAllByRole("option").map((o) => o.textContent);

function Controlled({
  onChange,
  ...props
}: Omit<React.ComponentProps<typeof Select>, "value" | "onChange"> & {
  onChange?: (v: string) => void;
}) {
  const [value, setValue] = useState("");
  return (
    <Select
      {...props}
      value={value}
      onChange={(v) => {
        setValue(v);
        onChange?.(v);
      }}
    />
  );
}

describe("Select", () => {
  it("shows the placeholder until a value matches, then the option's label", async () => {
    const user = userEvent.setup();
    render(<Controlled options={FRUIT} placeholder="Pick a fruit…" />);
    const trigger = screen.getByRole("button", { name: "Pick a fruit…" });
    expect(trigger.getAttribute("aria-expanded")).toBe("false");
    expect(screen.queryByRole("listbox")).toBeNull();

    await user.click(trigger);
    expect(trigger.getAttribute("aria-expanded")).toBe("true");
    expect(optionLabels()).toEqual([
      "Apple",
      "Apricot",
      "Banana",
      "Cherry",
      "Damson",
    ]);

    await user.click(screen.getByRole("option", { name: "Banana" }));
    expect(screen.queryByRole("listbox")).toBeNull();
    expect(screen.getByRole("button", { name: "Banana" })).toBe(trigger);
  });

  it("reports the choice through onChange and a bubbling DOM event", async () => {
    const user = userEvent.setup();
    const onChange = vi.fn();
    const heard = vi.fn();
    const { container } = render(
      <Controlled options={FRUIT} name="fruit" onChange={onChange} />,
    );
    container.addEventListener("ui-select-change", (e) =>
      heard((e as CustomEvent).detail),
    );
    await user.click(screen.getByRole("button"));
    await user.click(screen.getByRole("option", { name: "Damson" }));
    expect(onChange).toHaveBeenCalledExactlyOnceWith("damson");
    expect(heard).toHaveBeenCalledExactlyOnceWith({
      name: "fruit",
      value: "damson",
    });
  });

  it("does not pick a disabled option", async () => {
    const user = userEvent.setup();
    const onChange = vi.fn();
    render(<Controlled options={FRUIT} onChange={onChange} />);
    await user.click(screen.getByRole("button"));
    const cherry = screen.getByRole("option", { name: "Cherry" });
    expect(cherry.getAttribute("aria-disabled")).toBe("true");
    await user.click(cherry);
    expect(onChange).not.toHaveBeenCalled();
    expect(screen.getByRole("listbox")).toBeTruthy();
  });

  it("is operable from the keyboard, skipping disabled options", async () => {
    const user = userEvent.setup();
    const onChange = vi.fn();
    render(<Controlled options={FRUIT} onChange={onChange} />);
    const trigger = screen.getByRole("button");
    trigger.focus();
    await user.keyboard("{ArrowDown}");
    expect(screen.getByRole("listbox")).toBeTruthy();
    // Opens on the first option; End goes to the last enabled one, and one
    // step up from Damson skips the disabled Cherry.
    await user.keyboard("{End}{ArrowUp}{Enter}");
    expect(onChange).toHaveBeenCalledExactlyOnceWith("banana");
    expect(screen.queryByRole("listbox")).toBeNull();
  });

  it("closes on Escape and on a click outside without choosing", async () => {
    const user = userEvent.setup();
    const onChange = vi.fn();
    render(
      <div>
        <Controlled options={FRUIT} onChange={onChange} />
        <p>elsewhere</p>
      </div>,
    );
    const trigger = screen.getByRole("button");
    await user.click(trigger);
    await user.keyboard("{Escape}");
    expect(screen.queryByRole("listbox")).toBeNull();

    await user.click(trigger);
    expect(screen.getByRole("listbox")).toBeTruthy();
    await user.click(screen.getByText("elsewhere"));
    expect(screen.queryByRole("listbox")).toBeNull();
    expect(onChange).not.toHaveBeenCalled();
  });

  it("does not open while disabled", async () => {
    const user = userEvent.setup();
    render(<Controlled options={FRUIT} disabled />);
    await user.click(screen.getByRole("button"));
    expect(screen.queryByRole("listbox")).toBeNull();
  });

  it("has no search field unless asked for one", async () => {
    const user = userEvent.setup();
    render(<Controlled options={FRUIT} />);
    await user.click(screen.getByRole("button"));
    expect(screen.queryByRole("combobox")).toBeNull();
  });

  describe("searchable", () => {
    it("opens onto a focused search field", async () => {
      const user = userEvent.setup();
      render(<Controlled options={FRUIT} searchable />);
      await user.click(screen.getByRole("button"));
      const search = screen.getByRole("combobox", { name: "Search" });
      expect(document.activeElement).toBe(search);
      expect(search.getAttribute("aria-controls")).toBe(
        screen.getByRole("listbox").id,
      );
    });

    it("filters the options as you type, whatever the case and position", async () => {
      const user = userEvent.setup();
      render(<Controlled options={FRUIT} searchable />);
      await user.click(screen.getByRole("button"));
      await user.keyboard("AP");
      expect(optionLabels()).toEqual(["Apple", "Apricot"]);
      await user.keyboard("{Backspace}{Backspace}nan");
      expect(optionLabels()).toEqual(["Banana"]);
    });

    it("says so when nothing matches, and Enter then picks nothing", async () => {
      const user = userEvent.setup();
      const onChange = vi.fn();
      render(<Controlled options={FRUIT} searchable onChange={onChange} />);
      await user.click(screen.getByRole("button"));
      await user.keyboard("zzz");
      expect(optionLabels()).toEqual([]);
      expect(screen.getByText("No matches")).toBeTruthy();
      await user.keyboard("{Enter}");
      expect(onChange).not.toHaveBeenCalled();
      expect(screen.getByRole("listbox")).toBeTruthy();
    });

    it("picks the first match on Enter and hands the focus back to the trigger", async () => {
      const user = userEvent.setup();
      const onChange = vi.fn();
      render(<Controlled options={FRUIT} searchable onChange={onChange} />);
      const trigger = screen.getByRole("button");
      await user.click(trigger);
      await user.keyboard("da{Enter}");
      expect(onChange).toHaveBeenCalledExactlyOnceWith("damson");
      expect(screen.queryByRole("listbox")).toBeNull();
      expect(document.activeElement).toBe(trigger);
    });

    it("moves through the matches with the arrow keys", async () => {
      const user = userEvent.setup();
      const onChange = vi.fn();
      render(<Controlled options={FRUIT} searchable onChange={onChange} />);
      await user.click(screen.getByRole("button"));
      await user.keyboard("ap{ArrowDown}{Enter}");
      expect(onChange).toHaveBeenCalledExactlyOnceWith("apricot");
    });

    it("skips a disabled first match", async () => {
      const user = userEvent.setup();
      const onChange = vi.fn();
      render(
        <Controlled
          options={[
            { value: "a", label: "match one", disabled: true },
            { value: "b", label: "match two" },
          ]}
          searchable
          onChange={onChange}
        />,
      );
      await user.click(screen.getByRole("button"));
      await user.keyboard("match{Enter}");
      expect(onChange).toHaveBeenCalledExactlyOnceWith("b");
    });

    it("closes on Escape with the focus back on the trigger and the search cleared", async () => {
      const user = userEvent.setup();
      const onChange = vi.fn();
      render(<Controlled options={FRUIT} searchable onChange={onChange} />);
      const trigger = screen.getByRole("button");
      await user.click(trigger);
      await user.keyboard("ban{Escape}");
      expect(screen.queryByRole("listbox")).toBeNull();
      expect(document.activeElement).toBe(trigger);
      expect(onChange).not.toHaveBeenCalled();

      await user.click(trigger);
      expect((screen.getByRole("combobox") as HTMLInputElement).value).toBe("");
      expect(optionLabels()).toHaveLength(5);
    });

    it("keeps only the groups that still have a match", async () => {
      const user = userEvent.setup();
      render(
        <Controlled
          searchable
          options={[
            { label: "Reads", options: [{ value: "bal", label: "balanceOf" }] },
            {
              label: "Writes",
              options: [
                { value: "tr", label: "transfer" },
                { value: "ap", label: "approve" },
              ],
            },
          ]}
        />,
      );
      await user.click(screen.getByRole("button"));
      const menu = screen.getByRole("listbox");
      expect(within(menu).getByText("Reads")).toBeTruthy();
      expect(within(menu).getByText("Writes")).toBeTruthy();
      await user.keyboard("trans");
      expect(optionLabels()).toEqual(["transfer"]);
      expect(within(menu).queryByText("Reads")).toBeNull();
      expect(within(menu).getByText("Writes")).toBeTruthy();
    });
  });

  describe("trigger", () => {
    it("replaces the label and the chevron with what it is given", async () => {
      const user = userEvent.setup();
      const onChange = vi.fn();
      const { container } = render(
        <Select
          options={FRUIT}
          value="apple"
          onChange={onChange}
          trigger={<span>ICON</span>}
          aria-label="Change the fruit"
        />,
      );
      const button = screen.getByRole("button", { name: "Change the fruit" });
      expect(within(button).getByText("ICON")).toBeTruthy();
      // The label and chevron stay in the markup, hidden.
      expect(within(button).getByText("Apple").closest(".hidden")).not.toBeNull();
      expect(
        container.querySelector("button > svg")?.classList.contains("hidden"),
      ).toBe(true);

      await user.click(button);
      expect(screen.getByRole("listbox", { name: "Change the fruit" })).toBeTruthy();
      await user.click(screen.getByRole("option", { name: "Banana" }));
      expect(onChange).toHaveBeenCalledExactlyOnceWith("banana");
    });

    it("shows the label and the chevron without one", () => {
      const { container } = render(<Select options={FRUIT} value="apple" />);
      const button = screen.getByRole("button", { name: "Apple" });
      expect(within(button).getByText("Apple").closest(".hidden")).toBeNull();
      expect(
        container.querySelector("button > svg")?.classList.contains("hidden"),
      ).toBe(false);
    });
  });
});
