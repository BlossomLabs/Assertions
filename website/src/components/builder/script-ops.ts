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

/** The variables a script sets to a literal address, by name (no `$`):
 *  the ones whose value is known without running anything. Config
 *  variables (`$mod:key`) are settings, not addresses to refer to. */
export function addressVariables(script: string): Map<string, string> {
  const variables = new Map<string, string>();
  for (const span of commandSpans(script)) {
    const variable = addressVariable(span);
    if (variable) variables.set(variable.name, variable.address);
  }
  return variables;
}

/** The variable a `set $name 0x…` command pins to a literal address. */
export function addressVariable(
  span: CommandSpan,
): { name: string; address: string } | undefined {
  if (!span.node || !isSetSpan(span) || span.node.args.length !== 2)
    return undefined;
  const target = setTarget(span.node);
  const value = span.node.args[1];
  if (!target || target.includes(":")) return undefined;
  if (value.type !== NodeType.AddressLiteral) return undefined;
  return { name: target.replace(/^\$/, ""), address: String(value.value) };
}

/** Every variable a script sets, to anything, by name (no `$`). */
export function setVariables(script: string): Set<string> {
  const names = new Set<string>();
  for (const span of commandSpans(script)) {
    if (!span.node || !isSetSpan(span)) continue;
    const target = setTarget(span.node);
    if (target) names.add(target.replace(/^\$/, ""));
  }
  return names;
}

/** Where a `#` comment starts in a line, or -1: a `#` inside quotes is
 *  text. */
function commentStart(line: string): number {
  let quote: string | null = null;
  for (let i = 0; i < line.length; i++) {
    const ch = line[i];
    if (quote) {
      if (ch === "\\") i++;
      else if (ch === quote) quote = null;
    } else if (ch === '"' || ch === "'") quote = ch;
    else if (ch === "#") return i;
  }
  return -1;
}

/** A line (or a command of several) without its comments: what it says to
 *  the interpreter. Lines are compared by this, so a line with a comment
 *  that says its unit is the same line without it. */
export function withoutComment(text: string): string {
  return text
    .split("\n")
    .map((line) => {
      const at = commentStart(line);
      return at < 0 ? line : line.slice(0, at).trimEnd();
    })
    .join("\n");
}

const VARIABLE_TOKEN = /\$([A-Za-z_][A-Za-z0-9_]*)(?![A-Za-z0-9_]|:(?!:))/g;

/** `text` with each `$name` token passed through `rename`, everywhere but
 *  inside quotes: code and comments say which variable they mean, a
 *  string is the user's text. */
function mapVariables(text: string, rename: (name: string) => string | undefined): string {
  return text
    .split("\n")
    .map((line) => {
      let out = "";
      let from = 0;
      let quote: string | null = null;
      const flush = (to: number) => {
        out += line
          .slice(from, to)
          .replace(VARIABLE_TOKEN, (token, name: string) => {
            const next = rename(name);
            return next === undefined ? token : `$${next}`;
          });
        from = to;
      };
      for (let i = 0; i < line.length; i++) {
        const ch = line[i];
        if (quote) {
          if (ch === "\\") i++;
          else if (ch === quote) {
            out += line.slice(from, i + 1);
            from = i + 1;
            quote = null;
          }
        } else if (ch === '"' || ch === "'") {
          flush(i);
          quote = ch;
        } else if (ch === "#") break;
      }
      if (quote) out += line.slice(from);
      else flush(line.length);
      return out;
    })
    .join("\n");
}

/** The script with a variable under another name: its `set`, every use,
 *  and every comment that mentions it. Names are given without the `$`. */
export function renameVariable(script: string, from: string, to: string): string {
  return mapVariables(script, (name) => (name === from ? to : undefined));
}

/** What a variable may be called when the user names it. */
const USER_NAME = /^[A-Za-z][A-Za-z0-9]*$/;

/** The user's own rename of a variable, or why not, in a few words. */
export function userRename(
  script: string,
  from: string,
  to: string,
): { script: string } | { error: string } {
  const taken = setVariables(script);
  if (!taken.has(from)) return { error: "No such variable." };
  const name = to.trim();
  if (name === from) return { script };
  if (name === "") return { error: "Type a name." };
  if (!USER_NAME.test(name))
    return { error: "Letters and digits only, starting with a letter." };
  if (taken.has(name)) return { error: `$${name} is already used.` };
  return { script: renameVariable(script, from, name) };
}

