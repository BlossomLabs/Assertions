import type { Category } from "../assertion-model";

/** What to type for a literal, by the category it is compared with. */
export const PLACEHOLDERS: Partial<Record<Category, string>> = {
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
