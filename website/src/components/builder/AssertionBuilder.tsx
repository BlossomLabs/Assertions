import "../../styles/evmcrispr-editor.css";

import { EvmcrisprProvider } from "@evmcrispr/editor";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { useState } from "react";
import { useAccount, WagmiProvider } from "wagmi";

import { AssertionForm } from "./AssertionForm";
import { Composer } from "./Composer";
import { ChatPanel } from "./ChatPanel";
import { contextReady, executorAddress, type ExecutionContext } from "./context";
import { ContextSelector } from "./ContextSelector";
import { evml } from "./evml";
import { ExecuteStep } from "./ExecuteStep";
import { SimulationResults, useSimulation } from "./SimulateBar";
import { useBuilderChatAgent } from "./useBuilderChatAgent";
import { useChainSupport } from "./useChainSupport";
import { useContextAddress } from "./useContextAddressCheck";
import {
  hasAssertions,
  stripAssertions,
  useScriptState,
} from "./useScriptState";
import { transports, wagmiConfig } from "./wagmi";

const queryClient = new QueryClient();

const SUGGEST_PROMPT =
  "Read my current script and suggest assertions for it: fetch the verified source of every contract it touches, work out what the batch does, and insert the assert commands (with `load assertions`) that best protect it: pre-assertions for the state it relies on, post-assertions for the outcome. Then simulate to confirm the protected batch still passes, and summarize what each assertion guards against.";

function Section({
  step,
  title,
  children,
  dimmed = false,
}: {
  step: number;
  title: string;
  children: React.ReactNode;
  dimmed?: boolean;
}) {
  return (
    <section
      className={`rounded-2xl border border-[var(--color-ink-3)]/20 bg-[var(--color-surface-2)] p-6 transition-opacity ${dimmed ? "opacity-50 pointer-events-none select-none" : ""}`}
    >
      <h2 className="flex items-center gap-3 font-mono font-semibold mb-5">
        <span className="size-7 flex items-center justify-center rounded-full bg-[var(--color-bp-500)]/15 text-[var(--color-bp-300)] text-sm">
          {step}
        </span>
        {title}
      </h2>
      {children}
    </section>
  );
}

