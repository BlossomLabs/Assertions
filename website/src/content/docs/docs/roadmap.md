---
title: Roadmap
description: From checks that guard a single batch to protections that guard every transaction an account sends.
---

Today, with [Byakko](/releases/byakko) (v2.0), an assertion guards the batch it is written into. A DAO proposal, a Safe batch or an EIP-7702 wallet batch can check live values when it executes: compare two reads, do arithmetic on them, follow an address from one contract into another, fall back when a read reverts, and check every item of a list. If a check fails, the batch reverts. Assertions and its three expansion packs are stateless and view-only, at the same address on every chain, and the [Assertion Builder](/builder) writes the checks in EVML.

Two things are out of reach. A check cannot keep a value from before an action to compare with after it, so a starting value has to be fixed when the script is built. And an assertion protects only the batch that carries it: a transaction written by someone else, or signed without looking, carries none. The next two releases address those gaps, in that order. Nothing below is a commitment: each release ships at new addresses as an opt-in, and earlier releases stay where they are.

## Cerberus (v2.1)

[Cerberus](/releases/cerberus) is in progress. It adds state that lasts for one transaction, assertions that stay on an account, and a way to read what a transaction checks.

- **Notations** keeps a value from one point of a transaction to a later one. A batch notes a read before an action, and an assertion after it compares with the note: "the balance dropped by at most 1,000". It can also work a value out with Solidity, loops included, in code that runs once and is thrown away, or deploy reusable helpers at an address fixed by their bytecode. It is the first contract in the suite that writes state, and what it writes lasts only until the end of the transaction. ([#10](https://github.com/BlossomLabs/Assertions/issues/10))
- **Protections** keeps assertions on an account, so every transaction is checked, whoever built it. The account's assertions compile to a checker, a small contract that takes a snapshot before each transaction and judges the state after it. It installs as a Safe v1.5.0 guard, for owner and module transactions, and as an ERC-7579 hook module. An account type is supported only when its hooks pass a published admission test, so a protection cannot be bypassed by a path the hook never sees. ([#14](https://github.com/BlossomLabs/Assertions/issues/14))
- **The Assertion Viewer** shows the assertions of a pending or executed transaction, or kept on a Safe, as plain sentences rebuilt from chain data rather than from the author's description. When the author shares the EVML, the Viewer compiles it and compares the result with the transaction byte for byte, so a signer knows the text they read is what they sign. ([#13](https://github.com/BlossomLabs/Assertions/issues/13))

The four existing contracts stay view-only, and their addresses do not move.

## Dharmapala (v3.0)

[Dharmapala](/releases/dharmapala) is planned. It builds on three Ethereum proposals that are still drafts: frame transactions ([EIP-8141](https://eips.ethereum.org/EIPS/eip-8141)), assertions over a transaction's state diff ([EIP-7906](https://eips.ethereum.org/EIPS/eip-7906)), and disabling an account's ECDSA key ([EIP-7851](https://eips.ethereum.org/EIPS/eip-7851)). It ships only once they are final, and the project feeds its findings back to their authors.

- **Only what you allow can change.** In a frame transaction, checks can run in a final read-only step that sees everything the transaction changed: balances, storage, code, nonces and events, each with its value before and after. Assertions v3 turns that into a policy. Instead of listing what must be true, the signer lists what is allowed to change, and anything else about their account fails the transaction. A wallet can show it as one statement: "this transaction may lower your USDC by up to 1,000, and changes nothing else of yours." An approval the user never meant to give, or a swapped EIP-7702 delegate, fails the check. ([#16](https://github.com/BlossomLabs/Assertions/issues/16))
- **Save a value now, check it at the end.** A frame transaction can save a value at any of its steps, such as a price before a swap or a position after a deposit, and its final checks compare against it. Notations writes the value to a log, which is still there when the final step runs. Balances and storage need no saving: the final step already sees their values from before the transaction.
- **Protections for frame transactions.** The final step of a frame transaction can judge every protected account the transaction touched, against a list of what each one may change. A Safe can refuse to act in any transaction that leaves out that step. Then a delegatecall that quietly changes the Safe's settings, for example by planting approvals for a later withdrawal, fails even if nobody thought to forbid it. Everyone who makes a protected Safe act, from the relayer that submits it to a module, has to send frame transactions. An existing EOA can delegate to a reference account that approves only transactions carrying the check. Once the account disables its old ECDSA key, no signature can skip it. ([#17](https://github.com/BlossomLabs/Assertions/issues/17))

## Following along

Each item above links to the issue where it is designed, and the issues are grouped by release in the [Cerberus](https://github.com/BlossomLabs/Assertions/milestone/1) and [Dharmapala](https://github.com/BlossomLabs/Assertions/milestone/2) milestones. Designs change there first: questions, use cases and objections are welcome on the issues themselves, and each release page here is updated once its contents are settled.
