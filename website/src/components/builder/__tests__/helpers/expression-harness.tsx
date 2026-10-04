import { useState } from "react";

import { type Path, type ValueExpr, updateAt } from "../../assertion-model";
import {
  CallAddressContext,
  type CallAddressResolver,
} from "../../expr/CallEditor";
import { ValueSlot, ValueTray } from "../../expr/ValueEditor";

export interface Sides {
  subject: ValueExpr;
  expected: ValueExpr | null;
}

/**
 * The two sides of a comparison and the tray under them, wired the way
 * ExpressionAssertionEditor wires them, without its compiler and chain
 * access. `onState` hears every tree and tray position the harness reaches.
 */
export function ExpressionHarness({
  initial,
  initialOpen = null,
  resolver = null,
  onState,
}: {
  initial: Sides;
  initialOpen?: Path | null;
  resolver?: CallAddressResolver | null;
  onState?: (state: { root: Sides; openPath: Path | null }) => void;
}) {
  const [root, setRoot] = useState(initial);
  const [openPath, setOpenPath] = useState<Path | null>(initialOpen);
  onState?.({ root, openPath });
  const update = (path: Path, updater: (node: any) => any) =>
    setRoot((r) => updateAt(r, path, updater));
  return (
    <div>
      <div data-testid="subject">
        <ValueSlot
          node={root.subject}
          path={["subject"]}
          update={update}
          chainId={1}
          openPath={openPath}
          onOpen={setOpenPath}
          noLiteral
        />
      </div>
      {root.expected && (
        <div data-testid="expected">
          <ValueSlot
            node={root.expected}
            path={["expected"]}
            update={update}
            chainId={1}
            openPath={openPath}
            onOpen={setOpenPath}
          />
        </div>
      )}
      <div data-testid="tray">
        <CallAddressContext.Provider value={resolver}>
          <ValueTray
            root={root}
            openPath={openPath}
            onOpen={setOpenPath}
            update={update}
            chainId={1}
            sides={{ subject: "Value to check", expected: "Expected value" }}
          />
        </CallAddressContext.Provider>
      </div>
    </div>
  );
}
