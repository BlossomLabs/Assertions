import { useQuery } from "@tanstack/react-query";
import { useEffect, useMemo, useRef, useState, type ReactNode } from "react";
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
import { ChainIcon } from "../ui/ChainIcon";
import { WalletIcon } from "../ui/ExecutorIcon";
import { ALL_CHAINS, chainById } from "./wagmi";

const inputCls =
  "w-full px-3 py-2 rounded bg-[var(--color-surface)] border border-[var(--color-ink-3)]/40 " +
  "focus:border-[var(--color-bp-400)] focus:outline-none text-sm placeholder:text-[var(--color-ink-3)]";

const primaryBtnCls =
  "px-4 py-2 rounded text-sm font-semibold bg-[var(--color-primary)] text-[var(--color-primary-fg)] " +
  "hover:bg-[var(--color-primary-hover)] disabled:opacity-40 disabled:cursor-not-allowed transition-colors";

const ghostBtnCls =
  "px-3 py-1.5 rounded text-sm font-medium border border-[var(--color-bp-400)] " +
  "text-[var(--color-bp-400)] hover:bg-[var(--color-bp-500)]/10 disabled:opacity-40 disabled:cursor-not-allowed transition-colors";

type DeployState =
  | { step: "idle" }
  | { step: "switching" }
  | { step: "sending"; contracts: string[] }
  | { step: "confirming"; contracts: string[] }
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

/** How a button names the contracts a wallet request covers. */
function contractsLabel(contracts: string[]): string {
  return contracts.length === 1 ? contracts[0] : `${contracts.length} contracts`;
}

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
      {!open && (
        <ChainIcon
          chainId={chain.id}
          name={chain.name}
          className="absolute left-3 top-1/2 -translate-y-1/2 pointer-events-none"
        />
      )}
      <input
        className={`${inputCls} ${open ? "" : "pl-9"}`}
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
        <ul className="absolute z-20 mt-1 w-full max-h-72 overflow-y-auto rounded border border-[var(--color-ink-3)]/30 bg-[var(--color-surface)] shadow-xl">
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
                  <ChainIcon
                    chainId={c.id}
                    name={c.name}
                    className="inline-block align-[-0.2em] mr-2"
                  />
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
    <div className="space-y-3 rounded border border-[var(--color-ink-3)]/30 p-4">
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
        className={ghostBtnCls}
      >
        Use this network
      </button>
    </div>
  );
}

type StationState = "done" | "active" | "todo" | "error" | "skipped";

