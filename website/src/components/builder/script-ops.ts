import { parseScript } from "@evmcrispr/core";
import type {
  ArrayExpressionNode,
  BlockExpressionNode,
  CallExpressionNode,
  CommandExpressionNode,
  CommandOptNode,
  HelperFunctionNode,
  NamedArgNode,
  Node,
} from "@evmcrispr/sdk";
import { NodeType, parseImportList } from "@evmcrispr/sdk";

import { HELPER_MODULES, ownerOf } from "./helper-owners";

/**
 * Script surgery on the parsed AST: which lines form one command, which
 * modules a command needs loaded, and the edits the builder makes to the
 * action block (inserting an assertion with its scaffolding, removing a
 * command with the scaffolding it orphaned). Pure functions over the
 * script text; every consumer goes through here instead of reading lines.
 *
 * Newlines inside `@h(...)`, `[...]`, `::(...)` and `(...)` blocks are
 * whitespace to the parser, so one command may span several lines.
 */

export type AssertionPlacement = "pre" | "post";

export interface CommandSpan {
  /** 1-based first and last line of the command, inclusive. */
  start: number;
  end: number;
  /** Command name, and its module prefix for `mod:cmd` forms. */
  name: string;
  module?: string;
  /** The parsed node; absent for a line the parser rejected. */
  node?: CommandExpressionNode;
  /** The command's source text, lines joined with "\n". */
  text: string;
}

const isBlankOrComment = (line: string): boolean => {
  const t = line.trim();
  return t === "" || t.startsWith("#");
};

/** Every top-level command of the script as a line span, in order. A line
 *  the parser rejects (or every non-blank line after a hard parse failure)
 *  still counts as one command, so nothing disappears from a listing. */
export function commandSpans(script: string): CommandSpan[] {
  const lines = script.split("\n");
  const textOf = (start: number, end: number) =>
    lines.slice(start - 1, end).join("\n");
  let body: CommandExpressionNode[] = [];
  try {
    body = parseScript(script).ast.body;
  } catch {
    body = [];
  }
  const spans: CommandSpan[] = [];
  const covered = new Set<number>();
  for (const node of body) {
    if (!node.loc) continue;
    const start = node.loc.start.line;
    const end = node.loc.end.line;
    spans.push({
      start,
      end,
      name: node.name,
      module: node.module,
      node,
      text: textOf(start, end),
    });
    for (let l = start; l <= end; l++) covered.add(l);
  }
  lines.forEach((line, i) => {
    const n = i + 1;
    if (covered.has(n) || isBlankOrComment(line)) return;
    const head = line.trim().split(/\s+/)[0];
    const colon = head.indexOf(":");
    spans.push({
      start: n,
      end: n,
      name: colon > 0 ? head.slice(colon + 1) : head,
      module: colon > 0 ? head.slice(0, colon) : undefined,
      text: line,
    });
  });
  return spans.sort((a, b) => a.start - b.start);
}

const isStdCommand = (span: CommandSpan, name: string): boolean =>
  (span.module ?? "std") === "std" && span.name === name;

export const isAssertSpan = (span: CommandSpan): boolean =>
  isStdCommand(span, "assert");
export const isLoadSpan = (span: CommandSpan): boolean =>
  isStdCommand(span, "load");
export const isSetSpan = (span: CommandSpan): boolean =>
  isStdCommand(span, "set");
export const isDefSpan = (span: CommandSpan): boolean =>
  isStdCommand(span, "def");

/** The span covering a 1-based line, if any. */
export function spanAtLine(
  spans: CommandSpan[],
  line: number,
): CommandSpan | undefined {
  return spans.find((s) => s.start <= line && line <= s.end);
}

/** Depth-first walk over every node reachable from `node`: helper and
 *  call arguments, array elements, named arguments, command options and
 *  the commands of a block argument. */
