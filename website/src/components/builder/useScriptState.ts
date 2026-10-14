import type { ScriptEditResult } from "@evmcrispr/ai";
import { useCallback, useRef, useState } from "react";

import {
  type AddressKind,
  type AssertionPlacement,
  type ContextVariable,
  type LineVariable,
  type Naming,
  addressVariables,
  bindVariables,
  insertAssertionLines,
  nameContext,
  removeCommand as removeCommandFrom,
  replaceCommand,
  rewriteCommand,
  setVariables,
  spanAtLine,
  markSuggested,
  unmarkSuggested,
  userRename,
  withoutSuggested,
  commandSpans,
} from "./script-ops";
import {
  type SuggestedCheck,
  applySuggestions,
  suggestionVariables,
} from "./suggested-checks";

type Managed = NonNullable<Naming["managed"]>;

/**
 * The composed action block, shared by every authoring surface (ABI form,
 * drag-and-drop, Monaco editor, AI chat). The script surgery itself
 * (spans, scaffolding, placement, names) lives in script-ops.ts; this
 * holds the script and what the builder knows of its variable names that
 * the text does not say: which names it gave (and may give again), the
 * accounts the context names, and which addresses have code.
 */
export function useScriptState(
  initial = "",
  {
    kindOf,
  }: {
    /** Whether an address has code on the chain the batch targets, when
     *  that can be read: what a variable is renamed to when its address
     *  turns out to play two roles. */
    kindOf?: (address: string) => Promise<AddressKind | undefined>;
  } = {},
) {
  const [script, setScriptState] = useState(initial);
  const scriptRef = useRef(script);
  const setScript = useCallback((next: string) => {
    scriptRef.current = next;
    setScriptState(next);
  }, []);

  const getScript = useCallback(() => scriptRef.current, []);

  const managedRef = useRef<Managed>(new Map());
  const contextRef = useRef<readonly ContextVariable[]>([]);
  const kindsRef = useRef(new Map<string, AddressKind>());
  const kindOfRef = useRef(kindOf);
  kindOfRef.current = kindOf;

  /** What is known of the names of the script as it is now. A name the
   *  script no longer sets is forgotten: typed again, it is the user's. */
  const naming = useCallback((): Naming => {
    const set = setVariables(scriptRef.current);
    managedRef.current = new Map(
      [...managedRef.current].filter(([name]) => set.has(name)),
    );
    return {
      managed: managedRef.current,
      context: contextRef.current,
      kinds: kindsRef.current,
    };
  }, []);

  // Edits that may need to read an address's code run one after another,
  // each on the script the one before left. One that needs no read, with
  // none waiting, applies at once.
  const pending = useRef<Promise<void>>(Promise.resolve());
  const waiting = useRef(0);
  const edit = useCallback(
    (addresses: readonly string[], apply: () => void): Promise<void> => {
      const read = kindOfRef.current;
      const unknown = read
        ? addresses
            .map((address) => address.toLowerCase())
            .filter((address) => !kindsRef.current.has(address))
        : [];
      if (unknown.length === 0 && waiting.current === 0) {
        apply();
        return Promise.resolve();
      }
      waiting.current++;
      const run = async () => {
        try {
          for (const address of new Set(unknown)) {
            const kind = await read?.(address).catch(() => undefined);
            if (kind) kindsRef.current.set(address, kind);
          }
          apply();
        } finally {
          waiting.current--;
        }
      };
      pending.current = pending.current.then(run, run);
      return pending.current;
    },
    [],
  );

  /** The addresses among `vars` the script already has a variable for,
   *  under a name the builder gave: the ones a new role could rename. */
  const renamable = (vars: readonly LineVariable[]): string[] => {
    const { managed } = naming();
    const byAddress = new Map(
      [...addressVariables(scriptRef.current)].map(([name, address]) => [
        address.toLowerCase(),
        name,
      ]),
    );
    return vars
      .map((v) => v.value)
      .filter((value) => {
        const name = byAddress.get(value.toLowerCase());
        return name !== undefined && managed?.has(name);
      });
  };

  const appendLines = useCallback(
    (lines: string) => {
      const current = scriptRef.current.trimEnd();
      setScript(current ? `${current}\n${lines}` : lines);
    },
    [setScript],
  );

  /**
   * Add a line that names addresses: an action, a suggested check. The
   * addresses (`vars`) take the script's variables, or get a `set` line of
   * their own (`bindVariables`); `sets` are lines it needs as they are (an
   * ENS lookup: helpers like @ens can't run mid-batch). The `set` lines
   * land in the script's header, the modules its helpers need are loaded,
   * and the line goes where `placement` says.
   */
  const addLine = useCallback(
    (
      line: string,
      placement: AssertionPlacement,
      { sets = [], vars = [] }: { sets?: string[]; vars?: readonly LineVariable[] } = {},
    ) =>
      edit(renamable(vars), () => {
        const bound = bindVariables(scriptRef.current, { line, vars }, naming());
        managedRef.current = bound.managed;
        setScript(
          insertAssertionLines(bound.script, bound.line, placement, [
            ...sets,
            ...bound.sets,
          ]).script,
        );
      }),
    // `renamable` reads refs only.
    [edit, naming, setScript],
  );

  /** Append an action (see `addLine`). */
  const appendWithSets = useCallback(
    (line: string, sets: string[], vars: readonly LineVariable[] = []) =>
      addLine(line, "post", { sets, vars }),
    [addLine],
  );

  /** What `addLine` would write for a line, without writing it. Where
   *  that depends on an address's code not read yet, it is read, and the
   *  preview is drawn again with it. */
  const [, redraw] = useState(0);
  const learning = useRef(new Set<string>());
  const previewLine = useCallback(
    (line: string, vars: readonly LineVariable[], script = scriptRef.current) => {
      const unread = kindOfRef.current
        ? renamable(vars)
            .map((address) => address.toLowerCase())
            .filter(
              (address) =>
                !kindsRef.current.has(address) && !learning.current.has(address),
            )
        : [];
      if (unread.length > 0) {
        for (const address of unread) learning.current.add(address);
        void edit(unread, () => redraw((n) => n + 1));
      }
      const { line: bound, sets } = bindVariables(script, { line, vars }, naming());
      return { line: bound, sets };
    },
    // `renamable` reads refs only.
    [edit, naming],
  );

  /** Put an action where the command covering a 1-based line is (see
   *  `replaceCommand`): what saving an edited action does. */
  const replaceLine = useCallback(
    (at: number, line: string, sets: string[], vars: readonly LineVariable[] = []) =>
      edit(renamable(vars), () => {
        const bound = bindVariables(scriptRef.current, { line, vars }, naming());
        managedRef.current = bound.managed;
        setScript(
          replaceCommand(bound.script, at, bound.line, [...sets, ...bound.sets]),
        );
      }),
    // `renamable` reads refs only.
    [edit, naming, setScript],
  );

  /** Tell the script which accounts the context names: their variables
   *  take those names, and one that had such a name for another account
   *  takes what can be read of it (`nameContext`). */
  const setContext = useCallback(
    (context: readonly ContextVariable[]) => {
      contextRef.current = context;
      const named = new Set(context.map((c) => c.address.toLowerCase()));
      const { managed } = naming();
      const stale = [...addressVariables(scriptRef.current)]
        .filter(
          ([name, address]) =>
            managed?.get(name) === "context" && !named.has(address.toLowerCase()),
        )
        .map(([, address]) => address);
      return edit(stale, () => {
        const next = nameContext(scriptRef.current, naming());
        managedRef.current = next.managed;
        if (next.script !== scriptRef.current) setScript(next.script);
      });
    },
    [edit, naming, setScript],
  );

  /** The user's own rename of a variable: every use follows, and the name
   *  is the user's from then on. Returns why not, when it is refused. */
  const renameVariable = useCallback(
    (from: string, to: string): { error?: string } => {
      const renamed = userRename(scriptRef.current, from, to);
      if ("error" in renamed) return renamed;
      if (renamed.script !== scriptRef.current) {
        const managed = new Map(managedRef.current);
        managed.delete(from);
        managedRef.current = managed;
        setScript(renamed.script);
      }
      return {};
    },
    [setScript],
  );

  /** Replace the script with one the builder composed (an import), with
   *  the names it gave in it. */
  const loadComposed = useCallback(
    (next: string, managed: Managed) => {
      managedRef.current = managed;
      setScript(next);
    },
    [setScript],
  );

  /** Remove the command covering a 1-based line, then the scaffolding it
   *  orphaned (see `removeCommand` in script-ops). */
  const removeCommand = useCallback(
    (line: number) => {
      setScript(removeCommandFrom(scriptRef.current, line));
    },
    [setScript],
  );

  /** Insert an assertion line as a pre- or post-condition (see
   *  `insertAssertionLines`). */
  const insertAssertion = useCallback(
    (line: string, placement: AssertionPlacement, sets: string[] = []) => {
      setScript(
        insertAssertionLines(scriptRef.current, line, placement, sets).script,
      );
    },
    [setScript],
  );

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
      setScript(next);
      return { ok: true };
    },
    [setScript],
  );

  const applyWrite = useCallback(
    (content: string): ScriptEditResult => {
      setScript(content);
      return { ok: true };
    },
    [setScript],
  );

  /** Make the script follow step 1's run (`applySuggestions`): the checks
   *  it manages are kept, replaced or removed, new suggestions added. What
   *  it holds of them, for the next run. */
  const applySuggestionRun = useCallback(
    (
      suggestions: readonly SuggestedCheck[],
      previous: ReadonlySet<string> | undefined,
    ): Promise<Set<string>> => {
      let applied = new Set<string>();
      return edit(
        renamable(suggestions.flatMap((check) => suggestionVariables(check))),
        () => {
          const next = applySuggestions(scriptRef.current, suggestions, previous, naming());
          if (next.managed) managedRef.current = new Map(next.managed);
          applied = next.applied;
          if (next.script !== scriptRef.current) setScript(next.script);
        },
      ).then(() => applied);
    },
    // `renamable` reads refs only.
    [edit, naming, setScript],
  );

  /** Make the suggested check covering a 1-based line the user's: its
   *  `suggested` mark taken out of its comment. */
  const unmarkCommand = useCallback(
    (line: number) => {
      const span = spanAtLine(commandSpans(scriptRef.current), line);
      if (!span) return;
      setScript(rewriteCommand(scriptRef.current, line, unmarkSuggested(span.text)));
    },
    [setScript],
  );

  /** Hand the check covering a 1-based line back to the suggestions: the
   *  `suggested` mark added to its comment (on its last line). */
  const markCommand = useCallback(
    (line: number) => {
      const span = spanAtLine(commandSpans(scriptRef.current), line);
      if (!span) return;
      const lines = span.text.split("\n");
      lines[lines.length - 1] = markSuggested(lines[lines.length - 1]);
      setScript(rewriteCommand(scriptRef.current, line, lines.join("\n")));
    },
    [setScript],
  );

  /** Take out every check still marked as suggested. */
  const dropSuggested = useCallback(() => {
    const next = withoutSuggested(scriptRef.current);
    if (next !== scriptRef.current) setScript(next);
  }, [setScript]);

  return {
    script,
    setScript,
    applySuggestionRun,
    unmarkCommand,
    markCommand,
    dropSuggested,
    getScript,
    getNaming: naming,
    appendLines,
    appendWithSets,
    addLine,
    previewLine,
    replaceLine,
    setContext,
    renameVariable,
    loadComposed,
    removeCommand,
    insertAssertion,
    applyStrReplace,
    applyWrite,
  };
}
