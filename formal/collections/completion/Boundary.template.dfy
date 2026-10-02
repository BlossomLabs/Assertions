// SPDX-License-Identifier: MIT
// Generated from the gated full Collections AST and compiler ABI method identifiers.
module CollectionsCompletionBoundary {
  datatype Entry = $ENTRIES$
  datatype Route = Unknown | Known(entry: Entry)

  function Selector(e: Entry): nat
    ensures Selector(e) < 0x100000000
  {
    match e
$SELECTORS$
  }
  function Arity(e: Entry): nat {
    match e
$ARITIES$
  }
  function Outputs(e: Entry): nat {
    match e
$OUTPUTS$
  }
  function View(e: Entry): bool {
    match e
$VIEWS$
  }
  function RouteFor(s: nat): Route {
$ROUTES$
  }

  lemma RoundTrip(e: Entry)
    ensures RouteFor(Selector(e)) == Known(e)
    ensures 1 <= Arity(e) <= 7
    ensures Outputs(e) == 1
  {
    match e {
$ROUNDTRIP_CASES$
    }
  }

  lemma Sound(s: nat)
    ensures RouteFor(s).Known? ==> Selector(RouteFor(s).entry) == s
  {}

  lemma Distinct(a: Entry, b: Entry)
    requires Selector(a) == Selector(b)
    ensures a == b
  {
    RoundTrip(a);
    RoundTrip(b);
  }

  lemma Complete(s: nat, e: Entry)
    requires Selector(e) == s
    ensures RouteFor(s) == Known(e)
  { RoundTrip(e); }

  lemma UnknownIsUnassigned(s: nat, e: Entry)
    requires RouteFor(s) == Unknown
    ensures Selector(e) != s
  { RoundTrip(e); }
}
