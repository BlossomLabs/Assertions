# Actual array state allocation and descriptor shape invocation

This owner extracts every actual instruction from PC 12814 through the descriptor shape call at PC 9893, preserving arbitrary lower stack prefix, argument words, six zero fields, physical free-pointer store and heap expansion. It does not abstract the descriptor parser as complete: its recursive names/tuples/array rules, validation loops, all errors, returns and complete retained graph remain open.
