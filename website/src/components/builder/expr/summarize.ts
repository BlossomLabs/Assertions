import {
  type CallHop,
  type CallNode,
  type ValueExpr,
  argText,
  callwrapHelperName,
  settledHops,
} from "../assertion-model";

/**
 * What is picked out of a call's return, written as indices after it:
 * `[1]` for the second return value, then one index per array element or
 * struct value reached, `[-1]` being the last element. Empty when the
 * whole return is used.
 */
export function lensText(hop: CallHop): string {
  const picked: string[] = [];
  if (hop.returnTypes.length > 1 && hop.lensIndex !== undefined)
    picked.push(String(hop.lensIndex));
  for (const entry of hop.lensPath ?? [])
    if (entry.trim() !== "") picked.push(entry.trim());
  return picked.map((index) => `[${index}]`).join("");
}

/** One-line summary of a call: its contract, then its functions, each
 *  with what is picked out of its return. */
export function callSummary(node: CallNode): string {
  const target = node.target.trim();
  if (!target) return "empty call";
  const short = /^0x[0-9a-fA-F]{40}$/.test(target)
    ? `${target.slice(0, 6)}…${target.slice(-4)}`
    : target;
  const fns = node.hops
    .filter((h) => h.fnName)
    .map((h) => `${h.fnName}()${lensText(h)}`)
    .join(".");
  return fns ? `${short}.${fns}` : short;
}

/**
 * Everything a call does after naming its contract, written out in full:
 * each function with its arguments (a live one by its summary) and what is
 * picked out of its return. Empty until a function is chosen.
 */
export function callTail(node: CallNode): string {
  return settledHops(node.hops)
    .filter((hop) => hop.fnName)
    .map((hop) => {
      const args = hop.args.map((arg) => {
        const text = argText(arg);
        if (text !== null) return text.trim() || "…";
        return summarize(arg as ValueExpr);
      });
      return `.${hop.fnName}(${args.join(", ")})${lensText(hop)}`;
    })
    .join("");
}

/** One-line summary of a value, shown on its pill. */
export function summarize(node: ValueExpr): string {
  switch (node.kind) {
    case "literal":
      return node.value.trim() || "(empty value)";
    case "call":
      return callSummary(node);
    case "balance":
      return `balance of ${node.token || "…"}`;
    case "minmax":
      return `@${node.op}! of ${node.items.length} values`;
    case "absDiff":
      return "|a − b|";
    case "arith":
      return node.op === "/"
        ? `division, rounding ${node.rounding === "ceil" ? "up" : "down"}`
        : `arithmetic (${node.op})`;
    case "cmp":
      return `comparison (${node.op})`;
    case "logic":
      return `logic (${node.op})`;
    case "bytes":
      return `bitwise (${node.op})`;
    case "not":
      return "not …";
    case "callwrap":
      return `@${callwrapHelperName(node.helper)}!(…)`;
    case "split":
      return `@str.split!(… ${node.index})`;
    case "strtest":
      return `@str.${node.helper}!(… ${node.arg ? JSON.stringify(node.arg) : "…"})`;
    case "numformat":
      return `@num.format!(… ${node.decimals})`;
    case "numparse":
      return `@num.parse!(… ${node.decimals})`;
    case "clock":
      return `@${node.which}!`;
    case "chainId":
      return "@chainId!";
    case "codeHash":
      return "@codeHash!(…)";
    case "codeAt":
      return "@codeAt!(…)";
  }
}