/** Where a variable's name came from, when the builder gave it:
 *  - `role`: what the address is in one use (a parameter's name, a
 *    suggestion's role): `to`, `spender`, `owner`.
 *  - `neutral`: what could be read of it (`account`, `contract`), or
 *    nothing (`address`).
 *  - `context`: what the user said the executing account is (`safe`).
 *  - `list`: the chain's token list (`usdc`). Never replaced, so never
 *    kept track of. */
export type NameOrigin = "role" | "neutral" | "context" | "list";

/** A variable a line refers to as `$name`, and the address it stands for.
 *  `wanted` is the name to give it in a script when `name` is only a
 *  placeholder in the line, and `origin` where that name comes from. */
export interface LineVariable {
  name: string;
  value: string;
  wanted?: string;
  origin?: NameOrigin;
}

/**
 * The names a variable has only on the user's own say-so: the account
 * that executes, as the context names it. THE one list. A script reads
 * `$safe` as the user's Safe and `$executor` as the account that runs the
 * batch, so nothing else may give these names: not an ABI's parameter
 * names, not an imported file, not a suggestion (`bindVariables` refuses
 * them for any address the context does not name that way). A new kind of
 * context adds its name here, and the type of `ContextVariable` makes sure
 * it cannot be given without being listed.
 */
export const ACCOUNT_NAMES = [
  "safe",
  "governor",
  "timelock",
  "dao",
  "wallet",
  "executor",
] as const;
export type AccountName = (typeof ACCOUNT_NAMES)[number];

/** Whether a name would read as one of the executing account's: whatever
 *  its case, the underscores around it or the number after it (`_Safe`,
 *  `executor2`). */
export function isAccountName(name: string): boolean {
  const word = name.replace(/^_+|_+$/g, "").replace(/\d+$/, "").replace(/_+$/, "").toLowerCase();
  return (ACCOUNT_NAMES as readonly string[]).includes(word);
}

/** An account the user told the builder about: the Safe, the Governor,
 *  the DAO, the wallet the batch runs as. Its variable has that name. */
export interface ContextVariable {
  name: AccountName;
  address: string;
}

export type AddressKind = "account" | "contract";

/** What the builder knows of a script's variable names beyond the script. */
export interface Naming {
  /** The names the builder gave and may give again, with where each came
   *  from. A name that is not here is the user's (typed in the editor,
   *  renamed by hand) or the token list's, and is never replaced. */
  managed?: ReadonlyMap<string, Exclude<NameOrigin, "list">>;
  context?: readonly ContextVariable[];
  /** Whether an address has code, by its lowercase address, where that
   *  was read. */
  kinds?: ReadonlyMap<string, AddressKind>;
}

const NEUTRAL_NAME = /^(account|contract|address)\d*$/;

/** Two names for one role: numbers aside, the same word, or the two words
 *  the form and a suggestion have for who receives. */
function sameRole(a: string, b: string): boolean {
  const word = (name: string) => {
    const plain = name.replace(/\d+$/, "").toLowerCase();
    return plain === "recipient" ? "to" : plain;
  };
  return word(a) === word(b);
}

/** The origin of a name nobody stated: a suggestion's variables carry
 *  their role, or one of the neutral words, as their name. */
const inferredOrigin = (name: string): Exclude<NameOrigin, "list"> =>
  NEUTRAL_NAME.test(name) ? "neutral" : "role";

/**
 * A line made ready for a script: the line under the script's variable
 * names, the `set` lines the script still needs for it, and the script
 * itself, where a variable had to change its name. The one way anything
 * that names addresses (a composed action, a suggested check) enters a
 * script.
 *
 * - An address the script already sets a variable to is referred to by
 *   that variable: no second variable for one address. When the builder
 *   named it for one role (`$to`) and this line does not give it that
 *   same role (it is a spender here, or nothing known), it is renamed
 *   everywhere to what can be read of it:
 *   `account` without code, `contract` with it, `address` when that is
 *   not known (`naming.kinds`).
 * - An account of the context (`naming.context`) has the context's name,
 *   and no other address can have one of those names from here
 *   (`ACCOUNT_NAMES`): a line that asks for one gets a neutral name.
 * - A name the script gives to something else (another address, an ENS
 *   lookup, a number) is left to it: the new variable takes the first
 *   free `name2`, `name3`, ...
 * - Anything else keeps its name and gets a `set`.
 *
 * Only names in `naming.managed` are ever replaced.
 */
