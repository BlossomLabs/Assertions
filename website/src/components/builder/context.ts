import type { Address } from "viem";

/** Who ultimately executes the batch — decides simulation `--from` and the
 *  wrapper the final script gets. */
export type ContextKind = "eoa" | "safe" | "governor" | "aragonosx";

export interface ExecutionContext {
  kind: ContextKind;
  /** Safe address / Governor address / DAO address, as typed — a plain
   *  address or an ENS name. For `eoa`, the account to impersonate in
   *  place of the connected wallet; empty means the connected wallet. */
  address?: string;
  /** AragonOSx governance plugin (repo name like `token-voting`, or its
   *  address). */
  plugin?: string;
  /** Proposal description (governor) / metadata (aragonosx). */
  description?: string;
}

export const CONTEXT_LABELS: Record<ContextKind, string> = {
  eoa: "A wallet",
  safe: "Safe",
  governor: "Governor",
  aragonosx: "Aragon OSx DAO",
};

/** The address the batch runs as: the contract account for proposals; for
 *  a direct batch, the impersonated account when one is given and the
 *  connected wallet otherwise. `resolved` is the context address after ENS
 *  resolution (equal to the input when it's a plain address). */
export function executorAddress(
  context: ExecutionContext,
  connected: Address | undefined,
  resolved: Address | null,
): Address | undefined {
  if (context.kind === "eoa" && !context.address) return connected;
  return resolved ?? undefined;
}

export function contextReady(
  context: ExecutionContext,
  connected: Address | undefined,
  resolved: Address | null,
): boolean {
  if (context.kind === "eoa" && !context.address) return !!connected;
  if (context.kind === "aragonosx") return !!resolved && !!context.plugin;
  return !!resolved;
}

/** A direct batch built for an impersonated account, with a different
 *  wallet connected: only the impersonated account can send it as built. */
export function senderMismatch(
  context: ExecutionContext,
  connected: Address | undefined,
  resolved: Address | null,
): boolean {
  return (
    context.kind === "eoa" &&
    !!context.address &&
    !!connected &&
    !!resolved &&
    connected.toLowerCase() !== resolved.toLowerCase()
  );
}

const ZERO_ADDRESS = "0x0000000000000000000000000000000000000000";

/** The account a simulation runs as. A Governor's proposal executes from
 *  its timelock (what governor:propose evaluates `@sender` as), so with a
 *  timelock the simulation must run from it; without one, from the
 *  executor. The zero address counts as no timelock. */
export function simulationSender(
  executor: Address | undefined,
  timelock: Address | null | undefined,
): Address | undefined {
  if (!timelock || timelock.toLowerCase() === ZERO_ADDRESS) return executor;
  return timelock;
}
