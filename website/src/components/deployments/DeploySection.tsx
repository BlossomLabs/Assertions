import { useQuery } from "@tanstack/react-query";
import { useEffect, useMemo, useRef, useState } from "react";
import type { Chain, EIP1193Provider } from "viem";
import { concat, createWalletClient, custom, defineChain, numberToHex } from "viem";
import { useAccount, useConnect, useDisconnect, useSwitchChain } from "wagmi";

import {
  CREATE2_PROXY,
  CREATE2_PROXY_DEPLOY_COST,
  CREATE2_PROXY_DEPLOY_TX,
  CREATE2_PROXY_DEPLOYER,
} from "../../lib/assertions-deployment";
import {
  DEPLOYED_CONTRACTS,
  explorerAddressUrl,
  explorerTxUrl,
  makePublicClient,
  shortAddress,
} from "./shared";
import {
  getEtherscanChains,
  isContractVerified,
  verifyContracts,
  type VerifyProgress,
} from "./verification";
import { ALL_CHAINS, chainById } from "./wagmi";

const inputCls =
  "w-full px-3 py-2 rounded-lg bg-[var(--color-surface)] border border-[var(--color-ink-3)]/30 " +
  "focus:border-[var(--color-bp-400)] focus:outline-none font-mono text-sm placeholder:text-[var(--color-ink-3)]";

const primaryBtnCls =
  "px-4 py-2 rounded-lg text-sm font-medium bg-[var(--color-primary)] text-[var(--color-primary-fg)] " +
  "hover:bg-[var(--color-primary-hover)] disabled:opacity-40 disabled:cursor-not-allowed transition-colors";

type DeployState =
  | { step: "idle" }
  | { step: "switching" }
  | { step: "sending"; contract: string }
  | { step: "confirming"; contract: string; hash: `0x${string}` }
  | { step: "success"; hashes: `0x${string}`[] }
  | { step: "error"; message: string };

type BootstrapState =
  | { step: "idle" }
  | { step: "funding" }
  | { step: "broadcasting" }
  | { step: "error"; message: string };

type VerifyState =
  | { step: "idle" }
  | { step: "running"; progress: VerifyProgress }
  | { step: "verified"; already: boolean }
  | { step: "error"; message: string };

const VERIFY_PROGRESS_LABELS: Record<VerifyProgress, string> = {
  submitting: "Submitting the source to the explorer…",
  polling: "Waiting for the explorer to verify…",
  verified: "Verified",
  "already-verified": "Already verified",
};

const API_KEY_STORAGE = "assertions:etherscan-api-key";

function errorMessage(error: unknown): string {
  if (error && typeof error === "object") {
    const err = error as { shortMessage?: string; message?: string };
    return err.shortMessage ?? err.message ?? String(error);
  }
  return String(error);
}

function ChainPicker({
  chain,
  onChange,
}: {
  chain: Chain;
  onChange: (chain: Chain) => void;
}) {
  const [search, setSearch] = useState("");
  const [open, setOpen] = useState(false);
  const blurTimeout = useRef<ReturnType<typeof setTimeout>>(undefined);

  const filtered = useMemo(() => {
    const q = search.trim().toLowerCase();
    if (!q) return ALL_CHAINS;
    return ALL_CHAINS.filter(
      (c) => c.name.toLowerCase().includes(q) || String(c.id).startsWith(q),
    );
  }, [search]);

  return (
    <div className="relative">
      <input
        className={inputCls}
        placeholder={`Search ${ALL_CHAINS.length} networks by name or chain ID…`}
        value={open ? search : `${chain.name} (${chain.id})`}
        onFocus={() => {
          clearTimeout(blurTimeout.current);
          setSearch("");
          setOpen(true);
        }}
        onBlur={() => {
          blurTimeout.current = setTimeout(() => setOpen(false), 150);
        }}
        onChange={(e) => setSearch(e.target.value)}
        spellCheck={false}
      />
      {open && (
        <ul className="absolute z-20 mt-1 w-full max-h-72 overflow-y-auto rounded-lg border border-[var(--color-ink-3)]/30 bg-[var(--color-surface)] shadow-xl">
          {filtered.length === 0 && (
            <li className="px-3 py-2 text-sm text-[var(--color-ink-3)]">
              No known network matches — add it as a custom network below.
            </li>
          )}
          {filtered.slice(0, 80).map((c) => (
            <li key={c.id}>
              <button
                type="button"
                onMouseDown={(e) => e.preventDefault()}
                onClick={() => {
                  onChange(c);
                  setOpen(false);
                }}
                className={`w-full text-left px-3 py-2 text-sm hover:bg-[var(--color-bp-500)]/10 flex items-baseline justify-between gap-3 ${
                  c.id === chain.id ? "text-[var(--color-bp-300)]" : ""
                }`}
              >
                <span>
                  {c.name}
                  {c.testnet && (
                    <span className="ml-2 text-[10px] uppercase tracking-wide text-[var(--color-ink-3)]">
                      testnet
                    </span>
                  )}
                </span>
                <span className="font-mono text-xs text-[var(--color-ink-3)]">
                  {c.id}
                </span>
              </button>
            </li>
          ))}
          {filtered.length > 80 && (
            <li className="px-3 py-2 text-xs text-[var(--color-ink-3)]">
              {filtered.length - 80} more — keep typing to narrow down.
            </li>
          )}
        </ul>
      )}
    </div>
  );
}

