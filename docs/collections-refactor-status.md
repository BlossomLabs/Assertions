# Operations / Collections refactor checkpoint

The source contracts are now `Operations.sol` and `Collections.sol`. Word and
ABI-valued collection operations share Collections; both sorting paths use
bottom-up merge sort. `uniqueWords` and `uniqueValues` take an `ordered` flag.
Callback failures preserve calldata and revert data, filters require canonical
booleans, word callbacks require exactly 32 return bytes, callback targets must
contain bytecode, and `flattenValues` validates its declared element type.

Validation after the final callback-policy cleanup:

- 324 Solidity tests passed with `pnpm test` in the restricted environment.
- That run did not execute the Node.js tests.
- The final SDK integration tests remain pending: automatic approval review
  rejected the unrestricted run because its usage limit was reached.
- SDK runtime fixtures reflect the current compiled contracts.

The checked-in Collections deployment address, salt, ABI and verification bundle
predate the final API and callback-policy changes. They are not the final release
artifacts. Complete the SDK/Node tests, then mine a new `c011ec7` CREATE2 salt and
regenerate the deployment exports. Operations keeps the `09e4a7e` prefix.
The website vendor pin also needs a tested, published SDK revision before release.
No live deployment or publication was performed.
