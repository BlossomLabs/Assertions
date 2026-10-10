---
codename: Argos
version: "1.0"
status: released
summary: The original Assertions contract, written and deployed for TheDAO Security Fund transaction.
banner: argos
order: 1
---

Argos is the first release of **Assertions**: a single contract of view-only assertions that anyone can append to a batch, so that the whole transaction reverts if one of them does not hold.

- **Address:** `0xA55e4707A94Ce4Aa647517ed9aD4084e4E5D1f3F`
- **ENS name:** `argos.assertions.eth`
- **First used:** January 29, 2026, in the [TheDAO Security Fund launch](/#featured)
- **Succeeded by:** [Byakko](/releases/byakko) (v2)

Argos stays where it is. Later releases ship at new addresses as opt-ins, so anything that references Argos by address or by that name keeps working. The bare name `assertions.eth` was Argos until Byakko; it now follows the latest release. Argos is listed on [Deployments](/docs/contracts/deployments) as the earlier release.

## What it can do

Argos has 98 functions: 49 checks, each with a variant that takes a message. Every check reads one value and compares it with a value fixed in the calldata.

- **A value returned by a call:** unsigned integers (equal, not equal, greater, less, or within a tolerance), addresses and `bytes32` (equal or not), booleans, and the whole return data as bytes.
- **One value out of several:** when a function returns more than one value, a check picks one by position: an unsigned integer, an address, a boolean, a `bytes32` or a string.
- **The length of a returned array:** equal, greater, or greater or equal.
- **Chain state:** an account's native balance, the block number and timestamp, the chain ID, and whether an address has code or a given code hash.

## What it lacks

Two known errors, both in what Argos accepts:

- **A position that does not exist.** The checks that pick a value by position do not verify that the position is inside the returned data. Past the end, the check reads memory that the call never returned and judges that.
- **A target with no code.** A call to an address that holds no contract succeeds and returns nothing. The single-value checks then revert without a reason, and the by-position and array-length checks read data that is not there, as above.

And what it never had:

- **Signed integers.** No check reads an `int256`. A negative number read as unsigned is a very large one, so greater and less give the wrong answer on it.
- **Some combinations.** There is no "not equal" for the whole return data, for an array length, or for an unsigned integer, `bytes32` or string picked by position, and no "less than" for an array length.
- **A second live value.** A check compares one read with a constant. It cannot compare two reads, do arithmetic on them, follow an address from one contract into another, or look at each item of a list.

A version 1.1 was written to fix the two errors and fill the first two gaps. It was never deployed: the third gap needed a different design, which became [Byakko](/releases/byakko). [Migrating from Argos (v1)](/docs/migration) covers the move.

## How Argos came to be

In January 2026 TheDAO's curators were preparing a single Safe batch that would move 71,202 ETH and the multisig's remaining DAO tokens. The curators would sign it one by one, and it would execute only after the last signature. What they could check beforehand was a simulation, and a simulation describes the chain as it was when it ran, not as it will be when the batch executes.

PC, one of TheDAO's curators, proposed having some way to assert that the transaction had gone through as intended. Sem, the author of Assertions, answered with a general solution instead of a check written for that one batch: a contract of view-only assertions that anyone can append to any batch, so that the whole transaction reverts if one of them does not hold.

## The transaction

The batch had to take six accounts from one state to another, and leave nothing in between.

| Account | Before | After |
| --- | --- | --- |
| [Old multisig](https://etherscan.io/address/0xDa4a4626d3E16e094De3225A751aAb7128e96526), the curators' wallet from 2016 | 719.09 ETH and 387,684.63 DAO | no ETH and no DAO tokens |
| [ExtraBalance](https://etherscan.io/address/0x755cdba6AE4F479f7164792B318b2a06c759833B), the contract that pays out open claims | 70,483.24 ETH | exactly 1,300 ETH |
| [TheDAO](https://etherscan.io/address/0xBB9bc244D798123fDe783fCc1C72d3Bb8C189413), holding some of its own tokens | 2,960.35 DAO tokens | no DAO tokens |
| [Security Fund Safe](https://etherscan.io/address/0x5256d6d94eD14667fa1661a99F5B142B1e051B8e) | empty | 719.09 ETH and 390,644.98 DAO |
| [Staking Safe](https://etherscan.io/address/0x52016A661a6cd35d88d30297E8840998ac3Db756), which endows the fund | 0.0000101 ETH | at least 69,183.24 ETH |
| [Curators' Safe](https://etherscan.io/address/0x47b7655Ee0fde88819F4d83B20A60223e5C6377D), which sends the batch | no ETH | no ETH |

Two tokens, DGD and SAI, also had to become allowed recipients in TheDAO.

Ten calls do the work. The curators' Safe sends every one of them through the old multisig:

1. Lift the old multisig's daily spending limit.
2. Send its 719.09 ETH to the Security Fund Safe.
3. Call `clawback()` on ExtraBalance, which returns 70,483.24 ETH to the old multisig.
4. Send 69,183.24 ETH of that to the Staking Safe.
5. Send the other 1,300 ETH back to ExtraBalance.
6. Move the 2,960.35 DAO that TheDAO holds to the Security Fund Safe.
7. Move the old multisig's 387,684.63 DAO to the Security Fund Safe.
8. Allow DGD as a recipient.
9. Allow SAI as a recipient.
10. Set the daily limit to zero.

Nine more calls, all to Assertions, state most of the right-hand column of the table:

- ExtraBalance holds exactly 1,300 ETH.
- The Staking Safe holds at least 69,183.24 ETH.
- The Security Fund Safe holds exactly 719.09 ETH.
- The curators' Safe holds no ETH.
- The Security Fund Safe holds exactly 390,644.98 DAO.
- TheDAO holds none of its own tokens.
- The old multisig holds no DAO.
- DGD is an allowed recipient.
- SAI is an allowed recipient.

Each amount is checked to the wei. If one of the nine had not held, the other eighteen calls would have reverted with it.

The batch [executed on January 29, 2026](https://etherscan.io/tx/0x462475a38cd8a3b75b2732db28ea21a7addfce059af03ea4f638f461c707bf10). All nine held.

The fund that transaction launched later came back around. Assertions took part in TheDAO Security Fund's [Ethereum Security round](https://qf.giveth.io/project/assertionseth-on-chain-transaction-guards-for-ethereum?roundId=16), a quadratic funding round on Giveth, and the donations and matching from it funded the work on the next release, [Byakko](/releases/byakko).

## The name

Releases of Assertions are named after guardians from myth. Argos is the first.

Argos Panoptes, "the all-seeing", is a giant of Greek myth with eyes all over his body. The oldest account gives him four, looking every way. Ovid gives him a hundred.

Before he was anyone's watchman, he kept Arcadia. A bull was laying the country waste: he killed it and wore its hide. A satyr was stealing the herds: he stood in his way and killed him. Echidna, who carried off travellers on the road, he caught asleep.

Later Hera had something that needed watching, and gave it to him. An old poem says of that watch: "sleep never fell upon his eyes; but he kept sure watch always."
