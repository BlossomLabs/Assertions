import {
  type ChatItem,
  loginWithNexus,
  logoutNexus,
  NexusBrokerClient,
} from "@evmcrispr/ai";
import { useEffect, useMemo, useRef, useState } from "react";

import type { useBuilderChatAgent } from "./useBuilderChatAgent";

type Agent = ReturnType<typeof useBuilderChatAgent>;

/** Nexus OAuth only allows registered origins. When this site's origin isn't
 *  allowlisted (e.g. assertions.eth.limo), the login runs inside a broker
 *  iframe hosted on an allowlisted EVMcrispr deploy, which posts the
 *  provisioned API key back (see @evmcrispr/ai's nexus-broker). */
const BROKER_URL = import.meta.env.PUBLIC_NEXUS_BROKER_URL as
  | string
  | undefined;

function BrokerLogin({
  onKey,
  onError,
}: {
  onKey: (key: string) => void;
  onError: (message: string) => void;
}) {
  const iframeRef = useRef<HTMLIFrameElement>(null);
  const client = useMemo(
    () =>
      BROKER_URL
        ? new NexusBrokerClient({ brokerUrl: BROKER_URL, onKey, onError })
        : null,
    [onKey, onError],
  );

  useEffect(() => {
    if (!client || !iframeRef.current) return;
    client.listen(iframeRef.current);
    return () => client.dispose();
  }, [client]);

  if (!client) return null;
  return (
    <iframe
      ref={iframeRef}
      src={client.iframeSrc}
      title="Login with Dappnode Nexus"
      className="w-full h-16 rounded-lg border border-[var(--color-ink-3)]/20"
    />
  );
}

/** Revokes a broker-provisioned Nexus session (key + refresh token) by
 *  mounting the broker in a hidden iframe just long enough to send it the
 *  logout message. Best-effort: resolves after a timeout if the broker
 *  never loads, so the local key is forgotten regardless. */
function brokerLogout(brokerUrl: string): Promise<void> {
  return new Promise((resolve) => {
    const iframe = document.createElement("iframe");
    iframe.style.display = "none";
    let settled = false;
    const finish = () => {
      if (settled) return;
      settled = true;
      client.dispose();
      iframe.remove();
      resolve();
    };
    const client = new NexusBrokerClient({
      brokerUrl,
      onKey: () => {},
      onReady: () => void client.logout().finally(finish),
    });
    iframe.src = client.iframeSrc;
    document.body.appendChild(iframe);
    client.listen(iframe);
    setTimeout(finish, 10_000);
  });
}

function ToolChip({ item }: { item: ChatItem & { role: "tool" } }) {
  const running = item.phase === "call";
  const failed =
    item.phase === "error" ||
    (item.artifact?.kind === "script-change" && !item.artifact.ok);
  return (
    <div className="flex items-center gap-2 text-xs font-mono text-[var(--color-ink-3)]">
      <span
        className={`size-1.5 rounded-full ${
          running
            ? "bg-[var(--color-bp-400)] animate-pulse"
            : failed
              ? "bg-[var(--color-err)]"
              : "bg-[var(--color-ok)]"
        }`}
      />
      {item.text}
      {item.artifact?.kind === "simulation" &&
        (item.artifact.success ? " ✓ passed" : " ✗ failed")}
      {item.artifact?.kind === "script-change" &&
        item.artifact.ok &&
        (item.artifact.undone ? " (undone)" : " ✓")}
      {item.error && <span className="text-[var(--color-err)]">{item.error}</span>}
    </div>
  );
}

