/**
 * Restrained line icons shared by the simple-form check tiles and the
 * expression editor's source pickers. One path set per value kind.
 */

export type IconName =
  | "value"
  | "call"
  | "balance"
  | "code"
  | "block"
  | "chainid"
  | "timestamp";

export const ICON_PATHS: Record<IconName, string[]> = {
  // An input box with a text cursor: a literal typed in by hand.
  value: [
    "M3 9.5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-5z",
    "M7 10.5v3",
  ],
  call: [
    "M4 6.5C4 5 7.6 3.8 12 3.8s8 1.2 8 2.7-3.6 2.7-8 2.7-8-1.2-8-2.7z",
    "M4 6.5v11c0 1.5 3.6 2.7 8 2.7s8-1.2 8-2.7v-11",
    "M4 12c0 1.5 3.6 2.7 8 2.7s8-1.2 8-2.7",
  ],
  balance: ["M12 2.5 19 13l-7 8.5L5 13l7-10.5z", "M5 13l7 3.5L19 13"],
  code: ["m8 6-6 6 6 6", "m16 6 6 6-6 6"],
  block: [
    "M12 2.5 20 7v10l-8 4.5L4 17V7l8-4.5z",
    "M12 11.5 4 7",
    "m12 11.5 8-4.5",
    "M12 11.5v10",
  ],
  chainid: [
    "m9 15 6-6",
    "M11 5.5 12.5 4a4 4 0 0 1 5.6 5.6L16.5 11",
    "M13 18.5 11.5 20a4 4 0 0 1-5.6-5.6L7.5 13",
  ],
  timestamp: ["M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18z", "M12 7.5V12l3 2"],
};

export function LineIcon({
  name,
  className = "size-4 shrink-0 opacity-70",
}: {
  name: IconName;
  className?: string;
}) {
  return (
    <svg
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="1.5"
      strokeLinecap="round"
      strokeLinejoin="round"
      className={className}
      aria-hidden
    >
      {ICON_PATHS[name].map((d, i) => (
        <path key={i} d={d} />
      ))}
    </svg>
  );
}
