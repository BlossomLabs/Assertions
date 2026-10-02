# unzipWords actual loop connection development

Connects actual checked multiplication/addition/slicing/read helpers and compiled control segments to physical original-word stores and exact lane bytes. Arbitrary finite lane count is handled with rank laneCount minus index; no fixture-sized loop bound is assumed. Fitting aligned calldata, valid lane, fresh memory, faithful instruction semantics and adequate resources remain explicit. Allocation, raw entry, serializer and retained evidence remain open.

V1 is preserved as a terminal development failure: all obligations except two join preconditions passed; those two hit the 30-second solver limit. V2 explicitly separates the frame equality and destination-subset obligations at these joins. No obligation is removed and the time limit is unchanged.

V2 is preserved as a terminal failure with one remaining frame equality timeout. V3 pins the common physical frame on both sides of that join and proves the identical segment projections explicitly, without changing contracts or solver limits.
