include "Control.generated.dfy"
module OperationsReplaceConnection {
  import M = OperationsReplaceModel
  import W = OperationsWordMatchModel
  import S = OperationsReplaceSource
  ghost method Replace(s: seq<bv8>,needle: seq<bv8>,repl: seq<bv8>,sOffset: nat,needleOffset: nat,outsideS: seq<bv8>,outsideNeedle: seq<bv8>,ptr: nat) returns (out: M.Outcome)
    requires |s|+1 < W.Half && |needle| < W.Half && |repl| < W.Word
    requires |outsideS| == 32 && |outsideNeedle| == 32
    requires sOffset+|s|+32 < W.Word && needleOffset+|needle|+32 < W.Word
    requires 128 <= ptr && ptr%32 == 0
    requires |needle| > 0 && M.Length(s,needle,repl) < W.Word ==> ptr+64+M.Length(s,needle,repl) < W.Word
    ensures out == M.Spec(s,needle,repl)
  { out := S.Replace(s,needle,repl,sOffset,needleOffset,outsideS,outsideNeedle,ptr); }
}
