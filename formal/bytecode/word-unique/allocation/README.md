# uniqueWords physical allocation development

Compiler-bound instructions at PC 6676 allocate the bytes header and free pointer. Nonempty allocation executes CALLDATACOPY at 6714 from exactly calldata size, producing the zero payload; empty allocation follows its actual branch. The after-copy path reaches the outer loop at 6724 with output pointer 128, zero retained count and index.

Generators pin the entire current runtime and public selector. Generated files must never be edited directly. Allocation arithmetic, rounded memory and fitting calldata premises are explicit; execution resources remain conditional. Development native verification is separate from retained public-bytecode evidence and grants no public coverage.
