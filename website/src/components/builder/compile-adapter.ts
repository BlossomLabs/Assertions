import { type EvmlTag, parseDiagnosticString } from "@evmcrispr/core";
import type { InputParam, Operand, ResolvedValue } from "@evmcrispr/sdk/onchain";
import {
  CORE_ADDRESS,
  decodeResolved,
  isAssertionAction,
  resolveCall,
} from "@evmcrispr/sdk/onchain";
import type { PublicClient } from "viem";
import { formatUnits } from "viem";

import { buildExprText } from "./assertion-codegen";
import { type Category, type ValueExpr, inferCategory } from "./assertion-model";
import {
  type AssertionPlacement,
  type CommandSpan,
  commandSpans,
  insertAssertionLines,
  isDefSpan,
  isLoadSpan,
  isSetSpan,
  setTarget,
  spanAtLine,
  variableRefs,
} from "./script-ops";

/**
 * The compiler as the form's authority: an assertion line is merged into
 * the batch, validated offline, then compiled by interpreting a PROBE (the
 * batch's load/def lines, the set lines the assertion reaches, and the
 * line itself; never the whole batch, whose exec/send lines would hit RPC
 * and ABI fetches). The compiled operands come back beside the diagnostics.
 */

export interface CompileDiagnostic {
  /** 1-based line in the candidate script and 0-based columns, when the
   *  error carries a location. */
  line?: number;
  col?: number;
  endLine?: number;
  endCol?: number;
  message: string;
  /** The location falls inside the inserted assertion (otherwise the
   *  problem sits elsewhere in the batch). */
  inAssertion: boolean;
}

export interface CompileOutcome {
  ok: boolean;
  /** The live side, after mirroring. */
  subject?: Operand & { kind: "call" };
  expected?: Operand;
  param?: InputParam;
  /** The assertion only resolves inside a transaction: an eth_call cannot
   *  preview it. */
  transact?: boolean;
  diagnostics: CompileDiagnostic[];
  /** The batch with the assertion (and its scaffolding) merged in. */
  candidate: string;
  /** 1-based line the assertion landed on in `candidate`. */
  insertedAt: number;
}

/** `Name(l:c,l:c): msg` with any name shape (`@helper`, `mod:cmd`, ...):
 *  the core's `parseDiagnosticString` accepts word names only. */
const LOCATED_RE = /^(\S+?)\((\d+):(\d+)(?:,(\d+):(\d+))?\):\s*(.+)$/s;

function locate(message: string): {
  line?: number;
  col?: number;
  endLine?: number;
  endCol?: number;
  message: string;
} {
  const parsed = parseDiagnosticString(message);
  if (parsed) return parsed;
  const m = message.match(LOCATED_RE);
  if (!m) return { message };
  return {
    line: Number(m[2]),
    col: Number(m[3]),
    ...(m[4] !== undefined ? { endLine: Number(m[4]), endCol: Number(m[5]) } : {}),
    message: m[6],
  };
}

/** The probe: load and def spans, the set spans the assertion reaches
 *  (transitively) and the assertion itself, with a map from each probe
 *  line to the candidate line it came from. */
function buildProbe(
  candidate: string,
  target: CommandSpan,
  spans: CommandSpan[],
): { probe: string; lineMap: number[] } {
  const sets = spans.filter((s) => isSetSpan(s) && s.node);
  const needed = new Set<CommandSpan>();
  const queue = [target];
  while (queue.length) {
    const span = queue.pop() as CommandSpan;
    if (needed.has(span)) continue;
    needed.add(span);
    if (!span.node) continue;
    const own = isSetSpan(span) ? setTarget(span.node) : undefined;
    const refs = variableRefs(span.node).filter((v) => v !== own);
    for (const set of sets) {
      const defined = set.node ? setTarget(set.node) : undefined;
      if (defined && refs.includes(defined)) queue.push(set);
    }
  }
  const lines = candidate.split("\n");
  const probeLines: string[] = [];
  const lineMap: number[] = [];
  for (const span of spans) {
    if (!(isLoadSpan(span) || isDefSpan(span) || needed.has(span))) continue;
    for (let l = span.start; l <= span.end; l++) {
      probeLines.push(lines[l - 1] ?? "");
      lineMap.push(l);
    }
  }
  return { probe: probeLines.join("\n"), lineMap };
}

/**
 * Merge `line` (plus its hoisted `sets`) into `script`, validate the
 * candidate offline, then compile the assertion through a probe. `ok`
 * means the compiler accepted it; the diagnostics carry candidate
 * locations and say whether they fall inside the assertion.
 */
