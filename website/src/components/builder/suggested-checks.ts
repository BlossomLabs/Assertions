import type { SimulateOptions, SimulationResult } from "@evmcrispr/core";
import { isAddress } from "viem";

import { chainById } from "../deployments/wagmi";
import type { AddressName } from "./address-names";
import type { ContextKind } from "./context";
import {
  type LineVariable,
  type Naming,
  addressVariable,
  addressVariables,
  bindVariables,
  type CommandSpan,
  commandSpans,
  insertAssertionLines,
  isAssertSpan,
  isSuggestedText,
  markSuggested,
  removeCommand,
  rewriteCommand,
  unmarkSuggested,
  isLoadSpan,
  isSetSpan,
  withoutComment,
} from "./script-ops";
import type { SimKey, SimulationState } from "./simulation";

/**
 * Checks a simulation suggests: `assert` lines EVMcrispr derives from what
 * a passing run did, each confirmed by the emitting contract's own views.
 * They belong to the one simulation that produced them, and the builder
 * only ever offers them. Pure functions; the component only draws them.
 */

type Suggestion = NonNullable<SimulationResult["suggestions"]>[number];

/** A suggestion as the builder takes it: EVMcrispr's, or the older shape
 *  that had a description and a line of literal addresses only. */
export type SuggestedCheck = Omit<Suggestion, "vars" | "sentence"> &
  Partial<Pick<Suggestion, "vars" | "sentence">>;

/** What a simulation of `key` asks EVMcrispr to suggest: checks for the
 *  actions of step 1, guarding the balances of the account they run as.
 *  Nothing for the protected batch: its checks are the ones being added. A wallet batch executes as soon
 *  as it is signed, from the state just simulated, so its amounts are
 *  asked for exactly; anywhere else they are floors, since balances can
 *  move before a Safe, a Governor or a DAO executes. */
export function suggestOption(
  key: SimKey,
  context?: ContextKind,
): SimulateOptions["suggest"] {
  if (key.mode !== "actions-only") return undefined;
  const exact = context === "eoa" ? { exact: true } : {};
  if (key.from) return { executor: key.from, ...exact };
  return context === "eoa" ? exact : true;
}

/** A suggestion as the list shows it: in the batch already or not. */
export interface SuggestedRow {
  check: SuggestedCheck;
  /** A command of the script means the same: the row offers to remove it. */
  inBatch: boolean;
  /** That command still carries the `# suggested` mark: later runs manage
   *  it, and the row's chip can make it the user's. */
  marked: boolean;
}

export interface SuggestedChecks {
  /** Every suggestion of the run, in the order they came. */
  rows: SuggestedRow[];
  /** The run did more than was looked at: some may be missing. */
  truncated: boolean;
  /** Why the run gave none: it could not vouch for them (a simulator that
   *  does not report where a transaction's currency went). */
  error?: string;
  /** The actions changed since the run: its suggestions may no longer
   *  fit them. They stay listed, and can still be added or removed. */
  stale: boolean;
}

const isNativeFloor = (check: Pick<SuggestedCheck, "module" | "event">) =>
  check.module === "std" && check.event === "native";

/** An amount asserted exactly (`==`): an account the run emptied, or any
 *  amount of a wallet batch. Its line is not a floor. */
const isExact = (check: { line?: string }) => / == /.test(check.line ?? "");

/** A floor without its number: `assert <read> >=`. The number has been
 *  written three ways (`@token:amount(ETH 1.5)`, `1.5e18`, base units):
 *  a floor is the same floor in any of them. */
const withoutBound = (line: string): string =>
  line.replace(
    />=\s*(@token:amount\(\s*[A-Za-z0-9$]+\s+[\d.]+\s*\)|\d[\d.]*(e\d+)?)$/,
    ">=",
  );

/**
 * What a line says once its variables are the addresses they stand for:
 * two lines that assert the same thing under different variable names, or
 * one with a variable and one with the literal, have the same meaning.
 * Addresses are compared without their case, runs of blanks as one, and a
 * comment (the unit a line in base units states) says nothing.
 */
export function lineMeaning(
  line: string,
  variables: ReadonlyMap<string, string>,
): string {
  return withoutComment(line)
    .trim()
    .replace(/\$([A-Za-z_][A-Za-z0-9_]*)(?![A-Za-z0-9_]|:(?!:))/g, (token, name: string) =>
      variables.get(name) ?? token,
    )
    .replace(/0x[0-9a-fA-F]{40}(?![0-9a-fA-F])/g, (address) => address.toLowerCase())
    .replace(/\s+/g, " ");
}

