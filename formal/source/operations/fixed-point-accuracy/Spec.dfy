include "Bridge.dfy"
module OperationsFixedPointAccuracySpec {
  import B = OperationsBinaryLogModel
  import M = OperationsFixedPointModel
  import K = OperationsFixedPointAccuracyBridge
  import R = OperationsFixedPointAccuracySeries
  const Wad: real := 1000000000000000000.0
  const WadInteger: int := 1000000000000000000
  ghost function Input(entry: int): real { (entry as real)/Wad }
  ghost predicate ExpAccuracy(entry: int,e: real,absoluteUnits: real,relative: real) {
    M.Signed(entry) && entry < M.ExpUpper && absoluteUnits >= 0.0 && relative >= 0.0 &&
    R.ExpPoint(Input(entry),e) && M.Exp(entry).Value? &&
    R.Abs((M.Exp(entry).result as real)-Wad*e) <= absoluteUnits+relative*Wad*e
  }
  ghost predicate LnAccuracy(entry: int,l: real,absoluteUnits: real) {
    0 < entry && M.Signed(entry) && absoluteUnits >= 0.0 &&
    R.LnPoint(Input(entry),l) && M.Ln(entry).Value? &&
    R.Abs((M.Ln(entry).result as real)-Wad*l) <= absoluteUnits
  }
  ghost predicate UniformExpAccuracy(absoluteUnits: real,relative: real) {
    absoluteUnits >= 0.0 && relative >= 0.0 &&
    forall entry: int,e: real :: M.Signed(entry) && entry < M.ExpUpper && R.ExpPoint(Input(entry),e) ==>
                                   ExpAccuracy(entry,e,absoluteUnits,relative)
  }
  ghost predicate UniformLnAccuracy(absoluteUnits: real) {
    absoluteUnits >= 0.0 &&
    forall entry: int,l: real :: 0 < entry && M.Signed(entry) && R.LnPoint(Input(entry),l) ==>
                                   LnAccuracy(entry,l,absoluteUnits)
  }
  ghost function ExpK(entry: int): int { M.ExpExponent(M.ExpScale(entry)) }
  ghost function ExpReduced(entry: int): int { M.ExpReduction(M.ExpScale(entry),ExpK(entry)) }
  ghost predicate ExpBodyNoWrap(entry: int) {
    M.Signed(entry) && M.ExpLower < entry < M.ExpUpper &&
    M.ExpDenominator(ExpReduced(entry)) > 0 &&
    K.ExpFinishNoWrap(M.Trunc(M.ExpNumerator(ExpReduced(entry)),M.ExpDenominator(ExpReduced(entry))),ExpK(entry))
  }
  ghost function ExpKernel(entry: int): real
    requires ExpBodyNoWrap(entry)
  {
    K.ExpFinishReal((M.ExpNumerator(ExpReduced(entry)) as real)/(M.ExpDenominator(ExpReduced(entry)) as real),ExpK(entry))
  }
  ghost function ExpRoundingUnits(entry: int): real
    requires ExpBodyNoWrap(entry)
  { 1.0+(K.ExpMultiplier as real)/(B.Power((195-ExpK(entry)) as nat) as real) }
  ghost function LnLog(entry: int): nat
    requires entry > 0
  { B.Log(entry as nat) }
  ghost function LnReduced(entry: int): int
    requires entry > 0
  { M.LnNormalization(entry,LnLog(entry)) }
  ghost function LnK(entry: int): int
    requires entry > 0
  { M.S((LnLog(entry) as int)-96) }
  ghost predicate LnBodyNoWrap(entry: int) {
    0 < entry && M.Signed(entry) && M.LnDenominator(LnReduced(entry)) > 0 &&
    K.LnFinishNoWrap(M.Trunc(M.LnNumerator(LnReduced(entry)),M.LnDenominator(LnReduced(entry))),LnK(entry))
  }
  ghost function LnKernel(entry: int): real
    requires LnBodyNoWrap(entry)
  { K.LnFinishReal((M.LnNumerator(LnReduced(entry)) as real)/(M.LnDenominator(LnReduced(entry)) as real),LnK(entry)) }
  ghost function LnRoundingUnits(): real { 1.0+(K.LnMultiplier as real)/(B.Power(174) as real) }
  lemma ExpBodyRounding(entry: int)
    requires ExpBodyNoWrap(entry)
    ensures M.Exp(entry).Value?
    ensures R.Abs((M.Exp(entry).result as real)-ExpKernel(entry)) < ExpRoundingUnits(entry)
  {
    K.ExpKernelRounding(M.ExpNumerator(ExpReduced(entry)),M.ExpDenominator(ExpReduced(entry)),ExpK(entry));
  }
  lemma LnBodyRounding(entry: int)
    requires LnBodyNoWrap(entry)
    ensures M.Ln(entry).Value?
    ensures R.Abs((M.Ln(entry).result as real)-LnKernel(entry)) < LnRoundingUnits()
  {
    K.LnKernelRounding(M.LnNumerator(LnReduced(entry)),M.LnDenominator(LnReduced(entry)),LnK(entry));
  }
  // The analytic residual requirement is a future certificate obligation;
  // it is not assumed to hold universally, and does not add source coverage.
  lemma ExpAccuracyFromResidual(entry: int,e: real,analyticUnits: real)
    requires ExpBodyNoWrap(entry) && R.ExpPoint(Input(entry),e)
    requires analyticUnits >= 0.0 && R.Abs(ExpKernel(entry)-Wad*e) <= analyticUnits
    ensures ExpAccuracy(entry,e,ExpRoundingUnits(entry)+analyticUnits,0.0)
  {
    ExpBodyRounding(entry);
    K.ErrorCompose(M.Exp(entry).result as real,ExpKernel(entry),Wad*e,ExpRoundingUnits(entry),analyticUnits);
  }
  lemma LnAccuracyFromResidual(entry: int,l: real,analyticUnits: real)
    requires LnBodyNoWrap(entry) && R.LnPoint(Input(entry),l)
    requires analyticUnits >= 0.0 && R.Abs(LnKernel(entry)-Wad*l) <= analyticUnits
    ensures LnAccuracy(entry,l,LnRoundingUnits()+analyticUnits)
  {
    LnBodyRounding(entry);
    K.ErrorCompose(M.Ln(entry).result as real,LnKernel(entry),Wad*l,LnRoundingUnits(),analyticUnits);
  }
  lemma ExpUnderflowFromCutoff(entry: int,e: real)
    requires M.Signed(entry) && entry <= M.ExpLower && R.ExpPoint(Input(entry),e)
    requires e <= 1.0/Wad
    ensures ExpAccuracy(entry,e,1.0,0.0)
  { }
  ghost predicate InverseDomain(entry: int) {
    M.Signed(entry) && entry < M.ExpUpper && M.Exp(entry).Value? && M.Exp(entry).result > 0
  }
  ghost predicate InverseAccuracy(entry: int,absoluteUnits: real) {
    absoluteUnits >= 0.0 && InverseDomain(entry) && M.Ln(M.Exp(entry).result).Value? &&
    R.Abs((M.Ln(M.Exp(entry).result).result as real)-(entry as real)) <= absoluteUnits
  }
  // Supplying logInputError requires a later analytic Lipschitz/exp-log
  // identity argument and a positive lower bound on the reconstructed value.
  lemma InverseAccuracyFromResidual(entry: int,l: real,lnUnits: real,logInputError: real)
    requires InverseDomain(entry) && LnAccuracy(M.Exp(entry).result,l,lnUnits)
    requires logInputError >= 0.0 && R.Abs(l-Input(entry)) <= logInputError
    ensures InverseAccuracy(entry,lnUnits+Wad*logInputError)
  {
    R.AbsProduct(l-Input(entry),Wad);
    K.ErrorCompose(M.Ln(M.Exp(entry).result).result as real,Wad*l,entry as real,lnUnits,Wad*logInputError);
  }
}
