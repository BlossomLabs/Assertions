import type { Address, PublicClient } from "viem";
import { isAddress, keccak256, parseAbiItem } from "viem";

import type { CallHop, ValueExpr } from "./assertion-model";
import { resolveLens } from "./assertion-model";

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
 * address, timestamp/block number, len/bytelen transforms and the
 * numeric operators over those. Logic, split, hash and token symbols
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
          (h) =>
            h.fnName &&
            h.args.every((a) =>
              typeof a === "string" ? a.trim() : isEvaluable(a),
            ),
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
    case "chainid":
      return true;
    case "codehash":
      return (
        (expr.address.kind === "literal" &&
          isAddress(expr.address.value.trim())) ||
        (expr.address.kind === "call" && isEvaluable(expr.address))
      );
    case "minmax":
      return expr.items.length >= 2 && expr.items.every(isEvaluable);
    case "absdiff":
      return isEvaluable(expr.a) && isEvaluable(expr.b);
    case "arith":
    case "bytes":
      return isEvaluable(expr.left) && isEvaluable(expr.right);
    case "callwrap":
      return expr.helper !== "hash" && isEvaluable(expr.call);
    default:
      return false;
  }
}

/** Apply a hop's selection to its decoded result: first the picked output
 *  of a multi-value return, then each lens-path level (array elements and
 *  struct values both decode as arrays here). */
function narrowHop(hop: CallHop, result: unknown): unknown {
  let value = result;
  if (
    hop.returnTypes.length > 1 &&
    hop.lensIndex !== undefined &&
    Array.isArray(value)
  )
    value = value[hop.lensIndex];
  const lens = resolveLens(hop);
  if (lens?.valid) {
    for (const idx of lens.entries) {
      if (!Array.isArray(value))
        throw new Error("the selection does not match the decoded shape");
      const picked = idx < 0 ? value[value.length + idx] : value[idx];
      if (picked === undefined)
        throw new Error("selected element is out of the decoded range");
      value = picked;
    }
  }
  return value;
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
  for (let i = 0; i < expr.hops.length; i++) {
    const hop = expr.hops[i];
    const abiItem = parseAbiItem(
      `function ${hop.fnName}(${hop.argTypes.join(",")}) view returns (${hop.returnTypes.join(",")})`,
    );
    result = await client.readContract({
      address,
      abi: [abiItem],
      functionName: hop.fnName,
      args: await Promise.all(
        hop.argTypes.map((type, i) => {
          const arg = hop.args[i];
          // A nested live call argument: read its (lens-narrowed) value
          // now — a build-time snapshot of what the judge splices live.
          if (typeof arg === "object")
            return evalCall(client, arg, executor);
          return parseCallArg(type, arg ?? "", executor);
        }),
      ),
    });
    if (i < expr.hops.length - 1) {
      // The chain continues on the hop's selected address (a lens may
      // reach through array elements and struct values to pick it).
      const narrowed = narrowHop(hop, result);
      address = (Array.isArray(narrowed) ? narrowed[0] : narrowed) as Address;
    }
  }
  const last = expr.hops[expr.hops.length - 1];
  return last ? narrowHop(last, result) : result;
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
 * Client-side mirror of the operators the "use current value" button can
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
    case "chainid":
      return BigInt(await client.getChainId());
    case "codehash":
      // bytes32 has no place in the numeric operators; readSubjectValue
      // special-cases it to a hex string instead.
      throw new Error("codehash is not a numeric value");
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
      }
      break;
    }
    case "bytes": {
      const [l, r] = await Promise.all([
        evalExpr(client, expr.left, executor),
        evalExpr(client, expr.right, executor),
      ]);
      const mask = (1n << 256n) - 1n;
      const lw = l & mask;
      const rw = r & mask;
      switch (expr.op) {
        case "&":
          return lw & rw;
        case "|":
          return lw | rw;
        case "^":
          return lw ^ rw;
        case "<<":
          return rw > 255n ? 0n : (lw << rw) & mask;
        case ">>":
          return rw > 255n ? 0n : lw >> rw;
      }
      break;
    }
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
  if (expr.kind === "codehash") {
    if (expr.address.kind !== "call" && expr.address.kind !== "literal")
      throw new Error("unsupported codehash address");
    const address =
      expr.address.kind === "call"
        ? ((await evalCall(client, expr.address, executor)) as Address)
        : (parseCallArg("address", expr.address.value, executor) as Address);
    // EXTCODEHASH semantics, mirroring the @codehash helper: nonexistent
    // account -> bytes32(0), existing code-less account -> keccak256("").
    const code = await client.getCode({ address });
    if (code && code !== "0x") return keccak256(code);
    const [nonce, balance] = await Promise.all([
      client.getTransactionCount({ address }),
      client.getBalance({ address }),
    ]);
    if (nonce === 0 && balance === 0n)
      return "0x0000000000000000000000000000000000000000000000000000000000000000";
    return keccak256("0x");
  }
  return formatResult(await evalExpr(client, expr, executor));
}
