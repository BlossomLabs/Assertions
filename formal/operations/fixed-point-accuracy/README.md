# Prepared expWad / lnWad analytic specification

This owner adds **zero public coverage**. All new declarations, function
well-formedness and lemma obligations are native-unverified. Resolve, formatting,
audit and exact-fraction point diagnostics are static preparation; their success
must not be called a proved analytic error bound. No native Dafny/Z3 or EVM job
is part of `static-check.py`. Existing proof/evidence files are read-only inputs.

The baseline is the passed `../fixed-point/evidence/conditional-source-v1` source
packet: exact finite-word quantized rational kernels, all decoded int256 domains,
guard/error behavior, range/normalization and positive denominators. That packet
explicitly leaves real-function accuracy, positivity, monotonicity and inverse
bounds open. Its reviewed AST/source correspondence, primitive representation,
compiler ABI serialization, trusted tools and physical resource premises remain
unchanged. Pure analytic comparisons do not establish those premises or runtime
bytecode, deployment, gas or performance claims.

## Mathematical specification

`Series.dfy` characterizes exp by the limit of
`sum(i=0..n-1, t^i/i!)`. It characterizes ln(y), for y>0, by the limit of
`2*sum(i=0..n-1, z^(2i+1)/(2i+1))`, where z=(y-1)/(y+1).
There is no assumed or uninterpreted exp/log function, bodiless lemma, `assume`
or `{:axiom}`. Limit existence, positivity and identification with standard
real exp/log, including addition/power and inverse laws, remain obligations.
The definition is not a proof that the limit exists; future universal accuracy
claims must establish non-vacuity.

Prepared finite-series lemmas derive geometric majorants and transfer finite
bounds to any supplied limit:

- exp remainder <= 2*abs(t^n/n!) when 2*abs(t) <= n+1;
- ln remainder <= 2*abs(z^(2n+1))/((2n+1)*(1-z*z)) when abs(z)<1;
- for y in [1,2], the ln radius is at most
  (9/4)*(1/3)^(2n+1)/(2n+1).

These are exact rational expressions. The drafted proofs use finite recurrences,
geometric sums, epsilon limits and explicit absolute-value algebra. They have
not been checked by a native solver.

`Spec.dfy` defines error in **integer WAD output units**:

- exp: abs(quantized_output - WAD*real_exp(input/WAD))
  <= absolute_units + relative_error*WAD*real_exp(input/WAD);
- ln: abs(quantized_output - WAD*real_ln(input/WAD)) <= absolute_units.

Budgets are parameters, not claimed numerical constants. Exp inputs at or above
the overflow cutoff are errors rather than approximation values. Inputs at or
below the zero cutoff need a separate proof that real_exp(input/WAD) <= 1/WAD;
the prepared zero-branch bridge then gives an absolute bound of one output unit.
There is no uniform relative-only accuracy promise for the zero branch.

The inverse goal concerns `lnWad(expWad(input))` only when exp returns a positive
value. A zero exponential output cannot enter lnWad. An inverse budget additionally
needs real exp/ln identity and logarithm perturbation/Lipschitz bounds, with a
positive lower bound on the reconstructed exponential value. This owner does not
assume the NatSpec inverse approximation is globally valid.

## Connection work prepared

`Bridge.dfy` supplies drafted integer/real floor and signed-truncation errors,
nonwrapping Horner steps, unsigned shift-as-floor (including shifts >=256), final
exp scaling and ln affine/floor rounding. It exposes separate no-wrap certificate
predicates. The retained denominator positivity proof does not establish all
numerator products, ratio signs, scaling products or final signed casts as
nonwrapping. Those whole-domain certificate predicates remain open.

For a nonwrapping kernel, the total truncating-ratio/final-floor budget is
less than `1+C_exp/2^(195-k)` exp output units, or
`1+C_ln/2^174` ln output units. The prepared actual normalization bridge bounds
`entry/2^log - normalized_word/2^96` in [0,1/2^96). These statements are drafts,
not newly verified propositions.

`Kernel.dfy` defines the unquantized rational polynomials independently of
source assignments. Generic Horner quantization propagates local unit errors as
a finite geometric sum. Product and positive-denominator quotient perturbation
lemmas split numerator, denominator and stage errors. The universal real rational
kernel certificates are explicit goals, not assumed theorems. They must be
proved by rational polynomial interval certificates (for example positive-
denominator clearing and checked Bernstein/subdivision bounds), together with
the finite-series remainder. Passing a few point samples cannot discharge them.

`Intervals.dfy` gives exact interval algebra and a normalized logarithm enclosure
using mantissas `entry/2^log` and `WAD/2^59` in [1,2), plus `(log-59)*ln(2)`.
Equality of that decomposition to ln(entry/WAD) requires the open log addition/
power law. Range-reduction and scaling also need certificates for ln(2) constants,
input conversion, rational coefficients, overflow/underflow cutoffs and the real
exp addition law. No ideal computation replaces a possibly wrapping source step.

## Outstanding proof graph

1. Native-verify every new well-formedness/lemma obligation after CPU capacity is
   assigned; preserve failed snapshots and repair proofs without assuming results.
2. Establish series limit existence, positivity, uniqueness and real-function
   algebra, or explicitly expose and justify any adopted analytic foundation.
3. Prove whole admitted-domain no-wrap certificates for all numerator and final
   stages, and the ratio signs/final signed ranges.
4. Certify the two real rational approximations uniformly on reduced domains;
   integrate Horner/product/quotient quantization and input normalization.
5. Bound constant and input-conversion errors through range reduction/rescaling;
   prove zero-cutoff and overflow-domain separation.
6. Choose supported absolute/relative budgets, then prove all-domain source error
   and restricted inverse bounds. Keep resource/source/analytic premises distinct.
7. Only a later complete retained native run, meaningful semantic sensitivity and
   independent evidence checker may create an analytic claim. Existing 92/92
   conditional source coverage is unchanged.

Eight lightweight exact-fraction point diagnostics are generated by
`enclosures.py`; they interpret the immutable finite-word oracle outputs under
the explicitly open series and normalized-log bridges. They use no float, EVM,
compiler or source parsing, and neither constitute a uniform certificate nor
prove the analytic bridge. Static provenance is retained separately from native
or public-source evidence after all owner files are complete.
