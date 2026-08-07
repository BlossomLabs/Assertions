import type { Address, PublicClient } from "viem";
import { isAddress, parseAbiItem } from "viem";

import type { ValueExpr } from "./assertion-model";

/** Integer parse accepting EVML-ish e-notation ("1e18", "2.5e6"). */
export function parseNumeric(v: string): bigint {
  if (/^-?\d+$/.test(v)) return BigInt(v);
  const m = v.match(/^(-?\d+)(?:\.(\d+))?e\+?(\d+)$/i);
  if (m) {
    const [, int, frac = "", exp] = m;
    const zeros = Number(exp) - frac.length;
    if (zeros >= 0) return BigInt(int + frac + "0".repeat(zeros));
  }
  throw new Error(`cannot parse "${v}" as an integer`);
}

/** Form string → JS value for an eth_call argument. */
export function parseCallArg(
  type: string,
  raw: string,
  executor?: Address,
): unknown {
  const v = raw.trim();
  if (v === "@me") {
    if (!executor) throw new Error("connect a wallet to resolve @me");
    return executor;
  }
  if (/^u?int\d*$/.test(type)) return parseNumeric(v);
  if (type === "bool") return v === "true";
  if (type === "address" || type.startsWith("bytes") || type === "string")
    return v;
  throw new Error(`unsupported argument type ${type}`);
}

/** eth_call result → form string. */
export function formatResult(value: unknown): string {
  if (typeof value === "bigint") return value.toString();
  if (typeof value === "boolean") return value ? "true" : "false";
  return String(value);
}

/** Unix-seconds string → local "YYYY-MM-DDTHH:mm" for a datetime-local
 *  input ("" when the value isn't a plain timestamp). */