function visitNodes(node: Node | undefined, visit: (n: Node) => void): void {
  if (!node) return;
  visit(node);
  switch (node.type) {
    case NodeType.HelperFunctionExpression:
      for (const a of (node as HelperFunctionNode).args) visitNodes(a, visit);
      break;
    case NodeType.ArrayExpression:
      for (const el of (node as ArrayExpressionNode).elements)
        visitNodes(el, visit);
      break;
    case NodeType.CallExpression: {
      const call = node as CallExpressionNode;
      visitNodes(call.target, visit);
      for (const a of call.args) visitNodes(a, visit);
      break;
    }
    case NodeType.NamedArg:
      visitNodes((node as NamedArgNode).value, visit);
      break;
    case NodeType.CommandOpt:
      visitNodes((node as CommandOptNode).value, visit);
      break;
    case NodeType.BlockExpression:
      for (const c of (node as BlockExpressionNode).body) visitNodes(c, visit);
      break;
    case NodeType.CommandExpression: {
      const c = node as CommandExpressionNode;
      for (const a of c.args) visitNodes(a, visit);
      for (const o of c.opts) visitNodes(o, visit);
      break;
    }
  }
}

export interface HelperRef {
  module?: string;
  name: string;
}

/** Every helper a command references (arguments and options, nested
 *  anywhere), with its `@mod:` prefix when written. */
export function helperRefs(node: CommandExpressionNode): HelperRef[] {
  const refs: HelperRef[] = [];
  visitNodes(node, (n) => {
    if (n.type === NodeType.HelperFunctionExpression) {
      const h = n as HelperFunctionNode;
      refs.push({ module: h.module, name: h.name });
    }
  });
  return refs;
}

/** Every `$variable` a command references (its own `set` target included,
 *  see `setTarget`). */
export function variableRefs(node: CommandExpressionNode): string[] {
  const refs: string[] = [];
  visitNodes(node, (n) => {
    if (n.type === NodeType.VariableIdentifier) refs.push(String(n.value));
  });
  return refs;
}

/** The variable a `set` command assigns (`$name`), if parsed. */
export function setTarget(node: CommandExpressionNode): string | undefined {
  const first = node.args[0];
  return first?.type === NodeType.VariableIdentifier
    ? String(first.value)
    : undefined;
}

/** The module a `load` command activates (`name>alias` binds the alias). */
export function loadModule(node: CommandExpressionNode): string | undefined {
  const first = node.args[0];
  if (!first || first.type !== NodeType.Bareword) return undefined;
  const parts = String(first.value).split(">");
  return parts[parts.length - 1] || undefined;
}

/** Names a `load m [imports]` list binds unprefixed, with their module. */
function importedNames(spans: CommandSpan[]): {
  helpers: Map<string, string>;
  commands: Map<string, string>;
} {
  const helpers = new Map<string, string>();
  const commands = new Map<string, string>();
  for (const span of spans) {
    if (!span.node || !isLoadSpan(span)) continue;
    const module = loadModule(span.node);
    const list = span.node.args[1];
    if (!module || list?.type !== NodeType.ArrayExpression) continue;
    for (const entry of parseImportList(list as ArrayExpressionNode).entries) {
      (entry.kind === "command" ? commands : helpers).set(
        entry.boundName,
        module,
      );
    }
  }
  return { helpers, commands };
}

/**
 * The modules a script needs loaded: the owners of every `!` face it
 * references, the modules of its `mod:cmd` commands and `@mod:helper`
 * references, and the modules whose import lists bind a name it uses.
 * std never counts; an unprefixed name nothing owns adds nothing.
 */
export function requiredLoads(text: string): string[] {
  const spans = commandSpans(text);
  const imported = importedNames(spans);
  const needed = new Set<string>();
  const add = (module: string | undefined) => {
    if (module && module !== "std") needed.add(module);
  };
  for (const span of spans) {
    if (!span.node || isLoadSpan(span)) continue;
    add(span.module ?? imported.commands.get(span.name));
    for (const ref of helperRefs(span.node)) {
      add(ownerOf(ref) ?? (ref.module ? undefined : imported.helpers.get(ref.name)));
    }
  }
  return [...needed];
}

/** A `load` line of a helper-owning module: the scaffolding an assertion
 *  brings with it, hidden from the batch listing and garbage-collected
 *  with the last command using the module. */
export function isHelperLoad(line: string): boolean {
  const [head, module] = line.trim().split(/\s+/);
  return head === "load" && HELPER_MODULES.includes(module ?? "");
}

export function hasAssertions(script: string): boolean {
  return commandSpans(script).some(isAssertSpan);
}