const ownVariables = (check: Pick<SuggestedCheck, "vars">): Map<string, string> =>
  new Map((Array.isArray(check.vars) ? check.vars : []).map((v) => [v.name, v.value]));

/** What a suggestion's line means, by its own variables. */
const suggestionMeaning = (check: Pick<SuggestedCheck, "line" | "vars">): string =>
  lineMeaning(check.line, ownVariables(check));

/** What each command of a script means, scaffolding aside. */
function scriptMeanings(script: string): Set<string> {
  const variables = addressVariables(script);
  return new Set(
    commandSpans(script)
      .filter((span) => !isSetSpan(span) && !isLoadSpan(span))
      .map((span) => lineMeaning(span.text, variables)),
  );
}

const sameAccount = (a: string | undefined, b: string | undefined): boolean =>
  (a ?? "").toLowerCase() === (b ?? "").toLowerCase();

/** The actions of a script by meaning, one per line: what step 1
 *  simulates. Loads, variables pinned to an address and checks are left
 *  out, so adding or removing a check does not change it. */
function actionsMeaning(script: string): string {
  const variables = addressVariables(script);
  return commandSpans(script)
    .filter((span) => !isLoadSpan(span) && !addressVariable(span) && !isAssertSpan(span))
    .map((span) => lineMeaning(span.text, variables))
    .join("\n");
}

/**
 * The checks step 1's last simulation suggests (`state`), against the
 * batch as it is now (`key`, the protected batch). Null until that
 * simulation has passed for this executor and chain. Every suggestion is
 * listed, each marked when the script already holds it, and they stay
 * when the actions change after (`stale`): what was suggested is the
 * user's to keep or take back.
 */
export function suggestedChecks(
  state: SimulationState,
  key: SimKey,
): SuggestedChecks | null {
  const { simulated, result } = state;
  if (state.status !== "success" || !simulated || !result) return null;
  if (
    simulated.mode !== "actions-only" ||
    simulated.chainId !== key.chainId ||
    !sameAccount(simulated.from, key.from)
  )
    return null;

  // Lines are compared by what they mean: a suggestion is added under the
  // script's own variable names, which need not be the suggestion's.
  const present = scriptMeanings(key.script);
  const floors = new Set([...present].map(withoutBound));
  const seen = new Set<string>();
  const rows: SuggestedRow[] = [];
  // A result of the older shape, without the field, suggested nothing.
  const suggestions = Array.isArray(result.suggestions)
    ? (result.suggestions as SuggestedCheck[])
    : [];
  for (const suggestion of suggestions) {
    const line = suggestionMeaning(suggestion);
    if (seen.has(line)) continue;
    seen.add(line);
    // The native floor depends on the gas a run used, so a script holding
    // one with another number holds the same check.
    const inBatch =
      present.has(line) ||
      (isNativeFloor(suggestion) && floors.has(withoutBound(line)));
    const span = inBatch ? suggestionSpan(key.script, suggestion) : undefined;
    rows.push({
      check: suggestion,
      inBatch,
      marked: !!span && isSuggestedText(span.text),
    });
  }
  return {
    rows,
    truncated: result.suggestionsTruncated === true,
    ...(result.suggestionsError ? { error: result.suggestionsError } : {}),
    stale: actionsMeaning(key.script) !== actionsMeaning(simulated.script),
  };
}

/** The command of `script` a suggestion stands for, by meaning: what its
 *  Remove takes out. */
export function suggestionSpan(
  script: string,
  check: Pick<SuggestedCheck, "line" | "vars" | "module" | "event">,
): CommandSpan | undefined {
  const variables = addressVariables(script);
  const line = suggestionMeaning(check);
  const spans = commandSpans(script).filter(isAssertSpan);
  return (
    spans.find((span) => lineMeaning(span.text, variables) === line) ??
    (isNativeFloor(check)
      ? spans.find(
          (span) => withoutBound(lineMeaning(span.text, variables)) === withoutBound(line),
        )
      : undefined)
  );
}

