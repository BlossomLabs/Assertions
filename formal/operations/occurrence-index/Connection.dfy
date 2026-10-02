include "Control.generated.dfy"
module OperationsOccurrenceConnection {
  import M = OperationsOccurrenceModel
  import W = OperationsWordMatchModel
  import S = OperationsOccurrenceSource
  method Index(s: seq<bv8>,needle: seq<bv8>,occurrence: int,sOffset: nat,needleOffset: nat,outsideS: seq<bv8>,outsideNeedle: seq<bv8>) returns (out: nat)
    requires -W.Half <= occurrence < W.Half
    requires |s|+1 < W.Half && |needle| < W.Half
    requires |outsideS| == 32 && |outsideNeedle| == 32
    requires sOffset+|s|+32 < W.Word && needleOffset+|needle|+32 < W.Word
    ensures out == M.Index(s,needle,occurrence) && out <= |s|
  { out := S.Index(s,needle,occurrence,sOffset,needleOffset,outsideS,outsideNeedle); M.IndexBounds(s,needle,occurrence); }
}
