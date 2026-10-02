# Fold decoder invocation development

The owned generator extracts all three current public wrapper calls: range entry1055 to decoder23187, and bytes/words entries713/732 to decoder22132. It pins the current runtime hash, compiler selectors and wrapper entries, every executed opcode/immediate and jump destination. Native lemmas preserve arbitrary lower stack and byte memory and prove the exact passed calldata size, offset4, outer return604 and wrapper-specific decoder return1069/727/746.

Only the invocation instructions are covered here. PC-zero prefixes, raw decoding and rejection, alignment/windows, allocation/template copying, fold loop and every callback/early-exit/error path, terminal output and retained independent checking remain required. Selected development imports assume included contracts. No public coverage or gas/deployment/performance claim.