/**
 * The script after step 1's run suggested `suggestions`: the checks the
 * builder manages (marked `# suggested`, see `markSuggested`) follow the
 * run, the user's are never touched.
 *
 * - A marked check the run suggests again stays as it is.
 * - A marked check it no longer suggests, or suggests with another number,
 *   goes, with the variables only it used.
 * - A marked check that is none of the last applied run's suggestions
 *   (`previous`) was edited by hand: it is the user's now, and loses the
 *   mark.
 * - A suggestion the script has no check for is added, marked, unless the
 *   user took it out after the last run (it was applied and is gone).
 *
 * `applied` is what the script holds of this run's suggestions, marked:
 * the next run's `previous`. Without `previous` (a reload), the mark alone
 * says what is managed and nothing counts as taken out.
 */
export function applySuggestions(
  script: string,
  suggestions: readonly SuggestedCheck[],
  previous: ReadonlySet<string> | undefined,
  naming: Naming = {},
): { script: string; applied: Set<string>; managed: Naming["managed"] } {
  const meaningOf = (text: string, s = script) => lineMeaning(text, addressVariables(s));
  const wanted = new Map<string, SuggestedCheck>();
  for (const check of suggestions) {
    const m = suggestionMeaning(check);
    if (!wanted.has(m)) wanted.set(m, check);
  }
  const before = scriptMeanings(script);
  const dismissed = new Set(
    previous ? [...previous].filter((m) => wanted.has(m) && !before.has(m)) : [],
  );

  // The marked checks, one at a time: each edit moves the lines after it.
  let current = script;
  const settled = new Set<number>();
  for (;;) {
    const span = commandSpans(current).find(
      (sp) => isAssertSpan(sp) && isSuggestedText(sp.text) && !settled.has(sp.start),
    );
    if (!span) break;
    const m = meaningOf(span.text, current);
    if (wanted.has(m)) {
      settled.add(span.start);
    } else if (previous && !previous.has(m)) {
      current = rewriteCommand(current, span.start, unmarkSuggested(span.text));
      settled.add(span.start);
    } else {
      current = removeCommand(current, span.start);
      // Lines moved up: what was settled is looked at again, and kept.
      settled.clear();
      for (const sp of commandSpans(current))
        if (isAssertSpan(sp) && isSuggestedText(sp.text) && wanted.has(meaningOf(sp.text, current)))
          settled.add(sp.start);
    }
  }

  let managed = naming.managed;
  for (const [m, check] of wanted) {
    const present = scriptMeanings(current);
    const floors = new Set([...present].map(withoutBound));
    if (present.has(m) || dismissed.has(m)) continue;
    // A native floor the script holds with another number is that check.
    if (isNativeFloor(check) && floors.has(withoutBound(m))) continue;
    const bound = bindVariables(
      current,
      { line: markSuggested(check.line), vars: suggestionVariables(check) },
      { ...naming, managed },
    );
    managed = bound.managed;
    current = insertAssertionLines(bound.script, bound.line, "post", bound.sets).script;
  }

  const applied = new Set<string>();
  const variables = addressVariables(current);
  for (const sp of commandSpans(current)) {
    if (!isAssertSpan(sp) || !isSuggestedText(sp.text)) continue;
    const m = lineMeaning(sp.text, variables);
    if (wanted.has(m)) applied.add(m);
  }
  return { script: current, applied, managed };
}

/** How long a block may be simulated at again: past this it says too
 *  little about the chain as it is, and a node may no longer serve it. */
export const PIN_MAX_AGE_MS = 5 * 60_000;

/**
 * The block to simulate the protected batch (`key`) at so that it
 * confirms checks step 1's run suggested (`state`): that run's own block,
 * while its actions are unchanged, the batch holds one of its suggestions,
 * and the block is recent. Undefined otherwise (other actions, another
 * executor or chain, a failed run, no suggestion added, an old block):
 * simulate at the latest block.
 */
export function confirmationBlock(
  state: SimulationState,
  key: SimKey,
  now: number,
): number | undefined {
  if (state.block === undefined || state.blockReadAt === undefined)
    return undefined;
  if (now - state.blockReadAt > PIN_MAX_AGE_MS) return undefined;
  const found = suggestedChecks(state, key);
  return found && !found.stale && found.rows.some((row) => row.inBatch)
    ? state.block
    : undefined;
}

/** A description with its shortened addresses written as the builder
 *  writes them (`0x1234…abcd`, where EVMcrispr writes three dots). For
 *  display only. */
