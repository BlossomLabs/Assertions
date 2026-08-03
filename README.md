# Assertions

On-chain assertion contract for verifying view function return values and blockchain state in Solidity.

## Overview

Assertions ships as **two contracts** with one tagline: **Assertions judge, Combinators compute.**

- **`Assertions` (the core)** provides a comprehensive suite of assertion functions that validate on-chain state. It uses `staticcall` to execute view functions on target contracts and compares results against expected values, reverting with descriptive custom errors on failure. The core is the trust anchor: it is **frozen forever** — no future version will change its behavior at its canonical address.
- **`Combinators` (the periphery)** provides small composable building blocks — chained reads, arithmetic, bitwise, comparison, boolean logic, hashing, string splitting, constants and environment getters. Each combinator computes and returns a value, and nested `(target, data)` operands in calldata compose them into arbitrary expressions. The core judges the final value: point any call assertion at the Combinators address with the encoded expression as data. See [Combinators](#combinators--computing-values) below.

Because combinators are stateless view targets, the periphery can evolve: old `Combinators` deployments never break (anything referencing them keeps working), and new versions ship at new addresses as pure opt-ins — all without ever touching the frozen core.

---

### Canonical addresses (same on every chain)

```
Assertions  v1.1  0xA55E47d30A22BBABACcb313fbA116E475eA4260A   (frozen core)
Combinators v1.0  0xA55eC03487C832ea7811204Fd46a337dD2DafAFF   (versionable periphery)
```

Version 1.0 of the core remains deployed at [`assertions.eth`](https://etherscan.io/address/0xA55e4707A94Ce4Aa647517ed9aD4084e4E5D1f3F) (`0xA55e4707A94Ce4Aa647517ed9aD4084e4E5D1f3F`). Core v1.1 is a strict superset of the 1.0 ABI: it adds int256 assertions, tuple index bounds checking, `CallFailed` on code-less targets, and the `Ne`/`Lt`/`Le` variants listed below. All composition functions live in the separate `Combinators` contract, which carries its own version line.

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
- **Combinators** - Chained reads, arithmetic, logic, bitwise, hashing and string splitting composed via the separate `Combinators` contract
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

// Assert the deadline has already passed (deadline < current timestamp)
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

## Combinators — computing values

Assertion functions revert or pass — they judge. Everything that *computes* lives in the separate `Combinators` contract (`0xA55eC03487C832ea7811204Fd46a337dD2DafAFF`): each function is a small composable building block, and nested `(target, data)` operands in calldata compose the blocks into arbitrary expressions. The core consumes the result by pointing any call assertion at the Combinators address.

The core is frozen forever; Combinators is versionable. A future `Combinators` v2 would deploy at a new address without touching the core or breaking anything that references v1.

### Chained Calls

Sometimes the value you want to assert lives behind a lookup: "the pool's token has the symbol WETH" means calling `pool.token()` first, then `symbol()` on whatever address it returns. The `chainCall` helper resolves such a path in one staticcall:

```solidity
function chainCall(address target, bytes[] calldata calls) external view
```

`calls[0]` runs on `target`, each non-final call's return value is decoded as the next call's target address, and the **final call's returndata is returned verbatim** (raw, not ABI-re-encoded). Because the returndata passes through byte-for-byte, `chainCall` composes with *every* call assertion — uint/int/address/bool/bytes32, tuple-indexed, array-length, and approximate variants — by pointing the assertion at the Combinators contract:

```solidity
bytes[] memory hops = new bytes[](2);
hops[0] = abi.encodeCall(IPool.token, ());   // pool.token()   -> address of the token
hops[1] = abi.encodeCall(IERC20.symbol, ()); // token.symbol() -> asserted value

assertions.assertEqCallStringN(
    address(combinators),                                    // target: the Combinators contract
    abi.encodeCall(Combinators.chainCall, (pool, hops)),    // data: the encoded chain
    0,                                                     // string returns decode at index 0
    "WETH"
);
```

In [EVMcrispr](https://evmcrispr.blossom.software) the same chain is written inline:

```
assertions:assert $pool::{token()(address)}::{symbol()(string)} == "WETH"
```

Chain failures are descriptive: a hop that reverts or targets an address without code makes `chainCall` revert with `CallFailed(target, data)` identifying the exact failing hop, a non-final hop returning fewer than 32 bytes reverts with `ReturnDataOutOfBounds`, and an empty `calls` array reverts with `EmptyCallChain`. (When composed inside an assertion, the outer assertion reports `CallFailed` on the `chainCall` invocation itself; call `chainCall` directly to inspect the failing hop.)

### Arithmetic, Comparison & Logic Composition

The same composition philosophy extends to expressions over call results. Every operand is a `(target, data)` pair — and operands may themselves be calls to the Combinators contract (`chainCall`, `calcUint`, `cmpUint`, `notBool`, …), so expressions nest recursively:

```solidity
function calcUint(ArithOp op, address target1, bytes data1, address target2, bytes data2) returns (uint256)
function calcInt (ArithOp op, address target1, bytes data1, address target2, bytes data2) returns (int256)
function cmpUint (CmpOp op,   address target1, bytes data1, address target2, bytes data2) returns (bool)
function cmpInt  (CmpOp op,   address target1, bytes data1, address target2, bytes data2) returns (bool)
function logicBool(LogicOp op, address target1, bytes data1, address target2, bytes data2) returns (bool)
function notBool  (address target, bytes data) returns (bool)
function boolToUint(address target, bytes data) returns (uint256)
function uintCall (address target, bytes[] calls, uint256 wordIndex) returns (uint256)
function lengthCall(address target, bytes[] calls) returns (uint256)
```

The op enums and their numeric encodings (what encoders put in calldata):

| Enum | Values |
|------|--------|
| `ArithOp` | `Add = 0`, `Sub = 1`, `Mul = 2`, `Div = 3`, `Mod = 4`, `Exp = 5` (Exp is `calcUint`-only; `calcInt` reverts with `UnsupportedOp` since Solidity defines `**` for unsigned operands only) |
| `CmpOp` | `Eq = 0`, `Ne = 1`, `Gt = 2`, `Lt = 3`, `Ge = 4`, `Le = 5` |
| `LogicOp` | `And = 0`, `Or = 1`, `Xor = 2` |
| `BitOp` | `And = 0`, `Or = 1`, `Xor = 2`, `Shl = 3`, `Shr = 4` |

Bitwise expressions use `bitUint(BitOp op, …)` and the unary `bitNotUint(target, data)`, both returning `uint256`. For `Shl`/`Shr` the second operand is the shift amount; shifts of 256 or more yield 0 (EVM shift semantics, no revert).

Value getters turn non-call quantities into operands: `ethBalance(account)` (native balance), `blockTimestamp()`, `blockNumber()`, and the literal echoes `constantUint(x)` / `constantInt(x)` for comparing a call result against a constant.

**Worked example** — "`addr1`'s ETH balance plus its WETH balance is positive":

```solidity
assertions.assertGtCallUint(
    address(combinators),
    abi.encodeCall(Combinators.calcUint, (
        Combinators.ArithOp.Add,
        address(combinators), abi.encodeCall(Combinators.ethBalance, (addr1)),
        weth,                abi.encodeCall(IERC20.balanceOf, (addr1))
    )),
    0
);
```

In EVMcrispr the same expression is written directly and compiles to nested `calcUint` calldata:

```
assertions:assert @balance($addr1) + $weth::balanceOf($addr1) > 0
```

**Logic example** — assertions revert on failure, so they cannot be OR-ed; `cmpUint` *returns* the comparison outcome instead, and `logicBool` combines outcomes. "`addr1` has ETH OR holds more than 10 tokens":

```solidity
bytes memory hasEth = abi.encodeCall(Combinators.cmpUint, (
    Combinators.CmpOp.Gt,
    address(combinators), abi.encodeCall(Combinators.ethBalance, (addr1)),
    address(combinators), abi.encodeCall(Combinators.constantUint, (0))
));
bytes memory hasTokens = abi.encodeCall(Combinators.cmpUint, (
    Combinators.CmpOp.Gt,
    token,               abi.encodeCall(IERC20.balanceOf, (addr1)),
    address(combinators), abi.encodeCall(Combinators.constantUint, (10))
));
assertions.assertEqCallBool(
    address(combinators),
    abi.encodeCall(Combinators.logicBool, (
        Combinators.LogicOp.Or,
        address(combinators), hasEth,
        address(combinators), hasTokens
    )),
    true
);
```

```
assertions:assert (@balance($addr1) > 0) || ($token::balanceOf($addr1) > 10)
```

**Bitmask example** — flag checks on a packed config word, with `constantUint` supplying the mask or shift. "`config & MASK != 0`":

```solidity
assertions.assertNeCallUint(
    address(combinators),
    abi.encodeCall(Combinators.bitUint, (
        Combinators.BitOp.And,
        configSource,        abi.encodeCall(IConfig.packedConfig, ()),
        address(combinators), abi.encodeCall(Combinators.constantUint, (MASK))
    )),
    0
);
```

And "bit `N` of the config is set" (`(config >> N) & 1 == 1`) nests a `Shr` inside an `And` the same way.

**Hashing complex returns** — when a function returns something the typed assertions can't decode (structs, arrays, long strings), `hashCall` returns `keccak256` of the resolved chain's final returndata so the existing bytes32 assertions can check it against a precomputed hash:

```solidity
bytes[] memory calls = new bytes[](1);
calls[0] = abi.encodeCall(IVault.getPosition, (positionId)); // returns a struct

assertions.assertEqCallBytes32(
    address(combinators),
    abi.encodeCall(Combinators.hashCall, (vault, calls)),
    keccak256(abi.encode(expectedAmount, expectedDebt, expectedOwner))
);
```

Like `chainCall`, it takes a call chain — a single call is a one-element array.

**String splitting** — `splitCall(target, calls, delimiter, index)` resolves a chain whose final call returns a string, splits it by the delimiter, and returns the `index`-th segment (0-based) as a normal ABI-encoded string, so string assertions consume it directly. "The second word of the pool's name is LP":

```solidity
bytes[] memory calls = new bytes[](1);
calls[0] = abi.encodeCall(IPool.name, ()); // "Curve LP Token"

assertions.assertEqCallStringN(
    address(combinators),
    abi.encodeCall(Combinators.splitCall, (pool, calls, " ", 1)),
    0,
    "LP"
);
```

```
assertions:assert @split($pool::name(), " ", 1) == "LP"
```

Split semantics: the delimiter is a non-empty exact byte sequence (empty reverts with `EmptyDelimiter`); segments are the maximal runs between occurrences, so adjacent delimiters produce empty segments; a string that doesn't contain the delimiter is one segment (index 0 = the whole string); and an index past the last segment reverts with `SegmentIndexOutOfBounds(index, segments)` — loud failure with the actual segment count. Version-string checks work the same way: split `"2.1.0"` by `"."` and assert segment 0 equals `"2"`.

**Exponentiation & live decimals scaling** — `Exp = 5` in `ArithOp` gives `calcUint` checked `**` (overflow reverts with `Panic(0x11)`, `0 ** 0 == 1` per EVM semantics). `calcInt` rejects `Exp` with `UnsupportedOp`: Solidity defines `**` for unsigned operands only, so signed exponentiation is ill-defined — use `calcUint` for powers. The canonical use is scaling thresholds by a live `decimals()` (EVMcrispr's `@num` with `^`): "`a` holds at least 5 whole tokens":

```solidity
bytes memory scale = abi.encodeCall(Combinators.calcUint, (        // 10 ** decimals()
    Combinators.ArithOp.Exp,
    address(combinators), abi.encodeCall(Combinators.constantUint, (10)),
    token,                abi.encodeCall(IERC20.decimals, ())
));
bytes memory threshold = abi.encodeCall(Combinators.calcUint, (   // 5 * 10 ** decimals()
    Combinators.ArithOp.Mul,
    address(combinators), abi.encodeCall(Combinators.constantUint, (5)),
    address(combinators), scale
));
assertions.assertEqCallBool(
    address(combinators),
    abi.encodeCall(Combinators.cmpUint, (
        Combinators.CmpOp.Ge,
        token,                abi.encodeCall(IERC20.balanceOf, (a)),
        address(combinators), threshold
    )),
    true
);
```

```
assertions:assert $token::balanceOf($a) >= @num(5, $token::decimals())
```

**Raw word extraction** — `uintCall(target, calls, wordIndex)` resolves a call chain and returns the `wordIndex`-th 32-byte word of the final returndata as a `uint256` (EVMcrispr's `@at` applied to a live tuple). It is raw-word extraction for static-layout returns like `getReserves()`, **not** an ABI decoder: dynamic types contribute head offsets at their word positions, not content. A `wordIndex` past the returndata reverts with `ReturnDataOutOfBounds(wordIndex, length)`. Because the word comes back as `uint256`, it also covers `bytes32`/`address` words at the word level via `cmpUint`. "The pool's reserve ratio is at least 5":

```solidity
bytes[] memory reserves = new bytes[](1);
reserves[0] = abi.encodeCall(IPair.getReserves, ());

bytes memory ratio = abi.encodeCall(Combinators.calcUint, (
    Combinators.ArithOp.Div,
    address(combinators), abi.encodeCall(Combinators.uintCall, (pair, reserves, 0)),
    address(combinators), abi.encodeCall(Combinators.uintCall, (pair, reserves, 1))
));
assertions.assertEqCallBool(
    address(combinators),
    abi.encodeCall(Combinators.cmpUint, (
        Combinators.CmpOp.Ge,
        address(combinators), ratio,
        address(combinators), abi.encodeCall(Combinators.constantUint, (5))
    )),
    true
);
```

**Returndata length** — `lengthCall(target, calls)` returns the byte length of the final resolved returndata (EVMcrispr's `@len` / `.length` on live data). It measures the raw ABI encoding, so a `uint256[]` with `n` items measures `64 + n * 32` (offset word + length word + items) — item counts derive arithmetically: `calcUint(Div, calcUint(Sub, lengthCall(...), constantUint(64)), constantUint(32))`.

**Bool→uint bridge** — `boolToUint(target, data)` returns 1 for `true` and 0 for `false` (strict 0/1 decoding like `logicBool` operands). It bridges boolean and arithmetic composition, enabling the conditional-select idiom — an expression-level `if` (EVMcrispr's live conditional): `cond * a + (1 - cond) * b` picks `a` when the condition holds and `b` otherwise, composed from three nested `calcUint` calls.

Nesting is unlimited — an operand can be a `chainCall`, another `calcUint`, a `cmpUint` feeding a `logicBool`, and so on: `(pool.token().decimals() + x.value() == 60) && !protocol.paused()` is one `assertTrue` call.

**Expressing other things** — several patterns need no dedicated functions:

- **Address equality inside expressions**: address returns occupy a single word, so `cmpUint(Eq, target, ownerCall, assertions, constantUint(uint256(uint160(expectedAddr))))` compares them (the top-level `assertEqCallAddress` remains the direct form).
- **Bool constants**: a constant `true` operand is `cmpUint(Eq, assertions, constantUint(1), assertions, constantUint(1))` — rarely needed since `logicBool` operands are usually real calls.
- **String operations**: splitting is covered by `splitCall`; concatenation is deliberately not included — instead of building strings on-chain, compare the final value against a constant (`assertEqCallStringN`) or its hash (`hashCall`).

Semantics to know:

- **Checked arithmetic.** `calcUint`/`calcInt` use Solidity 0.8 semantics: overflow/underflow reverts with `Panic(0x11)` (including `Exp` overflow), division or modulo by zero with `Panic(0x12)`.
- **Signed semantics.** `calcInt` division truncates toward zero (`45 / -7 == -6`), modulo takes the sign of the dividend (`45 % -7 == 3`, `-45 % 7 == -3`), and `type(int256).min / -1` reverts with `Panic(0x11)`.
- **No short-circuit.** `logicBool` always evaluates both operands (they are view calls executed before the op is applied) — don't rely on `And`/`Or` to skip a reverting operand.
- **Strict bool decoding.** Logic operands must return exactly 0 or 1; any other word reverts.
- **Operand failures.** An operand that reverts or targets a code-less address reverts with `CallFailed` identifying it; operands returning fewer than 32 bytes revert with `ReturnDataOutOfBounds`.

## Custom Errors

Both contracts use typed custom errors for gas-efficient and informative failure messages.

`Assertions` (core):

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
| `CallFailed(address, bytes)` | staticcall to target reverted, or target has no code |
| `ReturnDataOutOfBounds(uint256, uint256)` | tuple index points outside the returned data |

`Combinators`:

| Error | Description |
|-------|-------------|
| `CallFailed(address, bytes)` | a chain hop or expression operand reverted or targets a code-less address (identifies the exact failing call) |
| `ReturnDataOutOfBounds(uint256, uint256)` | an operand or non-final chain hop returned fewer than 32 bytes, a string return failed validation, or a `uintCall` word index points past the returndata |
| `EmptyCallChain()` | `chainCall` / `hashCall` / `splitCall` / `uintCall` / `lengthCall` received an empty `calls` array |
| `EmptyDelimiter()` | `splitCall` received an empty delimiter |
| `SegmentIndexOutOfBounds(uint256, uint256)` | `splitCall` index is past the last segment (arguments: requested index, segment count) |
| `UnsupportedOp()` | `calcInt` received `ArithOp.Exp` (signed exponentiation is ill-defined; use `calcUint`) |

The two contracts define `CallFailed` and `ReturnDataOutOfBounds` with identical signatures, so decoders treat them uniformly.

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

### Int256 Assertions

| Function | Description |
|----------|-------------|
| `assertEqCallInt` | Assert return equals expected |
| `assertNeCallInt` | Assert return not equals expected |
| `assertGtCallInt` | Assert return > expected |
| `assertLtCallInt` | Assert return < expected |
| `assertGeCallInt` | Assert return >= expected |
| `assertLeCallInt` | Assert return <= expected |

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

- `assertEqCallUintN`, `assertNeCallUintN`, `assertGtCallUintN`, `assertLtCallUintN`, `assertGeCallUintN`, `assertLeCallUintN`
- `assertEqCallIntN`, `assertNeCallIntN`, `assertGtCallIntN`, `assertLtCallIntN`, `assertGeCallIntN`, `assertLeCallIntN`
- `assertEqCallAddressN`, `assertNeCallAddressN`
- `assertEqCallBoolN`
- `assertEqCallBytes32N`
- `assertEqCallStringN`
- `assertApproxEqCallUintN`

An `index` that points past the returned data reverts with `ReturnDataOutOfBounds` instead of silently comparing against zeroed memory.

### Array Assertions

| Function | Description |
|----------|-------------|
| `assertEqCallArrayLength` | Assert array length equals expected |
| `assertGtCallArrayLength` | Assert array length > expected |
| `assertGeCallArrayLength` | Assert array length >= expected |
| `assertLtCallArrayLength` | Assert array length < expected |
| `assertLeCallArrayLength` | Assert array length <= expected |

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

### Combinators (separate `Combinators` contract)

These live at the Combinators address (`0xA55eC03487C832ea7811204Fd46a337dD2DafAFF`), not on the core. See [Combinators — computing values](#combinators--computing-values) for usage.

| Function | Description |
|----------|-------------|
| `chainCall` | Resolve a chain of staticcalls and return the final call's returndata verbatim — compose with any call assertion |
| `hashCall` | keccak256 of a resolved chain's final returndata — check complex returns via bytes32 assertions |
| `splitCall` | Split a chain's final string return by a delimiter and return the index-th segment |
| `uintCall` | Extract the wordIndex-th 32-byte word of a chain's final returndata (static-layout tuples) |
| `lengthCall` | Byte length of a chain's final returndata |
| `calcUint` / `calcInt` | Arithmetic over two call results (`ArithOp`: Add, Sub, Mul, Div, Mod, Exp — Exp is uint-only) |
| `bitUint` / `bitNotUint` | Bitwise ops over call results (`BitOp`: And, Or, Xor, Shl, Shr) |
| `cmpUint` / `cmpInt` | Comparison returning bool instead of reverting (`CmpOp`: Eq, Ne, Gt, Lt, Ge, Le) |
| `logicBool` / `notBool` | Boolean combination of call results (`LogicOp`: And, Or, Xor) — no short-circuit |
| `boolToUint` | 1 for true, 0 for false — enables the conditional-select idiom `cond * a + (1 - cond) * b` |
| `constantUint` / `constantInt` | Echo a literal, for comparing call results against constants |
| `ethBalance` | Native balance as a composition operand |
| `blockTimestamp` / `blockNumber` | Current block values as composition operands |

### Caveats

- **EIP-7702 delegated EOAs carry code.** An EOA that has delegated via EIP-7702 has a 23-byte delegation designator as its code, so `assertNoCode` fails and `assertHasCode` passes for it. Don't use `assertNoCode` as a strict "is an EOA" check on chains with EIP-7702.
- **`block.number` semantics differ across chains.** On OP-stack and most L2s, `assertEqBlockNumber` and friends see the L2 block number (on Arbitrum, `block.number` returns the approximate L1 block). Block times also vary per chain, so avoid porting block-number thresholds between networks.
- **Calls to code-less addresses revert with `CallFailed`.** A `staticcall` to an address without code would otherwise "succeed" with empty returndata; the contract detects this and reverts descriptively.

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
pnpm test
```

## Deploying to a new chain

Both contracts live at the same canonical addresses on every chain because they
are deployed via [Arachnid's deterministic-deployment proxy](https://github.com/Arachnid/deterministic-deployment-proxy)
(`0x4e59b44847b379578588920cA78FbF26c0B4956C`), which performs a CREATE2 with a
fixed salt per contract:

```
address = keccak256(0xff ++ 0x4e59b448...956C ++ salt ++ keccak256(initCode))[12:]
```

The easiest way to deploy is the **Deployments page on the website**: connect a
wallet, pick the network (or add a custom RPC), and send one transaction per
contract (Assertions ~4.2M gas, Combinators ~1.1M gas). If the Arachnid proxy
is missing on the chain, the page walks you through installing it
permissionlessly first.

Manually, each deployment is a single transaction to the proxy with
`salt ++ initCode` as calldata:

```bash
cast send 0x4e59b44847b379578588920cA78FbF26c0B4956C \
  "$(cat salt_and_initcode.hex)" --rpc-url <rpc> --private-key <key>
```

The salts live in `hardhat.config.ts` and `website/scripts/export-deploy-artifact.mjs`;
the script regenerates `website/src/lib/assertions-deployment.ts` and
`website/src/lib/combinators-deployment.ts` (salt, init code, and predicted
address for each contract) from a fresh compile — it refuses to export if the
compiled bytecode no longer reproduces a canonical address.

> **Do not use `hardhat ignition deploy` for the canonical deployment.**
> Ignition's `create2` strategy goes through the CreateX factory, which
> re-hashes the salt and therefore produces a *different* address than the
> Arachnid proxy. The Ignition module is kept only for local testing.

> **Chain requirements:** the bytecode targets `cancun` and contains `PUSH0`,
> so the target chain must support the Shanghai upgrade or later. The exact
> compiler settings in `hardhat.config.ts` (solc 0.8.28, optimizer 200 runs,
> `evmVersion: cancun`) must not change, or the CREATE2 addresses change with
> the bytecode.

## License

MIT
