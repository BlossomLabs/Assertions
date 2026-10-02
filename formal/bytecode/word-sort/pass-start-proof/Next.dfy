// SPDX-License-Identifier: MIT
// The pass loop's inductive block arithmetic, isolated from memory/trace context.
module BytecodeSortNextStart {
  lemma Next(start: nat,block: nat,width: nat,n: nat)
    requires start == block*(2*width) && start < n && 0 < width < n
    ensures start+2*width == (block+1)*(2*width)
    ensures start+2*width < 3*n
  {}
}
