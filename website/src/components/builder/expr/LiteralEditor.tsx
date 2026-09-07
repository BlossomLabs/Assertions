import { useEffect } from "react";

import type { Category } from "../assertion-model";
import { inputCls } from "../useContractFunctions";
import { smallLabelCls } from "../ui";

const PLACEHOLDERS: Partial<Record<Category, string>> = {
  uint: "e.g. 10e18",
  int: "e.g. -5",
  address: "0x…, name.eth or @me",
  bytes32: "0x… (32 bytes)",
  bytes: "0x…",
  string: "text",
};

/** Unix-seconds string to a local "YYYY-MM-DDTHH:mm" for a datetime-local
 *  input ("" when the value isn't a plain timestamp). */
export function unixToDatetimeLocal(value: string): string {
  const v = value.trim();
  if (!/^\d+$/.test(v)) return "";
  const d = new Date(Number(v) * 1000);
  if (Number.isNaN(d.getTime()) || d.getFullYear() > 9999) return "";
  const pad = (n: number) => String(n).padStart(2, "0");
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}T${pad(d.getHours())}:${pad(d.getMinutes())}`;
}

/**
 * A literal leaf. `counterpart` is the category of the other side of the
 * comparison (when this literal is a top-level side): it drives the
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
