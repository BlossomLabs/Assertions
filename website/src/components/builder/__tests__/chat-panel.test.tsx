// @vitest-environment jsdom
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";

import { AssistantAside } from "../AssistantAside";
import { ChatPanel } from "../ChatPanel";

const stored = vi.hoisted(() => ({ key: null as string | null }));

vi.mock("../useBuilderChatAgent", () => ({
  builderChatStorage: { getApiKey: () => stored.key },
  builderAuth: { loginWithNexus: vi.fn(), logoutNexus: vi.fn(async () => {}) },
  useBuilderChatAgent: vi.fn(),
}));

type Agent = React.ComponentProps<typeof ChatPanel>["agent"];

function fakeAgent(partial: Record<string, unknown> = {}) {
  const agent = {
    hasKey: false,
    isRunning: false,
    items: [],
    error: null,
    setApiKey: vi.fn(),
    clearApiKey: vi.fn(),
    send: vi.fn(async () => {}),
    stop: vi.fn(),
    ...partial,
  };
  return agent as typeof agent & Agent;
}

const COG = "Use your own API key";
const keyField = () => screen.queryByPlaceholderText("sk-…");

beforeEach(() => {
  stored.key = null;
  // Nothing here may reach the network: a call would be a test failure.
  vi.stubGlobal(
    "fetch",
    vi.fn(async () => {
      throw new Error("no network in tests");
    }),
  );
});
afterEach(() => vi.unstubAllGlobals());

describe("ChatPanel: logging in", () => {
  it("keeps the API key field behind the cog button", () => {
    render(<ChatPanel agent={fakeAgent()} />);
    expect(keyField()).toBeNull();
    expect(screen.queryByRole("button", { name: "Save key" })).toBeNull();
    const cog = screen.getByRole("button", { name: COG });
    expect(cog.getAttribute("aria-expanded")).toBe("false");
    expect(screen.getByText(/Assertion suggestions run on/)).toBeTruthy();
  });

  it("shows the field from the cog and hides it again", async () => {
    const user = userEvent.setup();
    render(<ChatPanel agent={fakeAgent()} />);
    const cog = screen.getByRole("button", { name: COG });
    await user.click(cog);
    expect(cog.getAttribute("aria-expanded")).toBe("true");
    const field = keyField() as HTMLInputElement;
    expect(field.type).toBe("password");
    expect(field.closest(`#${cog.getAttribute("aria-controls")}`)).not.toBeNull();

    await user.click(cog);
    expect(cog.getAttribute("aria-expanded")).toBe("false");
    expect(keyField()).toBeNull();
  });

  it("saves a pasted key, trimmed", async () => {
    const user = userEvent.setup();
    const agent = fakeAgent();
    render(<ChatPanel agent={agent} />);
    await user.click(screen.getByRole("button", { name: COG }));
    const save = screen.getByRole("button", { name: "Save key" }) as HTMLButtonElement;
    expect(save.disabled).toBe(true);
    await user.type(keyField() as HTMLElement, "  sk-test-123 ");
    expect(save.disabled).toBe(false);
    await user.click(save);
    expect(agent.setApiKey).toHaveBeenCalledExactlyOnceWith("sk-test-123");
    expect((keyField() as HTMLInputElement).value).toBe("");
  });

  it("does not save a blank key", async () => {
    const user = userEvent.setup();
    const agent = fakeAgent();
    render(<ChatPanel agent={agent} />);
    await user.click(screen.getByRole("button", { name: COG }));
    await user.type(keyField() as HTMLElement, "   ");
    expect(
      (screen.getByRole("button", { name: "Save key" }) as HTMLButtonElement).disabled,
    ).toBe(true);
    expect(agent.setApiKey).not.toHaveBeenCalled();
  });

  it("does not probe anything when no key is stored", () => {
    render(<ChatPanel agent={fakeAgent()} />);
    expect(fetch).not.toHaveBeenCalled();
  });

  it("drops to the login, saying why, when the key dies mid-conversation", () => {
    const agent = fakeAgent({
      hasKey: false,
      error: { kind: "auth", message: "invalid key" },
      items: [{ role: "user", text: "hello" }],
    });
    render(<ChatPanel agent={agent} />);
    expect(agent.clearApiKey).toHaveBeenCalled();
    expect(
      screen.getByText(/session has expired or its key was revoked/).textContent,
    ).toContain("your conversation is preserved");
  });
});

