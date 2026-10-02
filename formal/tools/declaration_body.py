"""Conservative body extraction for an already delimited Dafny declaration.

This is a review helper, not a Dafny parser. It requires a final braced body
and rejects unbalanced delimiters or non-comment text after that body.
"""


def mask_literals_and_comments(text):
    chars = list(text)
    i = 0
    while i < len(text):
        start = i
        if text.startswith("//", i):
            end = text.find("\n", i)
            i = len(text) if end < 0 else end
        elif text.startswith("/*", i):
            depth = 1
            i += 2
            while depth:
                if i >= len(text):
                    raise ValueError("Unterminated block comment")
                if text.startswith("/*", i):
                    depth += 1
                    i += 2
                elif text.startswith("*/", i):
                    depth -= 1
                    i += 2
                else:
                    i += 1
        elif text[i] in ('"', "'"):
            quote = text[i]
            i += 1
            while i < len(text):
                if text[i] == "\\":
                    i += 2
                elif text[i] == quote:
                    i += 1
                    break
                else:
                    i += 1
            else:
                raise ValueError("Unterminated literal")
        else:
            i += 1
            continue
        for j in range(start, min(i, len(text))):
            if chars[j] != "\n":
                chars[j] = " "
    return "".join(chars)


def split_body(declaration):
    masked = mask_literals_and_comments(declaration)
    stack = []
    pairs = []
    for i, char in enumerate(masked):
        if char == "{":
            stack.append(i)
        elif char == "}":
            if not stack:
                raise ValueError("Unmatched closing brace")
            opening = stack.pop()
            if not stack:
                pairs.append((opening, i))
    if stack or not pairs:
        raise ValueError("Missing or unbalanced braced body")
    opening, closing = pairs[-1]
    if masked[closing + 1:].strip():
        raise ValueError("Unexpected text after body")
    if masked[opening:opening + 2] == "{:":
        raise ValueError("Final brace group is an attribute, not a body")
    return declaration[:opening].strip(), declaration[opening:closing + 1]


if __name__ == "__main__":
    example = '''lemma {:isolate_assertions} L(x: int)
    requires x in {1, 2}
    ensures x > 0
  { assert x > 0; // } in a comment
    assert "{" == "{"; /* nested /* } */ comment */ }
'''
    header, body = split_body(example)
    assert "requires x in {1, 2}" in header
    assert body.startswith("{ assert")
    changed, _ = split_body(example.replace("{1, 2}", "{1}"))
    assert changed != header
    print("PASS attribute, set-contract, literals, nested comments, domain-change fixture")
