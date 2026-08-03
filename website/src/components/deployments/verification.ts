// Cross-chain Etherscan verification: fetches the verified source of the
// mainnet deployment and resubmits it to the target chain through the
// Etherscan V2 multichain API (one API key for every supported explorer).

import { mainnet } from "viem/chains";

import { DEPLOYED_CONTRACTS } from "./shared";

const V2_API = "https://api.etherscan.io/v2/api";

export type VerifyProgress =
  | "fetching-source"
  | "submitting"
  | "polling"
  | "verified"
  | "already-verified";

interface EtherscanResponse {
  status: string;
  message: string;
  result: unknown;
}

async function etherscanGet(
  chainId: number,
  apiKey: string,
  params: Record<string, string>,
): Promise<EtherscanResponse> {
  const url = new URL(V2_API);
  url.searchParams.set("chainid", String(chainId));
  url.searchParams.set("apikey", apiKey);
  for (const [key, value] of Object.entries(params)) {
    url.searchParams.set(key, value);
  }
  const response = await fetch(url);
  if (!response.ok) throw new Error(`Etherscan API HTTP ${response.status}`);
  return (await response.json()) as EtherscanResponse;
}

let supportedChainsPromise: Promise<Set<number>> | null = null;

/** Chain ids covered by the Etherscan V2 multichain API (cached, keyless). */
export function getEtherscanChains(): Promise<Set<number>> {
  supportedChainsPromise ??= (async () => {
    const response = await fetch("https://api.etherscan.io/v2/chainlist");
    if (!response.ok) throw new Error(`chainlist HTTP ${response.status}`);
    const data = (await response.json()) as {
      result: { chainid: string; status: number }[];
    };
    return new Set(data.result.map((c) => Number(c.chainid)));
  })();
  supportedChainsPromise.catch(() => {
    supportedChainsPromise = null;
  });
  return supportedChainsPromise;
}

/** True when the source of BOTH contracts is verified on the chain's explorer. */
export async function isContractVerified(
  chainId: number,
  apiKey: string,
): Promise<boolean> {
  for (const contract of DEPLOYED_CONTRACTS) {
    const response = await etherscanGet(chainId, apiKey, {
      module: "contract",
      action: "getabi",
      address: contract.address,
    });
    if (/missing\/invalid api key/i.test(String(response.result))) {
      throw new Error(String(response.result));
    }
    if (response.status !== "1") return false;
  }
  return true;
}

interface SourceInfo {
  SourceCode: string;
  ContractName: string;
  CompilerVersion: string;
  OptimizationUsed: string;
  Runs: string;
  EVMVersion: string;
  ConstructorArguments: string;
}

async function fetchMainnetSource(
  apiKey: string,
  address: string,
): Promise<SourceInfo> {
  const response = await etherscanGet(mainnet.id, apiKey, {
    module: "contract",
    action: "getsourcecode",
    address,
  });
  if (response.status !== "1") {
    throw new Error(`Could not fetch the mainnet source: ${String(response.result)}`);
  }
  const info = (response.result as SourceInfo[])[0];
  if (!info?.SourceCode) {
    throw new Error("The mainnet contract source is not verified on Etherscan.");
  }
  return info;
}

/** Builds the verifysourcecode form fields from the mainnet record. */
function buildVerificationFields(
  info: SourceInfo,
  address: string,
): Record<string, string> {
  const fields: Record<string, string> = {
    module: "contract",
    action: "verifysourcecode",
    contractaddress: address,
    compilerversion: info.CompilerVersion,
    constructorArguements: info.ConstructorArguments ?? "",
  };

  if (info.SourceCode.startsWith("{{")) {
    // Standard JSON input, wrapped by Etherscan in an extra pair of braces.
    const standardJson = info.SourceCode.slice(1, -1);
    fields.codeformat = "solidity-standard-json-input";
    fields.sourceCode = standardJson;
    fields.contractname = info.ContractName.includes(":")
      ? info.ContractName
      : deriveContractPath(standardJson, info.ContractName);
  } else {
    fields.codeformat = "solidity-singlefile";
    fields.sourceCode = info.SourceCode;
    fields.contractname = info.ContractName;
    fields.optimizationUsed = info.OptimizationUsed || "0";
    fields.runs = info.Runs || "200";
    if (info.EVMVersion && info.EVMVersion.toLowerCase() !== "default") {
      fields.evmversion = info.EVMVersion;
    }
  }
  return fields;
}

function deriveContractPath(standardJson: string, contractName: string): string {
  try {
    const parsed = JSON.parse(standardJson) as {
      sources: Record<string, unknown>;
    };
    const paths = Object.keys(parsed.sources);
    const match =
      paths.find((p) => p.endsWith(`/${contractName}.sol`)) ??
      paths.find((p) => p === `${contractName}.sol`) ??
      paths[0];
    return `${match}:${contractName}`;
  } catch {
    return `contracts/${contractName}.sol:${contractName}`;
  }
}

const sleep = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));

/** Replays one contract's mainnet verification on the target chain. */
async function verifyOneFromMainnet(
  targetChainId: number,
  apiKey: string,
  address: string,
  contractLabel: string,
  onProgress: (step: VerifyProgress) => void,
): Promise<"verified" | "already-verified"> {
  onProgress("fetching-source");
  const info = await fetchMainnetSource(apiKey, address);

  onProgress("submitting");
  const url = new URL(V2_API);
  url.searchParams.set("chainid", String(targetChainId));
  url.searchParams.set("apikey", apiKey);
  const body = new URLSearchParams(buildVerificationFields(info, address));
  const submitResponse = await fetch(url, { method: "POST", body });
  if (!submitResponse.ok) {
    throw new Error(`Etherscan API HTTP ${submitResponse.status}`);
  }
  const submitted = (await submitResponse.json()) as EtherscanResponse;
  const submitResult = String(submitted.result);
  if (submitted.status !== "1") {
    if (/already verified/i.test(submitResult)) return "already-verified";
    throw new Error(
      `Verification submission failed for ${contractLabel}: ${submitResult}`,
    );
  }

  onProgress("polling");
  const guid = submitResult;
  for (let attempt = 0; attempt < 30; attempt++) {
    await sleep(4000);
    const check = await etherscanGet(targetChainId, apiKey, {
      module: "contract",
      action: "checkverifystatus",
      guid,
    });
    const result = String(check.result);
    if (/^pass/i.test(result)) return "verified";
    if (/already verified/i.test(result)) return "already-verified";
    if (/^fail/i.test(result)) {
      throw new Error(`Verification failed for ${contractLabel}: ${result}`);
    }
    // "Pending in queue" / "Unable to locate ContractCode" — keep polling
    // while the explorer indexes the freshly deployed bytecode.
  }
  throw new Error(
    `Verification of ${contractLabel} timed out — it may still complete; ` +
      "check the explorer in a few minutes.",
  );
}

/**
 * Verifies BOTH contracts (Assertions + Combinators) on the target chain by replaying
 * their mainnet verifications. Resolves with "already-verified" only when
 * every contract was already verified, "verified" otherwise; throws on failure.
 */
export async function verifyFromMainnet(
  targetChainId: number,
  apiKey: string,
  onProgress: (step: VerifyProgress) => void,
): Promise<"verified" | "already-verified"> {
  let allAlready = true;
  for (const contract of DEPLOYED_CONTRACTS) {
    const result = await verifyOneFromMainnet(
      targetChainId,
      apiKey,
      contract.address,
      contract.name,
      onProgress,
    );
    if (result !== "already-verified") allAlready = false;
  }
  return allAlready ? "already-verified" : "verified";
}