function CustomChainForm({ onSubmit }: { onSubmit: (chain: Chain) => void }) {
  const [id, setId] = useState("");
  const [name, setName] = useState("");
  const [rpcUrl, setRpcUrl] = useState("");
  const [symbol, setSymbol] = useState("ETH");

  const chainId = Number(id);
  const valid =
    Number.isInteger(chainId) &&
    chainId > 0 &&
    name.trim().length > 0 &&
    /^https?:\/\/.+/.test(rpcUrl.trim());

  return (
    <div className="space-y-3 rounded-lg border border-[var(--color-ink-3)]/20 p-4">
      <div className="grid sm:grid-cols-2 gap-3">
        <div>
          <label className="block text-xs text-[var(--color-ink-2)] mb-1">
            Chain ID
          </label>
          <input
            className={inputCls}
            placeholder="e.g. 747474"
            value={id}
            onChange={(e) => setId(e.target.value.trim())}
            inputMode="numeric"
          />
        </div>
        <div>
          <label className="block text-xs text-[var(--color-ink-2)] mb-1">
            Name
          </label>
          <input
            className={inputCls}
            placeholder="My Network"
            value={name}
            onChange={(e) => setName(e.target.value)}
          />
        </div>
      </div>
      <div className="grid sm:grid-cols-[1fr_8rem] gap-3">
        <div>
          <label className="block text-xs text-[var(--color-ink-2)] mb-1">
            RPC URL
          </label>
          <input
            className={inputCls}
            placeholder="https://rpc.example.org"
            value={rpcUrl}
            onChange={(e) => setRpcUrl(e.target.value.trim())}
            spellCheck={false}
          />
        </div>
        <div>
          <label className="block text-xs text-[var(--color-ink-2)] mb-1">
            Currency
          </label>
          <input
            className={inputCls}
            value={symbol}
            onChange={(e) => setSymbol(e.target.value.trim() || "ETH")}
          />
        </div>
      </div>
      <button
        type="button"
        disabled={!valid}
        onClick={() => {
          const existing = chainById(chainId);
          onSubmit(
            defineChain({
              id: chainId,
              name: name.trim(),
              nativeCurrency: {
                name: symbol,
                symbol,
                decimals: 18,
              },
              rpcUrls: { default: { http: [rpcUrl.trim()] } },
              blockExplorers: existing?.blockExplorers,
            }),
          );
        }}
        className="px-3 py-1.5 rounded-lg text-sm font-medium border border-[var(--color-bp-400)] text-[var(--color-bp-300)] hover:bg-[var(--color-bp-500)]/10 disabled:opacity-40 disabled:cursor-not-allowed transition-colors"
      >
        Use this network
      </button>
    </div>
  );
}

