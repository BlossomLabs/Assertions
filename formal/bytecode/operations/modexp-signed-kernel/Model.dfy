// SPDX-License-Identifier: MIT
// Independent finite-word signed dimensions of the four modular-power wrappers.
include "../modexp-execution/Execution.dfy"
module OperationsModularPowerSignedKernel {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  const Half:nat:=0x8000000000000000000000000000000000000000000000000000000000000000
  function Magnitude(word:S.Word):S.Word { if word<Half then word else G.Modulus()-word }
  function SignedValue(word:S.Word):int { if word<Half then word else word-G.Modulus() }
  function Wrap(value:int):S.Word { value%G.Modulus() }
  function Odd(word:S.Word):bool { word%2==1 }
  function SignedResult(residue:S.Word,negative:bool):S.Word {
    if negative then Wrap(-(residue as int)) else residue
  }
  lemma MagnitudeIdentity(word:S.Word)
    ensures Magnitude(word)<=Half
    ensures Magnitude(word)==(if SignedValue(word)<0 then -SignedValue(word) else SignedValue(word))
    ensures Magnitude(word)==0 <==> word==0
    ensures SignedValue(word)==G.Signed(word)
  { }
  lemma Parity(word:S.Word)
    ensures Odd(word)==Odd(Magnitude(word))
  {
    if word>=Half {
      assert G.Modulus()%2==0;
      assert word==(word/2)*2+word%2;
      assert Magnitude(word)==G.Modulus()-word;
      assert Magnitude(word)%2==(G.Modulus()%2-word%2)%2;
    }
  }
  lemma ResultRepresentation(residue:S.Word,modulus:S.Word,negative:bool)
    requires 0<modulus<=Half && residue<modulus
    ensures SignedValue(SignedResult(residue,negative))==(if negative then -(residue as int) else residue as int)
    ensures -Half<SignedValue(SignedResult(residue,negative))<Half
    ensures negative && residue==0 ==> SignedResult(residue,negative)==0
    ensures !negative ==> SignedResult(residue,negative)==residue
  {
    if negative && residue>0 {
      assert 0<G.Modulus()-residue<G.Modulus();
      assert Wrap(-(residue as int))==G.Modulus()-residue;
      assert SignedResult(residue,negative)>=Half;
    }
  }
  lemma SignedModulusResult(base:S.Word,exponent:S.Word,modulusWord:S.Word,residue:S.Word)
    requires modulusWord!=0 && residue<Magnitude(modulusWord)
    ensures SignedValue(SignedResult(residue,SignedValue(base)<0 && Odd(exponent)))==
            (if SignedValue(base)<0 && Odd(exponent) then -(residue as int) else residue as int)
  {
    MagnitudeIdentity(modulusWord);
    ResultRepresentation(residue,Magnitude(modulusWord),SignedValue(base)<0 && Odd(exponent));
  }
}
