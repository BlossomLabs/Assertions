import { Editor } from "@evmcrispr/editor";
import type { editor } from "monaco-editor";
import { Suspense, useCallback, useRef, useState } from "react";

import { AbiForm } from "./AbiForm";
import { isTxBuilderBatch, txBuilderToEvml } from "./safe-tx-builder";
import type { useScriptState } from "./useScriptState";

type Mode = "form" | "editor";

export function Composer({
  scriptState,
  chainId,
  onDroppedChainId,
}: {
  scriptState: ReturnType<typeof useScriptState>;
  chainId: number;
  onDroppedChainId?: (chainId: number) => void;
}) {
  const { script, setScript, appendWithSets } = scriptState;
  const [mode, setMode] = useState<Mode>("form");
  const [dragging, setDragging] = useState(false);
  const [dropError, setDropError] = useState<string | null>(null);
  const editorRef = useRef<editor.IStandaloneCodeEditor | null>(null);
  // Content last pushed to/received from Monaco, to break update loops.
  const editorContent = useRef<string>(script);

  // External updates (form adds, drops, AI edits) flow into Monaco.
  if (editorRef.current && editorContent.current !== script) {
    editorContent.current = script;
    if (editorRef.current.getValue() !== script)
      editorRef.current.setValue(script);
  }

  const handleFiles = useCallback(
    async (files: FileList) => {
      setDropError(null);
      const file = files[0];
      if (!file) return;
      const text = await file.text();

      if (file.name.endsWith(".evml") || file.name.endsWith(".txt")) {
        setScript(text.trim());
        setMode("editor");
        return;
      }

      try {
        const parsed = JSON.parse(text);
        if (!isTxBuilderBatch(parsed)) {
          setDropError(
            "That JSON doesn't look like a Safe Transaction Builder batch.",
          );
          return;
        }
        const { script: converted, chainId: batchChain } =
          txBuilderToEvml(parsed);
        setScript(converted);
        if (batchChain && onDroppedChainId) onDroppedChainId(batchChain);
        setMode("editor");
      } catch {
        setDropError(
          "Unrecognized file — drop a Safe Transaction Builder JSON or an .evml script.",
        );
      }
    },
    [setScript, onDroppedChainId],
  );

  return (
    <div
      className="relative"
      onDragOver={(e) => {
        e.preventDefault();
        setDragging(true);
      }}
      onDragLeave={(e) => {
        if (e.currentTarget.contains(e.relatedTarget as Node)) return;
        setDragging(false);
      }}
      onDrop={(e) => {
        e.preventDefault();
        setDragging(false);
        if (e.dataTransfer.files.length) void handleFiles(e.dataTransfer.files);
      }}
    >
      {dragging && (
        <div className="absolute inset-0 z-10 flex items-center justify-center rounded-xl border-2 border-dashed border-[var(--color-bp-400)] bg-[var(--color-bp-500)]/10 backdrop-blur-sm pointer-events-none">
          <p className="text-sm font-medium text-[var(--color-bp-300)]">
            Drop a Safe Transaction Builder JSON or .evml file
          </p>
        </div>
      )}

      {/* Mode tabs */}
      <div className="flex items-center gap-1 mb-4">
        {(
          [
            ["form", "Contract form"],
            ["editor", "EVML editor"],
          ] as [Mode, string][]
        ).map(([m, label]) => (
          <button
            key={m}
            type="button"
            onClick={() => setMode(m)}
            className={`px-3 py-1.5 rounded-lg text-sm font-medium transition-colors ${
              mode === m
                ? "bg-[var(--color-bp-500)]/15 text-[var(--color-bp-300)]"
                : "text-[var(--color-ink-3)] hover:text-[var(--color-ink-2)]"
            }`}
          >
            {label}
          </button>
        ))}
        <span className="ml-auto text-xs text-[var(--color-ink-3)]">
          or drag &amp; drop a batch file
        </span>
      </div>

      {dropError && (
        <p className="mb-3 text-xs text-[var(--color-err)]">{dropError}</p>
      )}

      {mode === "form" ? (
        <div className="space-y-5">
          <AbiForm chainId={chainId} onAdd={appendWithSets} />
          {script && (
            <div>
              <p className="text-xs text-[var(--color-ink-3)] mb-1.5">
                Batch so far
              </p>
              <pre className="p-3 rounded-lg bg-[var(--color-surface)] border border-[var(--color-ink-3)]/20 font-mono text-xs overflow-x-auto whitespace-pre-wrap">
                {script}
              </pre>
            </div>
          )}
        </div>
      ) : (
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
    </div>
  );
}