export function DeploySection({
  chain,
  onChainChange,
}: {
  chain: Chain;
  onChainChange: (chain: Chain) => void;
}) {
  const { address, isConnected, chainId: walletChainId, connector } =
    useAccount();
  const { connect, connectors, isPending: connectPending } = useConnect();
  const { disconnect } = useDisconnect();
  const { switchChainAsync } = useSwitchChain();

  const [showCustom, setShowCustom] = useState(false);
  const [deployState, setDeployState] = useState<DeployState>({
    step: "idle",
  });
  const [bootstrapState, setBootstrapState] = useState<BootstrapState>({
    step: "idle",
  });
  const [apiKey, setApiKey] = useState(
    () => localStorage.getItem(API_KEY_STORAGE) ?? "",
  );
  const [verifyState, setVerifyState] = useState<VerifyState>({
    step: "idle",
  });

  const injected =
    connectors.find((c) => c.id === "injected") ?? connectors[0];
  const isKnownChain = chainById(chain.id) !== undefined;

  useEffect(() => {
    setDeployState({ step: "idle" });
    setBootstrapState({ step: "idle" });
    setVerifyState({ step: "idle" });
  }, [chain.id]);

  const etherscanChains = useQuery({
    queryKey: ["etherscan-chains"],
    queryFn: getEtherscanChains,
    staleTime: Infinity,
    retry: 1,
  });
  const etherscanSupported = etherscanChains.data?.has(chain.id) ?? false;

  const status = useQuery({
    queryKey: ["deployment-status", chain.id, chain.rpcUrls.default.http[0]],
    queryFn: async () => {
      const client = makePublicClient(chain);
      const [proxyCode, ...contractCodes] = await Promise.all([
        client.getCode({ address: CREATE2_PROXY }),
        ...DEPLOYED_CONTRACTS.map((contract) =>
          client.getCode({ address: contract.address }),
        ),
      ]);
      const deployed = contractCodes.map(
        (code) => code !== undefined && code !== "0x",
      );
      return {
        deployed,
        allDeployed: deployed.every(Boolean),
        anyMissing: deployed.some((d) => !d),
        proxyPresent: proxyCode !== undefined && proxyCode !== "0x",
      };
    },
    retry: 1,
  });

  const isDeployedNow =
    status.data?.allDeployed === true || deployState.step === "success";

  // With an API key we can pre-check verification and skip the whole panel
  // when the source is already verified on the target explorer.
  const verifiedStatus = useQuery({
    queryKey: ["verified-status", chain.id],
    queryFn: () => isContractVerified(chain.id, apiKey),
    enabled: Boolean(apiKey) && etherscanSupported && isDeployedNow,
    staleTime: 60_000,
    retry: 1,
  });

  async function getWalletClient() {
    if (!connector || !address) throw new Error("Wallet not connected");
    const provider = (await connector.getProvider()) as EIP1193Provider;
    return createWalletClient({
      account: address,
      chain,
      transport: custom(provider),
    });
  }

  async function ensureWalletOnChain() {
    if (walletChainId === chain.id) return;
    if (isKnownChain) {
      await switchChainAsync({ chainId: chain.id });
      return;
    }
    // Custom chain: register it with the wallet, then switch.
    if (!connector) throw new Error("Wallet not connected");
    const provider = (await connector.getProvider()) as EIP1193Provider;
    const hexId = numberToHex(chain.id);
    try {
      await provider.request({
        method: "wallet_switchEthereumChain",
        params: [{ chainId: hexId }],
      });
    } catch {
      await provider.request({
        method: "wallet_addEthereumChain",
        params: [
          {
            chainId: hexId,
            chainName: chain.name,
            nativeCurrency: chain.nativeCurrency,
            rpcUrls: chain.rpcUrls.default.http as string[],
          },
        ],
      });
    }
  }

  function saveApiKey(value: string) {
    setApiKey(value);
    try {
      if (value) localStorage.setItem(API_KEY_STORAGE, value);
      else localStorage.removeItem(API_KEY_STORAGE);
    } catch {
      // Storage may be unavailable (private mode); the key still works in-memory.
    }
  }

  async function runVerification(key = apiKey) {
    if (!key) return;
    try {
      const result = await verifyContracts(chain.id, key, (progress) =>
        setVerifyState({ step: "running", progress }),
      );
      setVerifyState({
        step: "verified",
        already: result === "already-verified",
      });
      void verifiedStatus.refetch();
    } catch (error) {
      setVerifyState({ step: "error", message: errorMessage(error) });
    }
  }

  async function deploy() {
    try {
      setDeployState({ step: "switching" });
      await ensureWalletOnChain();
      const client = makePublicClient(chain);
      const walletClient = await getWalletClient();
      const hashes: `0x${string}`[] = [];
      for (const contract of DEPLOYED_CONTRACTS) {
        // Guard against a stale status check: never send a deployment that is
        // guaranteed to be a no-op because the contract already exists.
        const existing = await client.getCode({ address: contract.address });
        if (existing !== undefined && existing !== "0x") continue;
        setDeployState({ step: "sending", contract: contract.name });
        const hash = await walletClient.sendTransaction({
          to: CREATE2_PROXY,
          data: concat([contract.salt, contract.bytecode]),
        });
        setDeployState({
          step: "confirming",
          contract: contract.name,
          hash,
        });
        const receipt = await client.waitForTransactionReceipt({
          hash,
          timeout: 300_000,
        });
        if (receipt.status !== "success") {
          throw new Error(
            `The ${contract.name} deployment transaction reverted.`,
          );
        }
        const code = await client.getCode({ address: contract.address });
        if (code === undefined || code === "0x") {
          throw new Error(
            `The ${contract.name} transaction succeeded but no code was ` +
              "found at the expected address.",
          );
        }
        hashes.push(hash);
      }
      setDeployState({ step: "success", hashes });
      void status.refetch();
      // Kick off source verification right away if an API key is available.
      if (apiKey && etherscanSupported) void runVerification();
    } catch (error) {
      setDeployState({ step: "error", message: errorMessage(error) });
    }
  }

  async function bootstrapFactory() {
    try {
      const client = makePublicClient(chain);
      await ensureWalletOnChain();
      const balance = await client.getBalance({
        address: CREATE2_PROXY_DEPLOYER,
      });
      if (balance < CREATE2_PROXY_DEPLOY_COST) {
        setBootstrapState({ step: "funding" });
        const walletClient = await getWalletClient();
        const fundHash = await walletClient.sendTransaction({
          to: CREATE2_PROXY_DEPLOYER,
          value: CREATE2_PROXY_DEPLOY_COST - balance,
        });
        await client.waitForTransactionReceipt({
          hash: fundHash,
          timeout: 300_000,
        });
      }
      setBootstrapState({ step: "broadcasting" });
      const hash = await client.sendRawTransaction({
        serializedTransaction: CREATE2_PROXY_DEPLOY_TX,
      });
      await client.waitForTransactionReceipt({ hash, timeout: 300_000 });
      setBootstrapState({ step: "idle" });
      void status.refetch();
    } catch (error) {
      setBootstrapState({ step: "error", message: errorMessage(error) });
    }
  }

  const deploying =
    deployState.step === "switching" ||
    deployState.step === "sending" ||
    deployState.step === "confirming";
  const bootstrapping =
    bootstrapState.step === "funding" ||
    bootstrapState.step === "broadcasting";
  const explorer = explorerAddressUrl(chain);

  return (
    <div className="rounded-2xl border border-[var(--color-ink-3)]/20 bg-[var(--color-surface-2)] p-6 space-y-6">
      <h2 className="font-mono font-semibold">Deploy to a new network</h2>

      {/* Wallet */}
      <div className="flex items-center justify-between gap-4 flex-wrap">
        {isConnected && address ? (
          <div className="flex items-center gap-3">
            <span className="size-2 rounded-full bg-[var(--color-ok)]" />
            <span className="font-mono text-sm">{shortAddress(address)}</span>
            {walletChainId !== undefined && (
              <span className="text-xs px-2 py-0.5 rounded-full border border-[var(--color-ink-3)]/30 text-[var(--color-ink-2)]">
                {chainById(walletChainId)?.name ?? `chain ${walletChainId}`}
              </span>
            )}
            <button
              type="button"
              onClick={() => disconnect()}
              className="text-xs text-[var(--color-ink-3)] hover:text-[var(--color-err)] transition-colors"
            >
              Disconnect
            </button>
          </div>
        ) : (
          <button
            type="button"
            disabled={connectPending || !injected}
            onClick={() => injected && connect({ connector: injected })}
            className={primaryBtnCls}
          >
            {connectPending ? "Connecting…" : "Connect wallet"}
          </button>
        )}
      </div>

      {/* Network selection */}
      <div className="space-y-3">
        <label className="block text-sm text-[var(--color-ink-2)]">
          Target network
        </label>
        <ChainPicker chain={chain} onChange={onChainChange} />
        <div className="flex items-center gap-4 flex-wrap text-xs">
          <button
            type="button"
            onClick={() => setShowCustom((v) => !v)}
            className="text-[var(--color-bp-300)] hover:underline"
          >
            {showCustom ? "Hide custom network" : "Can't find your network? Add it with an RPC URL"}
          </button>
        </div>
        {showCustom && (
          <CustomChainForm
            onSubmit={(customChain) => {
              onChainChange(customChain);
              setShowCustom(false);
            }}
          />
        )}
        <div>
          <label className="block text-xs text-[var(--color-ink-3)] mb-1">
            Etherscan API key{" "}
            <span>(optional — verifies the source automatically after deploying)</span>
          </label>
          <input
            className={inputCls}
            type="password"
            placeholder="One key works on every Etherscan-family explorer"
            value={apiKey}
            onChange={(e) => saveApiKey(e.target.value.trim())}
            spellCheck={false}
            autoComplete="off"
          />
        </div>
      </div>

      {/* Status */}
      <div className="space-y-4">
        {status.isPending && (
          <p className="text-sm text-[var(--color-ink-3)]">
            Checking {chain.name}…
          </p>
        )}
        {status.isError && (
          <div className="rounded-lg border border-[var(--color-err)]/40 bg-[var(--color-err)]/5 px-4 py-3 text-sm">
            <p className="text-[var(--color-err)]">
              Could not reach an RPC for {chain.name}:{" "}
              {errorMessage(status.error)}
            </p>
            <p className="text-[var(--color-ink-3)] mt-1 text-xs">
              Try re-adding the network as a custom network with a working RPC
              URL.
            </p>
          </div>
        )}

        {status.data?.allDeployed && (
          <div className="rounded-lg border border-[var(--color-ok)]/40 bg-[var(--color-ok)]/5 px-4 py-3 text-sm">
            <p className="text-[var(--color-ok)] font-medium">
              Both contracts are already deployed on {chain.name}.
            </p>
            {DEPLOYED_CONTRACTS.map((contract) => {
              const url = explorerAddressUrl(chain, contract.address);
              return (
                <p key={contract.key} className="font-mono text-xs mt-1">
                  <span className="text-[var(--color-ink-3)]">
                    {contract.name}:{" "}
                  </span>
                  {url ? (
                    <a
                      href={url}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="text-[var(--color-bp-300)] hover:underline"
                    >
                      {contract.address} ↗
                    </a>
                  ) : (
                    contract.address
                  )}
                </p>
              );
            })}
          </div>
        )}

        {status.data && status.data.anyMissing && !status.data.proxyPresent && (
          <div className="rounded-lg border border-[var(--color-warn,#b58900)]/40 bg-[var(--color-bp-500)]/5 px-4 py-3 text-sm space-y-2">
            <p className="font-medium">
              The CREATE2 factory is missing on {chain.name}.
            </p>
            <p className="text-[var(--color-ink-2)] text-xs leading-relaxed">
              Deterministic deployment relies on the{" "}
              <a
                href="https://github.com/Arachnid/deterministic-deployment-proxy"
                target="_blank"
                rel="noopener noreferrer"
                className="text-[var(--color-bp-300)] hover:underline"
              >
                deterministic deployment proxy
              </a>{" "}
              at{" "}
              <span className="font-mono">{shortAddress(CREATE2_PROXY)}</span>.
              It can be installed permissionlessly: fund its one-time deployer
              with 0.01 {chain.nativeCurrency.symbol} and broadcast a presigned
              transaction.
            </p>
            <button
              type="button"
              disabled={!isConnected || bootstrapping}
              onClick={() => void bootstrapFactory()}
              className={primaryBtnCls}
            >
              {bootstrapState.step === "funding"
                ? "Funding the deployer…"
                : bootstrapState.step === "broadcasting"
                  ? "Broadcasting the factory deployment…"
                  : `Install the factory (0.01 ${chain.nativeCurrency.symbol})`}
            </button>
            {bootstrapState.step === "error" && (
              <p className="text-xs text-[var(--color-err)]">
                {bootstrapState.message}
              </p>
            )}
          </div>
        )}

        {status.data && status.data.anyMissing && status.data.proxyPresent && (
          <div className="space-y-3">
            <p className="text-sm text-[var(--color-ink-2)]">
              Ready to deploy to{" "}
              <span className="font-medium">{chain.name}</span>. One
              transaction per missing contract:
            </p>
            <ul className="text-xs space-y-1">
              {DEPLOYED_CONTRACTS.map((contract, i) => (
                <li key={contract.key} className="flex items-baseline gap-2">
                  {status.data.deployed[i] ? (
                    <span className="text-[var(--color-ok)]">✓</span>
                  ) : (
                    <span className="text-[var(--color-ink-3)]">•</span>
                  )}
                  <span>
                    {contract.name} ({contract.gasLabel} gas) at{" "}
                    <span className="font-mono">{contract.address}</span>
                    {status.data.deployed[i] && (
                      <span className="text-[var(--color-ok)]"> — deployed</span>
                    )}
                  </span>
                </li>
              ))}
            </ul>
            <button
              type="button"
              disabled={!isConnected || deploying}
              onClick={() => void deploy()}
              className={primaryBtnCls}
            >
              {deployState.step === "switching"
                ? "Switching network…"
                : deployState.step === "sending"
                  ? `Confirm ${deployState.contract} in your wallet…`
                  : deployState.step === "confirming"
                    ? `Waiting for ${deployState.contract} confirmation…`
                    : `Deploy to ${chain.name}`}
            </button>
            {!isConnected && (
              <p className="text-xs text-[var(--color-ink-3)]">
                Connect a wallet to deploy.
              </p>
            )}
          </div>
        )}

        {deployState.step === "success" && (
          <div className="rounded-lg border border-[var(--color-ok)]/40 bg-[var(--color-ok)]/5 px-4 py-3 text-sm">
            <p className="text-[var(--color-ok)] font-medium">
              Deployed! Assertions and Combinators now live on {chain.name}:
            </p>
            {DEPLOYED_CONTRACTS.map((contract) => (
              <p key={contract.key} className="font-mono text-xs mt-1">
                <span className="text-[var(--color-ink-3)]">
                  {contract.name}:{" "}
                </span>
                {contract.address}
              </p>
            ))}
            {deployState.hashes.map((hash) => {
              const tx = explorerTxUrl(chain, hash);
              return (
                <p key={hash} className="font-mono text-xs mt-1">
                  {tx ? (
                    <a
                      href={tx}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="text-[var(--color-bp-300)] hover:underline"
                    >
                      {shortAddress(hash)} ↗
                    </a>
                  ) : (
                    hash
                  )}
                </p>
              );
            })}
          </div>
        )}

        {deployState.step === "error" && (
          <div className="rounded-lg border border-[var(--color-err)]/40 bg-[var(--color-err)]/5 px-4 py-3 text-sm">
            <p className="text-[var(--color-err)]">{deployState.message}</p>
            <button
              type="button"
              onClick={() => setDeployState({ step: "idle" })}
              className="text-xs text-[var(--color-ink-3)] hover:underline mt-1"
            >
              Dismiss
            </button>
          </div>
        )}

        {/* Source verification: only offered once an API key is entered, and
            hidden when the pre-check shows the source is already verified. */}
        {isDeployedNow &&
          Boolean(apiKey) &&
          !(
            verifyState.step === "idle" &&
            etherscanSupported &&
            (verifiedStatus.isPending || verifiedStatus.data === true)
          ) && (
          <div className="rounded-lg border border-[var(--color-ink-3)]/20 px-4 py-3 text-sm space-y-2">
            <p className="font-medium">Source verification</p>
            {!etherscanSupported ? (
              <p className="text-xs text-[var(--color-ink-3)]">
                {etherscanChains.isPending
                  ? "Checking explorer support…"
                  : `The Etherscan API does not cover ${chain.name}, so the source can't be verified from here.`}
              </p>
            ) : verifyState.step === "verified" ? (
              <p className="text-[var(--color-ok)]">
                {verifyState.already
                  ? "The source is already verified on the explorer."
                  : "Source verified."}{" "}
                {explorer && (
                  <a
                    href={`${explorer}#code`}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="text-[var(--color-bp-300)] hover:underline"
                  >
                    View the code ↗
                  </a>
                )}
              </p>
            ) : verifyState.step === "running" ? (
              <p className="text-xs text-[var(--color-ink-2)]">
                {VERIFY_PROGRESS_LABELS[verifyState.progress]}
              </p>
            ) : (
              <div className="space-y-2">
                <p className="text-xs text-[var(--color-ink-3)] leading-relaxed">
                  Submits the compiler input bundled with this site to the
                  chain's explorer.
                </p>
                <button
                  type="button"
                  onClick={() => void runVerification()}
                  className="px-3 py-1.5 rounded-lg text-sm font-medium border border-[var(--color-bp-400)] text-[var(--color-bp-300)] hover:bg-[var(--color-bp-500)]/10 disabled:opacity-40 disabled:cursor-not-allowed transition-colors"
                >
                  Verify the source
                </button>
                {verifyState.step === "error" && (
                  <p className="text-xs text-[var(--color-err)]">
                    {verifyState.message}
                  </p>
                )}
              </div>
            )}
          </div>
        )}
      </div>
    </div>
  );
}
