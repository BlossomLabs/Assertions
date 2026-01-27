# Assertions

On-chain assertion contract for verifying view function return values and blockchain state in Solidity.

## Overview

The `Assertions` contract provides a comprehensive suite of assertion functions that can be used to validate on-chain state. It uses `staticcall` to execute view functions on target contracts and compares results against expected values, reverting with descriptive custom errors on failure.

---

### Deployed at [`assertions.eth`](https://etherscan.io/address/0xA55e4707A94Ce4Aa647517ed9aD4084e4E5D1f3F)

```
0xA55e4707A94Ce4Aa647517ed9aD4084e4E5D1f3F
```

---

## Why Assertions?

### Secure DAO Proposals

DAO governance proposals often execute complex multi-step transactions. A malicious or buggy proposal could drain the treasury, change critical permissions, or break protocol invariants. By including assertion calls in your proposals, you can **guarantee that certain conditions hold** before and after execution—or the entire transaction reverts.

### Safe Transaction Guards

When using multisig wallets like [Safe](https://safe.global/), you can batch assertion calls alongside your actual transactions. This adds a layer of **transaction security** by verifying:
- Pre-conditions are met before execution
- Post-conditions hold after execution  
- Protocol invariants remain intact
- No unexpected state changes occurred

### Enforce Invariants On-Chain

Unlike off-chain simulations that can be fooled by MEV or state changes between submission and execution, on-chain assertions execute atomically with your transaction. If any assertion fails, **the entire transaction reverts**—no partial execution, no unexpected outcomes.

### Use Cases

| Scenario | Example |
|----------|---------|
| **Treasury protection** | Assert treasury balance doesn't drop below threshold |
| **Permission safety** | Assert admin roles haven't been changed unexpectedly |
| **Price manipulation guards** | Assert oracle price is within expected bounds |
| **Upgrade verification** | Assert proxy implementation matches expected codehash |
| **Timelock validation** | Assert current timestamp is after unlock period |
| **Liquidity checks** | Assert pool reserves meet minimum requirements |
| **Ownership verification** | Assert critical contracts still owned by DAO |

## Features

- **Call-based assertions** - Execute view functions on any contract and assert return values
- **Multiple type support** - `uint256`, `int256`, `address`, `bool`, `bytes32`, `bytes`, `string`
- **Tuple indexing** - Assert specific elements from functions returning multiple values
- **Comparison operators** - Equal, not equal, greater than, less than, greater/less than or equal
- **Approximate equality** - Assert values within a tolerance (absolute delta)
- **Array length assertions** - Validate dynamic array lengths
- **Balance assertions** - Check native token balances
- **Block assertions** - Verify block number and timestamp
- **Chain ID assertions** - Ensure correct network
- **Contract existence** - Check if address has code, verify code hash
- **Custom error messages** - All assertions have overloaded versions accepting custom messages

## Usage

### DAO Proposal with Safety Checks

Include assertions in your governance proposal to ensure invariants hold:

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

### Safe Multisig Transaction Batch

Bundle assertions with your Safe transactions for added security:

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

### Protocol Upgrade Verification

Verify critical state before and after upgrades:

```solidity
// Before upgrade: Store expected state
bytes32 expectedImplementation = keccak256(newImplementationCode);

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
    expectedImplementation,
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

### Basic Call Assertions

Assert that a view function returns an expected value:

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

### Comparison Assertions

```solidity
// Assert balance is greater than minimum
assertions.assertGtCallUint(
    tokenAddress,
    abi.encodeCall(IERC20.balanceOf, (user)),
    minimumBalance
);

// Assert timestamp is before deadline
assertions.assertLtCallUint(
    contractAddress,
    abi.encodeCall(IVesting.deadline, ()),
    block.timestamp
);
```

### Tuple-Indexed Assertions

For functions that return multiple values:

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

### Approximate Equality

For values that may have slight variations:

```solidity
// Assert price is within 1% tolerance (100 basis points)
assertions.assertApproxEqCallUint(
    oracleAddress,
    abi.encodeCall(IOracle.getPrice, ()),
    expectedPrice,
    expectedPrice / 100  // 1% max delta
);
```

### Balance Assertions

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

### Block and Chain Assertions

```solidity
// Assert we're on mainnet
assertions.assertEqChainId(1);

// Assert block timestamp is after unlock time
assertions.assertGtBlockTimestamp(unlockTime);

// Assert block number is within range
assertions.assertGeBlockNumber(startBlock);
assertions.assertLeBlockNumber(endBlock);
```

### Contract Existence

```solidity
// Assert address is a contract
assertions.assertHasCode(contractAddress);

// Assert address is an EOA
assertions.assertNoCode(eoaAddress);

// Verify exact bytecode (useful for proxy implementations)
assertions.assertEqCodeHash(proxyAddress, expectedCodeHash);
```

### Custom Error Messages

All assertion functions have overloaded versions that accept a custom message:

```solidity
assertions.assertEqCallUint(
    tokenAddress,
    abi.encodeCall(IERC20.totalSupply, ()),
    expectedSupply,
    "Token supply mismatch after mint"
);
```

## Custom Errors

The contract uses typed custom errors for gas-efficient and informative failure messages:

| Error | Description |
|-------|-------------|
| `AssertionFailedUint(string, uint256, uint256)` | uint256 assertion failed |
| `AssertionFailedInt(string, int256, int256)` | int256 assertion failed |
| `AssertionFailedAddress(string, address, address)` | address assertion failed |
| `AssertionFailedBool(string, bool, bool)` | bool assertion failed |
| `AssertionFailedBytes32(string, bytes32, bytes32)` | bytes32 assertion failed |
| `AssertionFailedBytes(string, bytes32, bytes32)` | bytes assertion failed (shows hashes) |
| `AssertionFailedString(string, string, string)` | string assertion failed |
| `AssertionFailedApprox(string, uint256, uint256, uint256, uint256)` | approximate equality failed |
| `CallFailed(address, bytes)` | staticcall to target reverted |

## API Reference

### Uint256 Assertions

| Function | Description |
|----------|-------------|
| `assertEqCallUint` | Assert return equals expected |
| `assertNeCallUint` | Assert return not equals expected |
| `assertGtCallUint` | Assert return > expected |
| `assertLtCallUint` | Assert return < expected |
| `assertGeCallUint` | Assert return >= expected |
| `assertLeCallUint` | Assert return <= expected |
| `assertApproxEqCallUint` | Assert return ≈ expected (within delta) |

### Address Assertions

| Function | Description |
|----------|-------------|
| `assertEqCallAddress` | Assert return equals expected address |
| `assertNeCallAddress` | Assert return not equals expected address |

### Bool Assertions

| Function | Description |
|----------|-------------|
| `assertEqCallBool` | Assert return equals expected bool |
| `assertTrue` | Assert return is true |
| `assertFalse` | Assert return is false |

### Bytes32 Assertions

| Function | Description |
|----------|-------------|
| `assertEqCallBytes32` | Assert return equals expected bytes32 |
| `assertNeCallBytes32` | Assert return not equals expected bytes32 |

### Tuple-Indexed Assertions (N suffix)

All basic assertion types have tuple-indexed variants with an `N` suffix that accept an additional `index` parameter:

- `assertEqCallUintN`, `assertGtCallUintN`, `assertLtCallUintN`, `assertGeCallUintN`, `assertLeCallUintN`
- `assertEqCallAddressN`, `assertNeCallAddressN`
- `assertEqCallBoolN`
- `assertEqCallBytes32N`
- `assertEqCallStringN`
- `assertApproxEqCallUintN`

### Array Assertions

| Function | Description |
|----------|-------------|
| `assertEqCallArrayLength` | Assert array length equals expected |
| `assertGtCallArrayLength` | Assert array length > expected |
| `assertGeCallArrayLength` | Assert array length >= expected |

### Balance Assertions

| Function | Description |
|----------|-------------|
| `assertEqBalance` | Assert native balance equals expected |
| `assertGtBalance` | Assert native balance > expected |
| `assertLtBalance` | Assert native balance < expected |
| `assertGeBalance` | Assert native balance >= expected |
| `assertLeBalance` | Assert native balance <= expected |
| `assertApproxEqBalance` | Assert native balance ≈ expected |

### Block Assertions

| Function | Description |
|----------|-------------|
| `assertEqBlockNumber` | Assert block.number equals expected |
| `assertGtBlockNumber` | Assert block.number > expected |
| `assertLtBlockNumber` | Assert block.number < expected |
| `assertGeBlockNumber` | Assert block.number >= expected |
| `assertLeBlockNumber` | Assert block.number <= expected |
| `assertEqBlockTimestamp` | Assert block.timestamp equals expected |
| `assertGtBlockTimestamp` | Assert block.timestamp > expected |
| `assertLtBlockTimestamp` | Assert block.timestamp < expected |
| `assertGeBlockTimestamp` | Assert block.timestamp >= expected |
| `assertLeBlockTimestamp` | Assert block.timestamp <= expected |

### Chain & Contract Assertions

| Function | Description |
|----------|-------------|
| `assertEqChainId` | Assert chain ID equals expected |
| `assertHasCode` | Assert address has deployed code |
| `assertNoCode` | Assert address has no code |
| `assertEqCodeHash` | Assert address has specific code hash |

## Development

### Install

```bash
pnpm install
```

### Build

```bash
pnpm hardhat compile
```

### Test

```bash
pnpm hardhat test
```

### Deploy

```bash
pnpm hardhat ignition deploy ignition/modules/Assertions.ts --network <network>
```

## License

MIT
