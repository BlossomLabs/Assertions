import { useState } from "react";
import type { Address } from "viem";

import { AssertionForm } from "./AssertionForm";
import { BatchList } from "./BatchList";
import { Block } from "./ComposeStage";
import type { ContextKind } from "./context";
import { type AssertionPlacement, hasAssertions, isAssertSpan } from "./script-ops";
import { SimulationPanel, simKeyFor, type useSimulation } from "./SimulationPanel";
import type { SimulationState } from "./simulation";
import { type SuggestWiring, SuggestedChecks } from "./SuggestedChecks";
import type { useScriptState } from "./useScriptState";

/**
 * Assertions: the checks step 1's simulation suggests, the assistant that
 * can add more, the form to build one by hand (on request), the batch so
 * far with them in place, and the simulation of the protected batch,
 * which is what Submit requires.
 */
export function AssertionsStage({
  chainId,
  executor,
  context,
  scriptState,
  suggest,
  simulation,
  suggestions,
}: {
  chainId: number;
  executor: Address | undefined;
  /** Who executes the batch: decides each suggested check's notices. */
  context: ContextKind;
  scriptState: ReturnType<typeof useScriptState>;
  /** The assistant's "Suggest more assertions". */
  suggest: SuggestWiring;
  /** The protected-batch simulation. */
  simulation: ReturnType<typeof useSimulation>;
  /** Step 1's simulation: the checks it suggested. */
  suggestions: SimulationState;
}) {
  const { script, removeCommand } = scriptState;
  const hasScript = script.trim().length > 0;
  const protectedScript = hasAssertions(script);
  const simKey = simKeyFor("protected", script, executor, chainId);
  const [placement, setPlacement] = useState<AssertionPlacement>("post");
  // The form that builds a check by hand: shown on request.
  const [manual, setManual] = useState(false);

  return (
    <div className="space-y-8">
      <Block
        title="Checks"
        hint="Checks that make the whole batch revert unless the chain is in the state you expect."
      >
        <div className="space-y-4">
          <SuggestedChecks
            state={suggestions}
            simKey={simKey}
            context={context}
            chainId={chainId}
            scriptState={scriptState}
            suggest={suggest}
            manual={{
              open: manual,
              controls: "manual-assertion",
              onToggle: () => setManual((was) => !was),
            }}
          />
          {/* Hidden, not unmounted: closing it keeps a check half built. */}
          <div id="manual-assertion" hidden={!manual}>
            <AssertionForm
              scriptState={scriptState}
              chainId={chainId}
              placement={placement}
              onPlacementChange={setPlacement}
            />
          </div>
        </div>
      </Block>

      {hasScript && (
        <Block title="Batch so far">
          <BatchList
            script={script}
            chainId={chainId}
            onRename={scriptState.renameVariable}
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
