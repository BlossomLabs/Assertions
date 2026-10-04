import "../../styles/evmcrispr-editor.css";

import { EvmcrisprProvider, useEvmlTag } from "@evmcrispr/editor";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { useEffect, useMemo, useRef, useState } from "react";
import type { Address } from "viem";
import { useAccount, WagmiProvider } from "wagmi";

import { AssertionsStage } from "./AssertionsStage";
import { AssistantAside } from "./AssistantAside";
import { ChatPanel } from "./ChatPanel";
import { ComposeStage } from "./ComposeStage";
import {
  contextReady,
  executorAddress,
  simulationSender,
  type ExecutionContext,
} from "./context";
import { createLiveTag, evml } from "./evml";
import { SimRing } from "./SimRing";
import { isFresh } from "./simulation";
import { simKeyFor, useSimulation } from "./SimulationPanel";
import { SubmitStage } from "./SubmitStage";
import { type EyeState, eyeStateFor } from "./timeline";
import { useBuilderChatAgent } from "./useBuilderChatAgent";
import { type ChainSupport, useChainSupport } from "./useChainSupport";
import {
  type AddressCheck,
  useContextAddress,
  useGovernorTimelock,
} from "./useContextAddressCheck";
import { useScriptState } from "./useScriptState";
import { transports, wagmiConfig } from "./wagmi";

const queryClient = new QueryClient();

const SUGGEST_PROMPT =
  "Read my current script and suggest assertions for it: fetch the verified source of every contract it touches, work out what the batch does, and insert the assert commands that best protect it: pre-assertions for the state it relies on, post-assertions for the outcome. Then simulate to confirm the protected batch still passes, and summarize what each assertion guards against.";

/** What a step's ring says about its simulation, shown on hover. */
const EYE_TEXT: Record<EyeState, string> = {
  asleep: "nothing to simulate yet",
  stale: "not run for the batch as it is now",
  running: "running",
  pass: "passed",
  fail: "failed",
};

/** A numbered step card. A step whose fields cannot be used yet stays
 *  folded to its header, saying what it waits for, and unfolds once they
 *  can. The body stays mounted while folded, so nothing typed is lost. */
function Section({
  step,
  title,
  children,
  folded = false,
  foldedHint,
  eye,
  eyeSubject,
}: {
  step: number;
  title: string;
  /** The state of the step's simulation ring, for steps that have one. */
  eye?: EyeState;
  /** What that simulation runs, e.g. "the actions". */
  eyeSubject?: string;
  children: React.ReactNode;
  folded?: boolean;
  /** Shown in the header while folded: what unfolds the step. */
  foldedHint?: string;
}) {
  return (
    <section className="rounded-2xl border border-[var(--color-ink-3)]/20 bg-[var(--color-surface-2)] p-6">
      <h2
        className={`flex items-center gap-3 font-mono font-semibold transition-opacity ${folded ? "opacity-60" : ""}`}
      >
        <span className="size-7 shrink-0 flex items-center justify-center rounded-full bg-[var(--color-bp-500)]/15 text-[var(--color-bp-300)] text-sm">
          {step}
        </span>
        {title}
        {folded && foldedHint && (
          <span className="font-sans text-xs font-normal text-[var(--color-ink-2)]">
            {foldedHint}
          </span>
        )}
        {eye && (
          <SimRing
            state={eye}
            className="ml-auto"
            label={`Simulation of ${eyeSubject ?? "the batch"}: ${EYE_TEXT[eye]}.`}
          />
        )}
      </h2>
      <div
        inert={folded}
        className={`grid transition-[grid-template-rows] duration-300 motion-reduce:transition-none ${folded ? "grid-rows-[0fr]" : "grid-rows-[1fr]"}`}
      >
        <div className="min-h-0 overflow-hidden">
          <div className="pt-5">{children}</div>
        </div>
      </div>
    </section>
  );
}