function Builder() {
  const { address, chain } = useAccount();

  // The network the batch targets. Follows the connected wallet until the
  // user picks one explicitly — the script's addresses, ABIs, simulations
  // and ENS records are all per-chain, so the choice is made visible in
  // step 1 instead of silently tracking the wallet.
  const [selectedChainId, setSelectedChainId] = useState<number | null>(null);
  const chainId = selectedChainId ?? chain?.id ?? 1;

  const [context, setContext] = useState<ExecutionContext>({ kind: "eoa" });
  const scriptState = useScriptState();
  // Two simulations: the raw batch actions (assertions stripped) in step 3,
  // the protected script in step 5 — so a failure is attributable to either
  // the actions or the assertions guarding them.
  const batchSimulation = useSimulation(chainId);
  const fullSimulation = useSimulation(chainId);
  const [suggestPrompt, setSuggestPrompt] = useState<{
    text: string;
    nonce: number;
  } | null>(null);

  const { resolved: contextAddress, check: contextCheck } = useContextAddress(
    chainId,
    context.kind,
    context.address,
  );
  // Custom chains only work once the canonical contracts have code there.
  const chainSupport = useChainSupport(chainId);
  const chainReady =
    chainSupport.state === "official" || chainSupport.state === "ok";
  const executor = executorAddress(context, address, contextAddress);
  const ready =
    contextReady(context, address, contextAddress) && chainReady;
  const hasScript = scriptState.script.trim().length > 0;
  const protectedScript = hasAssertions(scriptState.script);
  const batchScript = protectedScript
    ? stripAssertions(scriptState.script)
    : scriptState.script;
  const batchSimulated = batchSimulation.status === "success";

  const agent = useBuilderChatAgent({ scriptState, executor, chainId });

  return (
    <div className="grid lg:grid-cols-[1fr_minmax(20rem,24rem)] gap-6 items-start">
      <div className="space-y-6 min-w-0">
        <Section step={1} title="Who executes it, and where?">
          <ContextSelector
            context={context}
            onChange={setContext}
            resolved={contextAddress}
            check={contextCheck}
            chainId={chainId}
            onChainChange={setSelectedChainId}
            chainSupport={chainSupport}
          />
        </Section>

        <Section step={2} title="Compose the batch" dimmed={!ready}>
          <Composer
            scriptState={scriptState}
            chainId={chainId}
            safeContext={context.kind === "safe"}
          />
        </Section>

        <Section step={3} title="Simulate the batch" dimmed={!ready || !hasScript}>
          <div className="space-y-3">
            <div className="flex items-center gap-3 flex-wrap">
              <button
                type="button"
                disabled={batchSimulation.status === "running" || !hasScript}
                onClick={() =>
                  void batchSimulation.simulate(batchScript, executor)
                }
                className="px-4 py-2 rounded-lg text-sm font-medium bg-[var(--color-primary)] text-[var(--color-primary-fg)] hover:bg-[var(--color-primary-hover)] disabled:opacity-40 transition-colors"
              >
                {batchSimulation.status === "running"
                  ? "Simulating…"
                  : "Simulate batch"}
              </button>
              {executor && (
                <span className="text-xs font-mono text-[var(--color-ink-3)]">
                  as {executor.slice(0, 6)}…{executor.slice(-4)}
                </span>
              )}
              {protectedScript && (
                <span className="text-xs text-[var(--color-ink-3)]">
                  assertions are ignored here; step 5 covers them
                </span>
              )}
            </div>
            <SimulationResults
              state={batchSimulation}
              stale={
                batchSimulation.simulatedScript !== null &&
                batchSimulation.simulatedScript !== batchScript
              }
            />
          </div>
        </Section>

        <Section step={4} title="Add assertions" dimmed={!ready || !hasScript}>
          <div className="space-y-5">
            <div className="flex items-center gap-3 flex-wrap">
              <button
                type="button"
                disabled={!batchSimulated || agent.isRunning}
                onClick={() =>
                  setSuggestPrompt({ text: SUGGEST_PROMPT, nonce: Date.now() })
                }
                title={
                  batchSimulated
                    ? "Ask the AI to insert protective assertions"
                    : "Simulate the batch successfully first"
                }
                className="px-4 py-2 rounded-lg text-sm font-medium border border-[var(--color-bp-400)] text-[var(--color-bp-300)] hover:bg-[var(--color-bp-500)]/10 disabled:opacity-40 disabled:cursor-not-allowed transition-colors"
              >
                ✦ Suggest assertions
              </button>
              <span className="text-xs text-[var(--color-ink-3)]">
                or build one manually below
              </span>
            </div>
            <AssertionForm
              scriptState={scriptState}
              chainId={chainId}
              executor={executor}
            />
          </div>
        </Section>

        <Section
          step={5}
          title="Simulate with assertions"
          dimmed={!ready || !hasScript || !protectedScript}
        >
          <div className="space-y-3">
            <div className="flex items-center gap-3 flex-wrap">
              <button
                type="button"
                disabled={
                  fullSimulation.status === "running" || !protectedScript
                }
                onClick={() =>
                  void fullSimulation.simulate(scriptState.script, executor)
                }
                className="px-4 py-2 rounded-lg text-sm font-medium bg-[var(--color-primary)] text-[var(--color-primary-fg)] hover:bg-[var(--color-primary-hover)] disabled:opacity-40 transition-colors"
              >
                {fullSimulation.status === "running"
                  ? "Simulating…"
                  : "Simulate with assertions"}
              </button>
              {executor && (
                <span className="text-xs font-mono text-[var(--color-ink-3)]">
                  as {executor.slice(0, 6)}…{executor.slice(-4)}
                </span>
              )}
            </div>
            <SimulationResults
              state={fullSimulation}
              stale={
                fullSimulation.simulatedScript !== null &&
                fullSimulation.simulatedScript !== scriptState.script
              }
            />
          </div>
        </Section>

        <Section
          step={6}
          title="Review & execute"
          dimmed={!ready || !hasScript}
        >
          <ExecuteStep
            block={scriptState.script}
            context={context}
            contextAddress={contextAddress}
            chainId={chainId}
          />
        </Section>
      </div>

      <aside className="rounded-2xl border border-[var(--color-ink-3)]/20 bg-[var(--color-surface-2)] p-6 lg:sticky lg:top-24 flex flex-col lg:h-[calc(100vh-8rem)] min-h-96">
        <h2 className="font-mono font-semibold mb-4 flex items-center gap-2">
          <span className="text-[var(--color-bp-300)]">✦</span> Assertion
          assistant
        </h2>
        <div className="flex-1 min-h-0">
          <ChatPanel agent={agent} suggestPrompt={suggestPrompt} />
        </div>
      </aside>
    </div>
  );
}

export default function AssertionBuilder() {
  // Providers live inside the island (Astro pages have no React root above).
  return (
    <WagmiProvider config={wagmiConfig}>
      <QueryClientProvider client={queryClient}>
        <EvmcrisprProvider evml={evml} transports={transports}>
          <Builder />
        </EvmcrisprProvider>
      </QueryClientProvider>
    </WagmiProvider>
  );
}
