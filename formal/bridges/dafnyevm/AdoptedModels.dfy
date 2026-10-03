// SPDX-License-Identifier: MIT
// Newly adopted models and all equivalence obligations; legacy source acceptance is separate.
include "HelperModelBridge.dfy"
include "../../foundations/SourceSequenceMemoryV1.dfy"
include "../../source/assertions/constraints/Model.dfy"
include "../../source/assertions/resolution/Words.dfy"
include "../../source/collections/word-memory/Model.dfy"
include "../../source/operations/full-mul-div/Memory.dfy"
include "../../source/operations/modular-power/Memory.dfy"
include "../../source/operations/scalars/Model.dfy"
include "SourceRefinement.dfy"
include "../../bytecode/dafnyevm/PublicResolve.dfy"
module EvmAdoptedModels {}
