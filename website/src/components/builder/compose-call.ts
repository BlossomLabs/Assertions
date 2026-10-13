import {
  type ArrayExpressionNode,
  BASE_UNITS_COMMENT,
  type HelperFunctionNode,
  type Node,
  NodeType,
  PLAIN_WORD,
  type TokenListEntry,
  symbolInList,
} from "@evmcrispr/sdk";
import {
  type Address,
  formatUnits,
  getAddress,
  isAddress,
  parseAbiItem,
  parseUnits,
} from "viem";

import {
  type LineVariable,
  type NameOrigin,
  addressVariables,
  commandSpans,
  isAccountName,
  isSetSpan,
  setTarget,
  spanAtLine,
} from "./script-ops";
import { canonicalType, evmlArg } from "./useContractFunctions";

/**
 * A call as the composer writes it: an `exec` line whose addresses are
 * variables and whose standard token amounts are in the token's own
 * units, so that an action reads like the checks around it and shares
 * their variables (`bindVariables` gives them their names in a script).
 * Pure but for what `env` reads.
 */

export interface ComposeEnv {
  chainId: number;
  /** The chain's own currency: its symbol names no token. */
  nativeSymbol: string;
  /** The chain's token list: the only source of a token's name. */
  tokens: readonly TokenListEntry[];
  /** A token's `decimals()`, or undefined when it does not say. */
  decimalsOf: (address: Address) => Promise<number | undefined>;
  /** The `$variable` for an ENS name (see AbiForm), null when it does
   *  not resolve. */
  ensToVar: (name: string) => Promise<string | null>;
}

export interface CallInput {
  /** The contract called, resolved to an address. */
  target: string;
  /** How the line refers to it when it is not to be a variable of its
   *  own: the `$variable` of the ENS name it was given as. Otherwise the
   *  address itself. */
  targetRef: string;
  /** Canonical signature, `transfer(address,uint256)`. */
  signature: string;
  inputs: readonly { name: string; type: string }[];
  /** What the user typed for each input, by name. */
  values: Readonly<Record<string, string>>;
  /** `--value`, as typed. */
  value?: string;
  /** The unit the amount of a token call was typed in: base units (the
   *  default, what the ABI says) or the token's own. */
  amountIn?: AmountIn;
  /** Arguments that are not typed text but already checked values (an
   *  imported file's arrays and tuples), by input name: written from the
   *  tree, never parsed again. */
  trees?: Readonly<Record<string, ArgTree>>;
}

/** A checked argument: an address (it becomes a variable), a literal
 *  already written in EVML, or a list of them (an array, a tuple). */
export type ArgTree =
  | { address: string }
  | { literal: string }
  | readonly ArgTree[];

export type AmountIn = "token" | "base";

/** The ERC-20 calls whose last argument is an amount of the token called. */
const TOKEN_AMOUNT_CALLS = new Set([
  "transfer(address,uint256)",
  "approve(address,uint256)",
  "transferFrom(address,address,uint256)",
]);

/** What each address is in those calls, whatever the contract's ABI calls
 *  its parameters (`guy`, `dst`, `_to`) and when there is no ABI at all:
 *  the standard says, and a variable is named for it. */
const TOKEN_CALL_ROLES: Record<string, readonly string[]> = {
  "transfer(address,uint256)": ["to"],
  "approve(address,uint256)": ["spender"],
  "transferFrom(address,address,uint256)": ["from", "to"],
};

const MAX_UINT256 = 2n ** 256n - 1n;

/** `transfer`, `approve` and `transferFrom` by their full signature: the
 *  calls whose amount field can take the token's own units. */
export const isTokenAmountCall = (signature: string): boolean =>
  TOKEN_AMOUNT_CALLS.has(signature);

/** The call that takes an unlimited amount: `max` in its amount field. */
export const takesMax = (signature: string): boolean =>
  signature === "approve(address,uint256)";

/** An amount typed in a token's own units, as base units: exact, or the
 *  reason it is not an amount of that token. `max` is the unlimited
 *  allowance, where the call takes one. */
