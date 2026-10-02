# reverseWords physical allocation development

The generated header paths scan the canonical runtime from PC 5799 to either
empty loop entry PC 5846 or actual CALLDATACOPY at PC 5837. The memory bridge
proves this copy starts beyond calldata and yields the zero payload heap,
including exact byte-length and free-pointer headers. The post-copy path
connects to the initial reverse loop frame.

The count bound below 2^59 will follow from the fitting raw bytes decoder, whose
length is below 2^64, and word alignment. Adequate allocation/execution resources,
finite valid representation, faithful runtime scanning and interpretation remain
explicit. This development package adds no public bytecode coverage, gas,
deployment or performance claim. Generated files are never edited manually.
