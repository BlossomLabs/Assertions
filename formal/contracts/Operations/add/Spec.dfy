// SPDX-License-Identifier: MIT
include "../../../shared/abi/Encoding.dfy"

module CheckedAddSpec {
  import opened Int
  import AbiEncoding

  datatype Outcome = Returned(data: seq<u8>) | Reverted(data: seq<u8>)

  function Unsigned(a: int, b: int): Outcome
    requires 0 <= a < AbiEncoding.Modulus && 0 <= b < AbiEncoding.Modulus
  {
    var sum := a + b;
    if sum < AbiEncoding.Modulus then Returned(AbiEncoding.Word(sum))
    else Reverted(AbiEncoding.Panic11())
  }

  function Signed(a: int, b: int): Outcome
    requires -AbiEncoding.SignedLimit <= a < AbiEncoding.SignedLimit
    requires -AbiEncoding.SignedLimit <= b < AbiEncoding.SignedLimit
  {
    var sum := a + b;
    if -AbiEncoding.SignedLimit <= sum < AbiEncoding.SignedLimit
    then Returned(AbiEncoding.Word(AbiEncoding.TwosComplement(sum)))
    else Reverted(AbiEncoding.Panic11())
  }
}