export function displayDescription(description: string): string {
  return description.replace(
    /(?<![0-9A-Za-z])(0x[0-9a-fA-F]{4})\.\.\.([0-9a-fA-F]{4})(?![0-9A-Za-z])/g,
    "$1…$2",
  );
}

/** The displayed description (see `displayDescription`) in pieces: the
 *  words, and each shortened address on its own so that it can be drawn
 *  as one unbreakable piece. */
export function descriptionParts(
  description: string,
): (string | { address: string })[] {
  return displayDescription(description)
    .split(/(?<![0-9A-Za-z])(0x[0-9a-fA-F]{4}…[0-9a-fA-F]{4})(?![0-9A-Za-z])/)
    .map((part, i) => (i % 2 ? { address: part } : part))
    .filter((part) => part !== "");
}

/** A link in a rendered sentence: an account, a contract or a token, by
 *  the label to show, with its address and, where the chain has a known
 *  explorer, its page there. */
export interface SentenceLink {
  label: string;
  address: string;
  href?: string;
  /** Where the name in the label comes from, when it was looked up. */
  named?: AddressName["source"];
}

/** Part of a long number shortened for reading, with every digit kept
 *  for a hover and for assistive technology. */
export interface SentenceAbbreviation {
  abbreviated: string;
  full: string;
}

/** A sentence ready to draw: words, and what they mention. */
export type SentenceView = (string | SentenceLink | SentenceAbbreviation)[];

/** How many decimals an exact amount shows before it is shortened. Its
 *  line keeps every digit (an equality is not rounded); the sentence only
 *  has to be read. */
const SHOWN_DECIMALS = 6;

/** An amount's number cut to `SHOWN_DECIMALS` places with an ellipsis,
 *  when it has more: "19,898.033836102187577703" reads "19,898.033836…".
 *  The text as it is otherwise. */
function readable(
  text: string,
  bound: string | undefined,
): string | SentenceAbbreviation {
  // A floor or a ceiling is already said at the precision it asserts.
  if (bound !== "exact") return text;
  const m = /^(\d[\d,]*)\.(\d+)(.*)$/s.exec(text);
  if (!m || m[2].length <= SHOWN_DECIMALS) return text;
  return {
    abbreviated: `${m[1]}.${m[2].slice(0, SHOWN_DECIMALS)}…${m[3]}`,
    full: text,
  };
}

const shortened = (address: string): string =>
  `${address.slice(0, 6)}…${address.slice(-4)}`;

const explorerPage = (chainId: number, address: string): string | undefined => {
  const explorer = chainById(chainId)?.blockExplorers?.default?.url;
  return explorer ? `${explorer.replace(/\/$/, "")}/address/${address}` : undefined;
};

/** The link for an address under a name. A name is the contract's own
 *  word: it stands alone only when the chain's token list gives that
 *  address that name (`listed`), and has the address beside it otherwise.
 *  A name that is not short and plain is not shown at all. */
export function addressLink(
  chainId: number,
  address: string,
  name?: string,
  listed?: boolean,
): SentenceLink {
  const plain = name && PLAIN_NAME.test(name) ? name : undefined;
  const href = explorerPage(chainId, address);
  return {
    label: !plain
      ? shortened(address)
      : listed === true
        ? plain
        : `${plain} (${shortened(address)})`,
    address,
    ...(href ? { href } : {}),
  };
}

/** Where `useAddressNames` keeps an address's name. */
export const nameKey = (chainId: number, address: string): string =>
  `${chainId}:${address.toLowerCase()}`;

/** An address in a sentence, by the best name it has: the token list's,
 *  which stands alone; an ENS name that resolves back; the name the
 *  contract gives itself; a verified contract name. Each but the first
 *  beside the shortened address. */
function sentenceAddress(
  chainId: number,
  part: { address: string; name?: string; listed?: boolean },
  names: ReadonlyMap<string, AddressName> | undefined,
): SentenceLink {
  const own = addressLink(chainId, part.address, part.name, part.listed);
  if (part.listed === true && own.label !== shortened(part.address)) return own;
  const looked = names?.get(nameKey(chainId, part.address));
  if (looked?.source === "ens") return namedLink(chainId, part.address, looked)!;
  if (own.label !== shortened(part.address)) return own;
  return namedLink(chainId, part.address, looked) ?? own;
}

