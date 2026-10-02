include "BlockHash.generated.dfy"
include "rejections/BlockHashArgs.generated.dfy"
include "BlobHash.generated.dfy"
include "rejections/BlobHashArgs.generated.dfy"
include "rejections/Nonzero.generated.dfy"
include "rejections/Short.generated.dfy"
module OperationsIndexedEnvironmentConnection {
  import opened OperationsIndexedEnvironmentMachine
  import BH = OperationsIndexedEnvironmentBlockHash
  import BlockHashA = OperationsIndexedEnvironmentRawBlockHashArgs
  import VH = OperationsIndexedEnvironmentBlobHash
  import BlobHashA = OperationsIndexedEnvironmentRawBlobHashArgs
  import N = OperationsIndexedEnvironmentRawNonzero
  import S = OperationsIndexedEnvironmentRawShort
  function DataWord(data: seq<Byte>, offset: nat): Word { Load(data,offset) }
  predicate Frame(data: seq<Byte>,world: World) { |data| < 0x10000000000000000 && |world.blobHashes| < 0x10000000000000000 && HistoryComplete(world) }
  function RawStep(code: seq<Byte>,destinations: set<nat>,state: State,value: Word,data: seq<Byte>,world: World): State
    requires Frame(data,world)
  { Step(code,destinations,state,value,|data| as Word,DataWord(data,0),DataWord(data,4),world) }
  function Expected(selector: Word,world: World,index: Word): Word {
    if selector == 2246005245 then BlockHash(world,index)
    else if selector == 195382834 then BlobHash(world,index) else 0
  }
  predicate Assigned(selector: Word) { selector in {2246005245,195382834} }
  opaque predicate Matches(code: seq<Byte>) { BH.Matches(code) && VH.Matches(code) && N.Matches(code) && S.Matches(code) && BlockHashA.Matches(code) && BlobHashA.Matches(code) }
  ghost method Run(code: seq<Byte>,value: Word,data: seq<Byte>,world: World) returns (state: State)
    requires Frame(data,world) && Matches(code)
    requires value != 0 || |data| < 4 || Assigned(Selector(DataWord(data,0)))
    ensures value != 0 || |data| < 36 ==> state == Reverted([])
    ensures value == 0 && |data| >= 36 ==> state == Returned(Encode(Expected(Selector(DataWord(data,0)),world,DataWord(data,4)),32))
  {
    reveal Matches();
    var size := |data| as Word; var word := DataWord(data,0); var a := DataWord(data,4);
    LoadProjection(data,0); LoadProjection(data,4);
    if value != 0 { state := N.Run(code,value,size,word,a,world); }
    else if size < 4 { state := S.Run(code,value,size,word,a,world); }
    else if size < 36 {
      if Selector(word) == 2246005245 { state := BlockHashA.Run(code,value,size,word,a,world); }
      else { state := BlobHashA.Run(code,value,size,word,a,world); }
    }
    else if Selector(word) == 2246005245 { state := BH.Run(code,value,size,word,a,world); }
    else { state := VH.Run(code,value,size,word,a,world); }
  }
}
