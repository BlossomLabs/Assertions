import { createContext, useContext, useEffect, useState } from "react";
import { type Address, type PublicClient, isAddress, parseAbi } from "viem";
import { usePublicClient } from "wagmi";

import { type ValueExpr, inferCategory, isEnsName } from "./assertion-model";
import { useChainClient } from "./useChainSupport";
import { resolveEnsAddress } from "./useContractFunctions";

/**
 * Whether the batch's executor is a Safe: the "From" choice is Safe and its
 * address has been checked. `@me` is the executor, so the Safe reads are
 * offered on it exactly then. Whoever knows the choice provides this.
 */
export const ExecutorIsSafe = createContext(false);

/**
 * Reads the address a value currently produces, the way the assertion
 * would read it, or null when it cannot be read now. Whoever can compile
 * and run a value against the chain provides it; without one, a call is
 * never taken to return a Safe.
 */
export type AddressReader = (node: ValueExpr) => Promise<string | null>;
export const CurrentAddress = createContext<AddressReader | null>(null);

/** How long a name or a call is left alone before it is looked up, so one
 *  being typed is not resolved letter by letter. */
const SETTLE_MS = 350;

const SAFE_ABI = parseAbi([
  "function getThreshold() view returns (uint256)",
  "function getOwners() view returns (address[])",
]);

/** One probe per chain and address for the whole session. */
const probes = new Map<string, Promise<boolean>>();

/** A failure of the connection, not an answer from the chain. */
function isTransportError(error: unknown): boolean {
  const walk = (error as { walk?: (fn: (e: unknown) => boolean) => unknown })
    ?.walk;
  if (typeof walk !== "function") return false;
  return !!walk.call(error, (e) => {
    const name = (e as { name?: string })?.name;
    return name === "HttpRequestError" || name === "TimeoutError";
  });
}

/**
 * Whether the address answers as a Safe on this chain: it has a threshold
 * and a list of owners. Anything else (no code, another contract) is not
 * one. A connection failure is not remembered, so the next look asks again.
 */
export function probeSafe(
  client: PublicClient,
  chainId: number,
  address: Address,
): Promise<boolean> {
  const key = `${chainId}:${address.toLowerCase()}`;
  const known = probes.get(key);
  if (known) return known;
  const probe = Promise.all([
    client.readContract({ address, abi: SAFE_ABI, functionName: "getThreshold" }),
    client.readContract({ address, abi: SAFE_ABI, functionName: "getOwners" }),
  ]).then(
    () => true,
    (error) => {
      if (isTransportError(error)) probes.delete(key);
      return false;
    },
  );
  probes.set(key, probe);
  return probe;
}

/** Forget every probe (tests). */
export function resetSafeProbes() {
  probes.clear();
}

/**
 * Whether a value is the address of a Safe, so the Safe reads can be
 * offered on it: an address typed in, an ENS name (resolved first, for
 * this chain), `@me` when the executor is a Safe, or a call that returns
 * an address. A call is judged by the address it returns NOW; it may
 * return another when the assertion runs, and the read is made against
 * that one. False until the chain has answered, so nothing is offered on
 * a guess.
 */
export function useIsSafe(node: ValueExpr, chainId: number): boolean {
  const client = useChainClient(chainId);
  const mainnetClient = usePublicClient({ chainId: 1 });
  const executorIsSafe = useContext(ExecutorIsSafe);
  const readAddress = useContext(CurrentAddress);
  const text = node.kind === "literal" ? node.value.trim() : "";
  const address = isAddress(text) ? (text as Address) : null;
  const name = !address && isEnsName(text) ? text : null;
  // The call as text: the same call is the same question.
  const call =
    readAddress && node.kind === "call" && inferCategory(node) === "address"
      ? JSON.stringify(node)
      : null;
  const [safe, setSafe] = useState<{ key: string; value: boolean } | null>(null);
  const key = address
    ? `${chainId}:${address.toLowerCase()}`
    : name
      ? `${chainId}:ens:${name.toLowerCase()}`
      : call
        ? `${chainId}:call:${call}`
        : null;

  useEffect(() => {
    if (!client || !key || !(address || name || call)) return;
    let current = true;
    const answer = (value: boolean) => {
      if (current) setSafe({ key, value });
    };
    if (address) {
      probeSafe(client, chainId, address).then(answer);
      return () => {
        current = false;
      };
    }
    const timer = setTimeout(async () => {
      const resolved = name
        ? await resolveEnsAddress(mainnetClient, name, chainId)
        : await (readAddress as AddressReader)(node).catch(() => null);
      if (!current) return;
      if (!resolved || !isAddress(resolved)) answer(false);
      else probeSafe(client, chainId, resolved as Address).then(answer);
    }, SETTLE_MS);
    return () => {
      current = false;
      clearTimeout(timer);
    };
    // `node` and the reader are covered by `key`: the call as text.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [client, mainnetClient, address, name, call, key, chainId]);

  if (text === "@me") return executorIsSafe;
  return !!key && safe?.key === key && safe.value;
}
