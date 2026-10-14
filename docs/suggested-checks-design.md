# Suggested checks in the builder: design note

EVMcrispr's `simulate({ suggest })` returns `assert` lines that pin down what
a run did. The builder offers them after a passing simulation of the protected
batch; the user picks which to add. Nothing is added without a click.

## Asking

`useSimulation` (`SimulationPanel.tsx`) is the one place the builder's stages
simulate. It passes `suggest` only for a key in `actions-only` mode: step 1's
run of the actions on their own suggests; the protected batch of step 2,
whose checks are the ones being added, and the chat's own simulations do not
ask.

The option is `{ executor: key.from }`: the account the batch is simulated as,
which is what `SimKey` already carries. That is `executorAddress()` for a
wallet, a Safe, an Aragon OSx DAO and a Governor without a timelock, and the
timelock for a Governor that has one (`simulationSender`): the timelock is the
account that makes the calls and holds the funds, so its balances are the ones
to guard. Without an executor the option is plain `true`. A wallet batch adds
`exact: true`: it executes as soon as it is signed, so amounts are asserted at
what the run left. `suggestOption(key, context)` in `suggested-checks.ts`
decides this.

## Where the list sits

Step 2 (Assertions), block "Checks", at the top, above the form that builds a
check by hand. The box holds the suggestions and the assistant's "Suggest
more assertions", which is disabled until the batch has a fresh passing
simulation (step 1's or the protected one) and the assistant is logged in
to Dappnode Nexus; the line beside it says which is missing.

## State

No new React state. The list is derived, on every render, from step 1's
simulation state and the protected batch's key (`suggestedChecks(state,
key)`):

- Null (the box asks for step 1's simulation) until that run passed, for the
  same executor and chain as now.
- Every suggestion of the run is listed, in order, once, each marked
  `inBatch` when a command of the script means the same (by `lineMeaning`;
  the native floor by `withoutBound`). A row in the batch offers Remove
  (`suggestionSpan`, then `removeCommand`, which takes the variables only it
  used), any other Add.
- `stale` when the actions changed since the run (compared by meaning, loads,
  variables pinned to an address and checks aside). The rows stay, marked as
  from an earlier simulation: which checks to keep is the user's call, and
  checks already accepted are never taken out by an edit of the actions.
- A run that suggested nothing says so; a result without the field reads as
  one.

Step 1's passing run adds its suggestions to the batch itself
(`applySuggestions`, through `scriptState.applySuggestionRun`), each line
marked by its comment: `  # suggested`, or `· suggested` added to the comment
it has (`# base units of $weth · suggested`). The mark is what makes a check
the builder's to manage; comments do not count in a line's meaning, so it
changes nothing that compares lines.

- On each passing run: a marked check the run suggests again stays; one it
  no longer suggests, or suggests with another number, goes (with the
  variables only it used); a new suggestion is added, marked, at the end
  (`addLine`'s path: the script's variable names, its `set` lines, the
  module `load`).
- A suggestion the user took out after the last run (it was applied and is
  gone, by the row's Remove or the listing's bin) is not added back while
  the run still suggests it; its row offers Add.
- The user's checks are never touched: those without the mark, those whose
  mark was taken off (the row's Keep, `unmarkSuggested`, or by editing the
  comment), and a marked check edited by hand (none of the last run's
  suggestions): the next run takes its mark off.
- Another executor or chain: the checks still marked go (`withoutSuggested`).
- A run that could not vouch for its suggestions changes nothing.
- After a reload the builder no longer knows the last run: the mark alone
  says what is managed.

Adding or removing changes the script, so the protected simulation is stale
again (ring, Submit gate): the added checks have to be simulated like any
other.

## The block

A check suggested from one fork of the latest block can fail seconds later
on another, when the account is busy. So step 1's run reads the chain's
latest block (the same client and endpoint the fork uses, `cacheTime: 0`)
just before it runs and passes it as `blockNumber`; its state keeps `block`
and `blockReadAt`. The protected simulation gets that state (`suggestedBy`)
and `confirmationBlock(state, key, now)` gives the block back while the
actions are the ones step 1 ran, the batch holds at least one of its
suggestions, and the block was read at most five minutes ago
(`PIN_MAX_AGE_MS`). Such a run is `pinned` and its result line says "· at
block 21 234 567". Anything else reads the latest block again.

## Copy

- Heading: "Suggested checks"
- Under it, by state: "Simulate the batch in step 1 to see the checks it
  suggests." (no passing run yet); "This simulation suggested no checks.";
  "No checks suggested: <why>" (the run could not vouch for them);
  otherwise "Drawn from what the simulation of step 1 did: read each one
  before adding it."
- When the actions changed since the run: "The actions changed since these
  were suggested: simulate the batch in step 1 again to update them."
- Per row: the sentence (see "Sentences and variables") ending in an (i)
  button ("About this check"), a "Show code" / "Hide code" toggle, and
  "Add" (accessible name "Add check: <description>") or, once the batch
  holds it, "Remove" ("Remove check: <description>").
