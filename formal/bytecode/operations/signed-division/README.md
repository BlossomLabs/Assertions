# Operations signed division and remainder exact-bytecode preparation

This isolated package specifies signed quotient truncated toward zero and remainder with the dividend sign for all finite words. It extracts the actual five complete raw body paths, including division by zero and the signed minimum divided by minus one overflow. Physical Panic bytes are modeled using the actual overlapping MSTORE0/MSTORE4 writes and REVERT(0,36). The reached compiler constants use SHL and NOT. Checked local conversion helpers are prepared to connect the shifts to their exact numerical values.

Preparation only: no native proof, retained evidence, ledger, or public coverage claim yet. Reviewed extraction/interpreter, finite fitting representation, physical fresh memory, faithful input observations and sufficient reached resources remain explicit. No gas, deployment, performance or source-to-bytecode inference is made.