/** One step of the launch sequence: a numbered node on a vertical rail. */
function Station({
  index,
  title,
  state,
  aside,
  last,
  children,
}: {
  index: number;
  title: string;
  state: StationState;
  aside?: ReactNode;
  last?: boolean;
  children: ReactNode;
}) {
  return (
    <li className="dp-station" data-state={state}>
      <div className="dp-rail">
        <span className="dp-node" aria-hidden="true">
          {state === "done" ? "✓" : state === "error" ? "!" : index}
        </span>
        {!last && <span className="dp-line" />}
      </div>
      <div className="min-w-0 pb-8">
        <div className="flex items-baseline justify-between gap-3 flex-wrap">
          <h4 className="dp-title">{title}</h4>
          {aside}
        </div>
        <div className="mt-3 space-y-3">{children}</div>
      </div>
    </li>
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

  // A wallet that can run a batch atomically (an EIP-7702 account, or one the
  // wallet will upgrade on approval) deploys every missing contract in one
  // request. A wallet without wallet_getCapabilities throws: no batching.
  const batching = useQuery({
    queryKey: ["wallet-batching", address, connector?.uid, chain.id],
    queryFn: async () => {
      try {
        const walletClient = await getWalletClient();
        const { atomic } = await walletClient.getCapabilities({
          account: address,
          chainId: chain.id,
        });
        return atomic?.status === "supported" || atomic?.status === "ready";
      } catch {
        return false;
      }
    },
    enabled: isConnected && Boolean(address) && Boolean(connector),
    staleTime: 60_000,
    retry: false,
  });
  const canBatch = batching.data === true;

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

  /** Deploys every missing contract: in one batch when the wallet can and
   *  `oneByOne` is not asked for, otherwise one transaction each. Together
   *  the contracts can exceed what a chain allows a single transaction. */
  async function deploy(oneByOne = false) {
    try {
      setDeployState({ step: "switching" });
      await ensureWalletOnChain();
      const client = makePublicClient(chain);
      const walletClient = await getWalletClient();
      const hashes: `0x${string}`[] = [];
      const hasCode = async (contract: (typeof DEPLOYED_CONTRACTS)[number]) => {
        const code = await client.getCode({ address: contract.address });
        return code !== undefined && code !== "0x";
      };
      // A confirmed transaction is not yet visible everywhere: a public RPC
      // spreads requests over nodes, and the one answering this read may be
      // a block behind the one that returned the receipt. Ask again for a
      // while before calling the deployment missing.
      const requireCode = async (contract: (typeof DEPLOYED_CONTRACTS)[number]) => {
        const deadline = Date.now() + 90_000;
        for (;;) {
          if (await hasCode(contract).catch(() => false)) return;
          if (Date.now() >= deadline) break;
          await new Promise((resolve) => setTimeout(resolve, 2_000));
        }
        throw new Error(
          `The ${contract.name} transaction succeeded but no code was ` +
            "found at the expected address after 90 seconds.",
        );
      };
      // Guard against a stale status check: never send a deployment that is
      // guaranteed to be a no-op because the contract already exists.
      const present = await Promise.all(DEPLOYED_CONTRACTS.map(hasCode));
      const missing = DEPLOYED_CONTRACTS.filter((_, i) => !present[i]);

      if (canBatch && missing.length > 1 && !oneByOne) {
        const contracts = missing.map((contract) => contract.name);
        setDeployState({ step: "sending", contracts });
        const { id } = await walletClient.sendCalls({
          calls: missing.map((contract) => ({
            to: CREATE2_PROXY,
            data: concat([contract.salt, contract.bytecode]),
          })),
          forceAtomic: true,
        });
        setDeployState({ step: "confirming", contracts });
        const result = await walletClient.waitForCallsStatus({
          id,
          timeout: 300_000,
        });
        if (result.status !== "success") {
          throw new Error("The deployment batch reverted.");
        }
        for (const contract of missing) await requireCode(contract);
        for (const receipt of result.receipts ?? []) {
          if (!hashes.includes(receipt.transactionHash)) {
            hashes.push(receipt.transactionHash);
          }
        }
      } else {
        for (const contract of missing) {
          setDeployState({ step: "sending", contracts: [contract.name] });
          const hash = await walletClient.sendTransaction({
            to: CREATE2_PROXY,
            data: concat([contract.salt, contract.bytecode]),
          });
          setDeployState({ step: "confirming", contracts: [contract.name] });
          const receipt = await client.waitForTransactionReceipt({
            hash,
            timeout: 300_000,
          });
          if (receipt.status !== "success") {
            throw new Error(
              `The ${contract.name} deployment transaction reverted.`,
            );
          }
          await requireCode(contract);
          hashes.push(hash);
        }
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

  const deployedNow = (i: number) =>
    status.data?.deployed[i] === true || deployState.step === "success";
  const busyNames =
    deployState.step === "sending" || deployState.step === "confirming"
      ? deployState.contracts
      : [];
  const missingCount = status.data?.deployed.filter((d) => !d).length ?? 0;
  const batchDeploy = canBatch && missingCount > 1;
  const needsFactory =
    status.data !== undefined && status.data.anyMissing && !status.data.proxyPresent;
  const readyToDeploy =
    status.data !== undefined && status.data.anyMissing && status.data.proxyPresent;

  const walletState: StationState = isConnected ? "done" : "active";
  const networkState: StationState = status.isError
    ? "error"
    : status.isPending
      ? "active"
      : "done";
  const factoryState: StationState = !status.data
    ? "todo"
    : !status.data.anyMissing
      ? "skipped"
      : status.data.proxyPresent
        ? "done"
        : "active";
  const contractsState: StationState =
    isDeployedNow
      ? "done"
      : deployState.step === "error"
        ? "error"
        : deploying
          ? "active"
          : readyToDeploy
            ? "active"
            : "todo";
  const verifyStationState: StationState =
    verifyState.step === "verified" || verifiedStatus.data === true
      ? "done"
      : verifyState.step === "error"
        ? "error"
        : "todo";

  return (
    <section className="dp-panel" aria-label="Deploy to a new network">
      <header className="dp-head">
        <h3 className="dp-heading">Deploy to a new network</h3>
        <p className="dp-target">
          <span className="dp-target-name inline-flex items-center gap-2">
            <ChainIcon chainId={chain.id} name={chain.name} />
            {chain.name}
          </span>
          <span className="dp-target-id">chain {chain.id}</span>
        </p>
      </header>

      <ol className="dp-steps">
        {/* 01 Wallet */}
        <Station
          index={1}
          title="Wallet"
          state={walletState}
          aside={
            isConnected && address ? (
              <button
                type="button"
                onClick={() => disconnect()}
                className="dp-link-quiet hover:text-[var(--color-err)]"
              >
                Disconnect
              </button>
            ) : undefined
          }
        >
          {isConnected && address ? (
            <p className="flex items-center gap-3 flex-wrap">
              <span className="dp-led" data-on="true" />
              <span className="font-mono text-sm">{shortAddress(address)}</span>
              {walletChainId !== undefined && (
                <span className="dp-chip inline-flex items-center gap-1.5">
                  <ChainIcon
                    chainId={walletChainId}
                    name={chainById(walletChainId)?.name}
                    size={12}
                  />
                  {chainById(walletChainId)?.name ?? `chain ${walletChainId}`}
                </span>
              )}
            </p>
          ) : (
            <button
              type="button"
              disabled={connectPending || !injected}
              onClick={() => injected && connect({ connector: injected })}
              className={`${primaryBtnCls} inline-flex items-center gap-2`}
            >
              <WalletIcon />
              {connectPending ? "Connecting…" : "Connect wallet"}
            </button>
          )}
        </Station>

        {/* 02 Network */}
        <Station
          index={2}
          title="Network"
          state={networkState}
          aside={
            status.isPending ? (
              <span className="dp-note">Checking {chain.name}…</span>
            ) : undefined
          }
        >
          <ChainPicker chain={chain} onChange={onChainChange} />
          <button
            type="button"
            onClick={() => setShowCustom((v) => !v)}
            className="dp-link"
          >
            {showCustom
              ? "Hide custom network"
              : "Can't find your network? Add it with an RPC URL"}
          </button>
          {showCustom && (
            <CustomChainForm
              onSubmit={(customChain) => {
                onChainChange(customChain);
                setShowCustom(false);
              }}
            />
          )}
          {status.isError && (
            <div className="dp-alert" data-tone="err">
              <p>
                Could not reach an RPC for {chain.name}: {errorMessage(status.error)}
              </p>
              <p className="dp-note mt-1">
                Try re-adding the network as a custom network with a working RPC URL.
              </p>
            </div>
          )}
        </Station>

        {/* 03 Factory */}
        <Station
          index={3}
          title="CREATE2 factory"
          state={factoryState}
          aside={
            factoryState === "skipped" ? (
              <span className="dp-note">Not needed</span>
            ) : status.data?.proxyPresent ? (
              <span className="dp-note font-mono">
                {shortAddress(CREATE2_PROXY)}
              </span>
            ) : undefined
          }
        >
          {!status.data && <p className="dp-note">Waiting for the network check.</p>}
          {factoryState === "skipped" && (
            <p className="dp-note">
              Every contract is already on {chain.name}, so the factory is not used.
            </p>
          )}
          {status.data?.anyMissing && status.data.proxyPresent && (
            <p className="dp-note">
              The deterministic deployment proxy is present on {chain.name}.
            </p>
          )}
          {needsFactory && (
            <div className="dp-alert" data-tone="warn">
              <p className="font-medium">
                The CREATE2 factory is missing on {chain.name}.
              </p>
              <p className="dp-note mt-1 leading-relaxed">
                Deterministic deployment relies on the{" "}
                <a
                  href="https://github.com/Arachnid/deterministic-deployment-proxy"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="dp-link"
                >
                  deterministic deployment proxy
                </a>{" "}
                at <span className="font-mono">{shortAddress(CREATE2_PROXY)}</span>.
                It can be installed permissionlessly: fund its one-time deployer
                with 0.01 {chain.nativeCurrency.symbol} and broadcast a presigned
                transaction.
              </p>
              <button
                type="button"
                disabled={!isConnected || bootstrapping}
                onClick={() => void bootstrapFactory()}
                className={`${primaryBtnCls} mt-3`}
              >
                {bootstrapState.step === "funding"
                  ? "Funding the deployer…"
                  : bootstrapState.step === "broadcasting"
                    ? "Broadcasting the factory deployment…"
                    : `Install the factory (0.01 ${chain.nativeCurrency.symbol})`}
              </button>
              {bootstrapState.step === "error" && (
                <p className="text-xs text-[var(--color-err)] mt-2">
                  {bootstrapState.message}
                </p>
              )}
            </div>
          )}
        </Station>

        {/* 04 Contracts */}
        <Station
          index={4}
          title="Contracts"
          state={contractsState}
          aside={
            status.data ? (
              <span className="dp-note">
                {DEPLOYED_CONTRACTS.filter((_, i) => deployedNow(i)).length} of{" "}
                {DEPLOYED_CONTRACTS.length} deployed
              </span>
            ) : undefined
          }
        >
          <ul className="dp-bay">
            {DEPLOYED_CONTRACTS.map((contract, i) => {
              const live = status.data ? deployedNow(i) : false;
              const busy = busyNames.includes(contract.name);
              const url = explorerAddressUrl(chain, contract.address);
              return (
                <li key={contract.key} className="dp-bay-row" data-live={live} data-busy={busy}>
                  <span className="dp-led" data-on={live} data-busy={busy} />
                  <span className="dp-bay-name">
                    {contract.name}
                    <span className="dp-bay-ver">
                      {contract.released ? "" : " unreleased"}
                    </span>
                  </span>
                  <span className="dp-bay-addr">
                    {url && live ? (
                      <a href={url} target="_blank" rel="noopener noreferrer" className="dp-link">
                        {contract.address} ↗
                      </a>
                    ) : (
                      contract.address
                    )}
                  </span>
                  <span className="dp-bay-gas">{contract.gasLabel} gas</span>
                </li>
              );
            })}
          </ul>

          {readyToDeploy && (
            <>
              <button
                type="button"
                disabled={!isConnected || deploying}
                onClick={() => void deploy()}
                className={primaryBtnCls}
              >
                {deployState.step === "switching"
                  ? "Switching network…"
                  : deployState.step === "sending"
                    ? `Confirm ${contractsLabel(deployState.contracts)} in your wallet…`
                    : deployState.step === "confirming"
                      ? `Waiting for ${contractsLabel(deployState.contracts)} confirmation…`
                      : `Deploy to ${chain.name}`}
              </button>
              <p className="dp-note">
                {batchDeploy
                  ? `Your wallet batches calls (EIP-7702): one transaction deploys all ${missingCount} missing contracts.`
                  : "One transaction per missing contract."}
                {!isConnected && " Connect a wallet to deploy."}
              </p>
              {batchDeploy && isConnected && (
                <p className="dp-note">
                  If the batch is too large for the network,{" "}
                  <button
                    type="button"
                    disabled={deploying}
                    onClick={() => void deploy(true)}
                    className="dp-link-quiet underline hover:text-[var(--color-bp-300)] disabled:opacity-50"
                  >
                    deploy them one after the other
                  </button>
                  : one transaction per missing contract.
                </p>
              )}
            </>
          )}

          {status.data?.allDeployed && deployState.step !== "success" && (
            <div className="dp-alert" data-tone="ok">
              <p className="font-medium">
                All {DEPLOYED_CONTRACTS.length} contracts are already deployed on {chain.name}.
              </p>
            </div>
          )}

          {deployState.step === "success" && (
            <div className="dp-alert" data-tone="ok">
              <p className="font-medium">
                Deployed. {DEPLOYED_CONTRACTS.map((c) => c.name).join(", ")} are now live on{" "}
                {chain.name}.
              </p>
              {deployState.hashes.map((hash) => {
                const tx = explorerTxUrl(chain, hash);
                return (
                  <p key={hash} className="font-mono text-xs mt-1">
                    {tx ? (
                      <a href={tx} target="_blank" rel="noopener noreferrer" className="dp-link">
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
            <div className="dp-alert" data-tone="err">
              <p>{deployState.message}</p>
              <button
                type="button"
                onClick={() => setDeployState({ step: "idle" })}
                className="dp-link-quiet mt-1"
              >
                Dismiss
              </button>
            </div>
          )}
        </Station>

        {/* 05 Verify */}
        <Station
          index={5}
          title="Verify the source"
          state={verifyStationState}
          aside={<span className="dp-note">Optional</span>}
          last
        >
          <div>
            <label className="block text-xs text-[var(--color-ink-3)] mb-1">
              Etherscan API key{" "}
              <span>(verifies the source automatically after deploying)</span>
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

          {/* Offered once an API key is entered, and hidden when the
              pre-check shows the source is already verified. */}
          {isDeployedNow &&
            Boolean(apiKey) &&
            !(
              verifyState.step === "idle" &&
              etherscanSupported &&
              (verifiedStatus.isPending || verifiedStatus.data === true)
            ) && (
              <div className="dp-alert" data-tone="plain">
                {!etherscanSupported ? (
                  <p className="dp-note">
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
                        className="dp-link"
                      >
                        View the code ↗
                      </a>
                    )}
                  </p>
                ) : verifyState.step === "running" ? (
                  <p className="dp-note">{VERIFY_PROGRESS_LABELS[verifyState.progress]}</p>
                ) : (
                  <div className="space-y-2">
                    <p className="dp-note leading-relaxed">
                      Submits the compiler input bundled with this site to the chain's explorer.
                    </p>
                    <button type="button" onClick={() => void runVerification()} className={ghostBtnCls}>
                      Verify the source
                    </button>
                    {verifyState.step === "error" && (
                      <p className="text-xs text-[var(--color-err)]">{verifyState.message}</p>
                    )}
                  </div>
                )}
              </div>
            )}
        </Station>
      </ol>
    </section>
  );
}
