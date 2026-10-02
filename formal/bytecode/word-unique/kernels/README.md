# uniqueWords reached checked helpers

Owned generation gates the current full runtime hash and uniqueWords selector, extracts every reached helper instruction, and produces per-instruction and full-trace certificates. These cover actual alignment remainder, loop division, checked word offset multiplication/addition, slice/read, ordered kept-minus-one and checked retained-count increment. Successful-domain bounds must be derived by public body composition; this development package contributes no retained public-entry coverage.

The generator paths use concrete samples only to choose instructions. Dafny verifies each branch under the stated arbitrary-word premises and every reached instruction; full public admission, loop memory, physical serializer, resources and retained evidence remain separate.
