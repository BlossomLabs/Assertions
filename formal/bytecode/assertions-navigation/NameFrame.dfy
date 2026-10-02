// SPDX-License-Identifier: MIT
// Lift ordinary scanner instructions and BYTE into the external frame model.
include "Frame.dfy"
module AssertionsNavigationNameFrame {
  import S = BytecodeScanMachine
  import B = AssertionsByteMachine
  import A = AssertionsSignedMachine
  import E = BytecodeExternalMachine
  import M = AssertionsExternalMachine
  import H = AssertionsNavigationFrame
  predicate Local(code: seq<S.Byte>,state: S.State) {
    H.Local(code,state) ||
    (state.Running? && state.pc < |code| && |state.stack| <= 1024 && code[state.pc] == 0x1a)
  }
  lemma Step(code: seq<S.Byte>,destinations: set<nat>,state: S.State,
             returned: seq<S.Byte>,cursor: nat,self: S.Word,value: S.Word,
             data: seq<S.Byte>,observations: seq<M.Observation>)
    requires Local(code,state)
    ensures M.Step(code,destinations,E.Frame(state,returned,cursor),self,value,data,observations) ==
            E.Frame(B.Step(code,destinations,state,value,data),returned,cursor)
  {
    if code[state.pc] == 0x1a {
      M.ArithmeticStep(code,destinations,E.Frame(state,returned,cursor),self,value,data,observations);
    } else {
      H.Step(code,destinations,state,returned,cursor,self,value,data,observations);
      B.Delegate(code,destinations,state,value,data);
      A.Delegate(code,destinations,state,value,data);
    }
  }
}
