import type { SimulateOptions, SimulationResult } from "@evmcrispr/core";
import { isAddress } from "viem";

import { chainById } from "../deployments/wagmi";
import type { ContextKind } from "./context";
import {
  type LineVariable,
  type Naming,
  addressVariable,
  addressVariables,
  bindVariables,
  commandSpans,
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
 *  protected batch, guarding the balances of the account it runs as.
 *  Nothing for the actions on their own. */
export function suggestOption(key: SimKey): SimulateOptions["suggest"] {
  if (key.mode !== "protected") return undefined;
  return key.from ? { executor: key.from } : true;
}

export interface SuggestedChecks {
  /** The suggestions not in the script yet, in the order they came. */
  checks: SuggestedCheck[];
  /** The run did more than was looked at: some may be missing. */
  truncated: boolean;
  /** The script holds suggestions the simulation did not run with. */
  added: boolean;
}

const isNativeFloor = (check: Pick<SuggestedCheck, "module" | "event">) =>
  check.module === "std" && check.event === "native";

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

/**
 * The suggestions to offer for the batch as it is now (`key`), from the
 * last simulation. Null unless that simulation passed, ran the protected
 * batch as the same executor on the same chain, and the script has not
 * changed since except by lines this very run suggested: adding one keeps
 * the others, any other edit ends them. A suggestion already in the script
 * is left out.
 */
export function suggestedChecks(
  state: SimulationState,
  key: SimKey,
): SuggestedChecks | null {
  const { simulated, result } = state;
  if (state.status !== "success" || !simulated || !result) return null;
  if (!Array.isArray(result.suggestions)) return null;
  if (
    key.mode !== "protected" ||
    simulated.mode !== "protected" ||
    simulated.chainId !== key.chainId ||
    !sameAccount(simulated.from, key.from)
  )
    return null;

  // Lines are compared by what they mean: a suggestion is added under the
  // script's own variable names, which need not be the suggestion's, and
  // adding one can rename a variable everywhere. So the two scripts are
  // compared command by command, by meaning, the variables pinned to an
  // address and the loads aside: those are scaffolding.
  const suggested = new Set(result.suggestions.map(suggestionMeaning));
  const rest = (script: string) => {
    const variables = addressVariables(script);
    return commandSpans(script)
      .filter((span) => !isLoadSpan(span) && !addressVariable(span))
      .map((span) => lineMeaning(span.text, variables))
      .filter((meaning) => !suggested.has(meaning))
      .join("\n");
  };
  if (rest(key.script) !== rest(simulated.script)) return null;

  const present = scriptMeanings(key.script);
  const ran = scriptMeanings(simulated.script);
  // A suggested line the simulation did not run with: a rename alone adds
  // nothing.
  const added = [...suggested].some((line) => present.has(line) && !ran.has(line));
  const floors = new Set([...present].map(withoutBound));
  const checks: SuggestedCheck[] = [];
  for (const suggestion of result.suggestions as SuggestedCheck[]) {
    const line = suggestionMeaning(suggestion);
    if (present.has(line)) continue;
    // The native floor depends on the gas the run used, so a batch
    // simulated with one in place gets it back with another number: the
    // same check, not a second one.
    if (isNativeFloor(suggestion) && floors.has(withoutBound(line))) continue;
    present.add(line);
    checks.push(suggestion);
  }
  return {
    checks,
    truncated: result.suggestionsTruncated === true,
    added,
  };
}

/** How long a block may be simulated at again: past this it says too
 *  little about the chain as it is, and a node may no longer serve it. */
export const PIN_MAX_AGE_MS = 5 * 60_000;

/**
 * The block to simulate `key` at so that the run confirms what the last
 * one suggested: that run's own block, while the batch is the one it
 * simulated plus checks it suggested, and the block is recent. Undefined
 * otherwise (any other edit, another executor or chain, a failed run, an
 * unchanged batch, an old block): simulate at the latest block.
 */
export function confirmationBlock(
  state: SimulationState,
  key: SimKey,
  now: number,
): number | undefined {
  if (state.block === undefined || state.blockReadAt === undefined)
    return undefined;
  if (now - state.blockReadAt > PIN_MAX_AGE_MS) return undefined;
  return suggestedChecks(state, key)?.added ? state.block : undefined;
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
}

/** A sentence ready to draw: words, and what they mention. */
export type SentenceView = (string | SentenceLink)[];

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
      else view.push(addressLink(chainId, part.address, part.name, part.listed));
    } else if (part.token === "native" || !isAddress(part.token)) {
      view.push(part.text);
    } else {
      const symbol =
        part.symbol && PLAIN_NAME.test(part.symbol) ? part.symbol : undefined;
      const at = symbol ? part.text.lastIndexOf(symbol) : -1;
      if (symbol && at >= 0) {
        const before = part.text.slice(0, at);
        const after = part.text.slice(at + symbol.length);
        if (before) view.push(before);
        view.push(addressLink(chainId, part.token, symbol, part.listed));
        if (after) view.push(after);
      } else {
        view.push(part.text, " of ", addressLink(chainId, part.token));
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
};

/** The one warning an amount carries. The native floor says what it
 *  depends on, in every context. Any other amount warns where execution
 *  comes after review (a Safe, a Governor, an Aragon OSx DAO): the number
 *  is the simulation's, and the sentence names what it is a number of. A
 *  wallet batch executes right away; a state check names no amount. */
export function amountWarning(
  check: Pick<SuggestedCheck, "kind" | "module" | "event">,
  context: ContextKind,
): string | null {
  if (check.kind !== "amount") return null;
  if (isNativeFloor(check)) return NATIVE_FLOOR_WARNING;
  if (context === "eoa") return null;
  return AMOUNT_WARNINGS[`${check.module}:${check.event}`] ?? AMOUNT_WARNING;
}
