/** Safe Transaction Builder batch JSON -> EVML lines. */

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
  meta?: { name?: string; description?: string };
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
