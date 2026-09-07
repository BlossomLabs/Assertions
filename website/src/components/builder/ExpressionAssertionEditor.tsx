import { useEvmlTag } from "@evmcrispr/editor";
import { useEffect, useMemo, useState } from "react";

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
import { previewSubjectValue } from "./compile-adapter";
import { ValueEditor } from "./expr/ValueEditor";
import { Select } from "../ui/Select";
import { useChainClient } from "./useChainSupport";
import { inputCls } from "./useContractFunctions";
import { btnSmallCls, labelCls } from "./ui";

/**
 * The assertion body: a subject expression, an operator and an expected
 * expression, both sides recursive combinator trees. "Use current value"
 * reads the subject the way the assertion will (compiled, then resolved
 * through the core) and freezes the answer into the expected literal.
 */
export function ExpressionAssertionEditor({
  assertion,
  setAssertion,
  chainId,
  script,
}: {
  assertion: Assertion;
  setAssertion: (updater: (a: Assertion) => Assertion) => void;
  chainId: number;
  /** The batch the assertion joins (its set/def lines are in scope). */
  script: string;
}) {
  const tag = useEvmlTag();
  const chainClient = useChainClient(chainId);
  const [fetchStatus, setFetchStatus] = useState<string | null>(null);

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
    <div className="space-y-4">
      <div>
        <label className={labelCls}>Value to check</label>
        <ValueEditor
          node={assertion.subject}
          path={["subject"]}
          update={update}
          depth={0}
          chainId={chainId}
          counterpart={expectedCat}
        />
      </div>

      <div className="flex gap-2 items-end flex-wrap">
        <div className="w-28">
          <label className={labelCls} htmlFor="expr-operator">
            Operator
          </label>
          <Select
            id="expr-operator"
            value={currentOp}
            options={operators.map((op) => ({ value: op, label: op }))}
            onChange={changeOperator}
          />
        </div>
        {canFetch && (
          <button
            type="button"
            onClick={() => void fetchCurrentValue()}
            className={btnSmallCls}
            title="Read the value from the chain and prefill it"
          >
            Use current value
          </button>
        )}
      </div>

      {assertion.expected !== null && (
        <div>
          <label className={labelCls}>Expected value</label>
          <ValueEditor
            node={assertion.expected}
            path={["expected"]}
            update={update}
            depth={0}
            chainId={chainId}
            counterpart={subjectCat}
            timestampHint={timestampSubject}
          />
        </div>
      )}

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
