"""Experimental candidate only. Does not edit the production source tree."""
import hashlib
BASE = '0e2609f7489272c58d1e137578fafe76349ad274b6bc688a37ec8f196864abd9'

def apply(source, omit=None):
    if hashlib.sha256(source.encode()).hexdigest() != BASE:
        raise ValueError('Candidate base source drift')
    source = source.replace('    error NotSelf(address caller);', '    error NotSelf(address caller);\n\n    error GuardedCallForbidden();')
    for path, signature, data in [
        ('probe', '    function _probe(address target, bytes memory callData, bytes4 expected) private view returns (bytes memory reason) {', 'callData'),
        ('call', '    function _call(address target, bytes memory data, uint256 index) private view returns (bytes memory result) {', 'data')]:
        if source.count(signature) != 1:
            raise ValueError('Dispatch source drift')
        if omit != path:
            source = source.replace(signature, signature + '\n        _checkPublicCall(target, ' + data + ');')
    helper = '''    function _checkPublicCall(address target, bytes memory data) private view {
        if (target == address(this) && data.length >= 4 && bytes4(data) == this.evaluateGuarded.selector) {
            revert GuardedCallForbidden();
        }
    }

'''
    return source.replace('    function _rejectOutOfGas(', helper + '    function _rejectOutOfGas(')
