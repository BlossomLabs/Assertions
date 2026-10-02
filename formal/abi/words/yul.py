"""Restricted, fail-closed solc Yul AST interpreter over 256-bit SMT terms.

This translator is trusted code, not a verified compiler. No source text is
evaluated. Calldata is an unconstrained byte array, including past `limit`.
"""
import z3 as z

if not __debug__:
    raise RuntimeError('Python -O disables translator validation')


def bv(n):
    return z.BitVecVal(n, 256)


def truth(x):
    return x != bv(0)


def flag(x):
    return z.If(x, bv(1), bv(0))


class Interpreter:
    def __init__(self, calldata=None):
        self.calldata = calldata
        self.completion = []

    def expr(self, node, env):
        kind = node['nodeType']
        if kind == 'YulIdentifier':
            return env[node['name']]
        if kind == 'YulLiteral':
            assert node['kind'] == 'number'
            return bv(int(node['value'], 0) if node['value'].startswith('0x') else int(node['value']))
        assert kind == 'YulFunctionCall', kind
        name = node['functionName']['name']
        args = node['arguments']
        # Exact EVM identity; avoids constructing 31 bytes discarded by BYTE.
        if name == 'byte' and args[0]['nodeType'] == 'YulLiteral' and args[0]['value'] == '0' and args[1]['nodeType'] == 'YulFunctionCall' and args[1]['functionName']['name'] == 'calldataload':
            assert len(args) == 2 and len(args[1]['arguments']) == 1
            return z.ZeroExt(248, z.Select(self.calldata, self.expr(args[1]['arguments'][0], env)))
        a = [self.expr(n, env) for n in args]
        unary = {'iszero': lambda x: flag(x == 0), 'not': lambda x: ~x}
        binary = {
            'add': lambda x, y: x+y, 'sub': lambda x, y: x-y,
            'mul': lambda x, y: x*y, 'and': lambda x, y: x & y,
            'or': lambda x, y: x | y, 'eq': lambda x, y: flag(x == y),
            'lt': lambda x, y: flag(z.ULT(x, y)), 'gt': lambda x, y: flag(z.UGT(x, y)),
            'shl': lambda x, y: y << x, 'shr': lambda x, y: z.LShR(y, x),
            'mod': lambda x, y: z.If(y == 0, bv(0), z.URem(x, y)),
            'byte': lambda x, y: z.If(z.UGE(x, bv(32)), bv(0), z.LShR(y, (31-x)*8) & bv(255)),
            'signextend': lambda x, y: z.If(z.UGE(x, bv(31)), y, (y << (248-8*x)) >> (248-8*x)),
        }
        if name in unary:
            assert len(a) == 1
            return unary[name](*a)
        if name in binary:
            assert len(a) == 2
            return binary[name](*a)
        if name == 'calldataload':
            assert len(a) == 1 and self.calldata is not None
            return z.Concat(*[z.Select(self.calldata, a[0]+bv(i)) for i in range(32)])
        raise ValueError(('unsupported builtin', name))

    def block(self, node, env, active, in_loop=False):
        assert node['nodeType'] == 'YulBlock'
        original = set(env)
        for statement in node['statements']:
            active = self.statement(statement, env, active, in_loop)
        for name in set(env)-original:
            del env[name]
        return active

    def statement(self, node, env, active, in_loop):
        kind = node['nodeType']
        if kind == 'YulVariableDeclaration':
            assert len(node['variables']) == 1
            name = node['variables'][0]['name']
            assert name not in env
            env[name] = self.expr(node['value'], env) if node.get('value') else bv(0)
        elif kind == 'YulAssignment':
            assert len(node['variableNames']) == 1
            name = node['variableNames'][0]['name']
            assert name in env
            env[name] = z.simplify(z.If(active, self.expr(node['value'], env), env[name]))
        elif kind == 'YulIf':
            take = z.And(active, truth(self.expr(node['condition'], env)))
            remainder = self.block(node['body'], env, take, in_loop)
            active = z.Or(z.And(active, z.Not(take)), remainder)
        elif kind == 'YulBreak':
            assert in_loop
            active = z.BoolVal(False)
        elif kind == 'YulForLoop':
            # This interpreter handles only wordRule's short width-digit loop.
            # A separate UNSAT obligation proves that four visits are exhaustive.
            assert not in_loop and node['pre']['statements'] == []
            loop = active
            for _ in range(4):
                loop = z.And(loop, truth(self.expr(node['condition'], env)))
                loop = self.block(node['body'], env, loop, True)
                loop = self.block(node['post'], env, loop, True)
            self.completion.append(z.And(loop, truth(self.expr(node['condition'], env))))
        elif kind == 'YulSwitch':
            value = self.expr(node['expression'], env)
            remaining = active
            endings = []
            for case in node['cases']:
                if case['value'] == 'default':
                    take = remaining
                else:
                    take = z.And(remaining, value == self.expr(case['value'], env))
                endings.append(self.block(case['body'], env, take, in_loop))
                remaining = z.And(remaining, z.Not(take))
            active = z.Or(remaining, *endings)
        else:
            raise ValueError(('unsupported statement', kind))
        return z.simplify(active)
