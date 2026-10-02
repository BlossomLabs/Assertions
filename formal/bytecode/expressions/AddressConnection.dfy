// SPDX-License-Identifier: MIT
// Independent InvalidNode ABI specification for the complete length rejection.
include "AddressLength.generated.dfy"
include "../scans/ErrorBytes.dfy"
module ExpressionsAddressConnection {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeScanExecution
  import B = BytecodeScanErrorBytes
  import A = ExpressionsPrimitiveAddressLength
  function InvalidNode(index: Word): seq<Byte> { G.Encode(0x64a42493,4)+G.Encode(index,32) }
  ghost method RejectLength(code: seq<Byte>, ptr: Word, length: Word, word: Word, index: Word, free: Word, ret: Word, prefix: seq<Word>, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires A.Matches(code) && A.Admitted(code,ptr,length,word,index,free,ret,prefix,mem)
    ensures state == Reverted(InvalidNode(index))
    ensures E.Trace(code,A.Destinations(ret),value,data,trace)
    ensures trace[0] == Running(5440,prefix+[ret,ptr,index],mem) && trace[|trace|-1] == state
  {
    state,trace := A.Run(code,ptr,length,word,index,free,ret,prefix,mem,value,data);
    var header: Word := 0x64a4249300000000000000000000000000000000000000000000000000000000;
    assert A.Memory2(ptr,length,word,index,free,ret,prefix,mem) == Store(Store(mem,free,header),free+4,index);
    B.PhysicalError(mem,free,0x64a42493,header,index);
    var image := A.Memory2(ptr,length,word,index,free,ret,prefix,mem);
    assert G.Grow(image,free+36) == image;
  }
}
