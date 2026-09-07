import type { Address } from "viem";

import { AssertionForm } from "./AssertionForm";
import { BatchList } from "./BatchList";
import { Block } from "./ComposeStage";
import { hasAssertions, isAssertSpan } from "./script-ops";
import { SimulationPanel, simKeyFor, type useSimulation } from "./SimulationPanel";
import type { useScriptState } from "./useScriptState";

/**
 * Assertions: the checks that protect the batch, the batch so far with
 * them in place, and the simulation of the protected batch, which is what
 * Submit requires.
 */
export function AssertionsStage({
  chainId,
  executor,
  scriptState,
  suggest,
  simulation,
}: {
  chainId: number;
  executor: Address | undefined;
  scriptState: ReturnType<typeof useScriptState>;
  suggest: React.ComponentProps<typeof AssertionForm>["suggest"];
  /** The protected-batch simulation. */
  simulation: ReturnType<typeof useSimulation>;
}) {
  const { script, removeCommand } = scriptState;
  const hasScript = script.trim().length > 0;
  const protectedScript = hasAssertions(script);

  return (
    <div className="space-y-8">
      <Block
        title="Checks"
        hint="Checks that make the whole batch revert unless the chain is in the state you expect."
      >
        <AssertionForm scriptState={scriptState} chainId={chainId} suggest={suggest} />
      </Block>

      {hasScript && (
        <Block title="Batch so far">
          <BatchList
            script={script}
            onRemove={removeCommand}
            // Actions are managed in step 1; here only assertions can go.
            canRemove={isAssertSpan}
          />
          <SimulationPanel
            label={protectedScript ? "Simulate protected batch" : "Simulate batch"}
            simKey={simKeyFor("protected", script, executor, chainId)}
            simulation={simulation}
            failureHint={
              protectedScript
                ? "Simulate the batch in step 1 to tell a failing action from a failing assertion."
                : undefined
            }
          />
        </Block>
      )}
    </div>
  );
}
