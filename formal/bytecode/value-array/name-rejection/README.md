# Invalid-name parser rejection development

`Connection.dfy` follows the actual type parser entry, the non-tuple invocation, the complete scanner and cleanup, and the full empty-name error path. It derives the zero-length name from the independently invalid first byte, preserving arbitrary lower frames and exact `InvalidTypeDescriptor(p)` bytes. Native checking includes the whole owner and every declaration.

`development/static-v1/results.json` records format, full resolution and zero audit findings. `development/physical-v1/results.json` verifies 20 complete 113-instruction rejection paths among 60 full PC-zero EVM receipts: 16 low-byte and four middle-byte scanner branches. The high-byte branch is admitted by the universal theorem but is not exercised by these ASCII receipts.

The original offset/length below 2^64, p below limit, represented stack budget, aligned fitting memory and correct free pointer remain explicit caller premises. The byte is neither a tuple opening nor lowercase/digit ASCII. Other recursive rejecting branches, public caller admission, complete codecs, native closure, faults and final independent retention remain open. No public coverage is assigned.
