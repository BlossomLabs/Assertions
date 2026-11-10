// @vitest-environment jsdom
import { render, screen } from "@testing-library/react";
import { beforeEach, describe, expect, it, vi } from "vitest";

import { ComposeStage } from "../ComposeStage";
import type { ContextKind } from "../context";
import { useSimulation } from "../SimulationPanel";
import { useScriptState } from "../useScriptState";
import { clearContracts } from "./helpers/fake-contracts";
import { useFreshTag } from "./helpers/fake-tag";
import { resetWallet } from "./helpers/fake-wagmi";

vi.mock("@evmcrispr/editor", async () =>
  (await import("./helpers/fake-tag")).fakeEditorModule(),
);
vi.mock("wagmi", async (importOriginal) =>
  (await import("./helpers/fake-wagmi")).fakeWagmiModule(await importOriginal()),
);
vi.mock("../useContractFunctions", async (importOriginal) =>
  (await import("./helpers/fake-contracts")).fakeContractFunctionsModule(
    await importOriginal(),
  ),
);
vi.mock("../token-list", () => ({ tokenList: async () => [] }));

const ME = "0x1234567890123456789012345678901234567890" as const;
const LIB = "0x00000000000000000000000000000000000000Bb";
const BLOCK = [
  "load safe",
  `set $lib ${LIB}`,
  'safe:delegate-exec $lib "signMessage(bytes)" 0x1234',
].join("\n");

function Stage({ kind }: { kind: ContextKind }) {
  const scriptState = useScriptState(BLOCK);
  const simulation = useSimulation();
  return (
    <ComposeStage
      context={{ kind, address: kind === "safe" ? ME : undefined }}
      onContextChange={() => {}}
      contextAddress={ME}
      contextCheck={{ state: "ok" } as never}
      chainId={1}
      onChainChange={() => {}}
      chainSupport={{ state: "official" } as never}
      ready
      executor={ME}
      scriptState={scriptState}
      simulation={simulation}
    />
  );
}

beforeEach(() => {
  resetWallet();
  clearContracts();
  useFreshTag(ME);
});

describe("ComposeStage: a delegatecall needs a Safe", () => {
  it("simulates the block under a Safe", () => {
    render(<Stage kind="safe" />);
    expect(screen.getByRole("button", { name: "Simulate batch" })).toBeTruthy();
    expect(screen.queryByText(/only a Safe can make/)).toBeNull();
  });

  it.each(["eoa", "governor", "aragonosx"] as const)(
    "under %s, says why and does not simulate",
    (kind) => {
      render(<Stage kind={kind} />);
      expect(screen.getByText(/only a Safe can make/)).toBeTruthy();
      expect(screen.queryByRole("button", { name: "Simulate batch" })).toBeNull();
    },
  );
});
