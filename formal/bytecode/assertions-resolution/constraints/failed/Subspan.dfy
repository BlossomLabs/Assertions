// SPDX-License-Identifier: MIT
// Pure sequence subspan preservation, isolated from all physical memory models.
include "../Sequences.dfy"
module AssertionsConstraintFalseSubspan {
  import Q = AssertionsConstraintSequences
  lemma Transfer<T>(left: seq<T>, right: seq<T>, start: nat, size: nat, offset: nat, length: nat)
    requires start+size <= |left| && start+size <= |right| && offset+length <= size
    requires left[start..start+size] == right[start..start+size]
    ensures left[start+offset..start+offset+length] == right[start+offset..start+offset+length]
  {
    var a := left[start..start+size]; var b := right[start..start+size];
    assert a == b;
    forall i: nat {:trigger left[start+offset+i]} | i < length
      ensures left[start+offset+i] == right[start+offset+i]
    {
      assert offset+i < size;
      assert a[offset+i] == left[start+offset+i];
      assert b[offset+i] == right[start+offset+i];
      assert a[offset+i] == b[offset+i];
    }
    Q.Span(left,right,start+offset,start+offset,length);
  }
}
