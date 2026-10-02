# Reached opcode kernels

`And.dfy` isolates the exact AND stack and memory frame step at any reached PC.
Callers separately prove arithmetic mask facts, then invoke this kernel so those
facts do not interact with the entire instruction dispatcher in one solver
obligation. The semantics, stack bound and unchanged physical memory are kept
explicit. Native evidence and complete retained caller graphs remain required.
