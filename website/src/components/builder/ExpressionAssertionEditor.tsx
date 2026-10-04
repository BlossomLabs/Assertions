import { useEvmlTag } from "@evmcrispr/editor";
import { useCallback, useEffect, useMemo, useRef, useState } from "react";

import {
  type Assertion,
  type Path,
  BARE_OP,
  emptyLiteral,
  inferCategory,
  isBuildTimeConst,
  opsFor,
  updateAt,
} from "./assertion-model";
import { buildExprText } from "./assertion-codegen";
import { previewSubjectValue } from "./compile-adapter";
import {
  CallAddressContext,
  type CallAddressResolver,
} from "./expr/CallEditor";
import { type AssertionPlacement, stripAssertions } from "./script-ops";
import { CategoryBadge, ValueSlot, ValueTray } from "./expr/ValueEditor";
import { Select } from "../ui/Select";
import { useChainClient } from "./useChainSupport";
import { inputCls } from "./useContractFunctions";
import { labelCls } from "./ui";

/**
 * The assertion body: a subject expression, an operator and an expected
 * expression side by side, both sides recursive combinator trees. "Use current value"
 * reads the subject the way the assertion will (compiled, then resolved
 * through the core) and freezes the answer into the expected literal.
 */
export function ExpressionAssertionEditor({
  assertion,
  setAssertion,
  chainId,
  script,
  placement = "post",
}: {
  assertion: Assertion;
  setAssertion: (updater: (a: Assertion) => Assertion) => void;
  chainId: number;
  /** The batch the assertion joins (its set/def lines are in scope). */
  script: string;
  /** Where the assertion runs: before the batch's actions or after them. */
  placement?: AssertionPlacement;
}) {
  const tag = useEvmlTag();
  const chainClient = useChainClient(chainId);
  const [fetchStatus, setFetchStatus] = useState<string | null>(null);
  // The value the tray under the row is showing: a nested value, or the
  // settings of one of the two sides.
  const [openPath, setOpenPath] = useState<Path | null>(null);
  // A click anywhere outside the expression (its two values and the tray)
  // closes the tray. The menus it opens float outside it in the page, so a
  // click in one of those still counts as inside.
  const rootRef = useRef<HTMLDivElement>(null);
  const trayOpen = openPath !== null;
  useEffect(() => {
    if (!trayOpen) return;
    const onDown = (e: MouseEvent) => {
      const target = e.target as Element | null;
      if (!target || rootRef.current?.contains(target)) return;
      if (target.closest('[role="listbox"], [role="dialog"]')) return;
      setOpenPath(null);
    };
    document.addEventListener("mousedown", onDown);
    return () => document.removeEventListener("mousedown", onDown);
  }, [trayOpen]);

  // The address a call returns where the assertion runs: the batch's
  // actions are simulated on a fork (none of them for a check placed
  // before the actions), then the call is read there and printed.
  const resolved = useRef(new Map<string, Promise<string | null>>());
  const resolveCallAddress = useCallback<CallAddressResolver>(
    async (call) => {
      const built = await buildExprText(call, {
        resolveEns: async () => null,
        chainId,
      }).catch(() => null);
      if (!built) return { error: "the previous call is incomplete" };
      const actions = placement === "post" ? stripAssertions(script) : "";
      // `::!` is the on-chain read; `::` reads while the script runs.
      const probe = [
        actions,
        ...built.sets,
        `print ${built.line.replaceAll("::!", "::")}`,
      ]
        .filter((part) => part.trim())
        .join("\n");
      let pending = resolved.current.get(probe);
      if (!pending) {
        pending = tag
          .script(probe)
          .simulate({ from: tag.config.account })
          .then((result) => {
            if (!result.success) throw new Error(result.error ?? "it failed");
            const printed = [...result.logs]
              .reverse()
              .map((line) => line.match(/0x[0-9a-fA-F]{40}(?![0-9a-fA-F])/))
              .find(Boolean);
            return printed ? printed[0] : null;
          });
        resolved.current.set(probe, pending);
        // A failed read is retried next time.
        pending.catch(() => resolved.current.delete(probe));
      }
      try {
        const address = await pending;
        return address
          ? { address }
          : { error: "the call did not return an address" };
      } catch (e) {
        return { error: e instanceof Error ? e.message : String(e) };
      }
    },
    [tag, script, chainId, placement],
  );

  const update = (path: Path, updater: (node: any) => any) =>
    setAssertion((a) => updateAt(a, path, updater));

  const subjectCat = inferCategory(assertion.subject);
  const expectedCat = assertion.expected
    ? inferCategory(assertion.expected)
    : "unknown";
  const subjectConst = isBuildTimeConst(assertion.subject);
  const expectedConst = assertion.expected
    ? isBuildTimeConst(assertion.expected)
    : false;

  const operators = useMemo(
    () => opsFor(subjectCat, expectedCat, subjectConst, expectedConst),
    [subjectCat, expectedCat, subjectConst, expectedConst],
  );

  const currentOp = assertion.operator === null ? BARE_OP : assertion.operator;

  // Keep the operator within the allowed set when categories shift.
  useEffect(() => {
    if (!operators.includes(currentOp)) {
      const next = operators[0];
      setAssertion((a) =>
        next === BARE_OP
          ? { ...a, operator: null, expected: null }
          : {
              ...a,
              operator: next,
              expected: a.expected ?? emptyLiteral(),
            },
      );
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [operators, currentOp]);

  const changeOperator = (op: string) =>
    setAssertion((a) =>
      op === BARE_OP
        ? { ...a, operator: null, expected: null }
        : { ...a, operator: op, expected: a.expected ?? emptyLiteral() },
    );

  // Two live numeric sides can't use ~=: offer the |a - b| <= d transform.
  const liveApprox =
    assertion.expected !== null &&
    !subjectConst &&
    !expectedConst &&
    ["uint", "int"].includes(subjectCat) &&
    ["uint", "int"].includes(expectedCat);
  const toAbsdiff = () =>
    setAssertion((a) => ({
      ...a,
      subject: { kind: "absDiff", a: a.subject, b: a.expected! },
      operator: "<=",
      expected: emptyLiteral(),
      delta: "",
    }));

  const canFetch =
    !subjectConst &&
    assertion.operator !== null &&
    (assertion.expected === null || assertion.expected.kind === "literal");
  const fetchCurrentValue = async () => {
    if (!chainClient) {
      setFetchStatus("No RPC is known for this chain.");
      return;
    }
    setFetchStatus("Fetching current value…");
    const preview = await previewSubjectValue(
      tag,
      chainClient,
      script,
      assertion.subject,
      chainId,
    );
    switch (preview.kind) {
      case "value":
      case "const":
        setAssertion((a) => ({
          ...a,
          expected: { kind: "literal", value: preview.text },
        }));
        setFetchStatus(null);
        break;
      case "not-previewable":
        setFetchStatus(`Cannot read this value now: ${preview.reason}`);
        break;
      case "error":
        setFetchStatus(`Could not fetch the current value: ${preview.message}`);
        break;
    }
  };

  const timestampSubject =
    assertion.subject.kind === "clock" &&
    assertion.subject.which === "timestamp";

  return (
    <div ref={rootRef} className="space-y-4">
      {/* The comparison reads top to bottom: the value on its own line,
          then the operator and what it is compared with. Every value is
          one field of the same height and the full width, so the rows
          keep their shape whatever the values are. */}
      <div className="grid gap-3 items-start grid-cols-[6rem_minmax(0,1fr)]">
        <div className="min-w-0 col-span-2">
          <div className="flex items-baseline gap-2">
            <label className={labelCls}>Value to check</label>
            <CategoryBadge node={assertion.subject} />
          </div>
          <ValueSlot
            node={assertion.subject}
            path={["subject"]}
            update={update}
            chainId={chainId}
            openPath={openPath}
            onOpen={setOpenPath}
            counterpart={expectedCat}
            noLiteral
          />
        </div>

        <div className={assertion.expected === null ? "col-span-2 w-24" : ""}>
          <label className={labelCls} htmlFor="expr-operator">
            Operator
          </label>
          {/* As tall as the inputs beside it. */}
          <Select
            id="expr-operator"
            className="[&>button]:h-[38px]"
            value={currentOp}
            options={operators.map((op) => ({ value: op, label: op }))}
            onChange={changeOperator}
          />
        </div>

        {assertion.expected !== null && (
          <div className="min-w-0">
            <div className="flex items-baseline justify-between gap-2">
              <span className="flex items-baseline gap-2">
                <label className={labelCls}>Expected value</label>
                <CategoryBadge node={assertion.expected} />
              </span>
              {canFetch && (
                <button
                  type="button"
                  onClick={() => void fetchCurrentValue()}
                  className="text-xs text-[var(--color-bp-300)] hover:underline"
                  title="Read the value from the chain and prefill it"
                >
                  Use current value
                </button>
              )}
            </div>
            <ValueSlot
              node={assertion.expected}
              path={["expected"]}
              update={update}
              chainId={chainId}
              openPath={openPath}
              onOpen={setOpenPath}
              counterpart={subjectCat}
              timestampHint={timestampSubject}
            />
          </div>
        )}
      </div>

      <CallAddressContext.Provider value={resolveCallAddress}>
        <ValueTray
          root={assertion}
          openPath={openPath}
          onOpen={setOpenPath}
          update={update}
          chainId={chainId}
          sides={{ subject: "Value to check", expected: "Expected value" }}
          timestampPath={timestampSubject ? ["expected"] : undefined}
        />
      </CallAddressContext.Provider>

      {fetchStatus && (
        <p className="text-xs text-[var(--color-ink-3)]">{fetchStatus}</p>
      )}

      {liveApprox && (
        <p className="text-xs text-[var(--color-ink-3)]">
          Approximate match between two live values?{" "}
          <button
            type="button"
            className="text-[var(--color-bp-300)] hover:underline"
            onClick={toAbsdiff}
          >
            Compare |a − b| ≤ delta instead
          </button>
        </p>
      )}

      {assertion.operator === "~=" && (
        <div>
          <label className={labelCls} htmlFor="expr-delta">
            Allowed delta{" "}
            <span className="text-xs text-[var(--color-ink-3)]">
              (tolerance for ~=)
            </span>
          </label>
          <input
            id="expr-delta"
            className={inputCls}
            placeholder="e.g. 50e8"
            value={assertion.delta}
            onChange={(e) =>
              setAssertion((a) => ({ ...a, delta: e.target.value }))
            }
            spellCheck={false}
          />
        </div>
      )}
    </div>
  );
}
