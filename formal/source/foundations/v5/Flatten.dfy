// SPDX-License-Identifier: MIT
module SourceFlattenV5 {
  function Flatten<T>(values: seq<seq<T>>): seq<T>
    decreases |values|
  { if |values| == 0 then [] else values[0]+Flatten(values[1..]) }
  lemma Append<T>(a: seq<seq<T>>,b: seq<seq<T>>)
    ensures Flatten(a+b) == Flatten(a)+Flatten(b)
    decreases |a|
  {
    if |a| > 0 {
      assert (a+b)[0] == a[0] && (a+b)[1..] == a[1..]+b;
      Append(a[1..],b);
    }
  }
}