interface BuilderState {
  chainId: number;
  onChainChange: (chainId: number) => void;
  context: ExecutionContext;
  onContextChange: (next: ExecutionContext) => void;
  contextAddress: Address | null;
  contextCheck: AddressCheck;
  chainSupport: ChainSupport;
  executor: Address | undefined;
  ready: boolean;
  scriptState: ReturnType<typeof useScriptState>;
}

/** The three stages, under the configured tag (chain, executor,
 *  transports): every simulation, compilation and execution goes through
 *  `useEvmlTag()`, so @me/@sender and the RPC endpoints apply uniformly. */
function BuilderBody({
  chainId,
  onChainChange,
  context,
  onContextChange,
  contextAddress,
  contextCheck,
  chainSupport,
  executor,
  ready,
  scriptState,
}: BuilderState) {
  const tag = useEvmlTag();
  // The chat tool set is built once; it reaches the current tag through a
  // live proxy so chain and executor changes apply without rebuilding it.
  const tagRef = useRef(tag);
  tagRef.current = tag;
  const liveTag = useMemo(() => createLiveTag(() => tagRef.current), []);
  const agent = useBuilderChatAgent({ scriptState, tag: liveTag });

  // Two simulations, one per batch listing: the actions on their own in
  // step 1 (a failure there is the batch's), the protected script in step
  // 2 (what Submit requires).
  const actionsSim = useSimulation();
  const protectedSim = useSimulation();
  const [suggestPrompt, setSuggestPrompt] = useState<{
    text: string;
    nonce: number;
  } | null>(null);

  const script = scriptState.script;
  const hasScript = script.trim().length > 0;
  // Suggest needs a fresh, passing run of the current script in either
  // mode; Submit wants the protected one.
  const passed = (sim: ReturnType<typeof useSimulation>, mode: "actions-only" | "protected") =>
    sim.state.status === "success" &&
    isFresh(sim.state, simKeyFor(mode, script, executor, chainId));
  const verified = passed(protectedSim, "protected");
  const freshPass = verified || passed(actionsSim, "actions-only");
  const eyeFor = (sim: ReturnType<typeof useSimulation>, mode: "actions-only" | "protected") =>
    eyeStateFor(sim.state, simKeyFor(mode, script, executor, chainId), hasScript);
  const protectedEye = eyeFor(protectedSim, "protected");
  // A step opens once the one before it has passed its simulation at least
  // once for this batch; later edits do not fold it again. Emptying the
  // batch starts over.
  const [actionsPassedOnce, setActionsPassedOnce] = useState(false);
  const [protectedPassedOnce, setProtectedPassedOnce] = useState(false);
  useEffect(() => {
    if (actionsSim.state.status === "success") setActionsPassedOnce(true);
  }, [actionsSim.state.status]);
  useEffect(() => {
    if (protectedSim.state.status === "success") setProtectedPassedOnce(true);
  }, [protectedSim.state.status]);
  useEffect(() => {
    if (hasScript) return;
    setActionsPassedOnce(false);
    setProtectedPassedOnce(false);
  }, [hasScript]);
  // A batch of assertions alone has no actions to simulate: "Skip actions"
  // opens step 2 without them.
  const [skippedActions, setSkippedActions] = useState(false);
  // Steps 2 and 3 work on a batch: they stay folded until there is one.
  const noBatch = !ready || !hasScript;
  const noBatchHint = ready
    ? "Add an action in step 1 first."
    : "Choose the executor in step 1 first.";
  const assertionsLocked =
    !ready || (!skippedActions && (!hasScript || !actionsPassedOnce));
  const assertionsHint = noBatch
    ? noBatchHint
    : "Simulate the batch in step 1 first.";
  const submitLocked = assertionsLocked || !hasScript || !protectedPassedOnce;
  const submitHint = assertionsLocked
    ? assertionsHint
    : hasScript
      ? "Simulate the protected batch in step 2 first."
      : "Add an assertion in step 2 first.";

  const suggest = {
    ready: freshPass,
    running: agent.isRunning,
    loggedIn: agent.hasKey,
    onSuggest: () => setSuggestPrompt({ text: SUGGEST_PROMPT, nonce: Date.now() }),
  };

  return (
    <div className="grid lg:grid-cols-[1fr_minmax(20rem,24rem)] gap-6 items-start">
      <div className="space-y-6 min-w-0">
        <Section
          step={1}
          title="Compose"
          eye={eyeFor(actionsSim, "actions-only")}
          eyeSubject="the actions on their own"
        >
          <ComposeStage
            context={context}
            onContextChange={onContextChange}
            contextAddress={contextAddress}
            contextCheck={contextCheck}
            chainId={chainId}
            onChainChange={onChainChange}
            chainSupport={chainSupport}
            ready={ready}
            executor={executor}
            scriptState={scriptState}
            simulation={actionsSim}
            onSkipActions={
              ready && !hasScript && assertionsLocked
                ? () => setSkippedActions(true)
                : undefined
            }
          />
        </Section>

        <Section
          step={2}
          title="Assertions"
          folded={assertionsLocked}
          foldedHint={assertionsHint}
          eye={protectedEye}
          eyeSubject="the protected batch"
        >
          <AssertionsStage
            chainId={chainId}
            executor={executor}
            scriptState={scriptState}
            suggest={suggest}
            simulation={protectedSim}
          />
        </Section>

        <Section
          step={3}
          title="Submit"
          folded={submitLocked}
          foldedHint={submitHint}
        >
          <SubmitStage
            block={script}
            context={context}
            contextAddress={contextAddress}
            chainId={chainId}
            gate={protectedEye}
            simulation={protectedSim.state}
          />
        </Section>
      </div>

      <AssistantAside full={agent.hasKey}>
        <h2 className="font-mono font-semibold mb-4 flex items-center gap-2">
          <span className="text-[var(--color-bp-300)]">✦</span> Assertion
          assistant
        </h2>
        <div className="flex-1 min-h-0">
          <ChatPanel agent={agent} suggestPrompt={suggestPrompt} />
        </div>
      </AssistantAside>
    </div>
  );
}

