// SPDX-License-Identifier: MIT
include "EntryModel.dfy"
module CollectionsWordApplyEntryReady {
  import opened CollectionsWordApplyEntryModel
  import L = CollectionsWordApplyModel
  import WP = CollectionsWordWindowsProperties
  lemma Static(k: Config)
    requires Basic(k)
    ensures Allocates(k) ==> L.Static(LoopConfig(k))
  { WP.ScanFacts(|k.template|,k.offsets,0); }
}
