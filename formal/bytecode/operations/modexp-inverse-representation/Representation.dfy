// SPDX-License-Identifier: MIT
// Pure word/Euclid representation bridges. Actual inverse bytecode traces remain open.
include "../modexp-execution/Execution.dfy"
include "../../../operations/modular-power/Euclid.dfy"
module OperationsModularPowerInverseRepresentation {
  import G = BytecodeGetterMachine
  import B = OperationsBinaryLogModel
  import E = OperationsModularPowerEuclid
  import H = OperationsFullMulDivSignedHelpers
  import P = OperationsFullMulDivProduct
  import V = OperationsFullMulDivInverse
  lemma WordContract()
    ensures G.Modulus()==B.Word && H.Word==B.Word
  {}
  lemma SignedProjection(word:G.Word)
    ensures G.Signed(word)==H.Signed(word)
  {}
  lemma CoefficientBound(value:int,modulus:G.Word)
    requires 2*E.Abs(value)<=modulus
    ensures -B.Word/2<=value<B.Word/2
    ensures G.Signed((value%B.Word) as G.Word)==value
  {
    E.CoefficientRange(value,modulus);
    H.WordIdentity(value);
    SignedProjection((value%B.Word) as G.Word);
  }
  lemma QuotientStep(g:G.Word,r:G.Word)
    requires 0<r<g
    ensures g/r<G.Modulus()
    ensures r*(g/r)<=g
    ensures (g+G.Modulus()-((r*(g/r))%G.Modulus()))%G.Modulus()==g%r
  {
    E.QuotientStep(g,r);
    assert P.Div(g,r)==g/r;
  }
  lemma SignedCoefficientStep(x:G.Word,y:G.Word,q:G.Word)
    ensures G.Signed((x+G.Modulus()-((y*q)%G.Modulus()))%G.Modulus())==H.Signed(G.Signed(x)-G.Signed(y)*q)
  {
    SignedProjection(x);SignedProjection(y);
    E.SignedResidue(x);E.SignedResidue(y);
    V.ProductResidue(G.Signed(y),q,B.Word);
    V.ProductResidue(y,q,B.Word);
    E.DifferenceResidue(G.Signed(x),G.Signed(y)*q,B.Word);
    E.DifferenceResidue(x,y*q,B.Word);
    var next:=(x+G.Modulus()-((y*q)%G.Modulus()))%G.Modulus();
    assert next==(G.Signed(x)-G.Signed(y)*q)%B.Word;
    SignedProjection(next);
  }
}
