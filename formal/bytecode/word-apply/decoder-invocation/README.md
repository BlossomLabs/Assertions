# Word apply public decoder invocation

Compiler-bound extraction of the seven actual wrapper instructions fromPC1036/770 to shared decoderPC22579. The caller's lower stack and memory are preserved, the public serializer returnPC518 and matching decoded returnPC1050/784 are pushed, and the actual CALLDATASIZE supplies the full input extent. All fitting EVM-word data sizes are admitted; the raw decoder owns framing and address rejection.

This is partial development evidence, requiring complete prefix, decoder, body and physical output/error composition before public retained coverage. Reviewed interpretation and adequate execution/stack resources remain explicit; no gas, deployment or performance claim follows.
