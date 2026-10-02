# sortWords physical copy allocation development

The owned generator extracts the 36 instructions before the initial CALLDATACOPY and 21 instructions after it, ending at the count division helper. The memory lemmas connect the physical source-byte copy, header/free-pointer stores and trailing zero word, including empty input. Scratch allocation remains a separate package.

Development only: copy, scratch allocation, bottom-up merge and serialization composition must all pass before retained public evidence is counted. Fitting finite representation, interpreter and reached-resource premises remain explicit. No gas or performance claim.

Never edit generated outputs. Finish direct package inputs before snapshotting and freeze live graphs.
