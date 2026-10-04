import { useState } from "react";
import type { Address } from "viem";

import { AssertionForm } from "./AssertionForm";
import { BatchList } from "./BatchList";
import { BatchTimeline } from "./BatchTimeline";
import { Block } from "./ComposeStage";
import { type AssertionPlacement, hasAssertions, isAssertSpan } from "./script-ops";
import { SimulationPanel, simKeyFor, type useSimulation } from "./SimulationPanel";
import type { useScriptState } from "./useScriptState";

/**
 * Assertions: the checks that protect the batch, the batch so far with
 * them in place (as a timeline and as a listing), and the simulation of the protected batch, which is what
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
  const simKey = simKeyFor("protected", script, executor, chainId);
  const [placement, setPlacement] = useState<AssertionPlacement>("post");
  // The command picked on the timeline, by its first line.
  const [selected, setSelected] = useState<number | null>(null);

  return (
    <div className="space-y-8">
      <Block
        title="Checks"
        hint="Checks that make the whole batch revert unless the chain is in the state you expect."
      >
        <AssertionForm
          scriptState={scriptState}
          chainId={chainId}
          placement={placement}
          onPlacementChange={setPlacement}
          suggest={suggest}
        />
      </Block>

      {hasScript && (
        <Block title="Batch so far">
          <BatchTimeline
            script={script}
            simKey={simKey}
            state={simulation.state}
            placement={placement}
            selected={selected}
            onSelect={setSelected}
          />
          <BatchList
            script={script}
            highlight={selected}
            onRemove={removeCommand}
            // Actions are managed in step 1; here only assertions can go.
            canRemove={isAssertSpan}
          />
          <SimulationPanel
            label={protectedScript ? "Simulate protected batch" : "Simulate batch"}
            simKey={simKey}
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
