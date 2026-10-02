// SPDX-License-Identifier: MIT
// Calldata behavior specification for an admitted RAW nav call with an empty path.
include "development/decoder-v7/Admission.dfy"
include "development/dispatch-v5/Dispatch.dfy"
include "development/setup-v1/Setup.dfy"
include "../assertions-resolution/raw/Raw.generated.dfy"
module AssertionsNavigationRawCaseAdmission {
  import S = BytecodeScanMachine
  import I = AssertionsNavigationDecoderAdmission
  import P = AssertionsNavigationDispatch
  import A = AssertionsNavigationSetup
  import R = AssertionsRawResolve
  import M = AssertionsRawResolveMemory
  import Q = BytecodeScanRepresentation
  type Byte = S.Byte
  type Word = S.Word
  predicate Calldata(data: seq<Byte>,value: Word,bytesRelative: Word,constraintsRelative: Word,length: Word) {
    I.Admitted(data) && P.Admitted(data,value) && I.PathLength(data) == 0 &&
    (I.Param(data) as nat)+bytesRelative+32+length <= |data| &&
    (I.Param(data) as nat)+constraintsRelative+32 <= |data| &&
    S.DataWord(data,I.Param(data)+32) == 0 &&
    S.DataWord(data,I.Param(data)+64) == bytesRelative &&
    S.DataWord(data,I.Param(data)+96) == constraintsRelative &&
    S.DataWord(data,I.Param(data)+bytesRelative) == length &&
    S.DataWord(data,I.Param(data)+constraintsRelative) == 0 &&
    160+S.Round32(length)+64 < 0x10000000000000000
  }
  lemma ReturnCertified()
    ensures 1081 in R.FullRuntimeDestinations()
  { reveal R.FullRuntimeDestinations(); reveal R.DestinationsChunk2(); }
  lemma PreparedMemory()
    ensures |P.Prepared()| == 96
    ensures S.Load(P.Prepared(),64) == 128
    ensures |A.Prepared(P.Prepared(),128)| == 160
    ensures S.Load(A.Prepared(P.Prepared(),128),64) == 160
  {
    Q.StoredWord([],64,128);
    var initial := P.Prepared();
    assert |initial| == 96;
    Q.StoredWord(initial,64,160);
    var first := S.Store(initial,64,160);
    Q.StoredWord(first,128,0);
    Q.StoredFrame(first,128,0,64);
    assert |A.Prepared(initial,128)| == 160;
    assert S.Load(A.Prepared(initial,128),64) == 160;
  }
  lemma SetupAdmitted(param: Word,typeOffset: Word,typeLength: Word,pathOffset: Word)
    ensures A.Admitted(128,285,param,typeOffset,typeLength,pathOffset,[531649507],P.Prepared())
  { PreparedMemory(); }
  lemma OffsetBounds(param: Word,relative: Word,length: Word,size: nat)
    requires (param as nat)+relative+32+length <= size < 0x10000000000000000
    ensures (R.PayloadOffset(param,relative) as nat)+length <= size
  {}
  lemma PreparedFits(offset: Word,length: Word,data: seq<Byte>)
    requires (offset as nat)+length <= |data| < 0x10000000000000000
    requires 160+S.Round32(length)+64 < 0x10000000000000000
    ensures M.Fits(A.Prepared(P.Prepared(),128),160,offset,length,data)
  { PreparedMemory(); }
  lemma Caller(data: seq<Byte>,value: Word,bytesRelative: Word,constraintsRelative: Word,length: Word)
    requires Calldata(data,value,bytesRelative,constraintsRelative,length)
    ensures A.Admitted(128,285,I.Param(data),I.TypeOffset(data),I.TypeLength(data),I.PathOffset(data),[531649507],P.Prepared())
    ensures R.Admitted(1081,I.Param(data),128,0,0,bytesRelative,constraintsRelative,length,160,[531649507,285,I.Param(data),I.TypeOffset(data),I.TypeLength(data),I.PathOffset(data),0,0],A.Prepared(P.Prepared(),128),data)
  {
    I.Bounds(data);
    ReturnCertified();
    PreparedMemory();
    SetupAdmitted(I.Param(data),I.TypeOffset(data),I.TypeLength(data),I.PathOffset(data));
    OffsetBounds(I.Param(data),bytesRelative,length,|data|);
    PreparedFits(R.PayloadOffset(I.Param(data),bytesRelative),length,data);
  }

}
