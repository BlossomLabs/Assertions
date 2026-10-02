/*
 * Copyright 2022 ConsenSys Software Inc.
 * Licensed under the Apache License, Version 2.0.
 * See ../upstream/evm-dafny-e2e52e86/source/LICENSE for the full license.
 * Adapted from DafnyEVM arrays.dfy at e2e52e86d6623d48d0849f5ce1664f88c8f0e547.
 * Only generic sequence operations are selected; Int and its axioms are not imported.
 */
module SharedFoundationSequenceCopy {
  predicate EqualsExcept<T(==)>(lhs: seq<T>, rhs: seq<T>, address: nat, length: nat)
    requires address+length <= |lhs|
  {
    |lhs| == |rhs| && lhs[..address] == rhs[..address] &&
    lhs[address+length..] == rhs[address+length..]
  }
  opaque function Copy<T>(src: seq<T>, dst: seq<T>, start: nat): (result: seq<T>)
    requires start+|src| <= |dst|
    ensures |result| == |dst|
    ensures src == result[start..start+|src|]
    ensures EqualsExcept(dst,result,start,|src|)
  {
    var end := start+|src|;
    seq(|dst|, i requires 0 <= i < |dst| => if start <= i < end then src[i-start] else dst[i])
  }
  function SliceAndPad<T>(mem: seq<T>, address: nat, length: nat, padding: T): (result: seq<T>)
    ensures |result| == length
  {
    var end := address+length;
    if end <= |mem| then mem[address..end]
    else if address < |mem| then mem[address..]+seq(end-|mem|, i => padding)
    else seq(length, i => padding)
  }
}
