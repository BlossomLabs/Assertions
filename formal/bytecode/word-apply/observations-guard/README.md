# Fresh failed-callback guard observations

An isolated development harness preserves the original observation owner. It adds map/filter fixtures for failed empty receipts, ordinary4byte reverts, exact4byte signals produced from dirty child memory, and INVALID consuming forwarded child gas. Each executes the canonical compiled runtime from PCzero and checks complete final memory slices, actual child outcome/returndata/caller/input, observations and callback count. Burn cases independently check the observed comparison gasAfter<=gasBefore/63; no fixed gas-cost or sufficiency claim.

The INVALID child terminal is separately admitted only for that fixture, with zero returned bytes and failed call flag checked against the actual parent frame. Ordinary reverts retain CallbackFailed calldata and reason; exact signals/burn paths return the actual4byte SubcallOutOfGas packet. Fixture observations are development evidence. Fresh native/full graph, semantic faults and independent retained checking remain mandatory for public coverage.

V1 physical harness passed8 receipts. The strengthened owner additionally checks actual parent RETURNDATASIZE after each child call; fresh V2 capture/run is required before claiming that owner current.

Fresh V2 adds nearBurn: two nested calls to the INVALID leaf consume forwarded child gas before the wrapper reverts with ordinary4byte data. This checks the exhausted4byte physical path independently of the exact-signal predicate. Parent RETURNDATASIZE is explicitly checked for every actual callback. The five new kinds produce ten map/filter fixtures.

V3 additionally checks nonzero padding in the parent's actual loaded receipt word, using a64byte packed template and exact4byte signal. Partial RETURNDATACOPY leaves28 old packed bytes below the selector. The harness requires these low224bits to be nonzero and still checks the exact4byte outer packet. Twelve cases now cover both modes and all5 guard paths. V2's ten unchanged-input receipts are preserved as historical development evidence.

V3's newly added parent-padding cases exposed an omitted target in the oracle's exact-signal classification, while both actual runtime packets were correct. That failed, unchanged-input snapshot is preserved. V4 fixes only the expected classification and requires a fresh twelve-case physical capture; no contract correction follows from this harness error.
