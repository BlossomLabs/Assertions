import { useEffect, useMemo, useState } from "react";
import type { Address } from "viem";

import { isEvaluable, readSubjectValue } from "./assertion-eval";
import { Callout } from "./Callout";
import { useChainClient } from "./useChainSupport";
import {
  type Assertion,
  type Path,
  BARE_OP,
  emptyLiteral,
  inferCategory,
  isBuildTimeConst,
  opsFor,
  updateAt,
  validateAssertion,
} from "./assertion-model";
import { ValueEditor } from "./expr/ValueEditor";
import { inputCls } from "./useContractFunctions";
import { btnSmallCls, labelCls } from "./ui";

/**
 * The expression-kind assertion body: a subject expression, an operator and
 * an expected expression — both sides recursive combinator trees.
 */
export function ExpressionAssertionEditor({
  assertion,
  setAssertion,
  chainId,
  executor,
}: {
  assertion: Assertion;
  setAssertion: (updater: (a: Assertion) => Assertion) => void;
  chainId: number;
  executor: Address | undefined;
}) {
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

  // Two live numeric sides can't use ~= — offer the |a − b| ≤ d transform.
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

  // "Use current value": evaluate the subject expression client-side and
  // freeze the result into the expected literal.
  const canFetch =
    isEvaluable(assertion.subject) &&
    assertion.operator !== null &&
    (assertion.expected === null || assertion.expected.kind === "literal");
  const fetchCurrentValue = async () => {
    if (!chainClient) return;
    setFetchStatus("Fetching current value…");
    try {
      const value = await readSubjectValue(
        chainClient,
        assertion.subject,
        executor,
      );
      setAssertion((a) => ({ ...a, expected: { kind: "literal", value } }));
      setFetchStatus(null);
    } catch {
      setFetchStatus("Could not fetch the current value. Enter it manually.");
    }
  };

  const issues = useMemo(() => validateAssertion(assertion), [assertion]);
  // Node-level issues render inline at their node; whole-assertion ones here.
  const rootIssues = issues.filter((i) => i.path.length === 0);

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
          issues={issues}
        />
      </div>

      <div className="flex gap-2 items-end flex-wrap">
        <div className="w-28">
          <label className={labelCls} htmlFor="expr-operator">
            Operator
          </label>
          <select
            id="expr-operator"
            className={inputCls}
            value={currentOp}
            onChange={(e) => changeOperator(e.target.value)}
          >
            {operators.map((op) => (
              <option key={op} value={op}>
                {op}
              </option>
            ))}
          </select>
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
            issues={issues}
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

      {rootIssues.length > 0 && (
        <Callout tone="error">
          {rootIssues.map((issue, i) => (
            <p key={i}>{issue.message}</p>
          ))}
        </Callout>
      )}
    </div>
  );
}
