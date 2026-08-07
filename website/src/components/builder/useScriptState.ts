import type { ScriptEditResult } from "@evmcrispr/ai";
import { useCallback, useRef, useState } from "react";

export type AssertionPlacement = "pre" | "post";

/** Whether the script contains any assertion commands. */
export function hasAssertions(script: string): boolean {
  return /^\s*assertions:/m.test(script);
}

/**
 * The script without its assertions: assertion command lines are dropped,
 * and the then-unused `load assertions` with them. Used to simulate the raw
 * batch actions separately from the protected script.
 */
export function stripAssertions(script: string): string {
  return script
    .split("\n")
    .filter((l) => {
      const t = l.trim();
      return !t.startsWith("assertions:") && t !== "load assertions";
    })
    .join("\n");
}

/**
 * Pure merge of an assertion line into an action block: ensures
 * `load assertions` heads the script, hoists missing `set` lines into the
 * leading header, then places the assertion before the first action line
 * (pre-condition) or at the end (post-condition). Exported so the assertion
 * form can preview/validate the candidate script before committing it.
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

  if (!lines.some((l) => t(l) === "load assertions")) {
    let loadEnd = 0;
    while (loadEnd < lines.length && t(lines[loadEnd]).startsWith("load "))
      loadEnd++;
    lines.splice(loadEnd, 0, "load assertions");
  }

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
    while (at < lines.length && t(lines[at]).startsWith("assertions:")) at++;
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
   * `set $var …` lines whose variable no other line references, and
   * `load assertions` once no assertion command remains.
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
          if (t === "load assertions")
            return cleaned.some((l) => l.trim().startsWith("assertions:"));
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
