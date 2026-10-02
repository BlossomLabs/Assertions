# Checked subtraction exact branch preparation

Generic nonunderflowing shared checked subtraction at PC23784 through13698 and actual caller return JUMPDEST. The original full stack has returnPc,subtrahend,minuend; the result is minuend-subtrahend. Full lower stack and memory remain unchanged. Development preparation only; underflow/panic serialization, full descriptor parser/codec and retained public graph remain open.
