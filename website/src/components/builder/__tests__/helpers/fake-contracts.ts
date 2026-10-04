import { isAddress } from "viem";

import type * as Real from "../../useContractFunctions";

/**
 * Stands in for the verified-ABI lookup (`useContractFunctions`), which
 * needs an RPC for ENS and the Etherscan API: tests register the contracts
 * they need by address and the hook answers at once, with no network.
 */
interface FakeContract {
  /** The verified name, null for an unverified contract. */
  name: string | null;
  /** Human-readable ABI entries, as the sdk returns them. */
  abi: string[];
  /** What a name resolves to; defaults to the input itself. */
  resolved?: string;
}

const contracts = new Map<string, FakeContract>();

export function registerContract(input: string, contract: FakeContract) {
  contracts.set(input, contract);
}

export function clearContracts() {
  contracts.clear();
  answers.clear();
}

type Answer = ReturnType<typeof Real.useContractFunctions>;
const answers = new Map<string, Answer>();

/** The module the tests install with `vi.mock`: everything real except the
 *  hook that fetches. */
export function fakeContractFunctionsModule(real: typeof Real): typeof Real {
  return {
    ...real,
    useContractFunctions: (_chainId, addressInput, kind) => {
      const input = addressInput.trim();
      const key = `${input}|${kind}`;
      let answer = answers.get(key);
      if (!answer) {
        const contract = contracts.get(input);
        answer = contract
          ? {
              resolved: (contract.resolved ?? input) as Answer["resolved"],
              status:
                contract.name === null && contract.abi.length === 0
                  ? "No verified ABI found."
                  : null,
              functions: real.parseFunctions(contract.abi, kind),
              contractName: contract.name,
            }
          : {
              resolved: isAddress(input) ? input : null,
              status: null,
              functions: null,
              contractName: null,
            };
        answers.set(key, answer);
      }
      return answer;
    },
  };
}
