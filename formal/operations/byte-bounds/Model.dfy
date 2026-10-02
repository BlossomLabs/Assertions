module OperationsByteBoundsModel {
  const Mod: int := 0x10000000000000000000000000000000000000000000000000000000000000000
  const Half: int := 0x8000000000000000000000000000000000000000000000000000000000000000
  predicate Word(n: int) { 0 <= n < Mod }
  predicate Signed(n: int) { -Half <= n < Half }
  function UCast(n: int): int { n % Mod }
  function ICast(n: int): int { if n % Mod < Half then n % Mod else n % Mod-Mod }
  datatype BytesOutcome = Ok(value: seq<bv8>) | Range(start: int, length: int, total: int) | InvalidByteIndex(index: int,total: int)
  datatype IndexOutcome = Position(position: int) | Invalid(index: int,length: int)
  function Clamp(index: int,len: int): int { if index < 0 then if len+index < 0 then 0 else len+index else if index > len then len else index }
  function Power(n: nat): int
    ensures Power(n) > 0
  { if n == 0 then 1 else 256*Power(n-1) }
  function WordBytes(n: int): seq<bv8>
    requires Word(n)
    ensures |WordBytes(n)| == 32
  { seq(32,i requires 0 <= i < 32 => ((n / Power(31-i)) % 256) as bv8) }
  function Hash(h: imap<seq<bv8>,bv256>,data: seq<bv8>): bv256
    requires data in h
  { h[data] }
}
