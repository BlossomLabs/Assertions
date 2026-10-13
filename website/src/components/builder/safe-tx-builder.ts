/** Safe Transaction Builder batch JSON <-> EVML. */

import {
  type Action,
  isBatchedAction,
  isTransactionAction,
  type TransactionAction,
} from "@evmcrispr/core";
import {
  type Abi,
  type Address,
  type Hex,
  encodeFunctionData,
  getAddress,
  isAddress,
  parseAbiItem,
} from "viem";

import { type ArgTree, type ComposeEnv, composeCall } from "./compose-call";
import { type Naming, bindVariables, insertAssertionLines } from "./script-ops";

interface TxBuilderTx {
  to: string;
  value?: string;
  data?: string | null;
  contractMethod?: {
    name: string;
    inputs: { name: string; type: string; components?: unknown }[];
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

/*
 * An imported file is someone else's text. Nothing in it reaches a script
 * as text: `parseTxBuilderBatch` reads the file into the structure below,
 * accepting each piece only when it is exactly the one thing it claims to
 * be (an address, a number in range, hex bytes, a type, an identifier),
 * and every line is then built from that structure and from nothing else.
 * A file with one piece that is not understood is refused whole: a batch
 * is meant to be taken as it is, not with a transaction missing.
 */

type AbiType =
  | { kind: "address" | "bool" | "string" | "bytes" }
  | { kind: "fixedBytes"; size: number }
  | { kind: "uint" | "int"; bits: number }
  | { kind: "array"; of: AbiType; length?: number }
  | { kind: "tuple"; components: AbiType[] };

/** A value read from the file: an address, a literal as EVML writes it,
 *  or a list (an array, a tuple). `js` is the same value for viem. */
type Value =
  | { kind: "address"; address: Address; js: Address }
  | { kind: "literal"; text: string; js: unknown }
  | { kind: "list"; items: Value[]; js: unknown[] };

interface ValidCall {
  name: string;
  /** Canonical input types, tuples spelled out. */
  types: string[];
  /** What each parameter is called, when that is a plain identifier. */
  names: (string | undefined)[];
  values: Value[];
}

interface ValidTx {
  to: Address;
  value: bigint;
  /** Raw calldata, for a transaction with no method to decode. */
  data?: Hex;
  call?: ValidCall;
}

interface ValidBatch {
  chainId?: number;
  name?: string;
  /** The batch's name and description, each one line of plain text. */
  comments: string[];
  transactions: ValidTx[];
}

const MAX_UINT256 = 2n ** 256n - 1n;
const IDENTIFIER = /^[A-Za-z_][A-Za-z0-9_]*$/;

/** One line of plain text out of a name or a description: control
 *  characters and every kind of line break become a space, and the line
 *  is cut short. It cannot end the comment it is written in. */
function oneLine(text: string): string {
  return text
    .replace(/[\p{Cc}\p{Zl}\p{Zp}]+/gu, " ")
    .replace(/\s+/g, " ")
    .trim()
    .slice(0, 120);
}

/** `uint256[][2]`, `tuple[]` with its components: the type, or nothing
 *  for anything that is not an ABI type. */
function parseType(input: unknown): AbiType | undefined {
  if (typeof input !== "object" || input === null) return undefined;
  const { type, components } = input as { type?: unknown; components?: unknown };
  if (typeof type !== "string") return undefined;
  const match = type.match(/^([a-z]+)([0-9]*)((?:\[[0-9]*\])*)$/);
  if (!match) return undefined;
  const [, word, digits, dimensions] = match;
  const size = digits === "" ? undefined : Number(digits);
  let parsed: AbiType | undefined;
  if (word === "tuple" && size === undefined) {
    if (!Array.isArray(components) || components.length === 0) return undefined;
    const inner = components.map(parseType);
    if (inner.some((c) => c === undefined)) return undefined;
    parsed = { kind: "tuple", components: inner as AbiType[] };
  } else if ((word === "address" || word === "bool" || word === "string") && size === undefined) {
    parsed = { kind: word };
  } else if (word === "bytes") {
    if (size === undefined) parsed = { kind: "bytes" };
    else if (size >= 1 && size <= 32 && String(size) === digits) parsed = { kind: "fixedBytes", size };
  } else if (word === "uint" || word === "int") {
    const bits = size ?? 256;
    if (bits >= 8 && bits <= 256 && bits % 8 === 0 && (digits === "" || String(bits) === digits))
      parsed = { kind: word, bits };
  }
  if (!parsed) return undefined;
  for (const [, length] of dimensions.matchAll(/\[([0-9]*)\]/g)) {
    if (length !== "" && (String(Number(length)) !== length || Number(length) < 1)) return undefined;
    parsed = { kind: "array", of: parsed, ...(length === "" ? {} : { length: Number(length) }) };
  }
  return parsed;
}

function canonical(type: AbiType): string {
  switch (type.kind) {
    case "array":
      return `${canonical(type.of)}[${type.length ?? ""}]`;
    case "tuple":
      return `(${type.components.map(canonical).join(",")})`;
    case "fixedBytes":
      return `bytes${type.size}`;
    case "uint":
    case "int":
      return `${type.kind}${type.bits}`;
    default:
      return type.kind;
  }
}

const holdsText = (type: AbiType): boolean =>
  type.kind === "string" ||
  type.kind === "tuple" ||
  (type.kind === "array" && holdsText(type.of));

/** A list as the Transaction Builder's form takes it when it is no JSON
 *  (`[0xabc…, 0xdef…]`): split at the top-level commas, quotes dropped.
 *  Every piece is checked as its type afterwards, like any other. */
function looseList(text: string): unknown {
  const trimmed = text.trim();
  if (!trimmed.startsWith("[") || !trimmed.endsWith("]")) return undefined;
  const items: string[] = [];
  let depth = 0;
  let current = "";
  for (const ch of trimmed.slice(1, -1)) {
    if (ch === "[") depth++;
    if (ch === "]") depth--;
    if (depth < 0) return undefined;
    if (ch === "," && depth === 0) {
      items.push(current);
      current = "";
    } else current += ch;
  }
  if (depth !== 0) return undefined;
  if (current.trim() !== "" || items.length > 0) items.push(current);
  return items.map((item) => {
    const piece = item.trim();
    return piece.startsWith("[") ? looseList(piece) : piece.replace(/^(["'])(.*)\1$/, "$2");
  });
}

/** A value of the file as a value of its type, or nothing. `raw` is the
 *  text of a form field, or a piece of a list parsed out of one. */
function parseValue(type: AbiType, raw: unknown): Value | undefined {
  if (type.kind === "array" || type.kind === "tuple") {
    let list = raw;
    if (typeof raw === "string") {
      try {
        list = JSON.parse(raw);
      } catch {
        // Not JSON: the loose form, for lists that hold no text.
        list = holdsText(type) ? undefined : looseList(raw);
      }
    }
    if (!Array.isArray(list)) return undefined;
    const types =
      type.kind === "tuple" ? type.components : list.map(() => type.of);
    if (type.kind === "tuple" && list.length !== types.length) return undefined;
    if (type.kind === "array" && type.length !== undefined && list.length !== type.length)
      return undefined;
    const items = list.map((item, i) => parseValue(types[i], item));
    if (items.some((item) => item === undefined)) return undefined;
    return { kind: "list", items: items as Value[], js: (items as Value[]).map((item) => item.js) };
  }
  // Inside JSON a number or a boolean may be written as one.
  const text =
    typeof raw === "string"
      ? raw
      : typeof raw === "boolean" || (typeof raw === "number" && Number.isSafeInteger(raw))
        ? String(raw)
        : undefined;
  if (text === undefined) return undefined;
  if (type.kind === "string")
    return { kind: "literal", text: stringLiteral(text), js: text };
  const value = text.trim();
  switch (type.kind) {
    case "address": {
      if (!isAddress(value)) return undefined;
      const address = getAddress(value);
      return { kind: "address", address, js: address };
    }
    case "bool": {
      const word = value.toLowerCase();
      if (word !== "true" && word !== "false" && word !== "1" && word !== "0") return undefined;
      const on = word === "true" || word === "1";
      return { kind: "literal", text: String(on), js: on };
    }
    case "bytes":
    case "fixedBytes": {
      if (!/^0x(?:[0-9a-fA-F]{2})*$/.test(value)) return undefined;
      if (type.kind === "fixedBytes" && value.length !== 2 + 2 * type.size) return undefined;
      return { kind: "literal", text: value, js: value };
    }
    case "uint":
    case "int": {
      // The form's own numbers may be quoted: "5".
      const digits = value.replace(/^(["'])(.*)\1$/, "$2").trim();
      if (!(type.kind === "int" ? /^-?[0-9]+$/ : /^[0-9]+$/).test(digits)) return undefined;
      if (digits.length > 80) return undefined;
      const number = BigInt(digits);
      const [min, max] =
        type.kind === "uint"
          ? [0n, 2n ** BigInt(type.bits) - 1n]
          : [-(2n ** BigInt(type.bits - 1)), 2n ** BigInt(type.bits - 1) - 1n];
      if (number < min || number > max) return undefined;
      return { kind: "literal", text: number.toString(), js: number };
    }
  }
}

/** Text as an EVML string literal: JSON's escaping, which EVML reads
 *  back to the same text (quotes, backslashes, line feeds, tabs). The two
 *  Unicode line separators stay as they are, as JSON leaves them: EVML has
 *  no escape for them and does not end a line or a string at one. */
const stringLiteral = (text: string): string => JSON.stringify(text);

/** A whole number of wei as an export writes it: digits (zero for
 *  nothing at all), or a JSON number. */
function parseWei(raw: unknown): bigint | undefined {
  if (raw === undefined || raw === null || raw === "") return 0n;
  const text =
    typeof raw === "string"
      ? raw.trim()
      : typeof raw === "number" && Number.isSafeInteger(raw)
        ? String(raw)
        : undefined;
  if (text === undefined || !/^[0-9]{1,80}$/.test(text)) return undefined;
  const wei = BigInt(text);
  return wei <= MAX_UINT256 ? wei : undefined;
}

function parseTx(raw: unknown): ValidTx | string {
  if (typeof raw !== "object" || raw === null || Array.isArray(raw))
    return "it is not a transaction.";
  const tx = raw as Record<string, unknown>;
  if (typeof tx.to !== "string" || !isAddress(tx.to.trim()))
    return '"to" is not an address.';
  const to = getAddress(tx.to.trim());
  const value = parseWei(tx.value);
  if (value === undefined) return '"value" is not a whole number of wei.';
  let data: Hex | undefined;
  if (tx.data !== undefined && tx.data !== null && tx.data !== "") {
    if (typeof tx.data !== "string" || !/^0x(?:[0-9a-fA-F]{2})*$/.test(tx.data))
      return '"data" is not hex bytes.';
    if (tx.data !== "0x") data = tx.data as Hex;
  }
  const method = tx.contractMethod;
  if (method === undefined || method === null) return { to, value, ...(data ? { data } : {}) };

  if (typeof method !== "object") return "the method is not understood.";
  const { name, inputs } = method as { name?: unknown; inputs?: unknown };
  if (typeof name !== "string" || !IDENTIFIER.test(name))
    return "the method name is not an identifier.";
  if (!Array.isArray(inputs)) return "the method's inputs are not a list.";
  const given =
    typeof tx.contractInputsValues === "object" && tx.contractInputsValues !== null
      ? (tx.contractInputsValues as Record<string, unknown>)
      : {};
  const types: string[] = [];
  const names: (string | undefined)[] = [];
  const values: Value[] = [];
  for (const [i, input] of inputs.entries()) {
    const type = parseType(input);
    if (!type) return `the type of input ${i + 1} is not an ABI type.`;
    const written = canonical(type);
    const key = (input as { name?: unknown }).name;
    const parsed =
      typeof key === "string" && Object.hasOwn(given, key)
        ? parseValue(type, given[key])
        : undefined;
    if (!parsed) return `input ${i + 1} (${written}) is not a value of that type.`;
    types.push(written);
    names.push(typeof key === "string" && /^[A-Za-z_][A-Za-z0-9_]*$/.test(key) ? key : undefined);
    values.push(parsed);
  }
  // A file that gives both the call and its bytes must mean one thing.
  if (data) {
    let encoded: Hex;
    try {
      encoded = encodeFunctionData({
        abi: [parseAbiItem(`function ${name}(${types.join(",")})`)] as Abi,
        functionName: name,
        args: values.map((v) => v.js),
      });
    } catch {
      return '"data" is not the call its method and values describe.';
    }
    if (encoded.toLowerCase() !== data.toLowerCase())
      return '"data" is not the call its method and values describe.';
  }
  return { to, value, call: { name, types, names, values } };
}

/**
 * A Transaction Builder file as a checked structure, or why it is not
 * taken: which transaction, by its position, and which field. Per field:
 * `to` an address (kept checksummed); `value` a whole number of wei up to
 * a uint256; `data` `0x` and whole bytes; the method's name an identifier;
 * each input's type an ABI type; each value a value of its type, in range,
 * with the shape its type declares; the name and the description one line
 * of text each. The messages name positions and never repeat the text.
 */
export function parseTxBuilderBatch(
  file: unknown,
): { batch: ValidBatch } | { error: string } {
  if (!isTxBuilderBatch(file))
    return { error: "That JSON doesn't look like a Safe Transaction Builder batch." };
  if (file.transactions.length === 0)
    return { error: "The batch has no transactions." };
  let chainId: number | undefined;
  const chain: unknown = file.chainId;
  if (chain !== undefined && chain !== null && chain !== "") {
    const text = typeof chain === "number" ? String(chain) : chain;
    if (typeof text !== "string" || !/^[1-9][0-9]{0,15}$/.test(text))
      return { error: 'The batch\'s "chainId" is not a chain id.' };
    chainId = Number(text);
  }
  const meta: unknown = file.meta ?? {};
  if (typeof meta !== "object" || meta === null)
    return { error: 'The batch\'s "meta" is not understood.' };
  const comments: string[] = [];
  let name: string | undefined;
  for (const key of ["name", "description"] as const) {
    const text = (meta as Record<string, unknown>)[key];
    if (text === undefined || text === null) continue;
    if (typeof text !== "string")
      return { error: `The batch's ${key} is not text.` };
    const line = oneLine(text);
    if (line === "") continue;
    comments.push(line);
    if (key === "name") name = line;
  }
  const transactions: ValidTx[] = [];
  for (const [i, raw] of file.transactions.entries()) {
    const tx = parseTx(raw);
    if (typeof tx === "string") return { error: `Transaction ${i + 1}: ${tx}` };
    transactions.push(tx);
  }
  return { batch: { chainId, name, comments, transactions } };
}

/** The checked file, or an error with the reason it was refused. */
function checked(file: unknown): ValidBatch {
  const parsed = parseTxBuilderBatch(file);
  if ("error" in parsed) throw new Error(parsed.error);
  return parsed.batch;
}

const valueOption = (tx: ValidTx): string =>
  tx.value === 0n ? "" : ` --value ${tx.value}`;

/** A raw call or a plain transfer: an address, bytes and a number. */
const sendLine = (tx: ValidTx): string =>
  `send ${tx.to}${tx.data ? ` --data ${tx.data}` : ""}${valueOption(tx)}`;

const literal = (value: Value): string =>
  value.kind === "address"
    ? value.address
    : value.kind === "literal"
      ? value.text
      : `[${value.items.map(literal).join(" ")}]`;

/** A decoded call with every address written out. */
function execLine(tx: ValidTx, call: ValidCall): string {
  const args = call.values.map(literal).join(" ");
  return `exec ${tx.to} "${call.name}(${call.types.join(",")})"${args ? ` ${args}` : ""}${valueOption(tx)}`;
}

const tree = (value: Value): ArgTree =>
  value.kind === "address"
    ? { address: value.address }
    : value.kind === "literal"
      ? { literal: value.text }
      : value.items.map(tree);

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
 *  per transaction), with the batch's name and description as leading
 *  comments. Built from the checked file only (`parseTxBuilderBatch`);
 *  throws, with the reason, for a file that is refused. */
export function txBuilderToEvml(file: TxBuilderBatch): {
  script: string;
  chainId?: number;
  name?: string;
} {
  const batch = checked(file);
  return {
    script: [
      ...batch.comments.map((line) => `# ${line}`),
      ...batch.transactions.map((tx) =>
        tx.call ? execLine(tx, tx.call) : sendLine(tx),
      ),
    ].join("\n"),
    chainId: batch.chainId,
    name: batch.name,
  };
}

/**
 * A Transaction Builder batch as the contract form would have written it:
 * each call with a method goes through `composeCall` and `bindVariables`,
 * so its addresses are named variables and the three standard token calls
 * are in the token's own units. A transaction with no method (raw
 * calldata, a plain transfer) is the `send` line `txBuilderToEvml` writes.
 * A batch of another chain than the one `env` reads is that plain
 * conversion: nothing read here would be about its contracts. Everything
 * comes from the checked file (`parseTxBuilderBatch`), and a file that is
 * refused throws with the reason: nothing of it is imported.
 */
export async function importTxBuilder(
  file: TxBuilderBatch,
  env: ComposeEnv,
  naming: Naming = {},
): Promise<{
  script: string;
  managed: NonNullable<Naming["managed"]>;
  chainId?: number;
  name?: string;
}> {
  const batch = checked(file);
  if (batch.chainId !== undefined && batch.chainId !== env.chainId)
    return { ...txBuilderToEvml(file), managed: new Map() };
  let script = batch.comments.map((line) => `# ${line}`).join("\n");
  // An import replaces the batch: only the names given here are known.
  let managed: NonNullable<Naming["managed"]> = new Map();
  for (const tx of batch.transactions) {
    const call = tx.call;
    if (!call) {
      script = script ? `${script}\n${sendLine(tx)}` : sendLine(tx);
      continue;
    }
    // A name of the form's own for each input: the file's when it is an
    // identifier (it may then suggest a variable's name), a position
    // otherwise. The values are keyed by it, never by the file's text.
    const inputs = call.types.map((type, i) => ({
      name: call.names[i] !== undefined && call.names.indexOf(call.names[i]) === i
        ? (call.names[i] as string)
        : `arg${i}`,
      type,
    }));
    const composed = await composeCall(
      {
        target: tx.to,
        targetRef: tx.to,
        signature: `${call.name}(${call.types.join(",")})`,
        inputs,
        // A single value is the text the form would hold (an address, a
        // number, hex, a boolean, a string's own text); a list is written
        // from its checked tree.
        values: Object.fromEntries(
          call.values.flatMap((value, i) =>
            value.kind === "list"
              ? []
              : [[inputs[i].name, value.kind === "address" ? value.address : String(value.js)]],
          ),
        ),
        trees: Object.fromEntries(
          call.values.flatMap((value, i) =>
            value.kind === "list" ? [[inputs[i].name, tree(value)]] : [],
          ),
        ),
        value: tx.value === 0n ? "" : tx.value.toString(),
      },
      env,
    );
    const bound = bindVariables(script, composed, { ...naming, managed });
    managed = bound.managed;
    script = insertAssertionLines(bound.script, bound.line, "post", bound.sets).script;
  }
  return { script, managed, chainId: batch.chainId, name: batch.name };
}
