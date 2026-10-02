"""Conservative interfaces for single-module, conventionally indented Dafny files.

Module imports between declarations delimit the previous declaration. Unsupported
module layouts fail closed; this is not a complete Dafny parser.
"""
import importlib.util
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
spec = importlib.util.spec_from_file_location('body', ROOT/'scripts/dafny_declaration_body.py')
body = importlib.util.module_from_spec(spec)
spec.loader.exec_module(body)


def declarations(path):
    text = path.read_text()
    masked = body.mask_literals_and_comments(text)
    assert len(re.findall(r'(?m)^module \w+', masked)) == 1, 'Expected one top-level module'
    declaration = r'(?m)^  (?:(?:ghost|opaque) )*(lemma|method|function|predicate|const|datatype|type)(?: \{:[^}]+\})* (\w+)'
    pattern = declaration + r'|(?m:^  import\b[^\n]*)'
    boundaries = list(re.finditer(pattern, masked))
    out = {}
    for i, match in enumerate(boundaries):
        if match[1] is None:
            continue
        end = boundaries[i+1].start() if i+1 < len(boundaries) else len(text)
        segment = text[match.start():end].strip()
        if i+1 == len(boundaries):
            last = body.mask_literals_and_comments(segment).rstrip().rfind('}')
            assert last >= 0
            segment = segment[:last] + segment[last+1:]
            segment = segment.rstrip()
        if match[1] in ['lemma','method','function','predicate']:
            interface, proofbody = body.split_body(segment)
        else:
            interface, proofbody = segment, None
        assert match[2] not in out, 'Duplicate declaration'
        out[match[2]] = {'kind':match[1],'interface':interface,'full':segment,'body':proofbody}
    return out
