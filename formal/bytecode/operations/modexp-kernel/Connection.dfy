// SPDX-License-Identifier: MIT
include "Model.dfy"
include "../modexp-execution/Execution.dfy"
module OperationsModularPowerKernelConnection {
  import K = OperationsModularPowerKernel
  import X = OperationsModularPowerExecution
  import S = BytecodeScanMachine
  lemma SamePower(a:nat,e:nat)
    ensures K.Power(a,e)==X.Power(a,e)
    decreases e
  { if e>0 { SamePower(a,e-1); } }
  lemma FaithfulReply(receipt:X.Observation)
    requires receipt.StaticCall? && receipt.target==5 && X.Packet(receipt.input)
    requires receipt.success && |receipt.returned|==32 && X.Faithful(receipt)
    ensures S.Load(receipt.returned,0)==
            (if S.Load(receipt.input,160)==0 then 0 else
             K.Power(S.Load(receipt.input,96),S.Load(receipt.input,128))%
             S.Load(receipt.input,160))
  {
    SamePower(S.Load(receipt.input,96),S.Load(receipt.input,128));
  }
}
