/*
 * Copyright 2022 ConsenSys Software Inc.
 * Licensed under the Apache License, Version 2.0.
 * See ../upstream/evm-dafny-e2e52e86/source/LICENSE for the full license.
 * The unsigned addition overflow characterization is adapted from AddOverflowNSC
 * in pinned DafnyEVM FM-paper.dfy; the unsafe example closure is not imported.
 * Fixed-width encoding uses the existing verified model, not variable-width ToBytes.
 */
include "../../bytecode/getters/Machine.dfy"
module SharedFoundationWordArithmetic {
  import G = BytecodeGetterMachine
  lemma AdditionOverflow(x: G.Word, y: G.Word)
    ensures G.Modulus() <= x+y <==> (x+y)%G.Modulus() < x
  { G.WordPower(); }
  lemma WordEncoding(word: G.Word)
    ensures |G.Encode(word,32)| == 32
    ensures G.Decode(G.Encode(word,32)) == word
  { G.WordPower(); G.RoundTrip(word,32); }
}
