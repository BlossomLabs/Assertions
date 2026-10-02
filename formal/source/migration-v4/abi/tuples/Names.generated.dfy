// SPDX-License-Identifier: MIT
// Generated from the separately SMT-verified 96-name whitelist.
include "Words.dfy"

module AbiTupleNames {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiWordSemantics

  opaque function Rule(name: seq<Byte>): WordRule
  {
    if name == [117,105,110,116,56] then Unsigned(8) else
    if name == [117,105,110,116,49,54] then Unsigned(16) else
    if name == [117,105,110,116,50,52] then Unsigned(24) else
    if name == [117,105,110,116,51,50] then Unsigned(32) else
    if name == [117,105,110,116,52,48] then Unsigned(40) else
    if name == [117,105,110,116,52,56] then Unsigned(48) else
    if name == [117,105,110,116,53,54] then Unsigned(56) else
    if name == [117,105,110,116,54,52] then Unsigned(64) else
    if name == [117,105,110,116,55,50] then Unsigned(72) else
    if name == [117,105,110,116,56,48] then Unsigned(80) else
    if name == [117,105,110,116,56,56] then Unsigned(88) else
    if name == [117,105,110,116,57,54] then Unsigned(96) else
    if name == [117,105,110,116,49,48,52] then Unsigned(104) else
    if name == [117,105,110,116,49,49,50] then Unsigned(112) else
    if name == [117,105,110,116,49,50,48] then Unsigned(120) else
    if name == [117,105,110,116,49,50,56] then Unsigned(128) else
    if name == [117,105,110,116,49,51,54] then Unsigned(136) else
    if name == [117,105,110,116,49,52,52] then Unsigned(144) else
    if name == [117,105,110,116,49,53,50] then Unsigned(152) else
    if name == [117,105,110,116,49,54,48] then Unsigned(160) else
    if name == [117,105,110,116,49,54,56] then Unsigned(168) else
    if name == [117,105,110,116,49,55,54] then Unsigned(176) else
    if name == [117,105,110,116,49,56,52] then Unsigned(184) else
    if name == [117,105,110,116,49,57,50] then Unsigned(192) else
    if name == [117,105,110,116,50,48,48] then Unsigned(200) else
    if name == [117,105,110,116,50,48,56] then Unsigned(208) else
    if name == [117,105,110,116,50,49,54] then Unsigned(216) else
    if name == [117,105,110,116,50,50,52] then Unsigned(224) else
    if name == [117,105,110,116,50,51,50] then Unsigned(232) else
    if name == [117,105,110,116,50,52,48] then Unsigned(240) else
    if name == [117,105,110,116,50,52,56] then Unsigned(248) else
    if name == [105,110,116,56] then Signed(8) else
    if name == [105,110,116,49,54] then Signed(16) else
    if name == [105,110,116,50,52] then Signed(24) else
    if name == [105,110,116,51,50] then Signed(32) else
    if name == [105,110,116,52,48] then Signed(40) else
    if name == [105,110,116,52,56] then Signed(48) else
    if name == [105,110,116,53,54] then Signed(56) else
    if name == [105,110,116,54,52] then Signed(64) else
    if name == [105,110,116,55,50] then Signed(72) else
    if name == [105,110,116,56,48] then Signed(80) else
    if name == [105,110,116,56,56] then Signed(88) else
    if name == [105,110,116,57,54] then Signed(96) else
    if name == [105,110,116,49,48,52] then Signed(104) else
    if name == [105,110,116,49,49,50] then Signed(112) else
    if name == [105,110,116,49,50,48] then Signed(120) else
    if name == [105,110,116,49,50,56] then Signed(128) else
    if name == [105,110,116,49,51,54] then Signed(136) else
    if name == [105,110,116,49,52,52] then Signed(144) else
    if name == [105,110,116,49,53,50] then Signed(152) else
    if name == [105,110,116,49,54,48] then Signed(160) else
    if name == [105,110,116,49,54,56] then Signed(168) else
    if name == [105,110,116,49,55,54] then Signed(176) else
    if name == [105,110,116,49,56,52] then Signed(184) else
    if name == [105,110,116,49,57,50] then Signed(192) else
    if name == [105,110,116,50,48,48] then Signed(200) else
    if name == [105,110,116,50,48,56] then Signed(208) else
    if name == [105,110,116,50,49,54] then Signed(216) else
    if name == [105,110,116,50,50,52] then Signed(224) else
    if name == [105,110,116,50,51,50] then Signed(232) else
    if name == [105,110,116,50,52,48] then Signed(240) else
    if name == [105,110,116,50,52,56] then Signed(248) else
    if name == [98,121,116,101,115,49] then HighBytes(1) else
    if name == [98,121,116,101,115,50] then HighBytes(2) else
    if name == [98,121,116,101,115,51] then HighBytes(3) else
    if name == [98,121,116,101,115,52] then HighBytes(4) else
    if name == [98,121,116,101,115,53] then HighBytes(5) else
    if name == [98,121,116,101,115,54] then HighBytes(6) else
    if name == [98,121,116,101,115,55] then HighBytes(7) else
    if name == [98,121,116,101,115,56] then HighBytes(8) else
    if name == [98,121,116,101,115,57] then HighBytes(9) else
    if name == [98,121,116,101,115,49,48] then HighBytes(10) else
    if name == [98,121,116,101,115,49,49] then HighBytes(11) else
    if name == [98,121,116,101,115,49,50] then HighBytes(12) else
    if name == [98,121,116,101,115,49,51] then HighBytes(13) else
    if name == [98,121,116,101,115,49,52] then HighBytes(14) else
    if name == [98,121,116,101,115,49,53] then HighBytes(15) else
    if name == [98,121,116,101,115,49,54] then HighBytes(16) else
    if name == [98,121,116,101,115,49,55] then HighBytes(17) else
    if name == [98,121,116,101,115,49,56] then HighBytes(18) else
    if name == [98,121,116,101,115,49,57] then HighBytes(19) else
    if name == [98,121,116,101,115,50,48] then HighBytes(20) else
    if name == [98,121,116,101,115,50,49] then HighBytes(21) else
    if name == [98,121,116,101,115,50,50] then HighBytes(22) else
    if name == [98,121,116,101,115,50,51] then HighBytes(23) else
    if name == [98,121,116,101,115,50,52] then HighBytes(24) else
    if name == [98,121,116,101,115,50,53] then HighBytes(25) else
    if name == [98,121,116,101,115,50,54] then HighBytes(26) else
    if name == [98,121,116,101,115,50,55] then HighBytes(27) else
    if name == [98,121,116,101,115,50,56] then HighBytes(28) else
    if name == [98,121,116,101,115,50,57] then HighBytes(29) else
    if name == [98,121,116,101,115,51,48] then HighBytes(30) else
    if name == [98,121,116,101,115,51,49] then HighBytes(31) else
    if name == [97,100,100,114,101,115,115] then Address else
    if name == [98,111,111,108] then Boolean else
    if name == [102,117,110,99,116,105,111,110] then Function else
    Opaque
  }

  lemma RuleClassified(name: seq<Byte>)
    ensures ClassifiedRule(Rule(name))
  { reveal Rule(); }
}
