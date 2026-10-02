# Operations tuple encoding: conditional source evidence

This package proves the two decoded Operations wrappers `encode(string,bytes[])` and `encodeBytes(string,bytes[])`. Coverage stays open until a retained run and the independent checker pass. Successful calls yield the independent canonical tuple body for the supplied descriptor and canonical single-value components, including nested dynamic frames. `encode` returns that body as raw bytes; `encodeBytes` returns the same body inside the standard compiler bytes envelope. Both wrappers propagate the reached codec failure outcome.

The generator pins complete wrapper bodies, the actual compiler declaration of AbiCodec.tuple, public selectors and the complete production codec AST. It freshly reruns the full construction/inherited source gates and compares every emitted reached construction control to the immutable proved version. The reviewed source lowering and byte-object memory interpretation remain explicit correspondence premises. Outer ABI/error serialization is a separate compiler representation premise; this does not certify the compiler.

The reached descriptor parser, recursive validators, error routing, tuple assembly and source memory-copy/store helpers already have retained native proofs in `formal/abi/evidence/production-abi-correspondence`. `codec-evidence.py` independently checks every current source and historical source-snapshot hash, all retained receipt hashes, the pinned tools, complete native module/declaration inventories and each native reuse's exact transitive inputs. Those 7,579 existing obligations are reused evidence, not freshly run obligations and not added to the new wrapper count. The wrapper graph receives fresh native verification without relying on an unproved tuple postcondition.

The raw return proof derives the payload slice from the actual source's object-relative ADD and MLOAD fields and proves the encoded length header round trip. The enveloped output connects to the independent ABI bytes encoding. Decoded calldata and faithful byte-object projection, exact source control/error propagation and compiler envelope/error serialization are explicit representation premises. The uint256 descriptor/count/component bounds and total-byte/return-memory budget are stated; physical pointer nonwrapping and adequate memory/gas/stack/allocation remain resource assumptions. Error acceptance and routing are inherited from the verified codec under its documented cursor/resource contracts; the wrappers do not silently introduce a separate validator.

The concrete fixture checks all raw bytes, the actual compiler return envelope, nested dynamic tuples and exact descriptor/count/length/value errors for both functions. Two compiling and translatable source mutations change the raw return offset and the encodeBytes descriptor operand. Each must fail a direct independent native witness and the real EVM fixture; parsing failures and timeouts are not semantic detection.

Run retained verification and the independent checker after direct files are final:

```sh
python3 -B formal/operations/tuple-encode/verify.py --dafny /tmp/assertions-dafny-4.11.0/dafny/dafny --solc /home/sem/.cache/hardhat-nodejs/compilers-v3/linux-amd64/solc-linux-amd64-v0.8.36+commit.8a079791 --output formal/operations/tuple-encode/evidence/conditional-source-v1
python3 -B formal/operations/tuple-encode/check-evidence.py --dafny /tmp/assertions-dafny-4.11.0/dafny/dafny --solc /home/sem/.cache/hardhat-nodejs/compilers-v3/linux-amd64/solc-linux-amd64-v0.8.36+commit.8a079791 --manifest formal/operations/tuple-encode/evidence/conditional-source-v1/manifest.json
```

No bytecode, gas, deployment or performance claim follows from this source package. Failed development records remain preserved.
