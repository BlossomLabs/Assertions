# Full callback receipt composition

Authored connection from the actual first GAS at16908 through payload packing,
STATICCALL, full nonempty returned-byte allocation/copy or empty zero pointer,
and the success flag branch to17065 or17008. Both flags and arbitrary finite
receipt contents/lengths are represented; exactly three truthful observations
are consumed. The returned bytes remain caller-local and unchanged.

Memory admission derives the child receipt requirements from a fitting input
heap and arithmetic bounds. The explicit finite footprint bound is2^70,
free is aligned and at least160, and the initial zero slot at96 is preserved
by packing. Raw prefix/iteration owners must derive these premises; local
assumptions do not establish public admission. Gas observations are inputs,
not a gas-cost or deployment theorem.

Development selected checks assume imported contracts. Complete fresh included
native verification, full raw failure composition, physical fixtures, semantic
fault campaign, and independent evidence checking remain required before public
coverage. Owners and dependencies are frozen during each snapshot run.

Development command: `python3 -B formal/bytecode/word-apply/callback-receipt-engine/development-run.py --output <fresh directory> --sources Memory.dfy Engine.dfy`. The final trace has91 frames for empty receipts and112 otherwise, derived from67 call instructions,20/41 receipt instructions and3 dispatch instructions. These are instruction counts, not gas measurements.
