# sortWords initial physical buffers

This model connects the actual source copy, scratch-header and free-pointer MSTORE results and past-end calldata zero copy to the two-buffer original-occurrence memory representation. It includes empty allocation behavior. Every original byte occupies its input-order slot; every scratch word starts at the represented zero sentinel.

Development only. Actual allocation instruction traces still need composition with these physical results before the merge body and public serialization can be retained. Fitting raw data, modeled EVM primitives and sufficient reached resources remain explicit. No public coverage, gas or performance claim follows.
