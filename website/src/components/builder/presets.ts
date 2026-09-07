import { chainById } from "../deployments/wagmi";
import { type Assertion, emptyCall } from "./assertion-model";

/**
 * The assertion presets: starting trees for the expression editor, one
 * per common check. Picking one replaces the tree; everything stays
 * editable afterwards. The lines they render match what the retired
 * flat form emitted.
 */

export type PresetKey =
  | "call"
  | "balance"
  | "codeHash"
  | "hasCode"
  | "noCode"
  | "blockNumber"
  | "timestamp"
  | "chainId";

export interface Preset {
  key: PresetKey;
  label: string;
  hint: string;
}

export const PRESETS: Preset[] = [
  {
    key: "call",
    label: "Contract state",
    hint: "A view function's return value, e.g. the new owner is set",
  },
  {
    key: "balance",
    label: "Native balance",
    hint: "An account's balance in the chain's own currency",
  },
  {
    key: "codeHash",
    label: "Code hash",
    hint: "The deployed code matches a known hash",
  },
  { key: "hasCode", label: "Has code", hint: "The address holds code" },
  { key: "noCode", label: "No code", hint: "The address holds no code" },
  {
    key: "blockNumber",
    label: "Block number",
    hint: "The block the batch lands in",
  },
  {
    key: "timestamp",
    label: "Timestamp",
    hint: "The block time, e.g. a proposal executes before a deadline",
  },
  {
    key: "chainId",
    label: "Chain ID",
    hint: "The batch runs on the intended chain",
  },
];

const literal = (value: string): Assertion["subject"] => ({
  kind: "literal",
  value,
});

/** The assertion a preset starts from, for the chain the batch targets. */
export function seedAssertion(preset: PresetKey, chainId: number): Assertion {
  const base = { delta: "", message: "" };
  switch (preset) {
    case "call":
      return { ...base, subject: emptyCall(), operator: "==", expected: literal("") };
    case "balance":
      // @balance! reads the native balance only for the chain's own
      // currency symbol (ETH on mainnet, XDAI on Gnosis).
      return {
        ...base,
        subject: {
          kind: "balance",
          token: chainById(chainId)?.nativeCurrency.symbol ?? "ETH",
          account: literal("@me"),
        },
        operator: ">=",
        expected: literal(""),
      };
    case "codeHash":
      return {
        ...base,
        subject: { kind: "codeHash", address: literal("") },
        operator: "==",
        expected: literal(""),
      };
    case "hasCode":
    case "noCode":
      // Code exists exactly when the deployed payload is non-empty.
      return {
        ...base,
        subject: {
          kind: "callwrap",
          helper: "bytelen",
          call: { kind: "codeAt", address: literal("") },
        },
        operator: preset === "hasCode" ? ">" : "==",
        expected: literal("0"),
      };
    case "blockNumber":
    case "timestamp":
      return {
        ...base,
        subject: {
          kind: "clock",
          which: preset === "timestamp" ? "timestamp" : "blocknumber",
        },
        operator: ">=",
        expected: literal(""),
      };
    case "chainId":
      return {
        ...base,
        subject: { kind: "chainId" },
        operator: "==",
        expected: literal(String(chainId)),
      };
  }
}
