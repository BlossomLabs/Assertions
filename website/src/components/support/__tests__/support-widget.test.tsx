// @vitest-environment jsdom
import { fireEvent, render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { afterEach, describe, expect, it, vi } from "vitest";

import SupportWidget, { SUPPORT_URL } from "../SupportWidget";

const mockFetch = (ok: boolean) => {
  const fetchMock = vi.fn(async () => ({ ok, status: ok ? 200 : 500 }));
  vi.stubGlobal("fetch", fetchMock);
  return fetchMock;
};

const openForm = async (category: string) => {
  const user = userEvent.setup();
  render(<SupportWidget />);
  await user.click(screen.getByRole("button", { name: "Support" }));
  await user.click(screen.getByRole("button", { name: category }));
  return user;
};

afterEach(() => vi.unstubAllGlobals());

describe("SupportWidget", () => {
  it("sends the message to the support inbox, tagged with the site, category and page", async () => {
    const fetchMock = mockFetch(true);
    const user = await openForm("Report a problem");
    await user.type(screen.getByLabelText("Email (optional)"), "a@b.org");
    await user.type(screen.getByLabelText("Message"), "  It broke  ");
    await user.click(screen.getByRole("button", { name: "Send" }));

    expect(fetchMock).toHaveBeenCalledTimes(1);
    const [url, init] = fetchMock.mock.calls[0] as unknown as [
      string,
      RequestInit,
    ];
    expect(url).toBe(SUPPORT_URL);
    expect(init.method).toBe("POST");
    expect(JSON.parse(String(init.body))).toEqual({
      name: "",
      email: "a@b.org",
      message: `[Assertions · Report a problem]\nPage: ${window.location.origin}${window.location.pathname}\n\nIt broke`,
    });
    expect(
      await screen.findByText("Thanks for writing. We read every message."),
    ).toBeTruthy();
  });

  it("keeps a wrong email in the form and sends nothing", async () => {
    const fetchMock = mockFetch(true);
    const user = await openForm("Something else");
    await user.type(screen.getByLabelText("Email (optional)"), "nope");
    await user.type(screen.getByLabelText("Message"), "hello");
    await user.click(screen.getByRole("button", { name: "Send" }));

    expect(fetchMock).not.toHaveBeenCalled();
    expect(screen.getByRole("alert").textContent).toContain(
      "That email does not look right",
    );
    expect(
      (screen.getByLabelText("Message") as HTMLTextAreaElement).value,
    ).toBe("hello");
  });

  it("drops a message whose hidden website field was filled", async () => {
    const fetchMock = mockFetch(true);
    const user = await openForm("Something else");
    const trap = document.querySelector<HTMLInputElement>(
      'input[name="website"]',
    );
    expect(trap?.hidden).toBe(true);
    fireEvent.change(trap as HTMLInputElement, {
      target: { value: "https://spam.example" },
    });
    await user.type(screen.getByLabelText("Message"), "buy now");
    await user.click(screen.getByRole("button", { name: "Send" }));

    expect(fetchMock).not.toHaveBeenCalled();
  });

  it("offers to try again when the inbox refuses, with the message kept", async () => {
    mockFetch(false);
    const user = await openForm("Suggest an improvement");
    await user.type(screen.getByLabelText("Message"), "an idea");
    await user.click(screen.getByRole("button", { name: "Send" }));
    await user.click(await screen.findByRole("button", { name: "Try again" }));

    expect(
      (screen.getByLabelText("Message") as HTMLTextAreaElement).value,
    ).toBe("an idea");
  });

  it("closes on Escape and starts over", async () => {
    const user = await openForm("Report a problem");
    await user.keyboard("{Escape}");
    expect(screen.queryByRole("dialog")).toBeNull();
    await user.click(screen.getByRole("button", { name: "Support" }));
    expect(screen.getByText("How can we help?")).toBeTruthy();
  });
});