describe("ChatPanel: the chat", () => {
  it("has no login and no key field once there is a key", () => {
    render(<ChatPanel agent={fakeAgent({ hasKey: true })} />);
    expect(screen.queryByRole("button", { name: COG })).toBeNull();
    expect(keyField()).toBeNull();
    expect(screen.getByRole("button", { name: "Log out of Nexus" })).toBeTruthy();
    expect(screen.getByText(/Once your batch simulates successfully/)).toBeTruthy();
  });

  it("sends what is typed, trimmed, and clears the field", async () => {
    const user = userEvent.setup();
    const agent = fakeAgent({ hasKey: true });
    render(<ChatPanel agent={agent} />);
    const send = screen.getByRole("button", { name: "Send" }) as HTMLButtonElement;
    expect(send.disabled).toBe(true);
    const input = screen.getByPlaceholderText(
      "Ask about the batch or its assertions…",
    ) as HTMLInputElement;
    await user.type(input, " what does this do? {Enter}");
    expect(agent.send).toHaveBeenCalledExactlyOnceWith("what does this do?");
    expect(input.value).toBe("");
  });

  it("offers Stop instead of Send while the assistant works", async () => {
    const user = userEvent.setup();
    const agent = fakeAgent({ hasKey: true, isRunning: true });
    render(<ChatPanel agent={agent} />);
    expect(screen.queryByRole("button", { name: "Send" })).toBeNull();
    await user.type(
      screen.getByPlaceholderText("Ask about the batch or its assertions…"),
      "again{Enter}",
    );
    expect(agent.send).not.toHaveBeenCalled();
    await user.click(screen.getByRole("button", { name: "Stop" }));
    expect(agent.stop).toHaveBeenCalledTimes(1);
  });

  it("shows the conversation: messages, tool steps and their outcome", () => {
    const agent = fakeAgent({
      hasKey: true,
      items: [
        { role: "user", text: "protect my batch" },
        { role: "tool", text: "simulate", phase: "result", artifact: { kind: "simulation", success: true } },
        { role: "tool", text: "edit script", phase: "result", artifact: { kind: "script-change", ok: true, undone: true } },
        { role: "assistant", text: "Added one assertion." },
      ],
    });
    render(<ChatPanel agent={agent} />);
    expect(screen.getByText("protect my batch")).toBeTruthy();
    expect(screen.getByText(/simulate/).textContent).toBe("simulate ✓ passed");
    expect(screen.getByText(/edit script/).textContent).toBe("edit script (undone)");
    expect(screen.getByText("Added one assertion.")).toBeTruthy();
    expect(screen.queryByText(/Once your batch simulates successfully/)).toBeNull();
  });

  it("shows an error that is not about the key in the conversation", () => {
    const agent = fakeAgent({
      hasKey: true,
      error: { kind: "balance", message: "Insufficient balance." },
    });
    render(<ChatPanel agent={agent} />);
    expect(screen.getByText("Insufficient balance.")).toBeTruthy();
    expect(agent.clearApiKey).not.toHaveBeenCalled();
  });

  it("sends the suggest prompt once per click of 'Suggest assertions'", () => {
    const agent = fakeAgent({ hasKey: true });
    const view = render(
      <ChatPanel agent={agent} suggestPrompt={{ text: "suggest", nonce: 1 }} />,
    );
    expect(agent.send).toHaveBeenCalledExactlyOnceWith("suggest");
    view.rerender(
      <ChatPanel agent={agent} suggestPrompt={{ text: "suggest", nonce: 1 }} />,
    );
    expect(agent.send).toHaveBeenCalledTimes(1);
    view.rerender(
      <ChatPanel agent={agent} suggestPrompt={{ text: "suggest", nonce: 2 }} />,
    );
    expect(agent.send).toHaveBeenCalledTimes(2);
  });

  it("does not send the suggest prompt without a key", () => {
    const agent = fakeAgent();
    render(<ChatPanel agent={agent} suggestPrompt={{ text: "suggest", nonce: 1 }} />);
    expect(agent.send).not.toHaveBeenCalled();
  });

  it("logs out by forgetting the key", async () => {
    const user = userEvent.setup();
    const agent = fakeAgent({ hasKey: true });
    render(<ChatPanel agent={agent} />);
    await user.click(screen.getByRole("button", { name: "Log out of Nexus" }));
    await vi.waitFor(() => expect(agent.clearApiKey).toHaveBeenCalledTimes(1));
  });
});

describe("AssistantAside", () => {
  const withHeight = (height: number, run: () => void) => {
    const original = Object.getOwnPropertyDescriptor(HTMLElement.prototype, "offsetHeight");
    Object.defineProperty(HTMLElement.prototype, "offsetHeight", {
      configurable: true,
      get: () => height,
    });
    try {
      run();
    } finally {
      if (original) Object.defineProperty(HTMLElement.prototype, "offsetHeight", original);
    }
  };

  it("is a sidebar holding the assistant", () => {
    render(
      <AssistantAside full={false}>
        <ChatPanel agent={fakeAgent()} />
      </AssistantAside>,
    );
    const aside = screen.getByRole("complementary");
    expect(aside.contains(screen.getByRole("button", { name: COG }))).toBe(true);
  });

  it("hugs its content while there is only the login: content height plus its border", () => {
    withHeight(180, () => {
      render(<AssistantAside full={false}>login</AssistantAside>);
      expect(screen.getByRole("complementary").style.height).toBe("182px");
    });
  });

  it("takes the height of the screen once the chat is open", () => {
    withHeight(180, () => {
      const view = render(<AssistantAside full={false}>login</AssistantAside>);
      view.rerender(<AssistantAside full>chat</AssistantAside>);
      expect(screen.getByRole("complementary").style.height).toBe("");
    });
  });
});