- Behind the (i), in a popover (one open at a time; Escape or a click
  outside closes it; the last row's opens upward, the step clips below):
  - The source line: "Suggested by USDC's Transfer event", from the
    suggestion's `emitterName` and `eventName` (`suggestionSource`), the
    name linked to the emitter on the chain's explorer with the full
    address as its `title`. For the chain's own currency (`std:native`,
    `std:nativeBalance`), which has no event: "Suggested by the
    simulation's balance changes".
  - Notices (`checkNotices`), plain text: on an `amount` row in a Safe,
    Governor or Aragon OSx context, "This account can move these funds
    before the proposal executes." for a recipient's floor, "Anyone can send
    it some before the proposal executes." for an emptied account's `== 0`,
    else what the amount is a number of ("The allowance may change…",
    "Balances may change…", "This amount may change…"). The executor's own
    native floor, in every context: "Other transactions from this account
    change this balance: the check fails if it falls below the floor."
- Under a row's sentence, links with their icon: "Show code" / "Hide code"
  (an eye), and for a check in the batch "Keep" (a pin; "Keep check:
  <description>") while it has the mark, "Unkeep" (the pin struck through;
  "Unkeep check: <description>") once it has not. Keep takes the mark off,
  so later runs leave the check as it is; Unkeep puts it back
  (`markCommand`), so they manage it again. Remove or Add on the right.
- The batch listings write each line as the script does: comments, the
  `# suggested` mark among them, dimmed.
- When the run reported truncation: "The simulation did more than was looked
  at: this list may be incomplete."
- "✦ Suggest more assertions", with beside it: "Simulate the batch in step 1
  first." / "The batch changed since its last simulation: simulate it again
  first." / "Log in to Dappnode Nexus in the assistant panel to use it." /
  what the assistant does, when it can be used.

## Sentences and variables

Since EVMcrispr returns a `sentence` and a line over `vars`:

- **The row** draws `sentenceView(check, chainId)`: text as it is, each
  address an `AddressLink` (shortened address, or the name when the token
  list vouches for it, or "NAME (0x1234…abcd)" when only the contract
  does), each token amount its text with the symbol inside it linked to the
  token. The native currency is not linked. The EVML is behind "Show code":
  the `set` lines the check still needs in this script, then its line. A
  suggestion without `sentence` shows its description as before.
- **Adding** goes through `prepareSuggestion(script, check)` and then
  `insertAssertion(line, "post", sets)`. An address the script already sets
  a variable to is referred to by that variable; a name the script gives to
  something else is left to it and the new variable takes `name2`,
  `name3`…; anything else keeps its name and gets a `set`. The rename is
  one pass over the line, so swapped names cannot chase each other (which
  is why it does not call `renameSuggestionVariable` in sequence). `set`
  lines land in the script's header, loads are derived and deduplicated by
  the existing insertion path, and `gcScaffolding` removes a variable with
  the last command that used it.
- **Comparing** is by meaning: `lineMeaning` replaces a line's variables
  with the addresses they stand for (the script's `set $x 0x…` lines on one
  side, the suggestion's `vars` on the other). "Already in the script",
  "the simulated script plus suggested lines", the one-native-floor rule
  and the confirmation block all use it, so a renamed or reused variable
  changes nothing.
- **The listing** shows variables pinned to an address once, above the
  commands, as "Addresses" (`$name` and the shortened, linked address), and
  not again as rows. Other `set` lines (an ENS lookup) stay rows.
- **The final script** has those `set` lines above the wrapper, after the
  loads (`hoistLoads`), except one whose name the wrapper's own ENS
  variable uses, which stays in the block.

## Composed actions

The contract form writes its `exec` through the same binding
(`bindVariables` in `script-ops.ts`, which `prepareSuggestion` delegates
to): `composeCall` (`compose-call.ts`) returns a line with a placeholder
per address and the name each would like, and `useScriptState.appendWithSets`
binds it against the script and inserts it with the checks' insertion path.
Names: the token list's symbol for a listed token (`symbolInList`, the
upstream rule), else the ABI parameter's name for an argument unless that
word is a listed symbol elsewhere, else `contract` / `address`; never
anything a contract says of itself. For `transfer`, `approve` and
`transferFrom` (full signature) on a target that answers `decimals()`, the
amount typed in base units becomes `@token:amount($token <exact>)`; dust,
the max uint and anything not a whole number of base units stay as typed.
The form only adds and removes: a removed action takes the variables only
it used, and a new recipient gets its own variable while the old one is
still in use.

## Modules asked

Only modules registered with the builder's tag (`evml.ts`) are asked. `ens`
and `proxies` are registered for that. `proxies` is also in the helper
registries (`helper-owners.ts`), since its suggestions use
`@proxies:implementation!`, `@proxies:admin!` and `@proxies:beacon!`: the
`load proxies` line is derived and hidden like any helper load, and the
reference page lists its four faces. `ens` is not: its suggestions are plain
`::!` calls, and its `@owner!` would be a second owner of acl's.

## Not in this change

The chat panel's simulations do not ask for suggestions.