/** The link for an address under a name looked up for it (an ENS name
 *  that resolves back, a verified contract name), beside its shortened
 *  address: neither is a name the builder can vouch for alone. */
function namedLink(
  chainId: number,
  address: string,
  name: AddressName | undefined,
): SentenceLink | undefined {
  if (!name) return undefined;
  const href = explorerPage(chainId, address);
  return {
    label: `${name.name} (${shortened(address)})`,
    address,
    ...(href ? { href } : {}),
    named: name.source,
  };
}

/**
 * A suggestion's sentence as the row draws it: text as it is, each address
 * a link, each token amount its text with the symbol inside it linked to
 * the token (the chain's own currency names no contract and is not
 * linked). Null when the suggestion has no sentence (the older shape):
 * the row then shows its description.
 */
export function sentenceView(
  check: Pick<SuggestedCheck, "sentence">,
  chainId: number,
  names?: ReadonlyMap<string, AddressName>,
): SentenceView | null {
  const { sentence } = check;
  if (!Array.isArray(sentence) || sentence.length === 0) return null;
  const view: SentenceView = [];
  for (const part of sentence) {
    if (part.type === "text") {
      view.push(part.text);
    } else if (part.type === "address") {
      // Not an address: nothing to link, and nothing to trust as one.
      if (!isAddress(part.address)) view.push(String(part.address));
      else view.push(sentenceAddress(chainId, part, names));
    } else if (part.token === "native" || !isAddress(part.token)) {
      view.push(readable(part.text, part.bound));
    } else {
      const symbol =
        part.symbol && PLAIN_NAME.test(part.symbol) ? part.symbol : undefined;
      const at = symbol ? part.text.lastIndexOf(symbol) : -1;
      if (symbol && at >= 0) {
        const before = part.text.slice(0, at);
        const after = part.text.slice(at + symbol.length);
        if (before) view.push(readable(before, part.bound));
        view.push(addressLink(chainId, part.token, symbol, part.listed));
        if (after) view.push(after);
      } else {
        view.push(readable(part.text, part.bound), " of ", addressLink(chainId, part.token));
      }
    }
  }
  return view;
}

/** A suggestion's variables as the script binds them. One the token
 *  list names (the sentence says which addresses it vouches for) keeps
 *  that name for good; the others carry their role as their name. */
export function suggestionVariables(
  check: Pick<SuggestedCheck, "vars" | "sentence">,
): LineVariable[] {
  const listed = new Set<string>();
  for (const part of Array.isArray(check.sentence) ? check.sentence : []) {
    if (part.type === "address" && part.listed === true)
      listed.add(String(part.address).toLowerCase());
    if (part.type === "amount" && part.listed === true)
      listed.add(String(part.token).toLowerCase());
  }
  return (Array.isArray(check.vars) ? check.vars : []).map((v) =>
    listed.has(v.value.toLowerCase()) ? { ...v, origin: "list" as const } : v,
  );
}

/** A suggestion made ready for a script: its line under the script's
 *  variable names, the `set` lines it still needs, and the script where a
 *  variable changed its name (`bindVariables`, the same rule a composed
 *  action goes through). */
export function prepareSuggestion(
  script: string,
  check: Pick<SuggestedCheck, "line" | "vars" | "sentence">,
  naming?: Naming,
): ReturnType<typeof bindVariables> {
  return bindVariables(
    script,
    { line: check.line, vars: suggestionVariables(check) },
    naming,
  );
}

export interface SuggestionSource {
  /** The emitter as shown: the name it gives itself, else its shortened
   *  address. */
  label: string;
  /** The emitter's page on the chain's block explorer, when one is known. */
  href?: string;
  /** The emitter's full address: a name is the contract's own word. */
  address: string;
  /** The event as the contract names it. */
  eventName: string;
}

/** What EVMcrispr lets through as a name; checked again here because the
 *  name is shown as link text. */
const PLAIN_NAME = /^[A-Za-z0-9.$_-]{1,12}$/;

/**
 * Where a suggestion comes from: which contract's which event. Null for a
 * suggestion that comes from no event (the native floor) or says nothing
 * about it (the older shape).
 */
