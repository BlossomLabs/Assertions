include "MemoryProjection.dfy"
include "../../bytecode/dafnyevm/Helpers.dfy"
include "FoundationRefinement.dfy"
include "../../source/assertions/resolution/Model.dfy"

module HelperModelBridge {
  import opened Int
  import opened EvmState
  import ByteUtils
  import H = ProductionHelpers
  import C = ConstraintModel
  import M = ResolutionModel
  import W = ResolutionWords

  // Representation relation: EVM memory stores the same first word as the
  // source model. Public callers must establish this relation separately.
  predicate FirstRepresentation(st:ExecutingState,pointer:u256,data:seq<C.Byte>) {
    (pointer as nat)+64 <= |st.evm.memory.contents| && |data| >= 32 &&
    st.Read(pointer as nat) as nat == |data| &&
    st.Read((pointer as nat)+32) as nat == C.Read(data[..32])
  }

  ghost method {:isolate_assertions} FirstRefinement(st:ExecutingState,pointer:u256,continuation:u256,data:seq<C.Byte>) returns(out:State)
    requires 4084 <= |st.evm.code.contents| && st.evm.code.contents[3975..4084] == H.Window()
    requires st.evm.fork == EvmFork.CANCUN && st.PC() == 3975
    requires st.IsJumpDest(3975) && st.IsJumpDest(4023) && st.IsJumpDest(continuation)
    requires st.evm.stack.contents == [pointer,continuation]
    requires (pointer as int) <= MAX_U256-64 && st.Gas() >= 200
    requires FirstRepresentation(st,pointer,data)
    ensures out.EXECUTING?
    ensures out.EXECUTING? ==> |out.evm.stack.contents| == 1
    ensures out.EXECUTING? ==> out.PC() == continuation as nat
    ensures out.EXECUTING? ==> out.evm.memory == st.evm.memory
    ensures out.EXECUTING? ==> M.FirstWord(data) == M.Value(W.EncodeWord(out.evm.stack.contents[0] as nat))
  {
    out := H.FirstSuccess(st,pointer,continuation);
  }

  ghost method {:isolate_assertions} AddressRefinement(st:ExecutingState,word:u256,index:u256,continuation:u256) returns(out:State)
    requires 4084 <= |st.evm.code.contents| && st.evm.code.contents[3975..4084] == H.Window()
    requires st.evm.fork == EvmFork.CANCUN && st.PC() == 4031
    requires st.IsJumpDest(4031) && st.IsJumpDest(4077) && st.IsJumpDest(continuation)
    requires st.evm.stack.contents == [index,word,continuation]
    requires word < 0x10000000000000000000000000000000000000000 && st.Gas() >= 200
    ensures out.EXECUTING?
    ensures out.EXECUTING? ==> |out.evm.stack.contents| == 1
    ensures out.EXECUTING? ==> out.PC() == continuation as nat
    ensures out.EXECUTING? ==> out.evm.memory == st.evm.memory
    ensures out.EXECUTING? ==> M.AddressResult(W.EncodeWord(word as nat),index as nat) == M.Value(W.EncodeWord(out.evm.stack.contents[0] as nat))
  {
    W.EncodedWord(word as nat);
    assert |W.EncodeWord(word as nat)| == 32;
    assert W.EncodeWord(word as nat)[..32] == W.EncodeWord(word as nat);
    assert C.Read(W.EncodeWord(word as nat)[..32]) == word as nat;
    assert W.AddressLimit() == 0x10000000000000000000000000000000000000000;
    reveal M.AddressResult();
    assert M.AddressResult(W.EncodeWord(word as nat),index as nat) == M.Value(W.EncodeWord(word as nat));
    out := H.AddressSuccess(st,word,index,continuation);
  }
}
