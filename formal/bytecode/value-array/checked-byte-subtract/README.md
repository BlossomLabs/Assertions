# Checked uint8 subtraction exact branch preparation

Actual shared PC24460→13698→caller return, with full256-bit inputs and their exact low8-bit masks. Admit every nonunderflowing masked pair, preserving the full lower stack and memory. ByteIdentity separately connects actual0..255 calldata bytes. Development preparation only: both complete native owners, underflow/panic and full parser/codec/public retention remain open.