export function suggestionSource(
  check: Pick<SuggestedCheck, "emitter" | "eventName" | "emitterName">,
  chainId: number,
): SuggestionSource | null {
  const { emitter, eventName, emitterName } = check;
  if (!eventName || typeof emitter !== "string" || !isAddress(emitter))
    return null;
  const explorer = chainById(chainId)?.blockExplorers?.default?.url;
  return {
    label:
      emitterName && PLAIN_NAME.test(emitterName)
        ? emitterName
        : `${emitter.slice(0, 6)}…${emitter.slice(-4)}`,
    ...(explorer
      ? { href: `${explorer.replace(/\/$/, "")}/address/${emitter}` }
      : {}),
    address: emitter,
    eventName,
  };
}

/** The chain's own currency has no events: its checks come from the
 *  balances the simulation changed (`std:native`, the executor's own, and
 *  `std:nativeBalance`, any other account's). */
export const BALANCE_SOURCE = "Suggested by the simulation's balance changes";
export function fromBalances(
  check: Pick<SuggestedCheck, "module" | "event">,
): boolean {
  return (
    check.module === "std" &&
    (check.event === "native" || check.event === "nativeBalance")
  );
}

export const BALANCE_WARNING =
  "Balances may change before the proposal executes.";
export const ALLOWANCE_WARNING =
  "The allowance may change before the proposal executes.";
/** The native floor, wherever it executes: the balance is everything the
 *  account does, not only this batch. */
export const NATIVE_FLOOR_WARNING =
  "Other transactions from this account change this balance: the check fails if it falls below the floor.";
/** For an amount whose event the builder does not know: true of any. */
export const AMOUNT_WARNING =
  "This amount may change before the proposal executes.";

/** What each amount suggestion is a number of, by the module and event
 *  that produced it (the names EVMcrispr reports them under). */
const AMOUNT_WARNINGS: Record<string, string> = {
  "token:erc20Approval": ALLOWANCE_WARNING,
  "token:erc20Transfer": BALANCE_WARNING,
  "token:erc1155TransferSingle": BALANCE_WARNING,
  "token:erc1155TransferBatch": BALANCE_WARNING,
  // The chain's own currency, from balances read before and after the run.
  "std:nativeBalance": BALANCE_WARNING,
  // The executor's own balance, asserted exactly (emptied).
  "std:native": BALANCE_WARNING,
};

/** A recipient's floor: the account it guards can spend what it got. */
export const RECIPIENT_NOTICE =
  "This account can move these funds before the proposal executes.";
/** An emptied account's zero: anyone can send it something. */
export const EMPTIED_NOTICE =
  "Anyone can send it some before the proposal executes.";

/**
 * What a row says about how its check can fail for reasons of its own,
 * behind its (i): the amount's notice, made specific where the check is a
 * recipient's floor (that account can spend it) or an emptied account's
 * zero (anyone can send it some). A wallet batch executes right away: it
 * has none but the native floor's. A state check has none.
 */
export function checkNotices(
  check: Pick<SuggestedCheck, "kind" | "module" | "event" | "line" | "sentence">,
  context: ContextKind,
  executor: string | undefined,
): string[] {
  const notice = amountWarning(check, context);
  if (!notice) return [];
  if (context !== "eoa") {
    if (/==\s*0$/.test(check.line)) return [EMPTIED_NOTICE];
    const subject = (Array.isArray(check.sentence) ? check.sentence : []).find(
      (part) => part.type === "address",
    );
    if (
      / >= /.test(check.line) &&
      subject?.type === "address" &&
      executor &&
      String(subject.address).toLowerCase() !== executor.toLowerCase()
    )
      return [RECIPIENT_NOTICE];
  }
  return [notice];
}

/** The one warning an amount carries. The native floor says what it
 *  depends on, in every context. Any other amount warns where execution
 *  comes after review (a Safe, a Governor, an Aragon OSx DAO): the number
 *  is the simulation's, and the sentence names what it is a number of. A
 *  wallet batch executes right away; a state check names no amount. */
export function amountWarning(
  check: Pick<SuggestedCheck, "kind" | "module" | "event"> & { line?: string },
  context: ContextKind,
): string | null {
  if (check.kind !== "amount") return null;
  if (isNativeFloor(check) && !isExact(check)) return NATIVE_FLOOR_WARNING;
  if (context === "eoa") return null;
  return AMOUNT_WARNINGS[`${check.module}:${check.event}`] ?? AMOUNT_WARNING;
}
