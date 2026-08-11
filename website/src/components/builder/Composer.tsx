import { Editor } from "@evmcrispr/editor";
import type { editor } from "monaco-editor";
import { Suspense, useRef, useState } from "react";

import { AbiForm } from "./AbiForm";
import { BatchList } from "./BatchList";
import { isTxBuilderBatch, txBuilderToEvml } from "./safe-tx-builder";
import { isHelperLoad, type useScriptState } from "./useScriptState";

type Mode = "form" | "editor" | "txbuilder";

export function Composer({
  scriptState,
  chainId,
  safeContext = false,
  onDroppedChainId,
}: {
  scriptState: ReturnType<typeof useScriptState>;
  chainId: number;
  /** The batch executes through a Safe — offers the Transaction Builder
   *  JSON import tab. */
  safeContext?: boolean;
  onDroppedChainId?: (chainId: number) => void;
}) {
  const { script, setScript } = scriptState;
  const [rawMode, setRawMode] = useState<Mode>("form");
  const [importError, setImportError] = useState<string | null>(null);
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
    try {
      const parsed = JSON.parse(await file.text());
      if (!isTxBuilderBatch(parsed)) {
        setImportError(
          "That JSON doesn't look like a Safe Transaction Builder batch.",
        );
        return;
      }
      const { script: converted, chainId: batchChain } =
        txBuilderToEvml(parsed);
      setScript(converted);
      if (batchChain && onDroppedChainId) onDroppedChainId(batchChain);
      setRawMode("editor");
    } catch {
      setImportError(
        "Unrecognized file: expected a Safe Transaction Builder JSON export.",
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
          <AbiForm chainId={chainId} onAdd={scriptState.appendWithSets} />
          {script && (
            <div>
              <p className="text-xs text-[var(--color-ink-3)] mb-1.5">
                Batch so far
              </p>
              <BatchList
                script={script}
                onRemoveLine={scriptState.removeLine}
                // Assertions are added and removed in step 4; here they
                // render dimmed, without a delete button.
                canRemove={(line) => !/^assert\b/.test(line)}
                hideLine={isHelperLoad}
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
