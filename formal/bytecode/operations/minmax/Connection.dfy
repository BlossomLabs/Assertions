include "MinUT.generated.dfy"
include "MinUF.generated.dfy"
include "rejections/MinUArgs.generated.dfy"
include "MinST.generated.dfy"
include "MinSF.generated.dfy"
include "rejections/MinSArgs.generated.dfy"
include "MaxUT.generated.dfy"
include "MaxUF.generated.dfy"
include "rejections/MaxUArgs.generated.dfy"
include "MaxST.generated.dfy"
include "MaxSF.generated.dfy"
include "rejections/MaxSArgs.generated.dfy"
include "rejections/Nonzero.generated.dfy"
include "rejections/Short.generated.dfy"
module OperationsMinMaxConnection {
  import opened OperationsMinMaxMachine
  import MinUT = OperationsMinMaxMinUT
  import MinUF = OperationsMinMaxMinUF
  import MinUA = OperationsMinMaxRawMinUArgs
  import MinST = OperationsMinMaxMinST
  import MinSF = OperationsMinMaxMinSF
  import MinSA = OperationsMinMaxRawMinSArgs
  import MaxUT = OperationsMinMaxMaxUT
  import MaxUF = OperationsMinMaxMaxUF
  import MaxUA = OperationsMinMaxRawMaxUArgs
  import MaxST = OperationsMinMaxMaxST
  import MaxSF = OperationsMinMaxMaxSF
  import MaxSA = OperationsMinMaxRawMaxSArgs
  import Nonzero = OperationsMinMaxRawNonzero
  import Short = OperationsMinMaxRawShort
  function DataWord(data: seq<Byte>,offset: nat): Word { Load(data,offset) }
  predicate Frame(data: seq<Byte>) { |data| < 0x10000000000000000 }
  function RawStep(code: seq<Byte>,destinations: set<nat>,state: State,value: Word,data: seq<Byte>): State
    requires Frame(data)
  { Step(code,destinations,state,value,|data| as Word,DataWord(data,0),DataWord(data,4),DataWord(data,36)) }
  predicate Assigned(selector: Word) { selector in {2061678023,699047102,1834234854,2180929414} }
  function Expected(selector: Word,a: Word,b: Word): Word {
    if selector == 2061678023 then (if a < b then a else b)
    else if selector == 699047102 then (if Signed(a) < Signed(b) then a else b)
    else if selector == 1834234854 then (if a > b then a else b)
    else if selector == 2180929414 then (if Signed(a) > Signed(b) then a else b)
    else 0
  }
  opaque predicate Matches(code: seq<Byte>) { MinUT.Matches(code) && MinUF.Matches(code) && MinST.Matches(code) && MinSF.Matches(code) && MaxUT.Matches(code) && MaxUF.Matches(code) && MaxST.Matches(code) && MaxSF.Matches(code) && MinUA.Matches(code) && MinSA.Matches(code) && MaxUA.Matches(code) && MaxSA.Matches(code) && Nonzero.Matches(code) && Short.Matches(code) }
  ghost method Run(code: seq<Byte>,value: Word,data: seq<Byte>) returns (state: State)
    requires Frame(data) && Matches(code)
    requires value != 0 || |data| < 4 || Assigned(Selector(DataWord(data,0)))
    ensures value != 0 || |data| < 68 ==> state == Reverted([])
    ensures value == 0 && |data| >= 68 ==> state == Returned(Encode(Expected(Selector(DataWord(data,0)),DataWord(data,4),DataWord(data,36)),32))
  {
    reveal Matches(); var size := |data| as Word; var word := DataWord(data,0);
    var a := DataWord(data,4); var b := DataWord(data,36);
    LoadProjection(data,0); LoadProjection(data,4); LoadProjection(data,36);
    if value != 0 { state := Nonzero.Run(code,value,size,word,a,b); }
    else if size < 4 { state := Short.Run(code,value,size,word,a,b); }
    else if size < 68 {
      if Selector(word) == 2061678023 { state := MinUA.Run(code,value,size,word,a,b); }
      else if Selector(word) == 699047102 { state := MinSA.Run(code,value,size,word,a,b); }
      else if Selector(word) == 1834234854 { state := MaxUA.Run(code,value,size,word,a,b); }
      else { state := MaxSA.Run(code,value,size,word,a,b); }
    }
    else if Selector(word) == 2061678023 {
      if a < b { state := MinUT.Run(code,value,size,word,a,b); }
      else { state := MinUF.Run(code,value,size,word,a,b); }
    }
    else if Selector(word) == 699047102 {
      if Signed(a) < Signed(b) { state := MinST.Run(code,value,size,word,a,b); }
      else { state := MinSF.Run(code,value,size,word,a,b); }
    }
    else if Selector(word) == 1834234854 {
      if a > b { state := MaxUT.Run(code,value,size,word,a,b); }
      else { state := MaxUF.Run(code,value,size,word,a,b); }
    }
    else {
      if Signed(a) > Signed(b) { state := MaxST.Run(code,value,size,word,a,b); }
      else { state := MaxSF.Run(code,value,size,word,a,b); }
    }
  }
}
