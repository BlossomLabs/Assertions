// SPDX-License-Identifier: MIT
// Isolated typed original-word projection; exact full32 bytes, no fixture cap.
include "../raw-decoder/Inputs.dfy"
include "../../scans/Representation.dfy"
module BytecodeApplyFirstElementPost {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import I = BytecodeApplyRawInputs
  import R = BytecodeScanRepresentation
  function Original(data: seq<S.Byte>): S.Word {
    S.DataWord(data,I.Offset(I.SourceHead(data)))
  }
  lemma Decode(data: seq<S.Byte>)
    requires I.Fits(data) && 0 < I.SourceLength(data) && I.SourceLength(data)%32 == 0
    ensures (I.Offset(I.SourceHead(data)) as nat)+32 <= |data|
    ensures Original(data) == G.Decode(data[I.Offset(I.SourceHead(data))..I.Offset(I.SourceHead(data))+32])
  {
    assert 32 <= I.SourceLength(data);
    R.WordProjection(data,I.Offset(I.SourceHead(data)));
  }
}
