---
title: Using assertions from Solidity
description: Complete patterns for DAO proposals, Safe batches, upgrades and every assertion family.
---

Every assertion is an external view call on the core contract: pass the target, the encoded calldata of the view function to check, and the expected value. Batch the assertion calls around the actions they guard; a failing assertion reverts the whole transaction.

## DAO proposal with safety checks

```solidity
// In a DAO proposal's action list:

// 1. Pre-condition: Verify treasury has expected balance before transfer
assertions.assertGeCallUint(
    treasury,
    abi.encodeCall(IERC20.balanceOf, (treasury)),
    requiredBalance,
    "Treasury balance too low"
);

// 2. Execute the actual transfer
treasury.transfer(recipient, amount);

// 3. Post-condition: Ensure treasury still has minimum reserves
assertions.assertGeCallUint(
    treasury,
    abi.encodeCall(IERC20.balanceOf, (treasury)),
    minimumReserves,
    "Transfer would deplete reserves below minimum"
);

// 4. Invariant: Confirm DAO still owns the treasury
assertions.assertEqCallAddress(
    treasury,
    abi.encodeCall(Ownable.owner, ()),
    address(dao),
    "Treasury ownership compromised"
);
```

## Safe multisig transaction batch

```solidity
// Safe transaction batch:

// Action 1: Assert protocol is not paused
assertions.assertFalse(
    protocol,
    abi.encodeCall(IProtocol.paused, ()),
    "Protocol is paused"
);

// Action 2: Assert oracle price is within bounds (MEV protection)
assertions.assertGeCallUint(
    oracle,
    abi.encodeCall(IOracle.getPrice, ()),
    minAcceptablePrice,
    "Price too low - possible manipulation"
);
assertions.assertLeCallUint(
    oracle,
    abi.encodeCall(IOracle.getPrice, ()),
    maxAcceptablePrice,
    "Price too high - possible manipulation"
);

// Action 3: Execute the actual swap/trade
protocol.swap(tokenIn, tokenOut, amount);

// Action 4: Assert we received expected output (slippage check)
assertions.assertGeCallUint(
    tokenOut,
    abi.encodeCall(IERC20.balanceOf, (safe)),
    minExpectedOutput,
    "Slippage too high"
);
```

## Protocol upgrade verification

```solidity
// Assert proxy admin is correct
assertions.assertEqCallAddress(
    proxy,
    abi.encodeCall(ITransparentProxy.admin, ()),
    expectedAdmin,
    "Unexpected proxy admin"
);

// Execute upgrade
proxyAdmin.upgrade(proxy, newImplementation);

// Assert new implementation has expected code
assertions.assertEqCodeHash(
    newImplementation,
    keccak256(newImplementationCode),
    "Implementation code mismatch"
);

// Assert critical storage wasn't corrupted
assertions.assertEqCallUint(
    proxy,
    abi.encodeCall(IProtocol.totalSupply, ()),
    expectedTotalSupply,
    "Storage corrupted during upgrade"
);
```

## Basic call assertions

```solidity
// Assert totalSupply() returns exactly 1000
assertions.assertEqCallUint(
    tokenAddress,
    abi.encodeCall(IERC20.totalSupply, ()),
    1000
);

// Assert owner() returns a specific address
assertions.assertEqCallAddress(
    contractAddress,
    abi.encodeCall(Ownable.owner, ()),
    expectedOwner
);

// Assert paused() returns false
assertions.assertFalse(
    contractAddress,
    abi.encodeCall(Pausable.paused, ())
);
```

## Comparison assertions

```solidity
// Assert balance is greater than minimum
assertions.assertGtCallUint(
    tokenAddress,
    abi.encodeCall(IERC20.balanceOf, (user)),
    minimumBalance
);

// Assert the deadline has already passed (deadline < current timestamp)
assertions.assertLtCallUint(
    contractAddress,
    abi.encodeCall(IVesting.deadline, ()),
    block.timestamp
);
```

## Tuple-indexed assertions

For functions that return multiple values, the `N`-suffixed variants take the index of the value to check:

```solidity
// Function: getPosition() returns (uint256 amount, uint256 debt, address owner)
// Assert the second return value (debt at index 1) equals expected
assertions.assertEqCallUintN(
    vaultAddress,
    abi.encodeCall(IVault.getPosition, (positionId)),
    1,  // index
    expectedDebt
);
```

An `index` that points past the returned data reverts with `ReturnDataOutOfBounds` instead of silently comparing against zeroed memory.

## Approximate equality

```solidity
// Assert price is within 1% tolerance (100 basis points)
assertions.assertApproxEqCallUint(
    oracleAddress,
    abi.encodeCall(IOracle.getPrice, ()),
    expectedPrice,
    expectedPrice / 100  // 1% max delta
);

// Signed values work the same way (the tolerance is always a uint256)
assertions.assertApproxEqCallInt(
    oracleAddress,
    abi.encodeCall(IOracle.getFundingRate, ()),
    expectedRate,
    maxDeviation
);
```

## Balance assertions

```solidity
// Assert account has at least 1 ETH
assertions.assertGeBalance(userAddress, 1 ether);

// Assert contract balance is approximately expected (within 0.01 ETH)
assertions.assertApproxEqBalance(
    contractAddress,
    expectedBalance,
    0.01 ether
);
```

## Block and chain assertions

```solidity
// Assert we're on mainnet
assertions.assertEqChainId(1);

// Assert block timestamp is after unlock time
assertions.assertGtBlockTimestamp(unlockTime);

// Assert block number is within range
assertions.assertGeBlockNumber(startBlock);
assertions.assertLeBlockNumber(endBlock);
```

## Contract existence

```solidity
// Assert address is a contract
assertions.assertHasCode(contractAddress);

// Assert address is an EOA
assertions.assertNoCode(eoaAddress);

// Verify exact bytecode (useful for proxy implementations)
assertions.assertEqCodeHash(proxyAddress, expectedCodeHash);
```

## Custom error messages

All assertion functions have overloaded versions that accept a custom message, reported in the revert when the assertion fails:

```solidity
assertions.assertEqCallUint(
    tokenAddress,
    abi.encodeCall(IERC20.totalSupply, ()),
    expectedSupply,
    "Token supply mismatch after mint"
);
```

## Caveats

- **EIP-7702 delegated EOAs carry code.** An EOA that has delegated via EIP-7702 has a 23-byte delegation designator as its code, so `assertNoCode` fails and `assertHasCode` passes for it. Don't use `assertNoCode` as a strict "is an EOA" check on chains with EIP-7702.
- **`block.number` semantics differ across chains.** On OP-stack and most L2s, `assertEqBlockNumber` and friends see the L2 block number (on Arbitrum, `block.number` returns the approximate L1 block). Block times also vary per chain, so avoid porting block-number thresholds between networks.
- **Calls to code-less addresses revert with `CallFailed`.** A `staticcall` to an address without code would otherwise "succeed" with empty returndata; the contract detects this and reverts descriptively.
