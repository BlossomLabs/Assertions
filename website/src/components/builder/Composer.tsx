import { Editor } from "@evmcrispr/editor";
import type { editor } from "monaco-editor";
import { Suspense, useEffect, useRef, useState } from "react";

import { type ActionEdit, AbiForm } from "./AbiForm";
import { BatchList } from "./BatchList";
import { decomposeCall } from "./compose-call";
import {
  type TxBuilderBatch,
  importTxBuilder,
  parseTxBuilderBatch,
} from "./safe-tx-builder";
import { isAssertSpan } from "./script-ops";
import { useComposeEnv } from "./useComposeEnv";
import type { useScriptState } from "./useScriptState";

type Mode = "form" | "editor" | "txbuilder";

export function Composer({
  scriptState,
  chainId,
  safeContext = false,
  onDroppedChainId,
  onSkipActions,
}: {
  scriptState: ReturnType<typeof useScriptState>;
  chainId: number;
  /** The batch executes through a Safe: offers the Transaction Builder
   *  JSON import tab. */
  safeContext?: boolean;
  onDroppedChainId?: (chainId: number) => void;
  /** Passed on to the contract form: go on to assertions with no actions. */
  onSkipActions?: () => void;
}) {
  const { script, setScript } = scriptState;
  const [rawMode, setRawMode] = useState<Mode>("form");
  const [importError, setImportError] = useState<string | null>(null);
  const compose = useComposeEnv(chainId);
  // The action loaded back into the contract form. Any change to the
  // batch ends the edit: the line it was on may be another one now.
  const [editing, setEditing] = useState<ActionEdit | null>(null);
  const formRef = useRef<HTMLDivElement | null>(null);
  useEffect(() => {
    setEditing(null);
  }, [script]);
  const editorRef = useRef<editor.IStandaloneCodeEditor | null>(null);
  // Content last pushed to/received from Monaco, to break update loops.
  const editorContent = useRef<string>(script);

  // The import tab is Safe-only; fall back if the context changed under it.
  const mode = rawMode === "txbuilder" && !safeContext ? "form" : rawMode;

  // External updates (form adds, imports, AI edits) flow into Monaco.
  if (editorRef.current && editorContent.current !== script) {
    editorContent.current = script;
    if (editorRef.current.getValue() !== script)
      editorRef.current.setValue(script);
  }

  const importTxBuilderFile = async (file: File) => {
    setImportError(null);
    let parsed: unknown;
    try {
      parsed = JSON.parse(await file.text());
    } catch {
      setImportError(
        "Unrecognized file: expected a Safe Transaction Builder JSON export.",
      );
      return;
    }
    // The file is someone else's text: it is taken whole, every piece
    // checked for what it claims to be, or not at all. A refusal says
    // which transaction and which field, and the batch stays as it is.
    const checkedFile = parseTxBuilderBatch(parsed);
    if ("error" in checkedFile) {
      setImportError(`Not imported. ${checkedFile.error}`);
      return;
    }
    try {
      // Through the contract form's own path: named addresses and, for
      // the standard token calls, the token's units.
      const { script: converted, managed, chainId: batchChain } =
        await importTxBuilder(
          parsed as TxBuilderBatch,
          await compose.env(async () => null),
          scriptState.getNaming(),
        );
      scriptState.loadComposed(converted, managed);
      if (batchChain && onDroppedChainId) onDroppedChainId(batchChain);
      setRawMode("editor");
    } catch (e) {
      setImportError(
        `Not imported. ${e instanceof Error ? e.message : "The file could not be read."}`,
      );
    }
  };

  const tabs: [Mode, string][] = [
    ["form", "Contract form"],
    ["editor", "EVML editor"],
    ...(safeContext
      ? ([["txbuilder", "Transaction Builder JSON"]] as [Mode, string][])
      : []),
  ];

  return (
    <div>
      {/* Mode tabs */}
      <div className="flex items-center gap-1 mb-4 flex-wrap">
        {tabs.map(([m, label]) => (
          <button
            key={m}
            type="button"
            onClick={() => setRawMode(m)}
            className={`px-3 py-1.5 rounded-lg text-sm font-medium transition-colors ${
              mode === m
                ? "bg-[var(--color-bp-500)]/15 text-[var(--color-bp-300)]"
                : "text-[var(--color-ink-3)] hover:text-[var(--color-ink-2)]"
            }`}
          >
            {label}
          </button>
        ))}
      </div>

      {mode === "form" && (
        <div className="space-y-5">
          <div ref={formRef}>
            <AbiForm
              chainId={chainId}
              onAdd={scriptState.appendWithSets}
              onSkip={onSkipActions}
              editing={editing}
              onSave={scriptState.replaceLine}
              onCancelEdit={() => setEditing(null)}
            />
          </div>
          {script.trim() !== "" && (
            <div>
              <p className="text-xs text-[var(--color-ink-3)] mb-1.5">
                Batch so far
              </p>
              <BatchList
                script={script}
                chainId={chainId}
                highlight={editing?.line}
                onRename={scriptState.renameVariable}
                // An action goes back into the form when the form can
                // hold it, and to the EVML editor otherwise.
                editable={(span) =>
                  isAssertSpan(span)
                    ? null
                    : decomposeCall(script, span.start)
                      ? "form"
                      : "editor"
                }
                onEdit={(line, where) => {
                  const call = where === "form" ? decomposeCall(script, line) : null;
                  if (!call) {
                    setRawMode("editor");
                    return;
                  }
                  setEditing({ line, call });
                  formRef.current?.scrollIntoView?.({ block: "nearest" });
                }}
                onRemove={scriptState.removeCommand}
                // Assertions are added and removed in step 2; here they
                // render dimmed, without a delete button.
                canRemove={(span) => !isAssertSpan(span)}
              />
            </div>
          )}
        </div>
      )}

      {mode === "editor" && (
        <div className="rounded-xl overflow-hidden border border-[var(--color-ink-3)]/25">
          <Suspense
            fallback={
              <div className="h-72 flex items-center justify-center text-sm text-[var(--color-ink-3)]">
                Loading editor…
              </div>
            }
          >
            <Editor
              height="18rem"
              defaultValue={script}
              onMount={(ed) => {
                editorRef.current = ed;
                if (ed.getValue() !== scriptState.getScript())
                  ed.setValue(scriptState.getScript());
              }}
              onChange={(value) => {
                editorContent.current = value;
                setScript(value);
              }}
            />
          </Suspense>
        </div>
      )}

      {mode === "txbuilder" && (
        <div className="space-y-3">
          <p className="text-sm text-[var(--color-ink-2)]">
            Load a JSON batch exported from Safe's{" "}
            <a
              href="https://help.safe.global/en/articles/40841-transaction-builder"
              target="_blank"
              rel="noreferrer"
              className="text-[var(--color-bp-300)] hover:underline"
            >
              Transaction Builder
            </a>{" "}
            app. Its transactions replace the current batch.
          </p>
          <input
            type="file"
            accept=".json,application/json"
            onChange={(e) => {
              const file = e.target.files?.[0];
              if (file) void importTxBuilderFile(file);
              e.target.value = "";
            }}
            className="block w-full text-sm text-[var(--color-ink-2)] file:mr-3 file:px-4 file:py-2 file:rounded-lg file:border-0 file:text-sm file:font-medium file:bg-[var(--color-primary)] file:text-[var(--color-primary-fg)] hover:file:bg-[var(--color-primary-hover)] file:cursor-pointer file:transition-colors"
          />
          {importError && (
            <p className="text-xs text-[var(--color-err)]">{importError}</p>
          )}
        </div>
      )}
    </div>
  );
}
