import type { ScriptEditResult } from "@evmcrispr/ai";
import { useCallback, useRef, useState } from "react";

export type AssertionPlacement = "pre" | "post";

/** Whether the script contains any assertion commands. */
export function hasAssertions(script: string): boolean {
  return /^\s*assert\b/m.test(script);
}

/**
 * On-chain helpers owned by the lang module (`@str.*!`, `@bytes.*!`,
 * `@len!` and the array faces), whose presence in a line requires
 * `load lang`. The builder's codegen emits a
 * subset of these; the pattern covers the whole lang bang surface so
 * chat-authored lines keep the load line alive too.
 */
const LANG_HELPER =
  /@(?:str|bytes)\.[a-z]+!|@(?:len|at|includes|all|any|reduce|map|sort|unique|reverse|zip|unzip|flat|concat)!/i;

export function usesLangHelpers(text: string): boolean {
  return LANG_HELPER.test(text);
}

/**
 * Helpers owned by the receipts module: the block/tx context reads
 * (`@block.timestamp!`, `@tx.from!`, `@tx.gasPrice!`, ...), the chain id
 * (`@chainId!`) and the off-chain receipt readers (`@receipts:tx`,
 * `@receipts:txs`, ...). Their presence requires `load receipts`.
 */
const RECEIPTS_HELPER =
  /@(?:receipts:)?(?:(?:block|tx)\.[a-zA-Z]+!?|txs?(?![\w.])|chainId!?(?![\w.]))/i;

export function usesReceiptsHelpers(text: string): boolean {
  return RECEIPTS_HELPER.test(text);
}

/**
 * Helpers owned by the contracts module: the code and storage reads
 * (`@codeHash!`, `@contracts:codeAt!`, ...), whose presence requires
 * `load contracts`.
 */
const CONTRACTS_HELPER =
  /@(?:contracts:)?(?:codeHash|codeAt|storageAt|account|next|slot\.[a-zA-Z0-9]+)!?(?![\w.])/i;

export function usesContractsHelpers(text: string): boolean {
  return CONTRACTS_HELPER.test(text);
}

/**
 * Helpers owned by the math module (`@min!`, `@max!`, `@absDiff!`,
 * `@sqrt!` and their plain off-chain faces), whose presence requires
 * `load math`.
 */
const MATH_HELPER = /@(?:math:)?(?:min|max|absDiff|sqrt)!?(?![\w.])/i;

export function usesMathHelpers(text: string): boolean {
  return MATH_HELPER.test(text);
}

/** The load lines an assertion brings with it: the helper modules its
 *  faces are owned by. `assert` itself is std's and needs none, so these
 *  are the lines the assertion surfaces hide as scaffolding. */
export function isHelperLoad(line: string): boolean {
  return /^load (?:lang|receipts|contracts|math)$/.test(line.trim());
}

/**
 * The script without its assertions: `assert` lines are dropped, and the
 * helper-module load lines they were the only user of go with them. Used
 * to simulate the raw batch actions separately from the protected script.
 */
export function stripAssertions(script: string): string {
  const kept = script.split("\n").filter((l) => !/^\s*assert\b/.test(l));
  // The helper-module load lines usually ride along with the assertions;
  // drop each once no remaining line uses one of its helpers.
  return kept
    .filter((l) => l.trim() !== "load lang" || kept.some(usesLangHelpers))
    .filter(
      (l) => l.trim() !== "load receipts" || kept.some(usesReceiptsHelpers),
    )
    .filter(
      (l) => l.trim() !== "load contracts" || kept.some(usesContractsHelpers),
    )
    .filter((l) => l.trim() !== "load math" || kept.some(usesMathHelpers))
    .join("\n");
}

/**
 * Pure merge of an assertion line into an action block: adds the load line
 * of every helper module the assertion reaches for, hoists missing `set`
 * lines into the leading header, then places the assertion before the
 * first action line (pre-condition) or at the end (post-condition).
 * Exported so the assertion form can preview/validate the candidate script
 * before committing it.
 */
export function insertAssertionLines(
  script: string,
  line: string,
  placement: AssertionPlacement,
  sets: string[] = [],
): string {
  const trimmed = script.trimEnd();
  const lines = trimmed ? trimmed.split("\n") : [];
  const t = (l: string) => l.trim();

  const ensureLoad = (name: string) => {
    if (lines.some((l) => t(l) === `load ${name}`)) return;
    let loadEnd = 0;
    while (loadEnd < lines.length && t(lines[loadEnd]).startsWith("load "))
      loadEnd++;
    lines.splice(loadEnd, 0, `load ${name}`);
  };
  // `assert` and @reverts! are std's, which is always loaded, so an assertion
  // needs no load line of its own. What it may need belongs to the helpers
  // it uses: the array/string faces (@str.split!, @bytes.len!, @len!, ...)
  // are lang's, the block/tx context reads and the chain id are receipts',
  // the code and storage reads contracts', the arithmetic conveniences
  // math's.
  if (usesLangHelpers(line)) ensureLoad("lang");
  if (usesReceiptsHelpers(line)) ensureLoad("receipts");
  if (usesContractsHelpers(line)) ensureLoad("contracts");
  if (usesMathHelpers(line)) ensureLoad("math");

  // Header = leading load/set/comment/blank lines; everything below is
  // actions (and any assertions already placed among them).
  const isHeader = (l: string) =>
    l === "" ||
    l.startsWith("#") ||
    l.startsWith("load ") ||
    l.startsWith("set ");
  let headerEnd = 0;
  while (headerEnd < lines.length && isHeader(t(lines[headerEnd]))) headerEnd++;

  const missing = sets.filter((s) => !lines.some((l) => t(l) === s.trim()));
  lines.splice(headerEnd, 0, ...missing);
  headerEnd += missing.length;

  if (placement === "pre") {
    // Group with any existing pre-assertions right below the header.
    let at = headerEnd;
    while (at < lines.length && /^assert\b/.test(t(lines[at]))) at++;
    lines.splice(at, 0, line);
  } else {
    lines.push(line);
  }
  return lines.join("\n");
}

