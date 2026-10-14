import { describe, expect, it } from "vitest";

import {
  isSuggestedText,
  markSuggested,
  unmarkSuggested,
  withoutSuggested,
} from "../script-ops";
import { type SuggestedCheck, applySuggestions, lineMeaning } from "../suggested-checks";
import { addressVariables } from "../script-ops";

const T = "0x00000000000000000000000000000000000000aa";
const O = "0x00000000000000000000000000000000000000bb";
const ACTION = `exec ${T} "pause()"`;

const check = (line: string, event = "paused"): SuggestedCheck => ({
  line,
  description: line,
  kind: "state",
  module: "std",
  event,
  emitter: T,
});
const PAUSED = check(`assert ${T}::!{paused()(bool)} == true`);
const OWNER = check(`assert @acl:owner!(${T}) == ${O}`, "ownershipTransferred");
const FLOOR = check(`assert @balance!(${T} ${O}) >= 95`, "erc20Transfer");
const FLOOR_96 = check(`assert @balance!(${T} ${O}) >= 96`, "erc20Transfer");
const meaning = (c: SuggestedCheck) => lineMeaning(c.line, new Map());
const lines = (script: string) => script.split("\n");

describe("the suggested mark", () => {
  it("is a comment of its own, or a word added to the comment a line has", () => {
    expect(markSuggested("assert 1 == 1")).toBe("assert 1 == 1  # suggested");
    expect(markSuggested("assert $w::!{x()(uint256)} == 5  # base units of $w")).toBe(
      "assert $w::!{x()(uint256)} == 5  # base units of $w · suggested",
    );
    // Once is enough.
    expect(markSuggested("assert 1 == 1  # suggested")).toBe("assert 1 == 1  # suggested");
  });

  it("is read from the comment only, never from a string", () => {
    expect(isSuggestedText("assert 1 == 1  # suggested")).toBe(true);
    expect(isSuggestedText("assert 1 == 1  # base units of $w · suggested")).toBe(true);
    expect(isSuggestedText('assert 1 == 1 "suggested"')).toBe(false);
    expect(isSuggestedText("assert 1 == 1  # not suggestedly")).toBe(false);
    expect(isSuggestedText("assert 1 == 1")).toBe(false);
  });

  it("comes off with the comment left saying anything else it said", () => {
    expect(unmarkSuggested("assert 1 == 1  # suggested")).toBe("assert 1 == 1");
    expect(unmarkSuggested("assert 1 == 5  # base units of $w · suggested")).toBe(
      "assert 1 == 5  # base units of $w",
    );
    expect(unmarkSuggested("assert 1 == 1")).toBe("assert 1 == 1");
  });

  it("takes the checks still marked out of a script, with the variables only they used", () => {
    const script = [
      `set $o ${O}`,
      ACTION,
      "assert $o::!{x()(bool)} == true  # suggested",
      "assert 1 == 1",
    ].join("\n");
    expect(withoutSuggested(script)).toBe([ACTION, "assert 1 == 1"].join("\n"));
  });
});

describe("applySuggestions", () => {
  it("adds every suggestion, marked, after the actions", () => {
    const { script, applied } = applySuggestions(ACTION, [PAUSED, OWNER], undefined);
    expect(lines(script)).toEqual([
      "load acl",
      ACTION,
      `${PAUSED.line}  # suggested`,
      `${OWNER.line}  # suggested`,
    ]);
    expect(applied).toEqual(new Set([meaning(PAUSED), meaning(OWNER)]));
  });

  it("keeps one suggested again, replaces one with a new number, and removes one no longer suggested", () => {
    const first = applySuggestions(ACTION, [PAUSED, OWNER, FLOOR], undefined);
    const next = applySuggestions(first.script, [PAUSED, FLOOR_96], first.applied);
    expect(lines(next.script)).toEqual([
      ACTION,
      `${PAUSED.line}  # suggested`,
      `${FLOOR_96.line}  # suggested`,
    ]);
    expect(next.applied).toEqual(new Set([meaning(PAUSED), meaning(FLOOR_96)]));
  });

  it("never touches the user's checks, and adds no copy of one", () => {
    const mine = `${ACTION}\n${OWNER.line}\nassert 1 == 1`;
    const { script } = applySuggestions(mine, [PAUSED, OWNER], undefined);
    expect(lines(script)).toEqual([
      ACTION,
      OWNER.line,
      "assert 1 == 1",
      `${PAUSED.line}  # suggested`,
    ]);
    // Still not suggested: the next run leaves it, suggested or not.
    const next = applySuggestions(script, [PAUSED], new Set([meaning(PAUSED)]));
    expect(lines(next.script)).toContain(OWNER.line);
  });

  it("does not add back one the user took out after the last run", () => {
    const first = applySuggestions(ACTION, [PAUSED, OWNER], undefined);
    const removed = lines(first.script)
      .filter((l) => !l.startsWith(PAUSED.line))
      .join("\n");
    const next = applySuggestions(removed, [PAUSED, OWNER], first.applied);
    expect(next.script).not.toContain(PAUSED.line);
    expect(next.applied).toEqual(new Set([meaning(OWNER)]));
    // Once the run stops suggesting it, it is forgotten: suggested again
    // later, it is added.
    const without = applySuggestions(next.script, [OWNER], next.applied);
    const back = applySuggestions(without.script, [PAUSED, OWNER], without.applied);
    expect(back.script).toContain(`${PAUSED.line}  # suggested`);
  });

  it("makes a marked check edited by hand the user's: it loses the mark and stays", () => {
    const first = applySuggestions(ACTION, [FLOOR], undefined);
    const edited = first.script.replace(">= 95", ">= 90");
    const next = applySuggestions(edited, [FLOOR_96], first.applied);
    expect(lines(next.script)).toEqual([
      ACTION,
      `assert @balance!(${T} ${O}) >= 90`,
      `${FLOOR_96.line}  # suggested`,
    ]);
  });

  it("leaves the user's check the run suggests too, unmarked, when the mark was taken off", () => {
    const first = applySuggestions(ACTION, [PAUSED], undefined);
    const mine = unmarkSuggested(first.script);
    const next = applySuggestions(mine, [PAUSED], first.applied);
    expect(lines(next.script)).toEqual([ACTION, PAUSED.line]);
    // It is the user's: nothing the run keeps managing.
    expect(next.applied).toEqual(new Set());
  });

  it("without a last run to compare with (a reload), goes by the mark alone", () => {
    const script = [ACTION, `${OWNER.line}  # suggested`, PAUSED.line].join("\n");
    const next = applySuggestions(script, [FLOOR], undefined);
    expect(lines(next.script)).toEqual([ACTION, PAUSED.line, `${FLOOR.line}  # suggested`]);
  });

  it("names addresses with the script's variables, marked lines included", () => {
    const named = check("assert @acl:owner!($contract) == $owner", "ownershipTransferred");
    named.vars = [
      { name: "contract", value: T as `0x${string}` },
      { name: "owner", value: O as `0x${string}` },
    ];
    const script = `set $token ${T}\nexec $token "pause()"`;
    const { script: out } = applySuggestions(script, [named], undefined);
    expect(lines(out).at(-1)).toBe("assert @acl:owner!($token) == $owner  # suggested");
    expect(addressVariables(out).get("owner")?.toLowerCase()).toBe(O);
  });
});
