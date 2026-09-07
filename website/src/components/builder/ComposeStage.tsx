import type { Address } from "viem";

import { Composer } from "./Composer";
import { ContextSelector } from "./ContextSelector";
import type { ExecutionContext } from "./context";
import { hasAssertions } from "./script-ops";
import { SimulationPanel, simKeyFor, type useSimulation } from "./SimulationPanel";
import type { ChainSupport } from "./useChainSupport";
import type { AddressCheck } from "./useContextAddressCheck";
import type { useScriptState } from "./useScriptState";

export function Block({
  title,
  hint,
  dimmed = false,
  children,
}: {
  title: string;
  hint?: string;
  dimmed?: boolean;
  children: React.ReactNode;
}) {
  return (
    <div
      className={`space-y-3 transition-opacity ${dimmed ? "opacity-50 pointer-events-none select-none" : ""}`}
    >
      <div>
        <h3 className="text-sm font-semibold text-[var(--color-ink)]">{title}</h3>
        {hint && <p className="text-xs text-[var(--color-ink-3)]">{hint}</p>}
      </div>
      {children}
    </div>
  );
}

/**
 * Compose: who executes the batch and where, the actions with the batch
 * so far, and the simulation of those actions on their own.
 */
export function ComposeStage({
  context,
  onContextChange,
  contextAddress,
  contextCheck,
  chainId,
  onChainChange,
  chainSupport,
  ready,
  executor,
  scriptState,
  simulation,
}: {
  context: ExecutionContext;
  onContextChange: (next: ExecutionContext) => void;
  contextAddress: Address | null;
  contextCheck: AddressCheck;
  chainId: number;
  onChainChange: (chainId: number) => void;
  chainSupport: ChainSupport;
  /** Executor and network are settled. */
  ready: boolean;
  executor: Address | undefined;
  scriptState: ReturnType<typeof useScriptState>;
  /** The actions-only simulation. */
  simulation: ReturnType<typeof useSimulation>;
}) {
  const { script } = scriptState;
  const hasScript = script.trim().length > 0;

  return (
    <div className="space-y-8">
      <Block title="Executor and network">
        <ContextSelector
          context={context}
          onChange={onContextChange}
          resolved={contextAddress}
          check={contextCheck}
          chainId={chainId}
          onChainChange={onChainChange}
          chainSupport={chainSupport}
        />
      </Block>

      <Block title="Actions" dimmed={!ready}>
        <Composer
          scriptState={scriptState}
          chainId={chainId}
          safeContext={context.kind === "safe"}
        />
        {hasScript && (
          <SimulationPanel
            label="Simulate batch"
            simKey={simKeyFor("actions-only", script, executor, chainId)}
            simulation={simulation}
            note={
              hasAssertions(script)
                ? "assertions are ignored here; step 2 covers them"
                : undefined
            }
          />
        )}
      </Block>
    </div>
  );
}