/**
 * The composed action block, shared by every authoring surface (ABI form,
 * drag-and-drop, Monaco editor, AI chat). Edits from the chat's script tools
 * are recorded as revisions so tool cards can offer one-click undo.
 */
export function useScriptState(initial = "") {
  const [script, setScriptState] = useState(initial);
  const scriptRef = useRef(script);
  const revisions = useRef(
    new Map<string, { before: string; after: string }>(),
  );

  const setScript = useCallback((next: string) => {
    scriptRef.current = next;
    setScriptState(next);
  }, []);

  const getScript = useCallback(() => scriptRef.current, []);

  const appendLines = useCallback(
    (lines: string) => {
      const current = scriptRef.current.trimEnd();
      setScript(current ? `${current}\n${lines}` : lines);
    },
    [setScript],
  );

  /**
   * Append a line, first ensuring the given `set` lines exist in the leading
   * set-block of the script (helpers like @ens can't run mid-batch, so
   * address lookups are hoisted to `set` commands at the top).
   */
  const appendWithSets = useCallback(
    (line: string, sets: string[]) => {
      const current = scriptRef.current.trimEnd();
      const lines = current ? current.split("\n") : [];
      const missing = sets.filter(
        (s) => !lines.some((l) => l.trim() === s.trim()),
      );
      let insertAt = 0;
      while (
        insertAt < lines.length &&
        lines[insertAt].trimStart().startsWith("set ")
      )
        insertAt++;
      lines.splice(insertAt, 0, ...missing);
      lines.push(line);
      setScript(lines.join("\n"));
    },
    [setScript],
  );

  /**
   * Remove the line at the given index, then drop scaffolding it orphaned:
   * `set $var …` lines whose variable no other line references, and a
   * helper module's load line once nothing uses its helpers.
   */
  const removeLine = useCallback(
    (index: number) => {
      const lines = scriptRef.current.split("\n");
      if (index < 0 || index >= lines.length) return;
      lines.splice(index, 1);

      let cleaned = lines;
      for (;;) {
        const next = cleaned.filter((line, i) => {
          const t = line.trim();
          const setMatch = t.match(/^set\s+(\$[a-zA-Z0-9_]+)/);
          if (setMatch) {
            const ref = new RegExp(
              `\\${setMatch[1]}(?![a-zA-Z0-9_])`,
            );
            return cleaned.some((l, j) => j !== i && ref.test(l));
          }
          if (t === "load lang")
            return cleaned.some((l, j) => j !== i && usesLangHelpers(l));
          if (t === "load receipts")
            return cleaned.some((l, j) => j !== i && usesReceiptsHelpers(l));
          if (t === "load contracts")
            return cleaned.some((l, j) => j !== i && usesContractsHelpers(l));
          if (t === "load math")
            return cleaned.some((l, j) => j !== i && usesMathHelpers(l));
          return true;
        });
        if (next.length === cleaned.length) break;
        cleaned = next;
      }

      setScript(cleaned.join("\n").trim() === "" ? "" : cleaned.join("\n"));
    },
    [setScript],
  );

  /** Insert an assertion line as a pre- or post-condition (see
   *  `insertAssertionLines`). */
  const insertAssertion = useCallback(
    (line: string, placement: AssertionPlacement, sets: string[] = []) => {
      setScript(insertAssertionLines(scriptRef.current, line, placement, sets));
    },
    [setScript],
  );

  const recordRevision = useCallback((before: string, after: string) => {
    const id = crypto.randomUUID();
    revisions.current.set(id, { before, after });
    return id;
  }, []);

  const applyStrReplace = useCallback(
    (oldString: string, newString: string): ScriptEditResult => {
      const current = scriptRef.current;
      const first = current.indexOf(oldString);
      if (first === -1)
        return { ok: false, error: "old_string not found in the script." };
      if (current.indexOf(oldString, first + 1) !== -1)
        return {
          ok: false,
          error:
            "old_string matches more than once. Include more surrounding context to make it unique.",
        };
      const next =
        current.slice(0, first) + newString + current.slice(first + oldString.length);
      const revisionId = recordRevision(current, next);
      setScript(next);
      return { ok: true, revisionId };
    },
    [recordRevision, setScript],
  );

  const applyWrite = useCallback(
    (content: string): ScriptEditResult => {
      const current = scriptRef.current;
      const revisionId = recordRevision(current, content);
      setScript(content);
      return { ok: true, revisionId };
    },
    [recordRevision, setScript],
  );

  const undoRevision = useCallback(
    (revisionId: string): ScriptEditResult => {
      const revision = revisions.current.get(revisionId);
      if (!revision) return { ok: false, error: "Unknown revision." };
      if (scriptRef.current !== revision.after)
        return {
          ok: false,
          error: "The script changed since this edit. Undo manually instead.",
        };
      revisions.current.delete(revisionId);
      setScript(revision.before);
      return { ok: true };
    },
    [setScript],
  );

  return {
    script,
    setScript,
    getScript,
    appendLines,
    appendWithSets,
    removeLine,
    insertAssertion,
    applyStrReplace,
    applyWrite,
    undoRevision,
  };
}