export function bindVariables(
  script: string,
  { line, vars }: { line: string; vars: readonly LineVariable[] },
  naming: Naming = {},
): {
  script: string;
  line: string;
  sets: string[];
  managed: Map<string, Exclude<NameOrigin, "list">>;
} {
  let current = script;
  const managed = new Map(naming.managed ?? []);
  const contextOf = new Map(
    (naming.context ?? []).map((c) => [c.address.toLowerCase(), c.name]),
  );
  const known = addressVariables(current);
  const byAddress = new Map(
    [...known].map(([name, address]) => [address.toLowerCase(), name]),
  );
  const taken = setVariables(current);
  const free = (base: string): string => {
    let name = base;
    for (let n = 2; taken.has(name); n++) name = `${base}${n}`;
    taken.add(name);
    return name;
  };
  const names = new Map<string, string>();
  const sets: string[] = [];
  /** Gives a variable of the script, or of this line, another name. */
  const renamed = (address: string, from: string, base: string, origin: Exclude<NameOrigin, "list">) => {
    // Its own name is free again: `$contract` for a contract stays.
    taken.delete(from);
    const to = free(base);
    if (to === from) {
      managed.set(to, origin);
      return to;
    }
    current = renameVariable(current, from, to);
    const at = sets.indexOf(`set $${from} ${address}`);
    if (at >= 0) sets[at] = `set $${to} ${address}`;
    for (const [placeholder, name] of names) if (name === from) names.set(placeholder, to);
    managed.delete(from);
    managed.set(to, origin);
    byAddress.set(address.toLowerCase(), to);
    return to;
  };
  for (const { name, value, wanted, origin } of vars) {
    const key = value.toLowerCase();
    const context = contextOf.get(key);
    // A name of the executing account is the context's to give, and only
    // to the account it names: asked for by anything else (a parameter, an
    // imported file, a suggestion), it is what can be read of the address.
    const claimed = isAccountName(wanted ?? name);
    const base = claimed ? (naming.kinds?.get(key) ?? "address") : (wanted ?? name);
    const from = claimed ? "neutral" : (origin ?? inferredOrigin(base));
    const existing = byAddress.get(key);
    if (existing !== undefined) {
      const was = managed.get(existing);
      let now = existing;
      if (context !== undefined) {
        if (was !== undefined && existing !== context) now = renamed(value, existing, context, "context");
      } else if (was === "role" && !sameRole(existing, base)) {
        // Named for one role, and this use is not known to be that role
        // (another one, or none that is known): the name would be read
        // into this line too.
        now = renamed(value, existing, naming.kinds?.get(key) ?? "address", "neutral");
      }
      names.set(name, now);
      continue;
    }
    const given = free(context ?? base);
    byAddress.set(key, given);
    names.set(name, given);
    if (context !== undefined) managed.set(given, "context");
    else if (from !== "list") managed.set(given, from);
    sets.push(`set $${given} ${value}`);
  }
  // One pass over the line, so that swapped names do not chase each other.
  const bound = mapVariables(line, (name) => names.get(name));
  return { script: current, line: bound, sets, managed };
}

/**
 * The script with the accounts of the context under the context's names
 * (`$safe`, `$governor`, `$dao`, `$timelock`, `$wallet`, `$executor`), and
 * a variable that had such a name for an account the context no longer
 * names under what can be read of it. Only names the builder gave
 * (`naming.managed`) change; a script that names none of these accounts
 * is left as it is.
 */