export function tokenAmount(
  raw: string,
  decimals: number,
  { max = false }: { max?: boolean } = {},
): { base: bigint } | { error: string } {
  const value = raw.trim();
  if (max && value.toLowerCase() === "max") return { base: MAX_UINT256 };
  if (!/^(\d+\.?\d*|\.\d+)$/.test(value))
    return { error: "Type an amount, like 1.5." };
  const typed = (value.split(".")[1] ?? "").length;
  if (typed > decimals)
    return {
      error:
        decimals === 0
          ? "A whole number: this token has no decimals."
          : `At most ${decimals} decimals.`,
    };
  const base = parseUnits(value.replace(/\.$/, "") as `${number}`, decimals);
  if (base > MAX_UINT256) return { error: "More than a uint256 holds." };
  return { base };
}

/** The amount in the unit the field is not in, for the line under it:
 *  base units for an amount typed in the token's, and the other way
 *  round. Null while what is typed is not an amount. */
export function amountHint(
  raw: string,
  decimals: number,
  amountIn: AmountIn,
  options: { max?: boolean } = {},
): string | null {
  if (amountIn === "token") {
    const amount = tokenAmount(raw, decimals, options);
    if ("error" in amount) return null;
    return amount.base === MAX_UINT256
      ? "an unlimited allowance"
      : `${amount.base} base units`;
  }
  const base = baseUnits(raw);
  if (base === undefined) return null;
  return base >= MAX_UINT256
    ? "an unlimited allowance"
    : `${formatUnits(base, decimals)} in token units`;
}

/** The amount field of a token call, as the form draws it. */
export interface AmountField {
  /** The unit the field is in, for its label. */
  unit: string;
  /** The amount in the other unit, once what is typed is one. */
  hint: string | null;
  /** Why what is typed cannot be written. */
  error: string | null;
  /** The field takes `max`: an unlimited allowance. */
  canMax: boolean;
  /** The label of the switch to the other unit. */
  switchTo: string;
}

/**
 * The amount field of `transfer`, `approve` and `transferFrom` on a
 * contract that says its decimals: in the token's own units unless the
 * user switched to base units. `symbol` is the token list's, the only
 * name a token is shown under. Null for any other call or contract: the
 * field takes what the ABI says, as typed.
 */
export function amountField({
  signature,
  decimals,
  symbol,
  amountIn,
  raw,
}: {
  signature: string;
  decimals: number | undefined;
  symbol?: string;
  amountIn: AmountIn;
  raw: string;
}): AmountField | null {
  if (!isTokenAmountCall(signature) || decimals === undefined) return null;
  const tokens = symbol ?? "token units";
  const max = takesMax(signature);
  const hint = amountHint(raw, decimals, amountIn, { max });
  if (amountIn === "base")
    return {
      unit: "base units",
      hint: hint === null ? null : `= ${symbol ? hint.replace("in token units", symbol) : hint}`,
      error: null,
      canMax: false,
      switchTo: `Type ${tokens}`,
    };
  const amount = raw.trim() === "" ? null : tokenAmount(raw, decimals, { max });
  return {
    unit: tokens,
    hint: hint === null ? null : `= ${hint}`,
    error: amount && "error" in amount ? amount.error : null,
    canMax: max,
    switchTo: "Type base units",
  };
}

/** A whole number of base units as typed: digits, or `25e17`. */
function baseUnits(raw: string): bigint | undefined {
  const value = raw.trim();
  if (/^\d+$/.test(value)) return BigInt(value);
  const scaled = value.match(/^(\d+)e(\d+)$/);
  if (scaled && Number(scaled[2]) <= 77)
    return BigInt(scaled[1]) * 10n ** BigInt(scaled[2]);
  return undefined;
}

/**
 * An amount of a token in the token's own units, exact to the last base
 * unit: this is what an action sends, so nothing is rounded. Undefined,
 * and the amount stays as typed, when it is not a whole number of base
 * units, is the largest number there is (an unlimited approval), or is
 * dust that would read as a run of zeros.
 */
