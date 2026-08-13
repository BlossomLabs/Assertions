import {
  type ChatItem,
  DEFAULT_NEXUS_CONFIG,
  NexusBrokerClient,
} from "@evmcrispr/ai";
import { useCallback, useEffect, useMemo, useRef, useState } from "react";

import { Markdown } from "./Markdown";
import {
  builderAuth,
  builderChatStorage,
  type useBuilderChatAgent,
} from "./useBuilderChatAgent";

type Agent = ReturnType<typeof useBuilderChatAgent>;

/** Nexus OAuth only allows registered origins. When this site's origin isn't
 *  allowlisted (e.g. assertions.eth.limo), the login runs inside a broker
 *  iframe hosted on an allowlisted EVMcrispr deploy, which posts the
 *  provisioned API key back (see @evmcrispr/ai's nexus-broker). */
const BROKER_URL = import.meta.env.PUBLIC_NEXUS_BROKER_URL as
  | string
  | undefined;

/** Machine-readable `type`/`code` values that mean the key itself is dead.
 *  Only these fields are matched, never the free-form `message`: an assistant
 *  quoting "invalid_api_key" back into an error must not log the user out. */
const KEY_DEAD_MARKERS = [
  "authentication_error",
  "permission_error",
  "invalid_api_key",
  "invalid_authentication",
  "api_key_expired",
  "api_key_revoked",
];
/** An empty wallet, not a bad key. Re-login cannot refill an account, so these
 *  must never count as expired — checked before the markers and the status. */
const BALANCE_MARKERS = [
  "insufficient_balance",
  "insufficient_quota",
  "insufficient_credit",
  "billing_hard_limit_reached",
];

/** True when Nexus says the key is dead. The probe names a nonexistent model:
 *  key auth runs before model resolution, so a live key answers 400 without
 *  ever reaching a paid completion. A network failure counts as alive, so a
 *  Nexus outage can't log the user out.
 *
 *  The response body decides when it names a cause, because a balance
 *  rejection can arrive under an auth-ish status; the status is the fallback
 *  for bodies that say nothing (proxy HTML, empty). */
async function nexusKeyExpired(key: string): Promise<boolean> {
  try {
    const res = await fetch(
      `${DEFAULT_NEXUS_CONFIG.baseURL}/chat/completions`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${key}`,
        },
        body: JSON.stringify({
          model: "__assertions_key_probe__",
          messages: [{ role: "user", content: "probe" }],
        }),
      },
    );

    let marker = "";
    try {
      const body: unknown = await res.json();
      const outer = (body ?? {}) as Record<string, unknown>;
      const inner =
        typeof outer.error === "object" && outer.error !== null
          ? (outer.error as Record<string, unknown>)
          : outer;
      const str = (v: unknown) => (typeof v === "string" ? v : "");
      marker = `${str(inner.type)} ${str(inner.code)}`.toLowerCase();
    } catch {
      // Not JSON (proxy HTML, empty body): the status decides.
    }

    if (BALANCE_MARKERS.some((m) => marker.includes(m))) return false;
    if (KEY_DEAD_MARKERS.some((m) => marker.includes(m))) return true;
    return res.status === 401;
  } catch {
    return false;
  }
}

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
  const [sessionExpired, setSessionExpired] = useState(false);
  const scrollRef = useRef<HTMLDivElement>(null);
  const sentSuggestRef = useRef<number | null>(null);
  const probedRef = useRef(false);

  // A key restored from a previous visit may belong to a Nexus session that
  // has since expired or been revoked; probe it once on mount so the user is
  // asked to log in again before composing a message, not after.
  useEffect(() => {
    if (probedRef.current) return;
    probedRef.current = true;
    const key = builderChatStorage.getApiKey();
    if (!key) return;
    void nexusKeyExpired(key).then((expired) => {
      // A fresh login can land while the probe is in flight; only the key we
      // actually probed may be cleared, never its replacement.
      if (expired && builderChatStorage.getApiKey() === key) {
        setSessionExpired(true);
        agent.clearApiKey();
      }
    });
  }, [agent.clearApiKey]);

  // A 401 mid-run means the key was revoked or the session expired while
  // chatting; drop to the login screen. The conversation stays in the hook's
  // state and resumes after re-login.
  useEffect(() => {
    if (!agent.isAuthError) return;
    setSessionExpired(true);
    agent.clearApiKey();
  }, [agent.isAuthError, agent.clearApiKey]);

  const acceptKey = useCallback(
    (key: string) => {
      setSessionExpired(false);
      setLoginError(null);
      agent.setApiKey(key);
    },
    [agent.setApiKey],
  );

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
      else await builderAuth.logoutNexus();
    } finally {
      agent.clearApiKey();
      setLoggingOut(false);
    }
  };

  if (!agent.hasKey) {
    return (
      <div className="space-y-4 text-sm">
        {sessionExpired && (
          <p className="px-3 py-2 rounded-lg text-xs leading-relaxed bg-[var(--color-err)]/10 border border-[var(--color-err)]/30 text-[var(--color-err)]">
            Your Dappnode Nexus session has expired or its key was revoked. Log
            in again to continue
            {agent.items.length > 0 && ", and your conversation is preserved"}.
          </p>
        )}
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
          <BrokerLogin onKey={acceptKey} onError={setLoginError} />
        ) : (
          <button
            type="button"
            disabled={loggingIn}
            onClick={async () => {
              setLoggingIn(true);
              setLoginError(null);
              try {
                acceptKey(await builderAuth.loginWithNexus());
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
              acceptKey(keyInput.trim());
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
            or ask anything about protecting it.
          </p>
        )}
        {agent.items.map((item, i) =>
          item.role === "tool" ? (
            // biome-ignore lint/suspicious/noArrayIndexKey: append-only list
            <ToolChip key={i} item={item} />
          ) : item.role === "user" ? (
            <div
              // biome-ignore lint/suspicious/noArrayIndexKey: append-only list
              key={i}
              className="text-sm leading-relaxed whitespace-pre-wrap px-3 py-2 rounded-lg bg-[var(--color-bp-500)]/10 dark:bg-[var(--color-bp-400)]/10 border border-[var(--color-bp-500)]/20 dark:border-[var(--color-bp-400)]/30"
            >
              {item.text}
            </div>
          ) : (
            <Markdown
              // biome-ignore lint/suspicious/noArrayIndexKey: append-only list
              key={i}
              text={item.text}
              className="text-[var(--color-ink)]"
            />
          ),
        )}
        {agent.error && !agent.isAuthError && (
          <p className="text-xs text-[var(--color-err)]">{agent.error}</p>
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
