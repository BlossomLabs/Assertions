---
title: Using assertions from Solidity
description: Complete patterns for DAO proposals, Safe batches, upgrades and every assertion family.
---

An assertion is one external view call to the judge: `assertParam(param[, message])`, where the `InputParam` says how to **fetch** a live value and which inline **constraints** it must satisfy. Batch the assertion calls around the actions they guard; a failing constraint reverts the whole transaction with `ConstraintFailed`.

## Building parameters

The wire format is three structs (import them from `ERC8211.sol`). A few one-line helpers cover almost everything:

```solidity
import {
    InputParam, InputParamType, InputParamFetcherType,
    Constraint, ConstraintType
} from "assertions/ERC8211.sol";

/// A staticcall fetcher: the raw returndata of target.data is the value.
function callParam(address target, bytes memory data, Constraint[] memory cs)
    pure returns (InputParam memory)
{
    return InputParam(
        InputParamType.CALL_DATA,
        InputParamFetcherType.STATIC_CALL,
        abi.encode(target, data),
        cs
    );
}

/// A balance fetcher: token == address(0) reads the native balance,
/// otherwise IERC20(token).balanceOf(account).
function balanceParam(address token, address account, Constraint[] memory cs)
    pure returns (InputParam memory)
{
    return InputParam(
        InputParamType.CALL_DATA,
        InputParamFetcherType.BALANCE,
        abi.encodePacked(token, account),
        cs
    );
}

function noConstraints() pure returns (Constraint[] memory cs) {
    cs = new Constraint[](0);
}
function eq(bytes32 x) pure returns (Constraint[] memory cs) {
    cs = new Constraint[](1);
    cs[0] = Constraint(ConstraintType.EQ, abi.encode(x));
}
function gte(uint256 x) pure returns (Constraint[] memory cs) {
    cs = new Constraint[](1);
    cs[0] = Constraint(ConstraintType.GTE, abi.encode(x));
}
function lte(uint256 x) pure returns (Constraint[] memory cs) {
    cs = new Constraint[](1);
    cs[0] = Constraint(ConstraintType.LTE, abi.encode(x));
}
/// Inclusive range; also the approximate-equality form (x - d .. x + d).
function within(uint256 lo, uint256 hi) pure returns (Constraint[] memory cs) {
    cs = new Constraint[](1);
    cs[0] = Constraint(ConstraintType.IN, abi.encode(lo, hi));
}
```

Constraints compare the value's **first 32-byte word**, unsigned, which covers `uint256`, `address`, `bool` and `bytes32` returns directly. Multi-value selections use the core's own [`pick` and `nav`](/docs/core/reads); signed comparisons and `!=` route through a read-spliced [Operators](/docs/operators) comparison that returns 0/1, judged `EQ 1`.

## DAO proposal with safety checks

```solidity
// In a DAO proposal's action list:

// 1. Pre-condition: Verify treasury has expected balance before transfer
assertions.assertParam(
    callParam(treasury, abi.encodeCall(IERC20.balanceOf, (treasury)), gte(requiredBalance)),
    "Treasury balance too low"
);

// 2. Execute the actual transfer
treasury.transfer(recipient, amount);

// 3. Post-condition: Ensure treasury still has minimum reserves
assertions.assertParam(
    callParam(treasury, abi.encodeCall(IERC20.balanceOf, (treasury)), gte(minimumReserves)),
    "Transfer would deplete reserves below minimum"
);

// 4. Invariant: Confirm DAO still owns the treasury
assertions.assertParam(
    callParam(treasury, abi.encodeCall(Ownable.owner, ()), eq(bytes32(uint256(uint160(address(dao)))))),
    "Treasury ownership compromised"
);
```

## Safe multisig transaction batch

```solidity
// Safe transaction batch:

// Action 1: Assert protocol is not paused (bool returns are 0/1 words)
assertions.assertParam(
    callParam(protocol, abi.encodeCall(IProtocol.paused, ()), eq(bytes32(0))),
    "Protocol is paused"
);

// Action 2: Assert oracle price is within bounds (MEV protection): one
// IN constraint instead of two comparisons
assertions.assertParam(
    callParam(oracle, abi.encodeCall(IOracle.getPrice, ()), within(minAcceptablePrice, maxAcceptablePrice)),
    "Price out of bounds - possible manipulation"
);

// Action 3: Execute the actual swap/trade
protocol.swap(tokenIn, tokenOut, amount);

// Action 4: Assert we received expected output (slippage check)
assertions.assertParam(
    callParam(tokenOut, abi.encodeCall(IERC20.balanceOf, (safe)), gte(minExpectedOutput)),
    "Slippage too high"
);
```

## Protocol upgrade verification

