# Local BYTE model for descriptor parsing

The scanner/copy models currently reject BYTE. This local owner extends only opcode 0x1a with the 256-bit big-endian byte rule, retaining the same state/stack/physical memory and delegating every other opcode unchanged. Existing complete copy traces lift because their interpreted non-Bad successors exclude BYTE. The scalar helper links BYTE(0,CALLDATALOAD(offset)) to the actual calldata byte or zero outside the span.

Complete native proof, physical opcode validation, universal descriptor parser/codec loops and all retained gates remain required. This preparation gives no public coverage.
