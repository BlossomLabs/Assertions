import type { ScriptEditResult } from "@evmcrispr/ai";
import { useCallback, useRef, useState } from "react";

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
            "old_string matches more than once — include more surrounding context to make it unique.",
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
          error: "The script changed since this edit — undo manually instead.",
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
    applyStrReplace,
    applyWrite,
    undoRevision,
  };
}