export function nameContext(
  script: string,
  naming: Naming,
): { script: string; managed: Map<string, Exclude<NameOrigin, "list">> } {
  const managed = new Map(naming.managed ?? []);
  const contextOf = new Map(
    (naming.context ?? []).map((c) => [c.address.toLowerCase(), c.name]),
  );
  const moves: { from: string; base: string; origin: Exclude<NameOrigin, "list"> }[] = [];
  for (const [name, address] of addressVariables(script)) {
    const origin = managed.get(name);
    if (origin === undefined) continue;
    const key = address.toLowerCase();
    const context = contextOf.get(key);
    if (context !== undefined) {
      if (name.replace(/\d+$/, "") !== context) moves.push({ from: name, base: context, origin: "context" });
    } else if (origin === "context") {
      moves.push({ from: name, base: naming.kinds?.get(key) ?? "address", origin: "neutral" });
    }
  }
  if (moves.length === 0) return { script, managed };
  // Out of the way first, so that two accounts can swap names.
  let current = script;
  moves.forEach(({ from }, i) => {
    current = renameVariable(current, from, `_moving${i}`);
    managed.delete(from);
  });
  const taken = setVariables(current);
  moves.forEach(({ base, origin }, i) => {
    let name = base;
    for (let n = 2; taken.has(name); n++) name = `${base}${n}`;
    taken.add(name);
    current = renameVariable(current, `_moving${i}`, name);
    managed.set(name, origin);
  });
  return { script: current, managed };
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
 * are settings, not scaffolding), `load m` lines of modules nothing
 * needs (see `requiredLoads`), and the `def @each…!` tests the builder
 * wrote for a quantifier no assertion uses any more.
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
      // A test the builder wrote for a quantifier, once nothing runs it.
      const generated = generatedTestName(current, span);
      if (generated)
        return !spans.some(
          (other) =>
            other !== span &&
            other.node !== undefined &&
            helperRefs(other.node).some((ref) => ref.name === generated),
        );
      return false;
    });
    if (garbage.length === 0) return current;
    current = dropSpans(current, garbage);
  }
}

/** The helper a builder-written `def @each…!` line defines (the name the
 *  codegen gives a quantifier's test), or undefined for any other line:
 *  a helper the user defined is never scaffolding. */
function generatedTestName(script: string, span: CommandSpan): string | undefined {
  if (!isDefSpan(span)) return undefined;
  const line = script.split("\n")[span.start - 1] ?? "";
  return line.trim().match(/^def @(each[0-9a-z]+!)\s/)?.[1];
}

/** The script without the commands `matches` picks, and without the
 *  scaffolding only they used. */
export function withoutCommands(
  script: string,
  matches: (span: CommandSpan) => boolean,
): string {
  return gcScaffolding(dropSpans(script, commandSpans(script).filter(matches)));
}

/** The script without its assertions and the scaffolding only they used:
 *  what the actions-only simulation runs. */
export function stripAssertions(script: string): string {
  return withoutCommands(script, isAssertSpan);
}

/** Remove the command covering a 1-based line, then the scaffolding it
 *  orphaned. */
export function removeCommand(script: string, line: number): string {
  const span = spanAtLine(commandSpans(script), line);
  if (!span) return script;
  return gcScaffolding(dropSpans(script, [span]));
}

/**
 * Put `line` where the command covering a 1-based line is: same position,
 * the `load` and `set` lines the new one needs added to the header, and
 * the scaffolding only the old one used dropped. What saving an edited
 * action does; an add followed by a remove would move it to the end.
 */