/** The script without the given spans' lines. */
function dropSpans(script: string, spans: CommandSpan[]): string {
  if (spans.length === 0) return script;
  const dropped = new Set<number>();
  for (const s of spans) for (let l = s.start; l <= s.end; l++) dropped.add(l);
  const kept = script.split("\n").filter((_, i) => !dropped.has(i + 1));
  const out = kept.join("\n");
  return out.trim() === "" ? "" : out;
}

/**
 * Drop scaffolding nothing uses any more, to a fixpoint: `set $v` lines
 * whose variable no other command references (config variables, `$m:k`,
 * are settings, not scaffolding) and `load m` lines of modules nothing
 * needs (see `requiredLoads`).
 */
export function gcScaffolding(script: string): string {
  let current = script;
  for (;;) {
    const spans = commandSpans(current);
    const required = requiredLoads(current);
    const garbage = spans.filter((span) => {
      if (!span.node) return false;
      if (isSetSpan(span)) {
        const target = setTarget(span.node);
        if (!target || target.includes(":")) return false;
        return !spans.some(
          (other) =>
            other !== span &&
            other.node !== undefined &&
            variableRefs(other.node).includes(target),
        );
      }
      if (isLoadSpan(span)) {
        const module = loadModule(span.node);
        return module !== undefined && !required.includes(module);
      }
      return false;
    });
    if (garbage.length === 0) return current;
    current = dropSpans(current, garbage);
  }
}

/** The script without its assertions and the scaffolding only they used:
 *  what the actions-only simulation runs. */
export function stripAssertions(script: string): string {
  return gcScaffolding(
    dropSpans(script, commandSpans(script).filter(isAssertSpan)),
  );
}

/** Remove the command covering a 1-based line, then the scaffolding it
 *  orphaned. */
export function removeCommand(script: string, line: number): string {
  const span = spanAtLine(commandSpans(script), line);
  if (!span) return script;
  return gcScaffolding(dropSpans(script, [span]));
}

/**
 * Merge an assertion line into the action block: `load` lines for every
 * module it needs go after the leading load run, missing `set` lines at
 * the end of the header (the leading load/set/def commands), and the line
 * itself right after the header's existing pre-assertions (`pre`) or at
 * the end (`post`). Returns the 1-based line the assertion landed on.
 */
export function insertAssertionLines(
  script: string,
  line: string,
  placement: AssertionPlacement,
  sets: string[] = [],
): { script: string; insertedAt: number } {
  const trimmed = script.trimEnd();
  const lines = trimmed ? trimmed.split("\n") : [];
  const spans = () => commandSpans(lines.join("\n"));

  // Loads: after the leading run of load commands.
  const present = new Set(
    spans()
      .filter((s) => isLoadSpan(s) && s.node)
      .map((s) => loadModule(s.node as CommandExpressionNode)),
  );
  for (const module of requiredLoads(line)) {
    if (present.has(module)) continue;
    let loadEnd = 0;
    for (const span of spans()) {
      if (!isLoadSpan(span)) break;
      loadEnd = span.end;
    }
    lines.splice(loadEnd, 0, `load ${module}`);
    present.add(module);
  }

  // Header: the leading load/set/def commands; missing sets go at its end.
  const headerEnd = () => {
    let end = 0;
    for (const span of spans()) {
      if (!(isLoadSpan(span) || isSetSpan(span) || isDefSpan(span))) break;
      end = span.end;
    }
    return end;
  };
  const existing = new Set(lines.map((l) => l.trim()));
  const missing = sets.map((s) => s.trim()).filter((s) => !existing.has(s));
  lines.splice(headerEnd(), 0, ...missing);

  let insertedAt: number;
  if (placement === "pre") {
    // Group with the pre-assertions already sitting below the header.
    let at = headerEnd();
    for (const span of spans()) {
      if (span.start <= at) continue;
      if (!isAssertSpan(span)) break;
      at = span.end;
    }
    lines.splice(at, 0, line);
    insertedAt = at + 1;
  } else {
    lines.push(line);
    insertedAt = lines.length;
  }
  return { script: lines.join("\n"), insertedAt };
}

/** `load` must sit at the top level, so the wrapper pulls the block's
 *  load commands out and above itself. */
export function hoistLoads(block: string): { loads: string[]; body: string } {
  const loadSpans = commandSpans(block).filter(isLoadSpan);
  const loads = [...new Set(loadSpans.map((s) => s.text.trim()))];
  return { loads, body: dropSpans(block, loadSpans).trim() };
}
