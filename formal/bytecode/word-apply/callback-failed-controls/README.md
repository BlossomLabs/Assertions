# Physical CallbackFailed serializer controls

Three generated segments cover PC17017 through the first shared bytes-copy invocation, PC24352 through the second invocation, and PC24370 through the physical final REVERT. They preserve the complete original callback caller stack and parameterize arbitrary payload/reason lengths, including zero. Every fetched opcode byte and actual jump target is compiler-bound. The shared bytes-copy helper is separately proven and must be composed at both boundaries.

Memory/resource, target canonicality, map/filter loaded selectors and fitted stack premises are explicit. Selected imports are assumed; raw callback failure composition, all admitted/rejected behavior, fresh full native graph, EVM fixtures, semantic mutations and independent retained checking remain mandatory for public evidence. No gas/deployment/performance claim. Never hand-edit generated files; generate.py owns controls and mappings.
