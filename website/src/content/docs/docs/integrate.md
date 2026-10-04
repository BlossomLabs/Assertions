---
title: Integrating
description: "How to put assertions into your own tools: compile EVML to calldata, build the call yourself, and what to do if your contract needs a check at run time."
---

Assertions are for transactions and batches that someone prepares, where the stakes justify the cost: a treasury payment, an upgrade, a proposal. Your tool prepares the batch, the assertions travel with it, and a signer can read them in [a decoded batch](/docs/reviewing).

They are not meant to be called by other contracts. If a contract of yours needs a check while it runs, write that check in Solidity. It costs far less than an external call into Assertions.

## Compile EVML in TypeScript

The [builder](/builder) compiles assertions with the EVMcrispr language packages, and you can use the same calls in your own app.

Assertions v2 (Byakko) needs EVMcrispr 0.12.0, which is not released yet. The builder on this site already includes it. Until the release, the builder is the supported way to produce assertions for v2. The example below shows the shape of the API.

The builder's compiler uses `@evmcrispr/core` for the EVML tag and `@evmcrispr/sdk/onchain` for the assertion helpers (`isAssertionAction`, `CORE_ADDRESS`, `decodeResolved`). The packages are under the AGPL-3.0-or-later license, and their READMEs say the API may change until 1.0.

```ts
import { createEvml } from "@evmcrispr/core";
import { isAssertionAction } from "@evmcrispr/sdk/onchain";
import { http } from "viem";

const token = "0x1111111111111111111111111111111111111111";
const treasury = "0x2222222222222222222222222222222222222222";

const evml = createEvml({
  chainId: 1,
  transports: { 1: http("https://your-rpc.example") },
});

const actions = await evml
  .script(
    `set $token ${token}
set $treasury ${treasury}
assert $token::!{balanceOf(address)(uint256) $treasury} >= 100e18 "treasury below floor"`,
  )
  .interpret();

for (const action of actions) {
  if (isAssertionAction(action)) {
    // action.to is the Assertions contract, action.data is the
    // assertParam calldata, action.readOnly is true.
  }
}
```

Replace the two placeholder addresses and the RPC URL with your own.

What you get back:

- `script(source).validate()` parses and checks a script and returns diagnostics with line and column.
- `script(source).interpret()` compiles the script to a list of actions without sending anything. An `assert` line becomes one action addressed to the Assertions contract, with the encoded `assertParam` call as its data.
- `script(source).execute(walletClient)` interprets the script and sends the actions with a viem wallet client. `simulate()` runs it on a fork.

Each assertion action also carries its compiled form (`action.compiled`: the live side, the expected side and the `InputParam`), which is what the builder uses to preview a value.

Modules such as `safe`, `governor` and `token` are registered with `evml.use(...)` and loaded in a script with `load`. Not every helper module the builder uses (`lang`, `math` and `token`, for example) has a package release yet, so check what your install contains before relying on one.

## Build the call yourself

If you prepare transactions in a script or a test and want to build the call without EVML, an assertion is one `assertParam` call on the Assertions contract. The structs and enums (`InputParam`, `Constraint`, `InputParamType`, `InputParamFetcherType`, `ConstraintType`) are defined in `ERC8211.sol`, in the same layout as the [ERC-8211](https://eips.ethereum.org/EIPS/eip-8211) wire format, so a batch built by any ERC-8211 library decodes unchanged.

There is no published Solidity package yet. Copy `ERC8211.sol` and the interface you need into your project, or add the repository as a dependency in a way you control.

Here is a minimal example that encodes the call for a batch, using the one-line helpers from [Solidity helpers](/docs/contracts/assertions#solidity-helpers) (`callParam`, `gte`):

```solidity
interface IAssertions {
    function assertParam(InputParam calldata param, string calldata message) external view;
}

/** Calldata for "the treasury holds at least `floor` tokens", to put in a batch. */
function floorCall(address token, address treasury, uint256 floor) pure returns (bytes memory) {
    return abi.encodeCall(
        IAssertions.assertParam,
        (
            callParam(token, abi.encodeCall(IERC20.balanceOf, (treasury)), gte(floor)),
            "treasury below floor"
        )
    );
}
```

Add that calldata to the batch, targeted at the Assertions address, before or after the action it guards. A failed constraint reverts with `ConstraintFailed`. The same page documents the other primitives (`pick`, `nav`, `cond`, `orElse` and the rest) with Solidity and EVML side by side.

## ABI and addresses

- **Addresses:** the four contract addresses are on [Deployments](/docs/contracts/deployments) and are the same on every chain.
- **ABI:** no ABI file is published yet. The function signatures are on the [contract pages](/docs/contracts), and compiling the Solidity sources gives you the full ABI.
- **Check the chain:** confirm code exists at the address on your chain before relying on it. [Deployments](/docs/contracts/deployments) lists supported chains and explains how to deploy to a new one.
- **Verification:** see [how the contracts are checked](/docs/contracts/verification), and "Verify the code on your chain" on [Deployments](/docs/contracts/deployments), to confirm the deployed code matches the source.

## If you run the batch

If your code executes batches that contain assertions (a wallet, a relayer, a Safe module), the assertion only protects the batch if your executor keeps its rules. Read the [executor guide](/docs/guides/executors) before shipping.

## Showing assertions to the user

A signer should see each assertion as a plain sentence before approving. Decode the `assertParam` call with the ABI above, then show the target, the function, the constraint and the message. [Reviewing an assertion](/docs/reviewing) describes every field and what a reader should check, including assertions built from other reads. For a wallet batch, see [the wallet batches guide](/docs/guides/wallet-batches).
