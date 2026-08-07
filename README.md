# Assertions

On-chain assertion contract for verifying view function return values and blockchain state in Solidity.

## Overview

Assertions ships as **two contracts** with one tagline: **Assertions judge, Combinators compute.**

- **`Assertions` (the core)** provides a comprehensive suite of assertion functions that validate on-chain state. It uses `staticcall` to execute view functions on target contracts and compares results against expected values, reverting with descriptive custom errors on failure. The core is the trust anchor: it is **frozen forever** — no future version will change its behavior at its canonical address.
- **`Combinators` (the periphery)** provides five composable building blocks — navigated call chains (`read`), binary word operations (`calc`), unary word operations (`unary`), returndata operations (`data`) and constants/environment values (`env`). Each combinator computes and returns a value, and nested `(target, data)` operands in calldata compose them into arbitrary expressions. The core judges the final value: point any call assertion at the Combinators address with the encoded expression as data. See [Combinators](#combinators--computing-values) below.

Because combinators are stateless view targets, the periphery can evolve: old `Combinators` deployments never break (anything referencing them keeps working), and new versions ship at new addresses as pure opt-ins — all without ever touching the frozen core.

---

### Canonical addresses (same on every chain)

```
Assertions  v1.1  0xA55E47bFD3d20A76e8E63a173387A5e3d4bEe3e0   (frozen core)
Combinators v1.0  0xA55Ec0AA973C18Cb7D7874d4c52B663FFFf6b1dC   (versionable periphery)
```

Version 1.0 of the core remains deployed at [`assertions.eth`](https://etherscan.io/address/0xA55e4707A94Ce4Aa647517ed9aD4084e4E5D1f3F) (`0xA55e4707A94Ce4Aa647517ed9aD4084e4E5D1f3F`). Core v1.1 is a strict superset of the 1.0 ABI: it adds int256 assertions (including approximate equality), tuple index bounds checking, `CallFailed` on code-less targets, and the `Ne`/`Lt`/`Le` variants listed below. All composition functions live in the separate `Combinators` contract, which carries its own version line.

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
- **Combinators** - Navigated chained reads, arithmetic, logic, bitwise, hashing and string splitting composed via the separate `Combinators` contract's five functions
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

// Signed values work the same way (the tolerance is always a uint256)
assertions.assertApproxEqCallInt(
    oracleAddress,
    abi.encodeCall(IOracle.getFundingRate, ()),
    expectedRate,
    maxDeviation
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

Assertion functions revert or pass — they judge. Everything that *computes* lives in the separate `Combinators` contract (`0xA55Ec0AA973C18Cb7D7874d4c52B663FFFf6b1dC`): five composable functions, and nested `(target, data)` operands in calldata compose them into arbitrary expressions. The core consumes the result by pointing any call assertion at the Combinators address.

The core is frozen forever; Combinators is versionable. A future `Combinators` v2 would deploy at a new address without touching the core or breaking anything that references v1.

The whole surface is five functions — one read primitive and four operators:

```solidity
function read (address target, bytes[] calls, string[] retTypes, int256[][] paths) external view  // raw return
function calc (CalcOp op, address target1, bytes data1, address target2, bytes data2) external view returns (uint256)
function unary(UnaryOp op, address target, bytes callData) external view returns (uint256)
function data (DataOp op, address target, bytes[] calls, bytes arg, int256 index) external view   // raw return, per-op type
function env  (EnvOp op, uint256 arg) external view returns (uint256)
```

The op enums and their numeric encodings (what encoders put in calldata):

| Enum | Values |
|------|--------|
| `CalcOp` | `Add = 0`, `SAdd = 1`, `Sub = 2`, `SSub = 3`, `Mul = 4`, `SMul = 5`, `Div = 6`, `SDiv = 7`, `Mod = 8`, `SMod = 9`, `Exp = 10`, `Min = 11`, `SMin = 12`, `Max = 13`, `SMax = 14`, `AbsDiff = 15`, `SAbsDiff = 16`, `And = 17`, `Or = 18`, `Xor = 19`, `Shl = 20`, `Shr = 21`, `Eq = 22`, `Ne = 23`, `Lt = 24`, `SLt = 25`, `Gt = 26`, `SGt = 27`, `Le = 28`, `SLe = 29`, `Ge = 30`, `SGe = 31` |
| `UnaryOp` | `Not = 0` (bitwise complement), `IsZero = 1` (logical not), `Balance = 2`, `CodeHash = 3` (of the address the operand call returns) |
| `DataOp` | `Split = 0`, `Includes = 1`, `Charset = 2`, `Hash = 3`, `ByteLen = 4` |
| `EnvOp` | `Constant = 0`, `Timestamp = 1`, `BlockNumber = 2`, `ChainId = 3`, `Balance = 4`, `CodeHash = 5` |

Every word — uint, int (two's complement), bool (0/1), address, bytes32 — travels through `calc`/`unary`/`env` as a raw `uint256`; the *opcode* carries the signedness. `S`-prefixed calc ops are the signed variants with checked Solidity semantics; comparisons return 0/1 words. There is no `SExp` (Solidity defines `**` for unsigned operands only).

### Chained calls & navigation — `read`

`read` is THE read primitive: every way of getting a value out of contract state goes through it. `calls[0]` runs on `target`; for each earlier hop the word its path selects (a clean address word) becomes the next hop's target; the final hop's selection is returned via a raw assembly return — indistinguishable from a contract returning that value directly, so every call assertion (and every combinator consuming a nested `read`) decodes it as if it had called the final target itself.

`retTypes` and `paths` are parallel to `calls`, one entry per hop, and each hop is in one of two modes:

- **Raw** — `retTypes[i]` is `""` and `paths[i]` holds at most one signed raw word index into the returndata (negative from the end, `-1` = last word; empty defaults to word 0 mid-chain, and to a byte-for-byte returndata passthrough on the final hop). No decoding: word positions follow the raw ABI encoding, so dynamic types contribute head offsets, not content.
- **Typed** — `retTypes[i]` is the hop's return tuple written as a parenthesized type (structs as parenthesized tuples, e.g. `"((address,uint256)[])"`), and `paths[i]` walks it: the first step selects a return component, each further step indexes the current tuple or array (array steps accept negative indices resolved against the live length). The terminal may be a single word, or a dynamic value (string/bytes/array of static elements) returned as the canonical `[0x20][length][payload]` envelope. A typed path ending in the `LEN` sentinel (`type(int256).min`, exposed as the public constant `LEN`) returns the decoded *length* of the navigated dynamic value instead — element count for arrays, byte length for string/bytes.

"The pool's token has the symbol WETH" — a two-hop chain in raw passthrough mode:

```solidity
bytes[] memory hops = new bytes[](2);
hops[0] = abi.encodeCall(IPool.token, ());   // pool.token()   -> address of the token
hops[1] = abi.encodeCall(IERC20.symbol, ()); // token.symbol() -> asserted value
string[] memory retTypes = new string[](2);  // ["", ""]: raw mode throughout
int256[][] memory paths = new int256[][](2); // [[], []]: word 0 mid-chain, passthrough at the end

assertions.assertEqCallStringN(
    address(combinators),                                        // target: the Combinators contract
    abi.encodeCall(Combinators.read, (pool, hops, retTypes, paths)),
    0,                                                           // string returns decode at index 0
    "WETH"
);
```

In [EVMcrispr](https://evmcrispr.blossom.software) the same chain is written inline:

```
assertions:assert $pool::{token()(address)}::{symbol()(string)} == "WETH"
```

**Typed navigation** is self-describing calldata: `read(reg, calls, ["(address[][],address)"], [[0, 3, 1]])` reads as "return value 0, element 3, element 1". The contract derives every offset-follow and bounds check from the descriptor — parsing only the *shape* (dynamic vs static, head footprints, strides). Struct arrays navigate the same way: `proposals()[1].executed` against `"((address,uint256,bool)[])"` is path `[0, 1, 2]` — EVMcrispr's nested lens `[[_ [_ _ $]]]`. The declared type is the author's claim about the encoder, like an inline ABI: a wrong claim reverts loudly in almost all cases, but a shape-compatible wrong type can read the wrong value.

**Raw word extraction** (EVMcrispr's single-index lens, `[_ $ _]` or the end-anchored `[... $]`) is a final hop with `retTypes` `""` and a one-index path: `read(pair, [getReservesCall], [""], [[1]])` returns reserve1 as a word. It is raw-word extraction for static-layout returns, **not** an ABI decoder — to select *into* tuples and arrays, use a typed hop, which decodes as it goes.

**Nested lengths** (EVMcrispr's `@len!`): `read(reg, [holdersCall], ["(address[])"], [[0, LEN]])` returns the holder count as a word; because the sentinel composes with navigation, the length of an array *inside* a struct is one call too.

Failures are descriptive: a hop that reverts or targets a code-less address makes `read` revert with `CallFailed(target, data)` identifying the exact failing hop; array-length mismatches revert with `ArgumentCountMismatch`, a mid-chain selection with dirty upper bytes with `InvalidAddressWord`, a malformed descriptor or unrepresentable terminal with `InvalidNavigation`, a path index outside its tuple/array with `ElementIndexOutOfBounds`, and data not matching the declared shape (truncated returndata, out-of-range offsets or word indices) with `ReturnDataOutOfBounds`. An empty `calls` array reverts with `EmptyCallChain`.

### Arithmetic, comparison & logic — `calc`

Expressions over call results follow the same composition philosophy. Every operand is a `(target, data)` pair — and operands may themselves be calls to the Combinators contract (`read`, another `calc`, `unary`, `data`, `env`), so expressions nest recursively. One opcode enum covers arithmetic, bitwise and comparison: unsigned ops sit next to their `S`-prefixed signed variants (pick the signed opcode when either operand is an int), and comparisons return 0/1 so they feed straight into boolean composition (`And`/`Or`/`Xor` on 0/1 words) and `assertTrue`.

`AbsDiff`/`SAbsDiff` return the `|a - b|` magnitude as a `uint256` and are total — no underflow, no overflow revert on wide spans — so `AbsDiff(a, b) <= d` with a `Le` assertion expresses live-vs-live approximate equality. For `Shl`/`Shr` the second operand is the shift amount; shifts of 256 or more yield 0 (EVM shift semantics, no revert).

Value getters turn non-call quantities into operands: `env(Balance, addr)` (native balance), `env(Timestamp, 0)`, `env(BlockNumber, 0)`, `env(ChainId, 0)`, `env(CodeHash, addr)` (EXTCODEHASH: `bytes32(0)` for a nonexistent account, `keccak256("")` for an existing code-less one), and the literal echo `env(Constant, x)` for comparing a call result against a constant (signed literals pass as their two's-complement word). When the account is not known at encoding time, `unary(Balance, target, callData)` / `unary(CodeHash, target, callData)` return the native balance / code hash of the address the operand call returns — e.g. the balance of `registry.treasury()`, or the code hash of `proxy.implementation()`:

```solidity
// "The proxy's current implementation is the audited contract"
assertions.assertEqCallBytes32(
    address(combinators),
    abi.encodeCall(Combinators.unary, (
        Combinators.UnaryOp.CodeHash,
        proxy, abi.encodeCall(IProxy.implementation, ())
    )),
    auditedCodeHash
);
```

**Worked example** — "`addr1`'s ETH balance plus its WETH balance is positive":

```solidity
assertions.assertGtCallUint(
    address(combinators),
    abi.encodeCall(Combinators.calc, (
        Combinators.CalcOp.Add,
        address(combinators), abi.encodeCall(Combinators.env, (Combinators.EnvOp.Balance, uint256(uint160(addr1)))),
        weth,                abi.encodeCall(IERC20.balanceOf, (addr1))
    )),
    0
);
```

In EVMcrispr the same expression is written directly and compiles to nested `calc` calldata:

```
assertions:assert @num!(@balance!(ETH $addr1) + $weth::balanceOf($addr1)) > 0
```

**Logic example** — assertions revert on failure, so they cannot be OR-ed; a comparison opcode *returns* the outcome as a 0/1 word instead, and `And`/`Or`/`Xor` combine outcomes (on 0/1 words the bitwise and logical ops coincide). "`addr1` has ETH OR holds more than 10 tokens":

```solidity
bytes memory hasEth = abi.encodeCall(Combinators.calc, (
    Combinators.CalcOp.Gt,
    address(combinators), abi.encodeCall(Combinators.env, (Combinators.EnvOp.Balance, uint256(uint160(addr1)))),
    address(combinators), abi.encodeCall(Combinators.env, (Combinators.EnvOp.Constant, 0))
));
bytes memory hasTokens = abi.encodeCall(Combinators.calc, (
    Combinators.CalcOp.Gt,
    token,               abi.encodeCall(IERC20.balanceOf, (addr1)),
    address(combinators), abi.encodeCall(Combinators.env, (Combinators.EnvOp.Constant, 10))
));
assertions.assertEqCallBool(
    address(combinators),
    abi.encodeCall(Combinators.calc, (
        Combinators.CalcOp.Or,
        address(combinators), hasEth,
        address(combinators), hasTokens
    )),
    true
);
```

```
assertions:assert @bool!((@balance!(ETH $addr1) > 0) or ($token::balanceOf($addr1) > 10))
```

Boolean negation is `unary(IsZero, target, data)`; the bitwise complement is `unary(Not, target, data)`.

**Bitmask example** — flag checks on a packed config word, with `env(Constant, …)` supplying the mask or shift. "`config & MASK != 0`":

```solidity
assertions.assertNeCallUint(
    address(combinators),
    abi.encodeCall(Combinators.calc, (
        Combinators.CalcOp.And,
        configSource,        abi.encodeCall(IConfig.packedConfig, ()),
        address(combinators), abi.encodeCall(Combinators.env, (Combinators.EnvOp.Constant, MASK))
    )),
    0
);
```

And "bit `N` of the config is set" (`(config >> N) & 1 == 1`) nests a `Shr` inside an `And` the same way. In EVMcrispr bitwise expressions are `@bytes!(a "&" b)` (also `|`, `^`, `<<`, `>>`), `@not!(x)` is the complement, and single-arg `@bytes!(x)` is the raw-word cast (e.g. bool → 0/1).

### Returndata operations — `data`

`data(op, target, calls, arg, index)` operates on the raw returndata of a resolved call chain (hops here are plain calldata chaining through single-address returns; for a navigated chain, self-chain a `read` call). `arg` and `index` are per-op arguments; unused ones pass as `""` / `0`.

**Hashing complex returns** — when a function returns something the typed assertions can't decode (structs, arrays, long strings), `data(Hash, …)` returns `keccak256` of the final returndata so the existing bytes32 assertions can check it against a precomputed hash:

```solidity
bytes[] memory calls = new bytes[](1);
calls[0] = abi.encodeCall(IVault.getPosition, (positionId)); // returns a struct

assertions.assertEqCallBytes32(
    address(combinators),
    abi.encodeCall(Combinators.data, (
        Combinators.DataOp.Hash, vault, calls, "", 0
    )),
    keccak256(abi.encode(expectedAmount, expectedDebt, expectedOwner))
);
```

**String splitting** — `data(Split, target, calls, delimiter, index)` decodes the chain's final string return, splits it by the delimiter, and returns the `index`-th segment as a normal ABI-encoded string, so string assertions consume it directly. The index is an `int256`: 0-based from the start, or negative from the end (`-1` = last segment), resolved against the segment count at execution time — so "the name ends with LP" is delimiter `" "` with index `-1`, with no composition-time segment counting. "The second word of the pool's name is LP":

```solidity
bytes[] memory calls = new bytes[](1);
calls[0] = abi.encodeCall(IPool.name, ()); // "Curve LP Token"

assertions.assertEqCallStringN(
    address(combinators),
    abi.encodeCall(Combinators.data, (
        Combinators.DataOp.Split, pool, calls, " ", 1
    )),
    0,
    "LP"
);
```

```
assertions:assert @split!($pool::name() " " 1) == "LP"
```

Split semantics: the delimiter is a non-empty exact byte sequence (empty reverts with `EmptyDelimiter`); segments are the maximal runs between occurrences, so adjacent delimiters produce empty segments; a string that doesn't contain the delimiter is one segment (index 0 = index -1 = the whole string); and an index outside the segments in either direction (valid range `-segments .. segments-1`) reverts with `SegmentIndexOutOfBounds(index, segments)` — loud failure with the actual segment count. Version-string checks work the same way: split `"2.1.0"` by `"."` and assert segment 0 equals `"2"`.

**Substring & character-set checks** — two string predicates return a 0/1 word, so they compose with `calc`'s logic opcodes and `unary(IsZero, …)` and assert via `assertTrue` / `assertFalse`. `data(Includes, target, calls, part, 0)` is `String.includes`: whether the chain's final string return contains `part` as an exact byte sequence (case-sensitive, no wildcards; an empty `part` reverts with `EmptySubstring` since it would match everything). `data(Charset, target, calls, mask, 0)` is the character-class check that usually gets reached for with a regex: `mask` is a 32-byte set where bit `i` covers byte value `i` (any other `arg` length reverts with `InvalidMaskLength`), and the call returns whether every byte of the string is in the set. "The token's symbol is lowercase a-z":

```solidity
bytes[] memory calls = new bytes[](1);
calls[0] = abi.encodeCall(IERC20.symbol, ());

assertions.assertTrue(
    address(combinators),
    abi.encodeCall(Combinators.data, (
        Combinators.DataOp.Charset, token, calls,
        abi.encodePacked(bytes32(uint256(0x07fffffe) << 96)), // bits 97..122 = a-z
        0
    ))
);
```

Masks are built off-chain from ranges and single bytes (`a-z` is `0x07fffffe << 96`, digits OR in bits 48..57, `-` is bit 45). The check is byte-level, so multi-byte UTF-8 characters (every byte ≥ 0x80) fail any ASCII-only mask, and the empty string is vacuously in every set — combine with a `LEN` read `> 0` to also require non-empty. Anything needing positional structure ("exactly one dash, not at the start") is deliberately out of scope: an on-chain regex engine would make assertion calldata unreviewable.

**Returndata byte length** — `data(ByteLen, target, calls, "", 0)` (EVMcrispr's `@bytelen!`) returns the byte length of the final resolved returndata — a `uint256[]` with `n` items measures `64 + n * 32` (offset word + length word + items) — for size checks on returns that are not a single dynamic value. The decoded counterpart is `read`'s `LEN` sentinel (element count for arrays, byte length for string/bytes).

### More composition patterns

**Exponentiation & live decimals scaling** — `Exp = 10` in `CalcOp` gives checked `**` (overflow reverts with `Panic(0x11)`, `0 ** 0 == 1` per EVM semantics). There is no `SExp`: Solidity defines `**` for unsigned operands only, so signed exponentiation is ill-defined. The canonical use is scaling thresholds by a live `decimals()` (EVMcrispr's `@num!` with `^`): "`a` holds at least 5 whole tokens":

```solidity
bytes memory scale = abi.encodeCall(Combinators.calc, (        // 10 ** decimals()
    Combinators.CalcOp.Exp,
    address(combinators), abi.encodeCall(Combinators.env, (Combinators.EnvOp.Constant, 10)),
    token,                abi.encodeCall(IERC20.decimals, ())
));
bytes memory threshold = abi.encodeCall(Combinators.calc, (   // 5 * 10 ** decimals()
    Combinators.CalcOp.Mul,
    address(combinators), abi.encodeCall(Combinators.env, (Combinators.EnvOp.Constant, 5)),
    address(combinators), scale
));
assertions.assertEqCallBool(
    address(combinators),
    abi.encodeCall(Combinators.calc, (
        Combinators.CalcOp.Ge,
        token,                abi.encodeCall(IERC20.balanceOf, (a)),
        address(combinators), threshold
    )),
    true
);
```

```
assertions:assert $token::balanceOf($a) >= @num!(5 * 10 ^ $token::decimals())
```

**Conditional select** — bool returns are 0/1 words that feed straight into arithmetic (no bridging call), enabling an expression-level `if`: `cond * a + (1 - cond) * b` picks `a` when the condition holds and `b` otherwise, composed from three nested `calc` calls.

Nesting is unlimited — an operand can be a `read`, another `calc`, a comparison feeding an `Or`, and so on: `(pool.token().decimals() + x.value() == 60) && !protocol.paused()` is one `assertTrue` call.

**Expressing other things** — several patterns need no dedicated functions:

- **Address equality inside expressions**: address returns occupy a single word, so `calc(Eq, target, ownerCall, combinators, env(Constant, uint256(uint160(expectedAddr))))` compares them (the top-level `assertEqCallAddress` remains the direct form).
- **Bool constants**: a constant `true` operand is simply `env(Constant, 1)` — bools are 0/1 words.
- **String operations**: splitting is covered by `data(Split)`, substring search by `data(Includes)`, and only-these-characters checks by `data(Charset)`; concatenation and regex matching are deliberately not included — instead of building strings on-chain, compare the final value against a constant (`assertEqCallStringN`) or its hash (`data(Hash)`).

Semantics to know:

- **Checked arithmetic.** `calc` uses Solidity 0.8 semantics: overflow/underflow reverts with `Panic(0x11)` (including `Exp` overflow), division or modulo by zero with `Panic(0x12)`.
- **Signed semantics.** `SDiv` truncates toward zero (`45 / -7 == -6`), `SMod` takes the sign of the dividend (`45 % -7 == 3`, `-45 % 7 == -3`), and `type(int256).min / -1` reverts with `Panic(0x11)`. `AbsDiff`/`SAbsDiff` are total: they return the `uint256` magnitude and never revert on wide spans.
- **Raw words, opcode-carried signedness.** Operands are raw 32-byte words — there is no per-word validation, and bools are their 0/1 words. Use the `S`-prefixed opcode when an operand is signed.
- **No short-circuit.** Logic composition always evaluates both operands (they are view calls executed before the op is applied) — don't rely on `And`/`Or` to skip a reverting operand.
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
| `AssertionFailedApproxInt(string, int256, int256, uint256, uint256)` | approximate int256 equality failed |
| `CallFailed(address, bytes)` | staticcall to target reverted, or target has no code |
| `ReturnDataOutOfBounds(int256, uint256)` | tuple index points outside the returned data (int256 only to keep the signature identical to Combinators'; core indices are never negative) |

`Combinators`:

| Error | Description |
|-------|-------------|
| `CallFailed(address, bytes)` | a chain hop or expression operand reverted or targets a code-less address (identifies the exact failing call) |
| `ReturnDataOutOfBounds(int256, uint256)` | an operand or chain hop returned fewer than 32 bytes, data doesn't match a declared shape, or a raw word index (possibly negative) lies outside the returndata |
| `EmptyCallChain()` | `read` / `data` received an empty `calls` array |
| `ArgumentCountMismatch(uint256, uint256, uint256)` | `read`'s `calls`, `retTypes` and `paths` arrays disagree in length |
| `InvalidAddressWord(uint256, bytes32)` | a mid-chain `read` selection is not a clean address word (dirty upper bytes) — arguments: hop index and the offending word |
| `EmptyDelimiter()` | `data(Split)` received an empty delimiter |
| `EmptySubstring()` | `data(Includes)` received an empty search string (every string vacuously contains `""`) |
| `InvalidMaskLength(uint256)` | `data(Charset)` received a mask that isn't exactly 32 bytes |
| `ElementIndexOutOfBounds(int256, uint256)` | a typed `read` path index is outside the tuple or array it steps into (arguments: requested index as given — possibly negative — and the component/element count) |
| `InvalidNavigation(uint256)` | a typed `read` descriptor is malformed at the given character, a path step indexes a non-composite value, or the terminal is not representable |
| `SegmentIndexOutOfBounds(int256, uint256)` | `data(Split)` index is outside the split's segments in either direction (arguments: requested index as given — possibly negative — and segment count) |

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
| `assertApproxEqCallInt` | Assert return ≈ expected (within delta) |

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

### Raw Bytes Assertions

| Function | Description |
|----------|-------------|
| `assertEqCallBytes` | Assert raw returndata equals expected bytes |
| `assertNeCallBytes` | Assert raw returndata not equals expected bytes |

### Tuple-Indexed Assertions (N suffix)

All basic assertion types have tuple-indexed variants with an `N` suffix that accept an additional `index` parameter:

- `assertEqCallUintN`, `assertNeCallUintN`, `assertGtCallUintN`, `assertLtCallUintN`, `assertGeCallUintN`, `assertLeCallUintN`
- `assertEqCallIntN`, `assertNeCallIntN`, `assertGtCallIntN`, `assertLtCallIntN`, `assertGeCallIntN`, `assertLeCallIntN`
- `assertEqCallAddressN`, `assertNeCallAddressN`
- `assertEqCallBoolN`
- `assertEqCallBytes32N`, `assertNeCallBytes32N`
- `assertEqCallStringN`, `assertNeCallStringN`
- `assertApproxEqCallUintN`, `assertApproxEqCallIntN`

An `index` that points past the returned data reverts with `ReturnDataOutOfBounds` instead of silently comparing against zeroed memory.

### Array Assertions

| Function | Description |
|----------|-------------|
| `assertEqCallArrayLength` | Assert array length equals expected |
| `assertNeCallArrayLength` | Assert array length not equals expected |
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

These live at the Combinators address (`0xA55Ec0AA973C18Cb7D7874d4c52B663FFFf6b1dC`), not on the core. See [Combinators — computing values](#combinators--computing-values) for usage.

| Function | Description |
|----------|-------------|
| `read` | THE read primitive: resolve a chain of staticcalls with per-hop typed navigation (`retTypes`/`paths`) and return the final selection raw — passthrough (empty path), raw word extraction (`""` type + word index), typed navigation into tuples/arrays (declared return tuple + index path, negative array indices from the end), dynamic terminals as canonical single-value returns, and decoded lengths via the `LEN` sentinel |
| `calc` | Binary word operation over two `(target, data)` operands, one `CalcOp` enum: checked arithmetic (Add…Exp, Min/Max) with `S`-prefixed signed variants, total `AbsDiff`/`SAbsDiff` magnitudes, bitwise And/Or/Xor/Shl/Shr, and 0/1-returning comparisons (Eq…SGe) |
| `unary` | Unary word operation over one operand (`UnaryOp`): Not (bitwise complement), IsZero (logical not), Balance / CodeHash of the address the operand call returns |
| `data` | Raw-returndata operation over a resolved chain (`DataOp`): Split (delimiter + signed segment index), Includes (substring), Charset (32-byte byte-class mask), Hash (keccak256), ByteLen |
| `env` | Constants and environment values as operands (`EnvOp`): Constant echo (ints as two's-complement words), Timestamp, BlockNumber, ChainId, Balance(addr), CodeHash(addr — EXTCODEHASH, `bytes32(0)` if the account doesn't exist) |

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
