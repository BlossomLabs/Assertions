---
codename: Byakko
version: "2.0"
status: released
date: "2026-10-09"
summary: Four contracts and a documentation rewrite built around EVML. Assertions is the main contract; Operations, Collections and Expressions are its expansion packs.
banner: byakko
order: 2
---

Byakko is the second release of **Assertions**, and the first with four contracts: Assertions and its expansion packs **Operations**, **Collections** and **Expressions**. All four are stateless and view-only, each at the same address on every chain, and each versions on its own.

| Contract | Address | Release name | Bare name |
| --- | --- | --- | --- |
| Assertions | `0xa55e47C835ACD377da79D57162117D9B5Ecf3496` | `byakko.assertions.eth` | `assertions.eth` |
| Operations | `0x09e4a7eF82674BaDD27a02E19f3D3e5a1903eA1f` | `operations.byakko.assertions.eth` | `operations.assertions.eth` |
| Collections | `0xc011ec7f6fAAaa37DE5923D2c6206C9597D16bc7` | `collections.byakko.assertions.eth` | `collections.assertions.eth` |
| Expressions | `0xe5594e55aCa44ac271209612FA57866130edC9e5` | `expressions.byakko.assertions.eth` | `expressions.assertions.eth` |

- **Version:** 2.0, all four contracts, released on October 9, 2026
- **Preceded by:** [Argos](/releases/argos) (v1)

A release name is permanent. A bare name follows the latest release, so it moves when a new one ships. Per-chain availability is on [Deployments](/docs/contracts/deployments).

## What it can do

Where Argos compared one read with a constant, Byakko can put a live value on both sides: compare two reads, do arithmetic on them, follow an address from one contract into another, fall back when a read reverts, and check every item of a list.

### Assertions, the main contract

Assertions judges a live value against constraints in the [ERC-8211](https://eips.ethereum.org/EIPS/eip-8211) wire format and reads values out of other contracts. It carries eleven primitives that work on reads before they are resolved:

- **Select:** `resolve`, `gather`, `pick` and `nav`, which walks tuples and arrays by type and can return a string's length or its raw payload.
- **Build calls:** `chain` follows addresses read at execution time, `read` splices live values into a call, and `get` builds a call from whole values, resolving each argument once.
- **Branch:** `cond` takes the branch that holds, `orElse` falls back when a read fails, `isValid` asks whether a read succeeds, and `revertData` reads why a call reverts.

Constraints cover equality, unsigned and signed comparisons, ranges, `OR` and `SKIP`.

### The expansion packs

- **Operations** is the most used pack: arithmetic, 512-bit and fixed-point math, comparisons such as `!=`, bytes and strings, hashing, parsing and formatting numbers, and block and transaction fields.
- **Collections** manages arrays: check every or any element, find, filter, sort, deduplicate and total the lists that contracts return, in one call.
- **Expressions** deduplicates calculations: define a read or a calculation once and reuse the result, with lazy branches and guarded fallbacks.

## What it lacks

- **Formal verification.** It is under way, not finished. Everything the contracts are meant to do is written down as 331 numbered claims. Of those, 145 are formally verified within stated bounds, 44 are partially verified, and 139 rest on tests alone. A second track, proving that the Solidity source and the compiled bytecode match an independent model, is incomplete. Nobody outside the project has audited the contracts. They hold no funds and write no state, so a bug produces a wrong answer, not a theft. [Towards formal verification](/docs/contracts/verification) lists every claim, its evidence and what is not proved.
- **A value saved mid-batch.** The contracts keep nothing between calls, so a check cannot read a value before an action and compare with it after. To assert that something changed, the starting value has to be fixed when the script is built, and it may be stale by the time a delayed batch executes.
- **A finished builder.** The contracts are final, but the [Assertion Builder](/builder) is in beta: it is still under active development, so expect changes and fixes.
- **An assertion viewer.** There is no tool yet that takes a batch and shows what its assertions check. A signer who has only the calldata decodes it by hand, the way [Reviewing an assertion](/docs/reviewing) describes.

## How Byakko came to be

Argos did one thing: compare a read with a constant. The first plan was to patch it. A version 1.1 fixed its two known errors and added signed integers, and a second contract was written beside it for calculations. Neither was deployed.

The patch could not give what people asked for next, which was a live value on both sides of a comparison. That needed the checks themselves to be data, not one function per case. Byakko takes that format from [ERC-8211](https://eips.ethereum.org/EIPS/eip-8211), so an assertion written for it is encoded the way the standard's reference implementation encodes it.

The work was paid for by the donations and matching of TheDAO Security Fund's [Ethereum Security round](https://qf.giveth.io/project/assertionseth-on-chain-transaction-guards-for-ethereum?roundId=16) on Giveth: the fund that Argos's first transaction launched.

## The name

Byakko is the Japanese name of the White Tiger, Báihǔ in Chinese: one of the four creatures that guard the four directions of the sky. The tiger keeps the west, and its season is autumn. This release came out in it.

In the old Chinese romances the guardian sometimes comes down and is born as a man. The best known is Xue Rengui. The emperor of Tang first sees him in a dream: a soldier in white who rides out, saves his life, and is gone before he can ask his name.

The man exists, but a jealous officer hides him among the army's cooks and gives the credit for his victories to another. So for years the emperor is guarded by someone he has never seen. He learns who it was on the day the dream comes true.

Japan took the guardian without ever seeing the animal: there have never been tigers there. Byakko has kept the west all the same. He is on the west wall of the Kitora tomb, painted thirteen centuries ago, and when Kyoto was founded the great road on its west side was counted as his. At Kurama, in the hills north of the city, the pair that guards the temple hall are not the usual lion-dogs. They are tigers.
