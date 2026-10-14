import { fetchVerifiedContract } from "@evmcrispr/sdk";
import { useContext, useEffect, useMemo, useState } from "react";
import { type Address, getAddress, isAddress } from "viem";
import { normalize } from "viem/ens";
import { WagmiContext } from "wagmi";
import { getPublicClient } from "wagmi/actions";
import { nameKey } from "./suggested-checks";
import { ensCoinType, resolveEnsAddress } from "./useContractFunctions";

/**
 * A name for an address that the address itself does not get to choose
 * alone. Shown beside the shortened address, never instead of it:
 * - `ens`: the ENS primary name the address set, kept only when that name
 *   resolves back to the same address on this chain. Anyone can register
 *   a name that looks like another.
 * - `verified`: the contract name published with its verified source on
 *   the chain's explorer. The source matches the code; the name is the
 *   deployer's word.
 */
export interface AddressName {
  name: string;
  source: "ens" | "verified";
}

/** What a published contract name may look like to be shown. */
const CONTRACT_NAME = /^[A-Za-z_$][A-Za-z0-9_$]{0,39}$/;
/** Long enough for real ENS names, short enough to stay a label. */
const MAX_ENS_LENGTH = 40;

type EnsClient = {
  getEnsName: (args: {
    address: Address;
    coinType?: bigint;
  }) => Promise<string | null>;
  getEnsAddress: (args: any) => Promise<string | null>;
};

/** The ENS primary name of `address` on `chainId`, when it resolves back. */
export async function ensName(
  client: EnsClient | undefined,
  address: Address,
  chainId: number,
): Promise<string | null> {
  if (!client) return null;
  const coinType = ensCoinType(chainId);
  let name: string | null = null;
  try {
    name = await client.getEnsName({
      address,
      ...(coinType !== undefined ? { coinType } : {}),
    });
  } catch {
    return null;
  }
  if (!name || name.length > MAX_ENS_LENGTH) return null;
  // Only a name in its normalized form: another form of it can look alike
  // and resolve elsewhere.
  try {
    if (normalize(name) !== name) return null;
  } catch {
    return null;
  }
  const back = await resolveEnsAddress(client, name, chainId);
  return back && getAddress(back) === getAddress(address) ? name : null;
}

type CodeClient = { getCode: (args: { address: Address }) => Promise<string | undefined> };

/** Whether `address` holds code; undefined when that could not be read. An
 *  account that only delegates (EIP-7702) holds no contract of its own. */
async function hasCode(
  client: CodeClient | undefined,
  address: Address,
): Promise<boolean | undefined> {
  if (!client) return undefined;
  try {
    const code = await client.getCode({ address });
    return !!code && code !== "0x" && !/^0xef0100/i.test(code);
  } catch {
    return undefined;
  }
}

/** The contract name published with the verified source of `address`.
 *  An account without code has none, so the explorer is not asked: its
 *  free tier answers a few requests a second, and a batch names many
 *  plain accounts. */
export async function verifiedName(
  address: Address,
  chainId: number,
  client?: CodeClient,
): Promise<string | null> {
  if ((await hasCode(client, address)) === false) return null;
  const info = await fetchVerifiedContract(chainId, address).catch(() => null);
  const name = info?.name?.trim();
  return name && CONTRACT_NAME.test(name) ? name : null;
}

/** An ENS name that resolves back, else a verified contract name. */
export async function lookupAddressName(
  client: EnsClient | undefined,
  address: Address,
  chainId: number,
  chainClient?: CodeClient,
): Promise<AddressName | null> {
  const ens = await ensName(client, address, chainId);
  if (ens) return { name: ens, source: "ens" };
  const verified = await verifiedName(address, chainId, chainClient);
  return verified ? { name: verified, source: "verified" } : null;
}

// Asked once per chain and address for the page's life: a check's rows
// render again on every edit, and the answer does not change with them.
const asked = new Map<string, Promise<AddressName | null>>();

/**
 * The names of `addresses` on `chainId`, by `nameKey`, as they arrive. An address without one is simply not in the map; nothing waits
 * for a lookup to draw the rows.
 */
export function useAddressNames(
  addresses: readonly string[],
  chainId: number,
): ReadonlyMap<string, AddressName> {
  // Outside the app's wallet provider (a test, a page without one) nothing
  // is looked up: the rows keep their addresses.
  const config = useContext(WagmiContext);
  const client = useMemo(
    () =>
      config
        ? (getPublicClient(config, { chainId: 1 } as never) as unknown as
            | EnsClient
            | undefined)
        : undefined,
    [config],
  );
  const key = useMemo(
    () =>
      [...new Set(addresses.filter((a) => isAddress(a)).map((a) => a.toLowerCase()))]
        .sort()
        .join(","),
    [addresses],
  );
  const [names, setNames] = useState<ReadonlyMap<string, AddressName>>(
    () => new Map(),
  );
  useEffect(() => {
    if (!config) return;
    let live = true;
    const wanted = key ? key.split(",") : [];
    for (const lower of wanted) {
      // Without the mainnet client no ENS name could be asked: that answer
      // is not kept for when it is there.
      const id = `${nameKey(chainId, lower)}:${client ? "ens" : "no-ens"}`;
      let answer = asked.get(id);
      if (!answer) {
        const chainClient = config
          ? (getPublicClient(config, { chainId } as never) as unknown as
              | CodeClient
              | undefined)
          : undefined;
        answer = lookupAddressName(
          client,
          getAddress(lower),
          chainId,
          chainClient,
        ).catch(() => null);
        asked.set(id, answer);
      }
      void answer.then((found) => {
        if (!live || !found) return;
        setNames((now) => {
          const at = nameKey(chainId, lower);
          if (now.get(at)?.name === found.name) return now;
          const next = new Map(now);
          next.set(at, found);
          return next;
        });
      });
    }
    return () => {
      live = false;
    };
  }, [key, chainId, client, config]);
  return names;
}