export function tokenUnits(raw: string, decimals: number): string | undefined {
  const amount = baseUnits(raw);
  if (amount === undefined || amount >= MAX_UINT256) return undefined;
  const units = formatUnits(amount, decimals);
  if (amount !== 0n && Number(units) < 0.000001) return undefined;
  return units;
}

/** A parameter's name as a variable name: `_to` is `to`. Nothing for a
 *  name the form made up (`arg0`) or one that is not a plain word. */
function parameterName(name: string): string | undefined {
  const plain = name.replace(/^_+|_+$/g, "");
  if (!PLAIN_WORD.test(plain) || /^arg\d+$/.test(name)) return undefined;
  return plain;
}

/**
 * The name an address would like in a script. A token the chain's list
 * resolves a symbol to is that symbol (`usdc`): the list is the only
 * thing that names a token, never what a contract says of itself. An
 * argument is otherwise its parameter (`to`, `spender`), unless that
 * word is the symbol of a listed token somewhere else (`$usdc` must not
 * be anything but USDC) or a name of the executing account (`$safe`,
 * `$executor`: only the context gives those). Failing both, what it is: `contract` for the
 * contract called, `address` for an argument.
 */
export function wantedName(
  address: Address,
  role: { target: true } | { parameter: string },
  env: Pick<ComposeEnv, "chainId" | "nativeSymbol" | "tokens">,
): string {
  return wanted(address, role, env).wanted;
}

/** The name, and where it comes from: the list's name is never replaced,
 *  a role is while the address plays one role only (`bindVariables`). */
function wanted(
  address: Address,
  role: { target: true } | { parameter: string },
  env: Pick<ComposeEnv, "chainId" | "nativeSymbol" | "tokens">,
): { wanted: string; origin: NameOrigin } {
  const listed = symbolInList(env.tokens, env.chainId, env.nativeSymbol, address);
  if (listed) return { wanted: listed.toLowerCase(), origin: "list" };
  if ("target" in role) return { wanted: "contract", origin: "role" };
  const name = parameterName(role.parameter);
  const borrowed =
    name !== undefined &&
    env.tokens.some(
      (token) =>
        token.chainId === env.chainId &&
        typeof token.symbol === "string" &&
        token.symbol.toLowerCase() === name.toLowerCase(),
    );
  // Nor may it be a name of the executing account (`$safe`, `$executor`):
  // whoever published the ABI wrote the parameter's name, and those names
  // are the user's own statement (`ACCOUNT_NAMES`).
  return name !== undefined && !borrowed && !isAccountName(name)
    ? { wanted: name, origin: "role" }
    : { wanted: "address", origin: "neutral" };
}

/** The `exec` line for a call, with a placeholder (`$_0`, `$_1`, ...) for
 *  each address and the name each would like. */
