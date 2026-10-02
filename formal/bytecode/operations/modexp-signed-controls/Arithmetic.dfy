// SPDX-License-Identifier: MIT
// Prepared signed-result bounds and representation; native verification pending.
include "../modexp-signed-kernel/Model.dfy"
include "../modexp-halving-kernel/Halving.dfy"
include "../modexp-unsigned-controls/Memory.dfy"
module OperationsModularPowerSignedArithmetic {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import K = OperationsModularPowerSignedKernel
  lemma Represent(base:S.Word,exponent:S.Word,modulusWord:S.Word,result:S.Word)
    requires modulusWord!=0 && result<K.Magnitude(modulusWord)
    ensures result<K.Half
    ensures K.SignedResult(result,base>=K.Half && K.Odd(exponent))==
            (if base>=K.Half && exponent%2==1 then (-result)%G.Modulus() else result)
    ensures G.Signed(K.SignedResult(result,base>=K.Half && K.Odd(exponent)))==
            (if base>=K.Half && exponent%2==1 then -(result as int) else result as int)
  {
    K.MagnitudeIdentity(base);K.MagnitudeIdentity(modulusWord);
    K.ResultRepresentation(result,K.Magnitude(modulusWord),base>=K.Half && K.Odd(exponent));
  }
}