export async function compileAssertionLine(
  tag: EvmlTag,
  script: string,
  line: string,
  sets: string[],
  placement: AssertionPlacement,
  { signal }: { signal?: AbortSignal } = {},
): Promise<CompileOutcome> {
  const { script: candidate, insertedAt } = insertAssertionLines(
    script,
    line,
    placement,
    sets,
  );
  const spans = commandSpans(candidate);
  const target = spanAtLine(spans, insertedAt);
  const assertionEnd = target?.end ?? insertedAt;
  const inAssertion = (l: number | undefined) =>
    l !== undefined && l >= insertedAt && l <= assertionEnd;
  const base = { candidate, insertedAt };

  const validation = await tag.script(candidate).validate();
  const errors = validation.diagnostics.filter((d) => d.severity === "error");
  if (errors.length > 0) {
    return {
      ...base,
      ok: false,
      diagnostics: errors.map((d) => ({
        line: d.line,
        col: d.col,
        endLine: d.endLine,
        endCol: d.endCol,
        message: d.message,
        inAssertion: inAssertion(d.line),
      })),
    };
  }
  if (!target) {
    return {
      ...base,
      ok: false,
      diagnostics: [
        { message: "The assertion did not parse as a command.", inAssertion: true },
      ],
    };
  }

  const { probe, lineMap } = buildProbe(candidate, target, spans);
  const fail = (message: string): CompileOutcome => {
    const located = locate(message);
    const mapped = (l: number | undefined) =>
      l === undefined ? undefined : (lineMap[l - 1] ?? l);
    const lineAt = mapped(located.line);
    return {
      ...base,
      ok: false,
      diagnostics: [
        {
          line: lineAt,
          col: located.col,
          endLine: mapped(located.endLine),
          endCol: located.endCol,
          message: located.message,
          // An error with no location came out of the probe, whose only
          // non-scaffolding command is the assertion.
          inAssertion: lineAt === undefined ? true : inAssertion(lineAt),
        },
      ],
    };
  };

  try {
    const actions = await tag.script(probe).interpret({ signal });
    if (signal?.aborted) return { ...base, ok: false, diagnostics: [] };
    const action = actions[0];
    if (actions.length !== 1 || !action || !isAssertionAction(action)) {
      return fail(
        `expected the assertion to compile to one action, got ${actions.length}`,
      );
    }
    const { compiled } = action;
    return {
      ...base,
      ok: true,
      subject: compiled.subject,
      expected: compiled.expected,
      param: compiled.param,
      transact: action.readOnly === false,
      diagnostics: [],
    };
  } catch (e) {
    if (signal?.aborted) return { ...base, ok: false, diagnostics: [] };
    return fail(e instanceof Error ? e.message : String(e));
  }
}

export type ValuePreview =
  | { kind: "value" | "const"; text: string }
  | { kind: "not-previewable"; reason: string }
  | { kind: "error"; message: string };

/** A constant of the category that `!=` accepts against any value. */
const PLACEHOLDER: Partial<Record<Category, string>> = {
  uint: "0",
  int: "0",
  address: "0x0000000000000000000000000000000000000000",
  bool: "false",
  bytes32: `0x${"00".repeat(32)}`,
  string: '""',
  bytes: "0x",
};

/** The inline ABI type of a live placeholder of the category. */
const LIVE_TYPE: Partial<Record<Category, string>> = {
  uint: "uint256",
  int: "int256",
  address: "address",
  bool: "bool",
  bytes32: "bytes32",
  string: "string",
  bytes: "bytes",
};

const BOTH_CONST = /both sides are build-time constants/;

function constText(operand: Operand & { kind: "const" }): string {
  const v = operand.value;
  if (typeof v === "boolean" || typeof v === "string") return String(v);
  return v.isInteger() ? v.toBigInt().toString() : v.toString();
}

function resolvedText(value: ResolvedValue, scale: number): string {
  switch (value.t) {
    case "num": {
      const whole = value.v.toBigInt();
      return scale > 0 ? formatUnits(whole, scale) : whole.toString();
    }
    case "bool":
      return value.v ? "true" : "false";
    case "list":
      return `[${value.v.map((v) => resolvedText(v, scale)).join(" ")}]`;
    default:
      return value.v;
  }
}

/**
 * The current value of a subject expression, read the way the assertion
 * will read it: the expression is compiled inside a probe assertion
 * (`assert <subject> != <placeholder>`; `!=` is legal for every category
 * and mirroring keeps the live side in `subject`), then the compiled
 * operand is resolved through the core with one eth_call and decoded by
 * the SDK's own decoder. A build-time constant is reported as its text.
 */
export async function previewSubjectValue(
  tag: EvmlTag,
  client: PublicClient,
  script: string,
  subject: ValueExpr,
  chainId: number,
): Promise<ValuePreview> {
  const built = await buildExprText(subject, {
    resolveEns: async () => null,
    chainId,
  }).catch(() => null);
  if (!built) return { kind: "error", message: "The value is incomplete." };
  const cat = inferCategory(subject);
  const compile = (placeholder: string) =>
    compileAssertionLine(
      tag,
      script,
      `assert ${built.line} != ${placeholder}`,
      built.sets,
      "post",
    );

  let compiled = await compile(PLACEHOLDER[cat] ?? "0");
  if (!compiled.ok && compiled.diagnostics.some((d) => BOTH_CONST.test(d.message))) {
    // The subject folded to a constant: compile it against a live
    // placeholder of its category, so the compiler mirrors it into
    // `expected` and hands back its value.
    const live = `${CORE_ADDRESS}::{LEN()(${LIVE_TYPE[cat] ?? "uint256"})}`;
    compiled = await compile(live);
    if (compiled.ok && compiled.expected?.kind === "const")
      return { kind: "const", text: constText(compiled.expected) };
    return {
      kind: "not-previewable",
      reason: "This value is fixed at composition time.",
    };
  }
  if (!compiled.ok)
    return {
      kind: "error",
      message: compiled.diagnostics[0]?.message ?? "The value does not compile.",
    };
  if (compiled.transact)
    return {
      kind: "not-previewable",
      reason: "This value only resolves inside a transaction.",
    };
  const operand = compiled.subject;
  if (!operand) return { kind: "error", message: "The value does not compile." };
  const call = resolveCall(operand);
  if (!call) return { kind: "const", text: "" };
  try {
    const { data } = await client.call({
      to: call.to,
      data: call.data,
      ...(tag.config.account ? { account: tag.config.account } : {}),
    });
    const scale = operand.scale ?? 0;
    const value = decodeResolved((data ?? "0x") as `0x${string}`, operand.cat, 0);
    return { kind: "value", text: resolvedText(value, scale) };
  } catch (e) {
    return { kind: "error", message: e instanceof Error ? e.message : String(e) };
  }
}