export async function composeCall(
  call: CallInput,
  env: ComposeEnv,
): Promise<{ line: string; vars: LineVariable[] }> {
  const vars: LineVariable[] = [];
  const refOf = (address: string, role: Parameters<typeof wanted>[1]): string => {
    const value = getAddress(address);
    let variable = vars.find((v) => v.value === value);
    if (!variable) {
      variable = { name: `_${vars.length}`, value, ...wanted(value, role, env) };
      vars.push(variable);
    }
    return `$${variable.name}`;
  };

  const target = isAddress(call.targetRef)
    ? refOf(call.target, { target: true })
    : call.targetRef;

  const last = call.inputs.length - 1;
  let decimals: number | undefined;
  if (TOKEN_AMOUNT_CALLS.has(call.signature))
    decimals = await env
      .decimalsOf(call.target as Address)
      .catch(() => undefined);

  // The amount as typed in base units, whatever unit the field was in.
  let typed = call.values[call.inputs[last]?.name] ?? "";
  if (call.amountIn === "token") {
    if (decimals === undefined)
      throw new Error("This contract does not say its decimals: type the amount in base units.");
    const amount = tokenAmount(typed, decimals, { max: takesMax(call.signature) });
    if ("error" in amount) throw new Error(amount.error);
    typed = String(amount.base);
  }
  // A bare integer does not say what it counts: where the line holds
  // base units of the token, it says so as a suggested check does.
  let inBaseUnits = false;

  const args = await Promise.all(
    call.inputs.map(async (input, i) => {
      const raw = i === last ? typed : (call.values[input.name] ?? "");
      if (i === last && decimals !== undefined) {
        const units = tokenUnits(raw, decimals);
        if (units !== undefined) return `@token:amount(${target} ${units})`;
        const base = baseUnits(raw);
        if (base !== undefined && base < MAX_UINT256) {
          inBaseUnits = true;
          return String(base);
        }
      }
      const tree = call.trees && Object.hasOwn(call.trees, input.name) ? call.trees[input.name] : undefined;
      if (tree !== undefined) {
        // An address inside a list has no part of its own to be named for.
        const write = (node: ArgTree): string =>
          "address" in node
            ? refOf(node.address, { parameter: "" })
            : "literal" in node
              ? node.literal
              : `[${node.map(write).join(" ")}]`;
        return write(tree);
      }
      const role = TOKEN_CALL_ROLES[call.signature]?.[i] ?? input.name;
      return evmlArg(input.type, raw, env.ensToVar, (address) =>
        refOf(address, { parameter: role }),
      );
    }),
  );
  const argStr = args.join(" ");
  const valueOpt = call.value?.trim() ? ` --value ${call.value.trim()}` : "";
  const unit = inBaseUnits ? `${BASE_UNITS_COMMENT}${target}` : "";
  return {
    line: `exec ${target} "${call.signature}"${argStr ? ` ${argStr}` : ""}${valueOpt}${unit}`,
    vars,
  };
}

/** An action as the contract form holds it: what `decomposeCall` reads
 *  back from a line the form could have written. */
export interface DecomposedCall {
  /** The contract: its address, or the ENS name it was given as. */
  target: string;
  signature: string;
  /** One text per argument, as the form's fields take them. */
  args: string[];
  /** `--value` as written, empty without one. */
  value: string;
  /** The unit the last argument is in. */
  amountIn: AmountIn;
}

/**
 * The action on a 1-based line of a script, read back into what the form
 * fills its fields with. Null for anything the form does not model (a
 * helper, a read, a variable that is no address, an option it has no
 * field for, a command that is no `exec` with a signature): that is
 * edited in the EVML editor.
 */
