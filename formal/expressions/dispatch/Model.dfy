module GuardedDispatch {
  type Byte = x: int | 0 <= x < 256
  datatype Site = GenericCall | GenericProbe | GuardHelper | ForeignCaller
  datatype Request = Request(site: Site, selfTarget: bool, data: seq<Byte>)

  predicate NamesGuard(data: seq<Byte>, selector: seq<Byte>)
    requires |selector| == 4
  {
    |data| >= 4 && data[..4] == selector
  }

  // EVM caller projection: a direct call made by this evaluator has self
  // as sender; a foreign account/contract is distinct from this evaluator.
  predicate SenderIsSelf(site: Site) {
    site != ForeignCaller
  }

  predicate Allowed(r: Request, selector: seq<Byte>)
    requires |selector| == 4
  {
    r.site in {GuardHelper, ForeignCaller} ||
    !(r.selfTarget && NamesGuard(r.data, selector))
  }

  predicate Entered(r: Request, selector: seq<Byte>)
    requires |selector| == 4
  {
    Allowed(r, selector) && r.selfTarget && NamesGuard(r.data, selector) && SenderIsSelf(r.site)
  }

  lemma OnlyGuardHelper(r: Request, selector: seq<Byte>)
    requires |selector| == 4
    requires Entered(r, selector)
    ensures r.site == GuardHelper
  {}

  lemma EveryEnteredFrame(trace: seq<Request>, selector: seq<Byte>)
    requires |selector| == 4
    ensures forall i | 0 <= i < |trace| && Entered(trace[i], selector) :: trace[i].site == GuardHelper
  {
    forall i | 0 <= i < |trace| && Entered(trace[i], selector)
      ensures trace[i].site == GuardHelper
    {
      OnlyGuardHelper(trace[i], selector);
    }
  }

  lemma TrustedCallRemainsPossible(selector: seq<Byte>, payload: seq<Byte>)
    requires |selector| == 4
    ensures Entered(Request(GuardHelper, true, selector + payload), selector)
  {}

  lemma OtherTargetsRemainAllowed(site: Site, data: seq<Byte>, selector: seq<Byte>)
    requires |selector| == 4
    ensures Allowed(Request(site, false, data), selector)
  {}
}
