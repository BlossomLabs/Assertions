"""Reviewable candidate repair. Applied only to retained scratch snapshots."""
BEFORE = 'if or(eq(w7, 0x75696e74323536), eq(w7, 0x62797465733332)) { p := 7 }'
AFTER = 'if and(gt(sub(limit, s), 6), or(eq(w7, 0x75696e74323536), eq(w7, 0x62797465733332))) { p := 7 }'


def candidate(source):
    assert source.count(BEFORE) == 1
    return source.replace(BEFORE, AFTER)
