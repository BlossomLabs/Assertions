// SPDX-License-Identifier: MIT
// Extensional byte-span equality isolated from arithmetic/opcode contexts.
module AssertionsConstraintSequences {
  lemma Extensional<T>(left: seq<T>, right: seq<T>)
    requires |left| == |right|
    requires forall i {:trigger left[i]} :: 0 <= i < |left| ==> left[i] == right[i]
    ensures left == right
  {}
  lemma Span<T>(left: seq<T>, right: seq<T>, start: nat, other: nat, length: nat)
    requires start+length <= |left| && other+length <= |right|
    requires forall i {:trigger left[start+i]} {:trigger right[other+i]} :: 0 <= i < length ==> left[start+i] == right[other+i]
    ensures left[start..start+length] == right[other..other+length]
  {
    var a := left[start..start+length];
    var b := right[other..other+length];
    assert |a| == length && |b| == length;
    forall i {:trigger a[i]} | 0 <= i < length
      ensures a[i] == b[i]
    {
      assert left[start+i] == right[other+i];
      assert a[i] == left[start+i];
      assert b[i] == right[other+i];
    }
    Extensional(a,b);
  }
}
