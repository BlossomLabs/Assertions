// SPDX-License-Identifier: MIT
// Preserve existing assertion bytes while allocating each decoded constraint.
include "CanonicalMemory.dfy"
include "../DecoderMemory.dfy"
include "Subspan.dfy"
module AssertionsConstraintFalseDecoderFrame {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import R = BytecodeScanRepresentation
  import C = BytecodeCopyMemory
  import Q = AssertionsConstraintSequences
  import P = AssertionsRawResolveMemory
  import H = AssertionsConstraintDecoderMemory
  import M = AssertionsConstraintFailedCanonicalMemory
  import U = AssertionsConstraintFalseSubspan
  type Word = S.Word
  type Byte = S.Byte
  lemma Subspan(left: seq<Byte>, right: seq<Byte>, start: nat, size: nat, offset: nat, length: nat)
    requires start+size <= |left| && start+size <= |right| && offset+length <= size
    requires left[start..start+size] == right[start..start+size]
    ensures left[start+offset..start+offset+length] == right[start+offset..start+offset+length]
  {
    U.Transfer(left,right,start,size,offset,length);
  }
  lemma CopySpan(mem: seq<Byte>, destination: Word, source: Word, length: Word, data: seq<Byte>, start: nat, size: nat)
    requires |mem|%32 == 0 && start+size <= |mem| && start+size <= destination
    ensures C.Calldata(mem,destination,source,length,data)[start..start+size] == mem[start..start+size]
    ensures |C.Calldata(mem,destination,source,length,data)|%32 == 0
  {
    C.Frame(mem,destination,S.Window(data,source,length));
    C.Size(mem,destination,S.Window(data,source,length));
    forall i: nat {:trigger C.Calldata(mem,destination,source,length,data)[start+i]} | i < size
      ensures C.Calldata(mem,destination,source,length,data)[start+i] == mem[start+i]
    {}
    Q.Span(C.Calldata(mem,destination,source,length,data),mem,start,start,size);
  }
  lemma {:isolate_assertions} Raw(mem: seq<Byte>, free: Word, offset: Word, length: Word, data: seq<Byte>, start: nat, size: nat)
    requires P.Fits(mem,free,offset,length,data)
    requires 96 <= start && start+size <= |mem| && start+size <= free
    ensures start+size <= |P.Construct(mem,free,offset,length,data)|
    ensures P.Construct(mem,free,offset,length,data)[start..start+size] == mem[start..start+size]
  {
    var reserved := S.Store(mem,64,free+32+S.Round32(length));
    R.StoredWord(mem,64,free+32+S.Round32(length));
    M.StoreSpan(mem,64,free+32+S.Round32(length),start,size);
    var header := S.Store(reserved,free,length);
    R.StoredWord(reserved,free,length); M.StoreSpan(reserved,free,length,start,size);
    var copied := C.Calldata(header,free+32,offset,length,data);
    CopySpan(header,free+32,offset,length,data,start,size);
    R.StoredWord(copied,free+32+length,0);
    M.StoreSpan(copied,free+32+length,0,start,size);
  }
  lemma {:isolate_assertions} Constraint(mem: seq<Byte>, free: Word, kind: Word, offset: Word,
                    length: Word, data: seq<Byte>, start: nat, size: nat)
    requires H.Fits(mem,free,offset,length,data)
    requires 96 <= start && start+size <= |mem| && start+size <= free
    ensures start+size <= |H.Construct(mem,free,kind,offset,length,data)|
    ensures H.Construct(mem,free,kind,offset,length,data)[start..start+size] == mem[start..start+size]
  {
    var reserved := S.Store(mem,64,free+64);
    R.StoredWord(mem,64,free+64); M.StoreSpan(mem,64,free+64,start,size);
    var record := S.Store(reserved,free,kind);
    R.StoredWord(reserved,free,kind); M.StoreSpan(reserved,free,kind,start,size);
    H.RecordFits(mem,free,kind,offset,length,data);
    Raw(record,free+64,offset,length,data,start,size);
    P.Built(record,free+64,offset,length,data);
    var payload := P.Construct(record,free+64,offset,length,data);
    R.StoredWord(payload,free+32,free+64);
    M.StoreSpan(payload,free+32,free+64,start,size);
  }
}