export function unixToDatetimeLocal(value: string): string {
  const v = value.trim();
  if (!/^\d+$/.test(v)) return "";
  const d = new Date(Number(v) * 1000);
  if (Number.isNaN(d.getTime()) || d.getFullYear() > 9999) return "";
  const pad = (n: number) => String(n).padStart(2, "0");
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}T${pad(d.getHours())}:${pad(d.getMinutes())}`;
}

function callAddress(
  expr: Extract<ValueExpr, { kind: "call" }>,
): Address | null {
  const t = expr.target.trim();
  return isAddress(t) ? t : ((expr.resolved as Address | null) ?? null);
}

/**
 * True when `evalExpr` can read the expression's current value client-side:
 * complete calls (any chain length), balances of ETH or a token given by
 * address, timestamp/block number, len/bytelen/at transforms and the
 * numeric combinators over those. Logic, split, hash and token symbols
 * (other than ETH) are not modeled.
 */
export function isEvaluable(expr: ValueExpr): boolean {
  switch (expr.kind) {
    case "literal": {
      const v = expr.value.trim();
      if (!v) return false;
      try {
        parseNumeric(v);
        return true;
      } catch {
        return false;
      }
    }
    case "call":
      return (
        callAddress(expr) !== null &&
        expr.hops.length > 0 &&
        expr.hops.every(
          (h) => h.fnName && h.args.every((a) => a.trim()),
        )
      );
    case "balance":
      return (
        (expr.token.trim().toUpperCase() === "ETH" ||
          isAddress(expr.token.trim())) &&
        (expr.account.kind === "call"
          ? isEvaluable(expr.account)
          : expr.account.kind === "literal")
      );
    case "clock":
      return true;
    case "minmax":
      return expr.items.length >= 2 && expr.items.every(isEvaluable);
    case "absdiff":
      return isEvaluable(expr.a) && isEvaluable(expr.b);
    case "arith":
      return isEvaluable(expr.left) && isEvaluable(expr.right);
    case "neg":
      return isEvaluable(expr.operand);
    case "callwrap":
      return expr.helper !== "hash" && isEvaluable(expr.call);
    case "at":
      return /^\d+$/.test(expr.index.trim()) && isEvaluable(expr.call);
    default:
      return false;
  }
}

/** Follow a call chain with eth_call and return the decoded final result. */
async function evalCall(
  client: PublicClient,
  expr: Extract<ValueExpr, { kind: "call" }>,
  executor?: Address,
): Promise<unknown> {
  let address = callAddress(expr);
  if (!address) throw new Error("unresolved target");
  let result: unknown = null;
  for (const hop of expr.hops) {
    const abiItem = parseAbiItem(
      `function ${hop.fnName}(${hop.argTypes.join(",")}) view returns (${hop.returnTypes.join(",")})`,
    );
    result = await client.readContract({
      address,
      abi: [abiItem],
      functionName: hop.fnName,
      args: hop.argTypes.map((type, i) =>
        parseCallArg(type, hop.args[i] ?? "", executor),
      ),
    });
    // Only consumed when another hop follows; a lens picks the address
    // out of a multi-value return.
    address = (
      Array.isArray(result) ? result[hop.lensIndex ?? 0] : result
    ) as Address;
  }
  return result;
}

const ERC20_BALANCE_OF = parseAbiItem(
  "function balanceOf(address) view returns (uint256)",
);

function toBigInt(value: unknown): bigint {
  if (typeof value === "bigint") return value;
  if (typeof value === "boolean") return value ? 1n : 0n;
  if (typeof value === "number") return BigInt(value);
  if (typeof value === "string") return parseNumeric(value);
  throw new Error("not a numeric value");
}

/**
 * Client-side mirror of the combinators the "use current value" button can
 * evaluate. Throws on anything `isEvaluable` rejects.
 */
export async function evalExpr(
  client: PublicClient,
  expr: ValueExpr,
  executor?: Address,
): Promise<bigint> {
  switch (expr.kind) {
    case "literal":
      return parseNumeric(expr.value.trim());
    case "call":
      return toBigInt(await evalCall(client, expr, executor));
    case "balance": {
      if (expr.account.kind !== "call" && expr.account.kind !== "literal")
        throw new Error("unsupported balance account");
      const account =
        expr.account.kind === "call"
          ? ((await evalCall(client, expr.account, executor)) as Address)
          : (parseCallArg("address", expr.account.value, executor) as Address);
      const token = expr.token.trim();
      if (token.toUpperCase() === "ETH")
        return client.getBalance({ address: account });
      return client.readContract({
        address: token as Address,
        abi: [ERC20_BALANCE_OF],
        functionName: "balanceOf",
        args: [account],
      });
    }
    case "clock": {
      const block = await client.getBlock();
      return expr.which === "timestamp" ? block.timestamp : block.number;
    }
    case "minmax": {
      const values = await Promise.all(
        expr.items.map((i) => evalExpr(client, i, executor)),
      );
      return values.reduce((a, b) =>
        expr.op === "min" ? (b < a ? b : a) : (b > a ? b : a),
      );
    }
    case "absdiff": {
      const [a, b] = await Promise.all([
        evalExpr(client, expr.a, executor),
        evalExpr(client, expr.b, executor),
      ]);
      return a > b ? a - b : b - a;
    }
    case "arith": {
      const [l, r] = await Promise.all([
        evalExpr(client, expr.left, executor),
        evalExpr(client, expr.right, executor),
      ]);
      switch (expr.op) {
        case "+":
          return l + r;
        case "-":
          return l - r;
        case "*":
          return l * r;
        case "/":
        case "//":
          return l / r;
        case "%":
          return l % r;
        case "^":
          return l ** r;
        case "xor":
          return l ^ r;
      }
      break;
    }
    case "neg":
      return -(await evalExpr(client, expr.operand, executor));
    case "callwrap": {
      if (expr.call.kind !== "call") throw new Error("expects a call");
      const result = await evalCall(client, expr.call, executor);
      if (expr.helper === "len") {
        if (Array.isArray(result)) return BigInt(result.length);
        if (typeof result === "string") return BigInt(result.length);
        throw new Error("len of a non-dynamic return");
      }
      if (expr.helper === "bytelen") {
        // Raw returndata size: 64 + n*32 for arrays, 64 + padded bytes for
        // string/bytes, 32 per word otherwise.
        if (Array.isArray(result)) return BigInt(64 + result.length * 32);
        if (typeof result === "string") {
          const bytes = result.startsWith("0x")
            ? (result.length - 2) / 2
            : new TextEncoder().encode(result).length;
          return BigInt(64 + Math.ceil(bytes / 32) * 32);
        }
        return 32n;
      }
      throw new Error("hash is not evaluable client-side");
    }
    case "at": {
      if (expr.call.kind !== "call") throw new Error("expects a call");
      const result = await evalCall(client, expr.call, executor);
      const index = Number(expr.index.trim());
      const values = Array.isArray(result) ? result : [result];
      if (index >= values.length)
        throw new Error("word index out of decoded range");
      return toBigInt(values[index]);
    }
    default:
      throw new Error(`cannot evaluate ${expr.kind} client-side`);
  }
  throw new Error("unreachable");
}

/** Read the current value of an evaluable subject, formatted for the
 *  expected-value literal. Single calls keep their native formatting
 *  (bool/address/string results included). */
export async function readSubjectValue(
  client: PublicClient,
  expr: ValueExpr,
  executor?: Address,
): Promise<string> {
  if (expr.kind === "call")
    return formatResult(await evalCall(client, expr, executor));
  return formatResult(await evalExpr(client, expr, executor));
}
