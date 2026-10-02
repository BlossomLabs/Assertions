# reverseWords raw bytes decoder development

The generated paths classify all fitting raw calldata frames of at least four
bytes rejected by the actual bytes decoder: short scalar head, offset at least
2^64, missing length word, length at least 2^64, or truncated payload. Each
path proves the physical empty REVERT under its explicit class predicate. The
accepted class allows loose offsets, dirty unused padding and trailing bytes.
Native proof and complete-entry retention remain required; this development
package adds no public bytecode coverage.

The generator reads the canonical runtime instructions and pins its identity
and selector. Never edit generated files directly.
