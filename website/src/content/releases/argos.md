---
codename: Argos
version: "1.0"
status: released
summary: The original Assertions contract, written and deployed for TheDAO Security Fund transaction.
banner: argos
order: 1
---

Argos is the first release of **Assertions**. It was written and deployed for one transaction: the [TheDAO Security Fund launch](/#featured) featured on the homepage.

## How it started

In January 2026 TheDAO's curators were preparing a single Safe batch that would move 71,202 ETH and the multisig's remaining DAO tokens. A batch like that cannot be redone, and a simulation only describes the chain as it was when it ran.

PC, one of TheDAO's curators, proposed having some way to assert that the transaction had gone through as intended. Sem, the author of Assertions, answered with a general solution instead of a check written for that one batch: a contract of view-only assertions that anyone can append to any batch, so that the whole transaction reverts if one of them does not hold.

## The first use

The batch executed on January 29, 2026. Its last nine calls went to Argos, and they checked the balances at every destination, that the sources were drained, and that the whitelist flags were set. All nine held, and the transaction landed.

## What came after

The fund that transaction launched later came back around. Assertions took part in TheDAO Security Fund's [Ethereum Security round](https://qf.giveth.io/project/assertionseth-on-chain-transaction-guards-for-ethereum?roundId=16), a quadratic funding round on Giveth, and the donations and matching from it funded the work on the next release, [Byakko](/releases/byakko).

## Where it is

Argos is a single contract at `0xA55e4707A94Ce4Aa647517ed9aD4084e4E5D1f3F`, reachable as `argos.assertions.eth` and listed on [Deployments](/docs/contracts/deployments) as the earlier release.

It stays where it is. Later releases ship at new addresses as opt-ins, so anything that references Argos by address or by that name keeps working. The bare name `assertions.eth` was Argos until Byakko; it now follows the latest release.
