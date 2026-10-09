# Executor behaviour tests

Assertions is a view contract: a batch is protected only if the executor makes
a failing call fail the whole batch. These tests establish, per executor, what
actually happens when an `assertParam` with a failing constraint sits next to a
state-changing call. Each failing scenario has a passing twin that differs only
in the constraint's reference word (asserted value 5; fail needs `>= 10`, pass
needs `>= 3`), and each is run with the assertion both after and before the
`target.set(1)` call.

## Running

```sh
# Governor tests: fully local, no network.
FOUNDRY_PROFILE=executors forge test

# Safe tests: Gnosis chain fork (chain id 100). Skipped when the variable is unset.
GNOSIS_RPC_URL=https://rpc.gnosischain.com FOUNDRY_PROFILE=executors forge test
```

`[profile.executors]` in `foundry.toml` selects this directory. This forge
(1.5.1) has no `--profile` flag on `forge test`; the profile is chosen with the
`FOUNDRY_PROFILE` environment variable. The default `forge test` does not see
these files.

## What each file establishes

- `GovernorExecution.t.sol`: OpenZeppelin Governor 5.6.1 (Governor +
  GovernorSettings + GovernorCountingSimple + GovernorVotes over an ERC20Votes
  token), plain and with GovernorTimelockControl + TimelockController. A
  proposal `[target.set(1), assertions.assertParam(...)]` is proposed, voted,
  (queued,) and executed. Asserts the bubbled `ConstraintFailed` fields
  (`"PARAM"`, entry 0, param 0, constraint 0, `GTE`, actual 5, reference 10),
  the counter, and the proposal/timelock state afterwards.
- `SafeMultiSend.t.sol`: Safe v1.3.0 and v1.4.1 (canonical Gnosis deployments:
  proxy factory, singleton, MultiSendCallOnly and MultiSend, each checked for
  code and by `VERSION()` on the singleton and the created proxy). A 1-owner Safe
  executes a DELEGATECALL to MultiSend(CallOnly) with
  `[set(1), assertParam]` through `execTransaction` using a pre-validated
  signature (`approveHash`, `v = 1`), with `safeTxGas = 0` and `safeTxGas > 0`.

## Observed results

| Executor | Scenario | Observed |
| --- | --- | --- |
| Governor (plain) | failing assertion, after or before `set` | `execute` reverts with the assertion's `ConstraintFailed` data bubbled unchanged; counter stays 0; proposal stays `Succeeded` (not `Executed`) |
| Governor (plain) | passing assertion, either order | `execute` succeeds; counter 1; proposal `Executed` |
| Governor + timelock | failing assertion, after or before `set` | `execute` reverts with `ConstraintFailed` bubbled unchanged; counter stays 0; proposal stays `Queued`; timelock operation still pending, not done |
| Governor + timelock | same, driving `TimelockController.executeBatch` directly | reverts with `ConstraintFailed`; counter 0 |
| Governor + timelock | passing assertion, either order | succeeds; counter 1; proposal `Executed` |
| Safe 1.3.0 and 1.4.1, MultiSendCallOnly and MultiSend | failing assertion, `safeTxGas = 0` | `execTransaction` reverts with `Error("GS013")`; the assertion's own revert data is not surfaced; counter 0; nonce not consumed |
| Safe 1.3.0 and 1.4.1, MultiSendCallOnly and MultiSend | failing assertion, `safeTxGas > 0` | `execTransaction` returns `false`, emits `ExecutionFailure`, consumes the nonce; counter 0 (MultiSend's revert undid the earlier call) |
| Safe 1.3.0 and 1.4.1, MultiSendCallOnly and MultiSend | passing assertion, either order, either `safeTxGas` | returns `true`, emits `ExecutionSuccess`; counter 1 |

No executor tested keeps the earlier action after a failed assertion. The
guarantee for Safe comes from MultiSend reverting the whole batch on any inner
failure; with `safeTxGas > 0` the caller must still check the returned `false`
(the transaction itself does not revert, and the nonce is spent).

## Not covered

Only Safe on Gnosis chain is forked; Safe on other chains, other MultiSend
variants, Safe modules/guards, and other timelock-style executors are not tested.
