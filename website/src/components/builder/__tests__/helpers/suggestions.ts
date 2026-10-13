import type { SuggestedCheck } from "../../suggested-checks";

// Suggestions as EVMcrispr returns them since sentences: a sentence in
// parts, and a line whose addresses are variables.
export const EXECUTOR = "0x5Afe000000000000000000000000000000005afe";
export const OTHER = "0xABcdEFABcdEFabcdEfAbCdefabcdeFABcDEFabCD";
export const USDC = "0x00000000000000000000000000000000000000aa";
export const WETH = "0x00000000000000000000000000000000000000ee";
export const FAKE = "0x00000000000000000000000000000000000000ff";
export const OWNED = "0x00000000000000000000000000000000000000bb";
export const ACTION = `exec ${USDC} "transfer(address,uint256)" ${OTHER} 5000000`;
export const ACTION_2 = `exec ${OWNED} "transferOwnership(address)" ${OTHER}`;
export const BATCH = `${ACTION}\n${ACTION_2}`;

export const SPENT: SuggestedCheck = {
  line: "assert @balance!($usdc $executor) >= @token:amount($usdc 51950.2982)",
  vars: [
    { name: "usdc", value: USDC },
    { name: "executor", value: EXECUTOR },
  ],
  sentence: [
    { type: "address", address: EXECUTOR },
    { type: "text", text: " keeps at least " },
    {
      type: "amount",
      value: "51950298200",
      bound: "floor",
      token: USDC,
      symbol: "USDC",
      decimals: 6,
      listed: true,
      text: "51,950.2982 USDC",
    },
  ],
  description: "0x5Afe...5afe keeps at least 51,950.2982 USDC (0x0000...00aa)",
  kind: "amount",
  module: "token",
  event: "erc20Transfer",
  eventName: "Transfer",
  emitterName: "USDC",
  emitter: USDC,
};
export const RECEIVED: SuggestedCheck = {
  line: "assert @balance!($usdc $recipient) >= @token:amount($usdc 5)",
  vars: [
    { name: "usdc", value: USDC },
    { name: "recipient", value: OTHER },
  ],
  sentence: [
    { type: "address", address: OTHER },
    { type: "text", text: " holds at least " },
    {
      type: "amount",
      value: "5000000",
      bound: "floor",
      token: USDC,
      symbol: "USDC",
      decimals: 6,
      listed: true,
      text: "5 USDC",
    },
    { type: "text", text: "; that account can make this check fail by moving it first" },
  ],
  description:
    "0xABcd...abCD holds at least 5 USDC (0x0000...00aa); that account can make this check fail by moving it first",
  kind: "amount",
  module: "token",
  event: "erc20Transfer",
  eventName: "Transfer",
  emitterName: "USDC",
  emitter: USDC,
};
export const OWNER: SuggestedCheck = {
  line: "assert @acl:owner!($contract) == $owner",
  vars: [
    { name: "contract", value: OWNED },
    { name: "owner", value: OTHER },
  ],
  sentence: [
    { type: "address", address: OWNED },
    { type: "text", text: " is owned by " },
    { type: "address", address: OTHER },
  ],
  description: "0x0000...00bb is owned by 0xABcd...abCD",
  kind: "state",
  module: "acl",
  event: "ownershipTransferred",
  eventName: "OwnershipTransferred",
  emitter: OWNED,
};
export const NATIVE: SuggestedCheck = {
  line: "assert @balance!(ETH $executor) >= @token:amount(ETH 122.0843)",
  vars: [{ name: "executor", value: EXECUTOR }],
  sentence: [
    { type: "text", text: "ETH balance of " },
    { type: "address", address: EXECUTOR },
    { type: "text", text: " stays at or above " },
    { type: "amount", value: "122084300000000000000", bound: "floor", token: "native", symbol: "ETH", decimals: 18, text: "122.0843 ETH" },
    { type: "text", text: ", which leaves up to " },
    { type: "amount", value: "20000000000000", bound: "ceiling", token: "native", symbol: "ETH", decimals: 18, text: "0.00002 ETH" },
    { type: "text", text: " for gas" },
  ],
  description: "ETH balance of 0x5Afe...5afe stays at or above 122.0843 ETH, which leaves up to 0.00002 ETH for gas",
  kind: "amount",
  module: "std",
  event: "native",
  emitter: EXECUTOR,
};
export const ALLOWANCE: SuggestedCheck = {
  line: "assert @token:allowance!($weth $executor $spender) == @token:amount($weth 5)",
  vars: [
    { name: "weth", value: WETH },
    { name: "executor", value: EXECUTOR },
    { name: "spender", value: OTHER },
  ],
  sentence: [
    { type: "address", address: OTHER },
    { type: "text", text: " is left with an allowance of " },
    {
      type: "amount",
      value: "5000000000000000000",
      bound: "exact",
      token: WETH,
      symbol: "WETH",
      decimals: 18,
      text: "5 WETH",
    },
  ],
  description: "0xABcd...abCD is left with an allowance of 5 WETH (0x0000...00ee)",
  kind: "amount",
  module: "token",
  event: "erc20Approval",
  eventName: "Approval",
  emitterName: "WETH",
  emitter: WETH,
};
