include "Origin.generated.dfy"
include "Coinbase.generated.dfy"
include "rejections/Nonzero.generated.dfy"
include "rejections/Short.generated.dfy"
module OperationsAddressEnvironmentConnection {
  import opened OperationsAddressEnvironmentMachine
  import O = OperationsAddressEnvironmentOrigin
  import C = OperationsAddressEnvironmentCoinbase
  import N = OperationsAddressEnvironmentRawNonzero
  import S = OperationsAddressEnvironmentRawShort
  function DataWord(data: seq<Byte>,offset: nat): Word { Load(data,offset) }
  predicate Frame(data: seq<Byte>) { |data| < 0x10000000000000000 }
  function RawStep(code: seq<Byte>, destinations: set<nat>, state: State,value: Word,data: seq<Byte>,world: World): State
    requires Frame(data)
  { Step(code,destinations,state,value,|data| as Word,DataWord(data,0),world) }
  predicate Assigned(selector: Word) { selector in {2475384626,2796423852} }
  function Expected(selector: Word,world: World): Word { if selector == 2475384626 then world.origin else if selector == 2796423852 then world.coinbase else 0 }
  opaque predicate Matches(code: seq<Byte>) { O.Matches(code) && C.Matches(code) && N.Matches(code) && S.Matches(code) }
  ghost method Run(code: seq<Byte>,value: Word,data: seq<Byte>,world: World) returns (state: State)
    requires Frame(data) && Matches(code)
    requires value != 0 || |data| < 4 || Assigned(Selector(DataWord(data,0)))
    ensures value != 0 || |data| < 4 ==> state == Reverted([])
    ensures value == 0 && |data| >= 4 ==> state == Returned(Encode(Expected(Selector(DataWord(data,0)),world),32))
  {
    reveal Matches(); var size := |data| as Word; var word := DataWord(data,0);
    LoadProjection(data,0);
    if value != 0 { state := N.Run(code,value,size,word,world); }
    else if size < 4 { state := S.Run(code,value,size,word,world); }
    else if Selector(word) == 2475384626 { state := O.Run(code,value,size,word,world); }
    else { state := C.Run(code,value,size,word,world); }
  }
}
