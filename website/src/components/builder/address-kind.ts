import type { AddressKind } from "./script-ops";

/**
 * Whether an address is an account or a contract: the one neutral thing
 * that can be read of an address nothing else names. Read once per chain
 * and address; a read that fails is not remembered and says nothing.
 */

/** The code of an account that only delegates to a contract (EIP-7702):
 *  still an account. */
const DELEGATION = /^0xef0100[0-9a-f]{40}$/i;

export const kindOfCode = (code: string | undefined | null): AddressKind =>
  !code || code === "0x" || DELEGATION.test(code) ? "account" : "contract";

export interface CodeReader {
  getCode: (args: { address: `0x${string}` }) => Promise<string | undefined>;
}

const kinds = new Map<string, Promise<AddressKind | undefined>>();

export function addressKind(
  client: CodeReader | undefined,
  chainId: number,
  address: string,
): Promise<AddressKind | undefined> {
  if (!client) return Promise.resolve(undefined);
  const key = `${chainId}:${address.toLowerCase()}`;
  let kind = kinds.get(key);
  if (!kind) {
    kind = (async () => client.getCode({ address: address as `0x${string}` }))()
      .then(kindOfCode)
      .catch(() => {
        kinds.delete(key);
        return undefined;
      });
    kinds.set(key, kind);
  }
  return kind;
}

/** Forget what was read (tests). */
export const resetAddressKinds = (): void => kinds.clear();
