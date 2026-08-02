import { useEffect, useState } from "react";
import type { Address, PublicClient } from "viem";
import { isAddress, parseAbi } from "viem";
import { normalize } from "viem/ens";
import { usePublicClient } from "wagmi";

import type { ContextKind } from "./context";

export type AddressCheck =
  | { state: "idle" }
  | { state: "resolving" }
  | { state: "checking" }
  | { state: "ok"; message: string }
  | { state: "error"; message: string };

const SAFE_ABI = parseAbi([
  "function getThreshold() view returns (uint256)",
  "function getOwners() view returns (address[])",
  "function VERSION() view returns (string)",
]);

const GOVERNOR_ABI = parseAbi([
  "function COUNTING_MODE() view returns (string)",
  "function name() view returns (string)",
]);

const TIMELOCK_ABI = parseAbi([
  "function getMinDelay() view returns (uint256)",
]);

const ARAGON_DAO_ABI = parseAbi([
  "function protocolVersion() view returns (uint8[3])",
  "function daoURI() view returns (string)",
]);

/** Probe the functions the selected execution path will call on the
 *  contract, so a wrong address fails here instead of at proposal time. */
async function probe(
  client: PublicClient,
  kind: ContextKind,
  address: Address,
): Promise<AddressCheck> {
  switch (kind) {
    case "safe": {
      try {
        const [threshold, owners] = await Promise.all([
          client.readContract({
            address,
            abi: SAFE_ABI,
            functionName: "getThreshold",
          }),
          client.readContract({
            address,
            abi: SAFE_ABI,
            functionName: "getOwners",
          }),
        ]);
        const version = await client
          .readContract({ address, abi: SAFE_ABI, functionName: "VERSION" })
          .catch(() => null);
        return {
          state: "ok",
          message: `Safe${version ? ` v${version}` : ""} — ${threshold}/${owners.length} owners`,
        };
      } catch {
        return { state: "error", message: "This address is not a Safe." };
      }
    }
    case "governor": {
      try {
        await client.readContract({
          address,
          abi: GOVERNOR_ABI,
          functionName: "COUNTING_MODE",
        });
        const name = await client
          .readContract({ address, abi: GOVERNOR_ABI, functionName: "name" })
          .catch(() => null);
        return {
          state: "ok",
          message: `Governor${name ? `: ${name}` : ""}`,
        };
      } catch {
        // A common mistake: pasting the timelock (the executor) instead of
        // the Governor (where proposals are created).
        const isTimelock = await client
          .readContract({
            address,
            abi: TIMELOCK_ABI,
            functionName: "getMinDelay",
          })
          .then(() => true)
          .catch(() => false);
        return {
          state: "error",
          message: isTimelock
            ? "This looks like a Timelock, not a Governor — proposals are created on the Governor contract."
            : "This address is not an OpenZeppelin Governor.",
        };
      }
    }
    case "aragonosx": {
      const version = await client
        .readContract({
          address,
          abi: ARAGON_DAO_ABI,
          functionName: "protocolVersion",
        })
        .catch(() => null);
      if (version)
        return {
          state: "ok",
          message: `Aragon OSx DAO v${version.join(".")}`,
        };
      // Pre-1.3 DAOs have no protocolVersion(); they do expose daoURI().
      const hasDaoUri = await client
        .readContract({ address, abi: ARAGON_DAO_ABI, functionName: "daoURI" })
        .then(() => true)
        .catch(() => false);
      if (hasDaoUri) return { state: "ok", message: "Aragon OSx DAO" };
      return {
        state: "error",
        message: "This address is not an Aragon OSx DAO.",
      };
    }
    default:
      return { state: "idle" };
  }
}

/**
 * Resolve the context address input (plain address or ENS name) and verify
 * that it holds the kind of contract the execution path expects — a Safe,
 * a Governor or an Aragon OSx DAO — on the current chain, by calling the
 * view functions that path relies on. RPC hiccups never block input.
 */
export function useContextAddress(
  chainId: number,
  kind: ContextKind,
  addressInput: string | undefined,
): { resolved: Address | null; check: AddressCheck } {
  const mainnetClient = usePublicClient({ chainId: 1 });
  const chainClient = usePublicClient({ chainId });
  const [resolved, setResolved] = useState<Address | null>(null);
  const [check, setCheck] = useState<AddressCheck>({ state: "idle" });

  useEffect(() => {
    const input = (addressInput ?? "").trim();
    setResolved(null);
    setCheck({ state: "idle" });
    if (kind === "eoa" || !input) return;

    const isPlain = isAddress(input);
    const isEns = !isPlain && input.includes(".");
    if (!isPlain && !isEns) return; // inline "not a valid address" handles it

    let cancelled = false;
    setCheck({ state: isEns ? "resolving" : "checking" });
    const timer = setTimeout(async () => {
      let address: Address | null = isPlain ? input : null;
      if (isEns) {
        try {
          address = ((await mainnetClient?.getEnsAddress({
            name: normalize(input),
          })) ?? null) as Address | null;
        } catch {
          address = null;
        }
        if (cancelled) return;
        if (!address) {
          setCheck({ state: "error", message: "ENS name did not resolve." });
          return;
        }
        setResolved(address);
      } else {
        setResolved(address);
      }
      if (!address || !chainClient) return;
      setCheck({ state: "checking" });
      try {
        const code = await chainClient.getCode({ address });
        if (cancelled) return;
        if (!code || code === "0x") {
          setCheck({
            state: "error",
            message: `No contract deployed at this address on ${chainClient.chain?.name ?? "this chain"}.`,
          });
          return;
        }
        const result = await probe(chainClient, kind, address);
        if (!cancelled) setCheck(result);
      } catch {
        // RPC hiccup — stay quiet rather than flag a valid address.
        if (!cancelled) setCheck({ state: "idle" });
      }
    }, 500);
    return () => {
      cancelled = true;
      clearTimeout(timer);
    };
  }, [chainId, kind, addressInput, mainnetClient, chainClient]);

  return { resolved, check };
}