export function replaceCommand(
  script: string,
  at: number,
  line: string,
  sets: string[] = [],
): string {
  const span = spanAtLine(commandSpans(script), at);
  if (!span) return script;
  const lines = script.split("\n");
  // A comment holds the place: nothing reads it, and it moves with the
  // lines the header gains.
  const marker = "# __replaced__";
  lines.splice(span.start - 1, span.end - span.start + 1, marker);
  const added = insertAssertionLines(lines.join("\n"), line, "post", sets).script.split("\n");
  added.pop();
  return gcScaffolding(added.map((l) => (l === marker ? line : l)).join("\n"));
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
  // A hoisted test can use a helper the line itself does not.
  for (const module of requiredLoads([...sets, line].join("\n"))) {
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
 *  load commands out and above itself. The variables pinned to a literal
 *  address go with them: they depend on nothing, and a reader of the
 *  final script finds every address it names in one place. One whose
 *  name is in `reserved` (the wrapper's own variables) stays in the
 *  block, where it cannot change what the wrapper itself refers to; so
 *  does every `set` of a variable the block sets more than once. */
export function hoistLoads(
  block: string,
  reserved: ReadonlySet<string> = new Set(),
): { loads: string[]; sets: string[]; body: string } {
  const spans = commandSpans(block);
  const loadSpans = spans.filter(isLoadSpan);
  // A variable set more than once takes its values in order: moved above
  // the wrapper, the last would hold for every command, and the batch
  // signed would not be the batch simulated. Those stay where they are.
  const timesSet = new Map<string, number>();
  for (const span of spans) {
    const target = span.node && isSetSpan(span) ? setTarget(span.node) : undefined;
    if (target) {
      const name = target.replace(/^\$/, "");
      timesSet.set(name, (timesSet.get(name) ?? 0) + 1);
    }
  }
  const setSpans = spans.filter((span) => {
    const variable = addressVariable(span);
    return (
      variable !== undefined &&
      !reserved.has(variable.name) &&
      timesSet.get(variable.name) === 1
    );
  });
  return {
    loads: [...new Set(loadSpans.map((s) => s.text.trim()))],
    sets: [...new Set(setSpans.map((s) => s.text.trim()))],
    body: dropSpans(block, [...loadSpans, ...setSpans]).trim(),
  };
}

// ---------------------------------------------------------------------------
// Suggested checks: marked in the script by a comment
// ---------------------------------------------------------------------------

/** The word a check's comment carries while the check is a suggestion the
 *  builder manages. Without it the check is the user's. */
export const SUGGESTED_MARK = "suggested";
const MARK_IN_COMMENT = /\bsuggested\b/;

/** The comment of a line (from its `#`), or "" when it has none. */
function commentOf(line: string): string {
  const at = commentStart(line);
  return at < 0 ? "" : line.slice(at);
}

/** Whether a command is a managed suggestion: one of its lines has a
 *  comment that says `suggested`. Removing the word, or the comment, makes
 *  it the user's. */
export function isSuggestedText(text: string): boolean {
  return text.split("\n").some((line) => MARK_IN_COMMENT.test(commentOf(line)));
}

/** A line with the mark: a comment of its own, or the word added to the
 *  comment it has (`# base units of $weth · suggested`). */
export function markSuggested(line: string): string {
  if (isSuggestedText(line)) return line;
  return commentStart(line) < 0
    ? `${line}  # ${SUGGESTED_MARK}`
    : `${line} · ${SUGGESTED_MARK}`;
}

/** A command without the mark: the word taken out of its comment, and a
 *  comment left with nothing else to say dropped. */
export function unmarkSuggested(text: string): string {
  return text
    .split("\n")
    .map((line) => {
      const at = commentStart(line);
      if (at < 0) return line;
      const code = line.slice(0, at).trimEnd();
      const comment = line
        .slice(at + 1)
        .replace(/\s*·\s*suggested\b/g, "")
        .replace(/\bsuggested\s*·\s*/g, "")
        .replace(/\bsuggested\b/g, "")
        .trim();
      return comment ? `${code}  # ${comment}` : code;
    })
    .join("\n");
}

/** The script with the command covering a 1-based line written as `text`
 *  instead, in place. */
export function rewriteCommand(script: string, at: number, text: string): string {
  const span = spanAtLine(commandSpans(script), at);
  if (!span) return script;
  const lines = script.split("\n");
  lines.splice(span.start - 1, span.end - span.start + 1, ...text.split("\n"));
  return lines.join("\n");
}

/** The script without the checks still marked as suggestions, and the
 *  scaffolding only they used: when the executor or the chain they were
 *  suggested for changes. */
export function withoutSuggested(script: string): string {
  const marked = commandSpans(script).filter(
    (span) => isAssertSpan(span) && isSuggestedText(span.text),
  );
  return marked.length ? gcScaffolding(dropSpans(script, marked)) : script;
}

/** A line as code and comment: the comment from its `#` (quotes aside),
 *  "" when it has none. For drawing the two apart. */
export function splitComment(line: string): { code: string; comment: string } {
  const at = commentStart(line);
  return at < 0
    ? { code: line, comment: "" }
    : { code: line.slice(0, at), comment: line.slice(at) };
}
