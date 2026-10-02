# Canonical foundations

`registry.json` lists exact interfaces, canonical files and transitive package
consumers. Eight modules cover total and sequence memory, sequence point updates,
replacement spans, memo order, flattening, nonnegative products and Assertions
constraint facts. Constraint facts are a contract helper rather than a generic
memory foundation.

A consumer must prove its representation bridge: total-map memory is not a byte
sequence, and a preservation lemma does not establish bounds or allocation by
itself. Find these obligations in the consumer's complete interface and package
layers. Publication alone grants no source or bytecode acceptance.

The catalog is derived from selected canonical closures:

```sh
python3 formal/source/library/catalog.py
```

Run it only when no verification snapshot needs changing. Native evidence may
cover a foundation transitively; its exact file hash must occur in the passing
snapshot and the declaration coverage review must succeed before claiming that
support. Source correspondence remains a separate gate.