/** Chain, context, script and executor state; the EvmcrisprProvider below
 *  it configures the tag every stage uses. */
function Builder() {
  const { address, chain } = useAccount();

  // The network the batch targets. Follows the connected wallet until the
  // user picks one explicitly: the script's addresses, ABIs, simulations
  // and ENS records are all per-chain, so the choice is made visible in
  // Compose instead of silently tracking the wallet.
  const [selectedChainId, setSelectedChainId] = useState<number | null>(null);
  const chainId = selectedChainId ?? chain?.id ?? 1;

  const [context, setContext] = useState<ExecutionContext>({ kind: "eoa" });
  const scriptState = useScriptState();

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
  const ready = contextReady(context, address, contextAddress) && chainReady;
  // A Governor's proposal runs from its timelock, so simulations do too.
  const timelock = useGovernorTimelock(chainId, context.kind, contextAddress);
  const simFrom = simulationSender(executor, timelock);

  return (
    <EvmcrisprProvider
      evml={evml}
      transports={transports}
      chainId={chainId}
      account={executor}
    >
      <BuilderBody
        chainId={chainId}
        onChainChange={setSelectedChainId}
        context={context}
        onContextChange={setContext}
        contextAddress={contextAddress}
        contextCheck={contextCheck}
        chainSupport={chainSupport}
        executor={simFrom}
        ready={ready}
        scriptState={scriptState}
      />
    </EvmcrisprProvider>
  );
}

export default function AssertionBuilder() {
  // Providers live inside the island (Astro pages have no React root above).
  return (
    <WagmiProvider config={wagmiConfig}>
      <QueryClientProvider client={queryClient}>
        <Builder />
      </QueryClientProvider>
    </WagmiProvider>
  );
}
