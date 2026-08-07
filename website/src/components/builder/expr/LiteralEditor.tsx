import { useEffect } from "react";

import { unixToDatetimeLocal } from "../assertion-eval";
import type { Category } from "../assertion-model";
import { inputCls } from "../useContractFunctions";
import { smallLabelCls } from "../ui";

const PLACEHOLDERS: Partial<Record<Category, string>> = {
  uint: "e.g. 10e18",
  int: "e.g. -5",
  address: "0x…, name.eth or @me",
  bytes32: "0x… (32 bytes)",
  string: "text",
};

/**
 * A literal leaf. `counterpart` is the category of the other side of the
 * comparison (when this literal is a top-level side) — it drives the
 * true/false select for booleans and the date picker for timestamps.
 */
export function LiteralEditor({
  value,
  onChange,
  counterpart,
  timestampHint = false,
}: {
  value: string;
  onChange: (value: string) => void;
  counterpart?: Category;
  timestampHint?: boolean;
}) {
  const boolValue = counterpart === "bool";

  // Booleans are compared against a fixed true/false select.
  useEffect(() => {
    if (boolValue && !["true", "false"].includes(value)) onChange("true");
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [boolValue, value]);

  if (boolValue)
    return (
      <select
        className={inputCls}
        value={value}
        onChange={(e) => onChange(e.target.value)}
      >
        <option value="true">true</option>
        <option value="false">false</option>
      </select>
    );

  return (
    <div className="space-y-2">
      <input
        className={inputCls}
        placeholder={counterpart ? (PLACEHOLDERS[counterpart] ?? "") : ""}
        value={value}
        onChange={(e) => onChange(e.target.value)}
        spellCheck={false}
      />
      {timestampHint && (
        <div>
          <label className={smallLabelCls}>
            …or pick a date{" "}
            <span className="opacity-60">(synced with the unix timestamp)</span>
          </label>
          <input
            type="datetime-local"
            className={inputCls}
            value={unixToDatetimeLocal(value)}
            onChange={(e) => {
              if (e.target.value)
                onChange(
                  String(Math.floor(new Date(e.target.value).getTime() / 1000)),
                );
            }}
          />
        </div>
      )}
    </div>
  );
}
