include "Control.generated.dfy"
module OperationsWordMatchConnection {
  import M = OperationsWordMatchModel
  import S = OperationsWordMatchSource
  method Contains(s: seq<bv8>,needle: seq<bv8>,sOffset: nat,needleOffset: nat,outsideS: seq<bv8>,outsideNeedle: seq<bv8>) returns (found: bool)
    requires |s| < M.Half && |needle| < M.Half
    requires |outsideS| == 32 && |outsideNeedle| == 32
    requires sOffset+|s|+32 < M.Word && needleOffset+|needle|+32 < M.Word
    ensures found == M.Contains(s,needle)
  { found := S.Contains(s,needle,sOffset,needleOffset,outsideS,outsideNeedle); }
}
