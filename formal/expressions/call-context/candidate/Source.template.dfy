include "Model.dfy"
// Isolated candidate source hash: $HASH
// Source gate pins the whole normalized Expressions contract after removing
// the two optional first-statement dispatch checks. Only those presence bits
// vary in the source fault campaign. No recursive evaluator theorem is claimed.
module GuardedDispatchSource {
  import M = GuardedDispatch

  function CheckPublicCall(selfTarget: bool, data: seq<M.Byte>, selector: seq<M.Byte>): bool
    requires |selector| == 4
  {
    !(selfTarget && |data| >= 4 && data[..4] == selector)
  }

  method Dispatch(r: M.Request, selector: seq<M.Byte>) returns (allowed: bool)
    requires |selector| == 4
    ensures allowed == M.Allowed(r, selector)
  {
    if r.site == M.GenericCall {
      allowed := $CALL_CHECK;
    } else if r.site == M.GenericProbe {
      allowed := $PROBE_CHECK;
    } else {
      allowed := true;
    }
  }

  method AcceptGuardedFrame(r: M.Request, selector: seq<M.Byte>) returns (entered: bool)
    requires |selector| == 4
    ensures entered == M.Entered(r, selector)
    ensures entered ==> r.site == M.GuardHelper
  {
    var allowed := Dispatch(r, selector);
    entered := allowed && r.selfTarget && M.NamesGuard(r.data, selector) && M.SenderIsSelf(r.site);
    if entered { M.OnlyGuardHelper(r, selector); }
  }
}