export function ChatPanel({
  agent,
  suggestPrompt,
}: {
  agent: Agent;
  /** Set by the page when the user clicks "Suggest assertions"; the nonce
   *  distinguishes repeated clicks with the same text. */
  suggestPrompt?: { text: string; nonce: number } | null;
}) {
  const [input, setInput] = useState("");
  const [keyInput, setKeyInput] = useState("");
  const [loggingIn, setLoggingIn] = useState(false);
  const [loggingOut, setLoggingOut] = useState(false);
  const [loginError, setLoginError] = useState<string | null>(null);
  const scrollRef = useRef<HTMLDivElement>(null);
  const sentSuggestRef = useRef<number | null>(null);

  // Auto-send the suggest-assertions prompt when the gate button fires.
  useEffect(() => {
    if (
      suggestPrompt &&
      agent.hasKey &&
      !agent.isRunning &&
      sentSuggestRef.current !== suggestPrompt.nonce
    ) {
      sentSuggestRef.current = suggestPrompt.nonce;
      void agent.send(suggestPrompt.text);
    }
  }, [suggestPrompt, agent]);

  useEffect(() => {
    scrollRef.current?.scrollTo({ top: scrollRef.current.scrollHeight });
  }, [agent.items]);

  // Revokes the Nexus session (provisioned API key + refresh token) where one
  // exists, then forgets the local key. For manually pasted keys the remote
  // part is a no-op and only the local key is dropped.
  const logout = async () => {
    setLoggingOut(true);
    try {
      if (BROKER_URL) await brokerLogout(BROKER_URL);
      else await logoutNexus();
    } finally {
      agent.clearApiKey();
      setLoggingOut(false);
    }
  };

  if (!agent.hasKey) {
    return (
      <div className="space-y-4 text-sm">
        <p className="text-[var(--color-ink-2)] leading-relaxed">
          Assertion suggestions run on{" "}
          <a
            href="https://nexus.dappnode.com"
            target="_blank"
            rel="noopener noreferrer"
            className="text-[var(--color-bp-300)] hover:underline"
          >
            Dappnode Nexus
          </a>
          , a privacy-preserving AI gateway. Log in to auto-provision an API
          key, or paste one.
        </p>
        {BROKER_URL ? (
          <BrokerLogin onKey={agent.setApiKey} onError={setLoginError} />
        ) : (
          <button
            type="button"
            disabled={loggingIn}
            onClick={async () => {
              setLoggingIn(true);
              setLoginError(null);
              try {
                agent.setApiKey(await loginWithNexus());
              } catch (e) {
                setLoginError(e instanceof Error ? e.message : String(e));
              } finally {
                setLoggingIn(false);
              }
            }}
            className="w-full px-4 py-2 rounded-lg text-sm font-medium bg-[var(--color-primary)] text-[var(--color-primary-fg)] hover:bg-[var(--color-primary-hover)] disabled:opacity-50 transition-colors"
          >
            {loggingIn ? "Waiting for login…" : "Login with Dappnode Nexus"}
          </button>
        )}
        {loginError && (
          <p className="text-xs text-[var(--color-err)]">{loginError}</p>
        )}
        <div className="flex gap-2">
          <input
            type="password"
            className="flex-1 px-3 py-2 rounded-lg bg-[var(--color-surface)] border border-[var(--color-ink-3)]/30 focus:border-[var(--color-bp-400)] focus:outline-none font-mono text-xs"
            placeholder="sk-…"
            value={keyInput}
            onChange={(e) => setKeyInput(e.target.value)}
          />
          <button
            type="button"
            disabled={!keyInput.trim()}
            onClick={() => {
              agent.setApiKey(keyInput.trim());
              setKeyInput("");
            }}
            className="px-3 py-2 rounded-lg text-sm border border-[var(--color-ink-3)]/30 hover:border-[var(--color-bp-400)] disabled:opacity-40 transition-colors"
          >
            Save key
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="flex flex-col h-full min-h-0">
      <div
        ref={scrollRef}
        className="flex-1 min-h-0 overflow-y-auto space-y-3 pr-1"
      >
        {agent.items.length === 0 && (
          <p className="text-sm text-[var(--color-ink-3)] leading-relaxed">
            Once your batch simulates successfully, hit{" "}
            <span className="text-[var(--color-ink-2)]">
              Suggest assertions
            </span>{" "}
            — or ask anything about protecting it.
          </p>
        )}
        {agent.items.map((item, i) =>
          item.role === "tool" ? (
            // biome-ignore lint/suspicious/noArrayIndexKey: append-only list
            <ToolChip key={i} item={item} />
          ) : (
            <div
              // biome-ignore lint/suspicious/noArrayIndexKey: append-only list
              key={i}
              className={`text-sm leading-relaxed whitespace-pre-wrap ${
                item.role === "user"
                  ? "px-3 py-2 rounded-lg bg-[var(--color-bp-500)]/10 dark:bg-[var(--color-bp-400)]/10 border border-[var(--color-bp-500)]/20 dark:border-[var(--color-bp-400)]/30"
                  : "text-[var(--color-ink)]"
              }`}
            >
              {item.text}
            </div>
          ),
        )}
        {agent.error && (
          <p className="text-xs text-[var(--color-err)]">
            {agent.error}
            {agent.isAuthError && (
              <button
                type="button"
                onClick={agent.clearApiKey}
                className="ml-2 underline"
              >
                Change key
              </button>
            )}
          </p>
        )}
      </div>

      <form
        className="mt-3 flex gap-2"
        onSubmit={(e) => {
          e.preventDefault();
          if (agent.isRunning) return;
          const text = input.trim();
          if (!text) return;
          setInput("");
          void agent.send(text);
        }}
      >
        <input
          className="flex-1 px-3 py-2 rounded-lg bg-[var(--color-surface)] border border-[var(--color-ink-3)]/30 focus:border-[var(--color-bp-400)] focus:outline-none text-sm"
          placeholder="Ask about the batch or its assertions…"
          value={input}
          onChange={(e) => setInput(e.target.value)}
        />
        {agent.isRunning ? (
          <button
            type="button"
            onClick={agent.stop}
            className="px-3 py-2 rounded-lg text-sm border border-[var(--color-err)]/50 text-[var(--color-err)] hover:bg-[var(--color-err)]/10 transition-colors"
          >
            Stop
          </button>
        ) : (
          <button
            type="submit"
            disabled={!input.trim()}
            className="px-4 py-2 rounded-lg text-sm font-medium bg-[var(--color-primary)] text-[var(--color-primary-fg)] hover:bg-[var(--color-primary-hover)] disabled:opacity-40 transition-colors"
          >
            Send
          </button>
        )}
      </form>

      <div className="mt-2 flex justify-end">
        <button
          type="button"
          disabled={loggingOut}
          onClick={() => void logout()}
          className="text-xs text-[var(--color-ink-3)] hover:text-[var(--color-ink-2)] disabled:opacity-50 transition-colors"
        >
          {loggingOut ? "Logging out…" : "Log out of Nexus"}
        </button>
      </div>
    </div>
  );
}