```solidity
// Assert proxy admin is correct
assertions.assertParam(
    callParam(proxy, abi.encodeCall(ITransparentProxy.admin, ()), eq(bytes32(uint256(uint160(expectedAdmin))))),
    "Unexpected proxy admin"
);

// Execute upgrade
proxyAdmin.upgrade(proxy, newImplementation);

// Assert new implementation has expected code, via Operators.codeHash
// as the fetched value (EXTCODEHASH semantics)
assertions.assertParam(
    callParam(
        address(operators),
        abi.encodeCall(Operators.codeHash, (newImplementation)),
        eq(keccak256(newImplementationCode))
    ),
    "Implementation code mismatch"
);

// Assert critical storage wasn't corrupted
assertions.assertParam(
    callParam(proxy, abi.encodeCall(IProtocol.totalSupply, ()), eq(bytes32(expectedTotalSupply))),
    "Storage corrupted during upgrade"
);
```

## Balance, block and environment assertions

Balance reads have a dedicated fetcher; block and chain values are plain [Operators](/docs/operators/words) calls, no splicing needed since they take no live arguments:

```solidity
// Assert account has at least 1 ETH (native balance fetcher)
assertions.assertParam(balanceParam(address(0), userAddress, gte(1 ether)));

// Assert a token balance without any staticcall encoding
assertions.assertParam(balanceParam(dai, treasury, gte(minReserves)));

// Assert contract balance is approximately expected (within 0.01 ETH)
assertions.assertParam(
    balanceParam(address(0), contractAddress, within(expected - 0.01 ether, expected + 0.01 ether))
);

// Assert we're on mainnet
assertions.assertParam(
    callParam(address(operators), abi.encodeCall(Operators.chainId, ()), eq(bytes32(uint256(1))))
);

// Assert block timestamp is past the unlock time
assertions.assertParam(
    callParam(address(operators), abi.encodeCall(Operators.timestamp, ()), gte(unlockTime + 1))
);
```

When the account is *computed* at judge time (the balance of `registry.treasury()`, the code hash of `proxy.implementation()`), splice the resolved address into `Operators.balance` / `Operators.codeHash` with the core's `read`; see [the words page](/docs/operators/words).

## Multi-value returns and deep reads

Selections out of tuples, arrays and structs are core primitives, `pick` for a raw word and [`nav`](/docs/core/reads) for typed navigation, judged as ordinary parameters by pointing the fetcher at the core itself:

```solidity
// getPosition() returns (uint256 amount, uint256 debt, address owner);
// assert debt (word 1) equals expected
assertions.assertParam(
    callParam(
        address(assertions),
        abi.encodeCall(Assertions.pick, (
            callParam(vault, abi.encodeCall(IVault.getPosition, (positionId)), noConstraints()),
            int256(1)
        )),
        eq(bytes32(expectedDebt))
    ),
    "Unexpected debt"
);
```

## Judging whole batches

`assertComposable(executions[, message])` judges an ERC-8211 batch: entries without a `TARGET` parameter are plain predicate entries (each input parameter is resolved and constraint-checked), and entries **with** one construct a call by splicing the resolved parameter values into calldata (the call is executed via `staticcall` and must not revert). It accepts unmodified batches built by any ERC-8211 SDK. For nested live call arguments ("use the result of `b()` as an argument of `a()`") judged through `assertParam`, the core's [`read` primitive](/docs/core/reads) constructs the same call as a composable expression.

## Custom error messages

Every judge function has an overload accepting a custom message, reported inside `ConstraintFailed` when the assertion fails:

```solidity
assertions.assertParam(
    callParam(token, abi.encodeCall(IERC20.totalSupply, ()), eq(bytes32(expectedSupply))),
    "Token supply mismatch after mint"
);
```

## Caveats

- **Constraints are unsigned word comparisons.** `GTE`/`LTE`/`IN` compare the first 32-byte word as a `uint256`. For `int256` returns use the [Operators int256 overloads](/docs/operators/words) (`gt(int256,int256)`, `le(int256,int256)`, ...) read-spliced and judged `EQ 1`, and the signed `absDiff` overload for tolerance. Overloads need explicit selectors in Solidity: `bytes4(keccak256("gt(int256,int256)"))`.
- **EIP-7702 delegated EOAs carry code.** A delegated EOA has a 23-byte delegation designator as its code, so a "has no code" check (`Operators.codeHash` equal to `bytes32(0)` or `keccak256("")`) is not a strict "is an EOA" check on chains with EIP-7702.
- **`block.number` semantics differ across chains.** On OP-stack and most L2s, `Operators.blockNumber()` sees the L2 block number (on Arbitrum, `block.number` returns the approximate L1 block). Block times also vary per chain, so avoid porting block-number thresholds between networks.
- **Calls to code-less addresses revert with `CallFailed`.** A `staticcall` to an address without code would otherwise "succeed" with empty returndata; the fetcher detects this and reverts descriptively. To *tolerate* a missing or reverting target instead, wrap the operand in the core's [`orElse`](/docs/core/control).
- **View-only judging.** The judge rejects batches with output parameters (Storage writes) or `VALUE` parameters (ETH forwarding): assertions never change state.
