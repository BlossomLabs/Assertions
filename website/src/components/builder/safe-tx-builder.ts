/** Safe Transaction Builder batch JSON <-> EVML. */

import {
  type Action,
  isBatchedAction,
  isTransactionAction,
  type TransactionAction,
} from "@evmcrispr/core";

interface TxBuilderTx {
  to: string;
  value?: string;
  data?: string | null;
  contractMethod?: {
    name: string;
    inputs: { name: string; type: string }[];
    payable?: boolean;
  } | null;
  contractInputsValues?: Record<string, string> | null;
}

export interface TxBuilderBatch {
  version?: string;
  chainId?: string;
  createdAt?: number;
  meta?: {
    name?: string;
    description?: string;
    txBuilderVersion?: string;
    createdFromSafeAddress?: string;
  };
  transactions: TxBuilderTx[];
}

export function isTxBuilderBatch(value: unknown): value is TxBuilderBatch {
  return (
    typeof value === "object" &&
    value !== null &&
    Array.isArray((value as TxBuilderBatch).transactions)
  );
}

/** EVML argument literal for one ABI input value. Tuples/arrays arrive from
 *  the Tx Builder as JSON-ish strings and pass through as-is. */
function evmlArg(type: string, raw: string): string {
  const value = raw.trim();
  if (type === "string") return JSON.stringify(value);
  if (type === "bool") return value === "true" ? "true" : "false";
  return value;
}

function txToLine(tx: TxBuilderTx): string {
  const value = tx.value && tx.value !== "0" ? ` --value ${tx.value}` : "";

  if (tx.contractMethod && tx.contractInputsValues) {
    const { name, inputs } = tx.contractMethod;
    const signature = `${name}(${inputs.map((i) => i.type).join(",")})`;
    const args = inputs
      .map((i) => evmlArg(i.type, tx.contractInputsValues?.[i.name] ?? ""))
      .join(" ");
    return `exec ${tx.to} "${signature}"${args ? ` ${args}` : ""}${value}`;
  }

  // Raw calldata (or plain value transfer).
  const data = tx.data && tx.data !== "0x" ? ` --data ${tx.data}` : "";
  return `send ${tx.to}${data}${value}`;
}

/** Convert interpreted EVML actions into a Safe Transaction Builder batch
 *  (the JSON the Safe{Wallet} Transaction Builder app imports). Throws when
 *  an action cannot be represented in that format. */
export function actionsToTxBuilderBatch(
  actions: Action[],
  opts: { chainId: number; safeAddress?: string; name?: string },
): TxBuilderBatch {
  const flat: TransactionAction[] = [];
  for (const action of actions) {
    if (isBatchedAction(action)) flat.push(...action.actions);
    else if (isTransactionAction(action)) flat.push(action);
    else
      throw new Error(
        `The script produced a "${action.type}" action, which cannot be ` +
          "represented in a Transaction Builder batch.",
      );
  }
  if (flat.length === 0)
    throw new Error("The script produced no transactions to export.");

  const transactions = flat.map((tx): TxBuilderTx => {
    if (!tx.to)
      throw new Error(
        "Contract deployments (CREATE) cannot be represented in a " +
          "Transaction Builder batch.",
      );
    if (tx.operation === 1)
      throw new Error(
        "Delegatecall actions cannot be represented in a Transaction " +
          "Builder batch.",
      );
    return {
      to: tx.to,
      value: (tx.value ?? 0n).toString(),
      data: tx.data ?? "0x",
      contractMethod: null,
      contractInputsValues: null,
    };
  });

  return {
    version: "1.0",
    chainId: String(opts.chainId),
    createdAt: Date.now(),
    meta: {
      name: opts.name ?? "Assertions batch",
      description: "Built with assertions.eth",
      txBuilderVersion: "1.17.1",
      createdFromSafeAddress: opts.safeAddress,
    },
    transactions,
  };
}

/** Convert a Transaction Builder batch into an EVML action block (one line
 *  per transaction), with the batch metadata as leading comments. */
export function txBuilderToEvml(batch: TxBuilderBatch): {
  script: string;
  chainId?: number;
  name?: string;
} {
  const lines: string[] = [];
  if (batch.meta?.name) lines.push(`# ${batch.meta.name}`);
  if (batch.meta?.description) lines.push(`# ${batch.meta.description}`);
  for (const tx of batch.transactions) lines.push(txToLine(tx));
  return {
    script: lines.join("\n"),
    chainId: batch.chainId ? Number(batch.chainId) : undefined,
    name: batch.meta?.name,
  };
}
