# sortWords physical helper connection

This connection composes the actual reached wordAt and setWord instruction traces with the independently proved two-buffer memory frame. Reads preserve memory and return the exact original occurrence word, including a represented zero scratch cell. Writes use an original occurrence ID and update exactly one modeled buffer slot through the actual EVM Store result. The caller stack prefix and complete finite trace endpoints are explicit.

Development only. The merge loop must establish the helper entry stack, all fitting pointer and index premises, original occurrence selection and complete termination ranks. Public serialization, complete retained evidence, gas and performance remain separate. Freeze all package inputs before verification.