export function decomposeCall(script: string, line: number): DecomposedCall | null {
  const spans = commandSpans(script);
  const span = spanAtLine(spans, line);
  const node = span?.node;
  if (!span || !node || node.module || node.name !== "exec") return null;
  const lines = script.split("\n");
  const source = (n: Node): string | null => {
    if (!n.loc || n.loc.start.line !== n.loc.end.line) return null;
    return (lines[n.loc.start.line - 1] ?? "").slice(n.loc.start.col, n.loc.end.col);
  };
  const addresses = addressVariables(script);
  const names = new Map<string, string>();
  for (const other of spans) {
    if (!other.node || !isSetSpan(other) || other.node.args.length !== 2) continue;
    const variable = setTarget(other.node);
    const helper = other.node.args[1] as HelperFunctionNode;
    if (
      variable &&
      helper.type === NodeType.HelperFunctionExpression &&
      !helper.module &&
      helper.name === "ens" &&
      helper.args.length === 1
    ) {
      const name = source(helper.args[0]);
      if (name) names.set(variable.replace(/^\$/, ""), name.replace(/^["']|["']$/g, ""));
    }
  }
  const addressOf = (n: Node): string | null => {
    if (n.type === NodeType.AddressLiteral) return String(n.value);
    if (n.type !== NodeType.VariableIdentifier) return null;
    const name = String(n.value).replace(/^\$/, "");
    return addresses.get(name) ?? names.get(name) ?? null;
  };

  const [targetNode, signatureNode, ...argNodes] = node.args;
  if (!targetNode || signatureNode?.type !== NodeType.StringLiteral) return null;
  const target = addressOf(targetNode);
  if (target === null) return null;
  let types: string[];
  let signature: string;
  try {
    const item = parseAbiItem(`function ${String(signatureNode.value)}`);
    if (item.type !== "function") return null;
    types = item.inputs.map(canonicalType);
    signature = `${item.name}(${types.join(",")})`;
  } catch {
    return null;
  }
  if (signature !== String(signatureNode.value) || argNodes.length !== types.length)
    return null;

  let value = "";
  for (const opt of node.opts) {
    if (opt.name !== "value" || opt.value.type !== NodeType.NumberLiteral) return null;
    const written = source(opt.value);
    if (written === null) return null;
    value = written;
  }

  const text = (n: Node, type: string): string | null => {
    const array = type.match(/^(.*)\[\d*\]$/);
    const tuple = type.startsWith("(") && type.endsWith(")");
    if (array || tuple) {
      // The parser reads `[]` and an array of variables alone (`[$a $b]`)
      // as a pattern of slots.
      if (n.type === NodeType.DestructurePattern) {
        const slots = (n as Node & { slots?: unknown[] }).slots ?? [];
        const inner = tuple ? splitTypes(type.slice(1, -1)) : null;
        if (inner && inner.length !== slots.length) return null;
        const parts = slots.map((slot, i) =>
          typeof slot === "string" && slot.startsWith("$")
            ? text(
                { type: NodeType.VariableIdentifier, value: slot },
                inner ? inner[i] : (array as RegExpMatchArray)[1],
              )
            : null,
        );
        return parts.some((part) => part === null) ? null : `[${parts.join(", ")}]`;
      }
      if (n.type !== NodeType.ArrayExpression) return null;
      const elements = (n as ArrayExpressionNode).elements;
      const inner = tuple ? splitTypes(type.slice(1, -1)) : null;
      if (inner && inner.length !== elements.length) return null;
      const parts = elements.map((el, i) => text(el, inner ? inner[i] : (array as RegExpMatchArray)[1]));
      return parts.some((part) => part === null) ? null : `[${parts.join(", ")}]`;
    }
    if (type === "address") return addressOf(n);
    if (type === "string")
      return n.type === NodeType.StringLiteral ? String(n.value) : null;
    const literal =
      type === "bool"
        ? n.type === NodeType.BoolLiteral
        : type.startsWith("bytes")
          ? n.type === NodeType.BytesLiteral
          : n.type === NodeType.NumberLiteral;
    return literal ? source(n) : null;
  };

  let amountIn: AmountIn = "base";
  const args: string[] = [];
  for (const [i, argNode] of argNodes.entries()) {
    const amount = argNode as HelperFunctionNode;
    if (
      i === argNodes.length - 1 &&
      isTokenAmountCall(signature) &&
      amount.type === NodeType.HelperFunctionExpression
    ) {
      // `@token:amount(<the contract called> <number>)`, and nothing else.
      const [of, units] = amount.args;
      const number = units?.type === NodeType.NumberLiteral ? source(units) : null;
      if (
        amount.module !== "token" ||
        amount.name !== "amount" ||
        amount.args.length !== 2 ||
        addressOf(of)?.toLowerCase() !== target.toLowerCase() ||
        number === null ||
        !/^\d+(\.\d+)?$/.test(number)
      )
        return null;
      amountIn = "token";
      args.push(number);
      continue;
    }
    const written = text(argNode, types[i]);
    if (written === null) return null;
    args.push(written);
  }
  return { target, signature, args, value, amountIn };
}

/** The component types of a tuple, split at its top-level commas. */
function splitTypes(types: string): string[] {
  const parts: string[] = [];
  let depth = 0;
  let current = "";
  for (const ch of types) {
    if (ch === "(") depth++;
    if (ch === ")") depth--;
    if (ch === "," && depth === 0) {
      parts.push(current);
      current = "";
    } else current += ch;
  }
  if (current) parts.push(current);
  return parts;
}
