import { useState, useCallback } from 'react';

const ADDR = '0xA55e4707A94Ce4Aa647517ed9aD4084e4E5D1f3F';

const CATEGORIES = [
  { group: 'View Function Return', items: [
    { id: 'call-uint', label: 'uint256' },
    { id: 'call-address', label: 'address' },
    { id: 'call-bool', label: 'bool' },
    { id: 'call-bytes32', label: 'bytes32' },
  ]},
  { group: 'On-Chain State', items: [
    { id: 'balance', label: 'ETH Balance' },
    { id: 'block-number', label: 'Block Number' },
    { id: 'block-timestamp', label: 'Timestamp' },
    { id: 'chain', label: 'Chain ID' },
  ]},
  { group: 'Contract', items: [
    { id: 'code-has', label: 'Has Code' },
    { id: 'code-no', label: 'No Code' },
    { id: 'code-hash', label: 'Code Hash' },
  ]},
];

type Op = { id: string; symbol: string };

const OPS: Record<string, Op[]> = {
  'call-uint':  [{ id:'eq', symbol:'==' },{ id:'ne', symbol:'!=' },{ id:'gt', symbol:'>' },{ id:'lt', symbol:'<' },{ id:'ge', symbol:'>=' },{ id:'le', symbol:'<=' },{ id:'approx', symbol:'≈' }],
  'call-address': [{ id:'eq', symbol:'==' },{ id:'ne', symbol:'!=' }],
  'call-bool':  [{ id:'true', symbol:'true' },{ id:'false', symbol:'false' },{ id:'eq', symbol:'==' }],
  'call-bytes32': [{ id:'eq', symbol:'==' },{ id:'ne', symbol:'!=' }],
  'balance':   [{ id:'eq', symbol:'==' },{ id:'gt', symbol:'>' },{ id:'lt', symbol:'<' },{ id:'ge', symbol:'>=' },{ id:'le', symbol:'<=' },{ id:'approx', symbol:'≈' }],
  'block-number': [{ id:'eq', symbol:'==' },{ id:'gt', symbol:'>' },{ id:'lt', symbol:'<' },{ id:'ge', symbol:'>=' },{ id:'le', symbol:'<=' }],
  'block-timestamp': [{ id:'eq', symbol:'==' },{ id:'gt', symbol:'>' },{ id:'lt', symbol:'<' },{ id:'ge', symbol:'>=' },{ id:'le', symbol:'<=' }],
  'chain':     [{ id:'eq', symbol:'==' }],
  'code-has':  [],
  'code-no':   [],
  'code-hash': [{ id:'eq', symbol:'==' }],
};

const FN: Record<string, Record<string, string>> = {
  'call-uint': { eq:'assertEqCallUint', ne:'assertNeCallUint', gt:'assertGtCallUint', lt:'assertLtCallUint', ge:'assertGeCallUint', le:'assertLeCallUint', approx:'assertApproxEqCallUint' },
  'call-address': { eq:'assertEqCallAddress', ne:'assertNeCallAddress' },
  'call-bool': { true:'assertTrue', false:'assertFalse', eq:'assertEqCallBool' },
  'call-bytes32': { eq:'assertEqCallBytes32', ne:'assertNeCallBytes32' },
  'balance': { eq:'assertEqBalance', gt:'assertGtBalance', lt:'assertLtBalance', ge:'assertGeBalance', le:'assertLeBalance', approx:'assertApproxEqBalance' },
  'block-number': { eq:'assertEqBlockNumber', gt:'assertGtBlockNumber', lt:'assertLtBlockNumber', ge:'assertGeBlockNumber', le:'assertLeBlockNumber' },
  'block-timestamp': { eq:'assertEqBlockTimestamp', gt:'assertGtBlockTimestamp', lt:'assertLtBlockTimestamp', ge:'assertGeBlockTimestamp', le:'assertLeBlockTimestamp' },
  'chain': { eq:'assertEqChainId' },
  'code-has': { _:'assertHasCode' },
  'code-no': { _:'assertNoCode' },
  'code-hash': { eq:'assertEqCodeHash' },
};

interface Params {
  target: string;
  fnSig: string;
  expected: string;
  message: string;
  delta: string;
}

const defaults: Params = { target: '', fnSig: '', expected: '', message: '', delta: '' };

function needsTarget(cat: string) { return cat.startsWith('call-') || cat === 'balance' || cat.startsWith('code-'); }
function needsCall(cat: string) { return cat.startsWith('call-'); }
function needsExpected(cat: string) { return !['code-has','code-no'].includes(cat); }
function needsDelta(cat: string, op: string) { return op === 'approx'; }
function isCallBoolSimple(cat: string, op: string) { return cat === 'call-bool' && (op === 'true' || op === 'false'); }

function getFnName(cat: string, op: string): string {
  return FN[cat]?.[op] || FN[cat]?.['_'] || 'assert';
}

function genSolidity(cat: string, op: string, p: Params): string {
  const fn = getFnName(cat, op);
  const args: string[] = [];
  if (needsTarget(cat)) args.push(p.target || '0x...');
  if (needsCall(cat)) args.push(`abi.encodeCall(${p.fnSig || 'IERC20.totalSupply, ()'})`);
  if (needsExpected(cat)) {
    if (cat === 'call-bool' && op === 'eq') args.push(p.expected || 'true');
    else if (!isCallBoolSimple(cat, op)) args.push(p.expected || '0');
  }
  if (needsDelta(cat, op)) args.push(p.delta || '0');
  if (p.message) args.push(`"${p.message}"`);
  return `assertions.${fn}(\n${args.map(a => `    ${a}`).join(',\n')}\n);`;
}

function genViem(cat: string, op: string, p: Params): string {
  const fn = getFnName(cat, op);
  const args: string[] = [];
  if (needsTarget(cat)) args.push(`"${p.target || '0x...'}" as \`0x\$\{string\}\``);
  if (needsCall(cat)) args.push(`encodeFunctionData({\n      abi: targetAbi,\n      functionName: "${(p.fnSig || 'totalSupply').split('(')[0].split('.').pop()}",\n    })`);
  if (needsExpected(cat)) {
    if (cat === 'call-bool' && op === 'eq') args.push(p.expected || 'true');
    else if (cat.includes('uint') || cat === 'balance' || cat.includes('block') || cat === 'chain')
      args.push(`${p.expected || '0'}n`);
    else if (!isCallBoolSimple(cat, op)) args.push(`"${p.expected || '0x...'}" as \`0x\$\{string\}\``);
  }
  if (needsDelta(cat, op)) args.push(`${p.delta || '0'}n`);
  if (p.message) args.push(`"${p.message}"`);
  return `import { encodeFunctionData } from "viem"

await walletClient.writeContract({
  address: "${ADDR}",
  abi: assertionsAbi,
  functionName: "${fn}",
  args: [\n${args.map(a => `    ${a}`).join(',\n')}\n  ],
});`;
}

function genEthers(cat: string, op: string, p: Params): string {
  const fn = getFnName(cat, op);
  const args: string[] = [];
  if (needsTarget(cat)) args.push(`"${p.target || '0x...'}"`);
  if (needsCall(cat)) args.push(`iface.encodeFunctionData("${(p.fnSig || 'totalSupply').split('(')[0].split('.').pop()}")`);
  if (needsExpected(cat)) {
    if (cat === 'call-bool' && op === 'eq') args.push(p.expected || 'true');
    else if (!isCallBoolSimple(cat, op)) args.push(p.expected || '0');
  }
  if (needsDelta(cat, op)) args.push(p.delta || '0');
  if (p.message) args.push(`"${p.message}"`);
  return `const assertions = new ethers.Contract(
  "${ADDR}",
  assertionsAbi,
  signer,
);

await assertions.${fn}(\n${args.map(a => `  ${a}`).join(',\n')}\n);`;
}

function genPython(cat: string, op: string, p: Params): string {
  const fn = getFnName(cat, op);
  const args: string[] = [];
  if (needsTarget(cat)) args.push(`"${p.target || '0x...'}"`);
  if (needsCall(cat)) args.push(`contract.encodeABI(fn_name="${(p.fnSig || 'totalSupply').split('(')[0].split('.').pop()}")`);
  if (needsExpected(cat)) {
    if (cat === 'call-bool' && op === 'eq') args.push(p.expected === 'false' ? 'False' : 'True');
    else if (isCallBoolSimple(cat, op)) { /* no expected */ }
    else args.push(p.expected || '0');
  }
  if (needsDelta(cat, op)) args.push(p.delta || '0');
  if (p.message) args.push(`"${p.message}"`);
  return `assertions = w3.eth.contract(
    address="${ADDR}",
    abi=assertions_abi,
)

assertions.functions.${fn}(\n${args.map(a => `    ${a}`).join(',\n')}\n).call()`;
}

const LANGS = [
  { id: 'solidity', label: 'Solidity', gen: genSolidity },
  { id: 'viem', label: 'Viem', gen: genViem },
  { id: 'ethers', label: 'Ethers.js', gen: genEthers },
  { id: 'python', label: 'Python', gen: genPython },
] as const;

function CopyBtn({ text }: { text: string }) {
  const [copied, setCopied] = useState(false);
  const copy = useCallback(() => {
    navigator.clipboard.writeText(text);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  }, [text]);
  return (
    <button
      onClick={copy}
      className="absolute top-3 right-3 p-1.5 rounded-md bg-[var(--color-surface-3)]/80 hover:bg-[var(--color-bp-500)]/20 text-[var(--color-ink-3)] hover:text-[var(--color-bp-400)] transition-all cursor-pointer"
      aria-label="Copy code"
    >
      {copied ? (
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="var(--color-ok)" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
      ) : (
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><rect x="9" y="9" width="13" height="13" rx="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>
      )}
    </button>
  );
}

export default function Wizard() {
  const [cat, setCat] = useState<string | null>(null);
  const [op, setOp] = useState<string | null>(null);
  const [params, setParams] = useState<Params>({ ...defaults });
  const [lang, setLang] = useState('solidity');

  const ops = cat ? OPS[cat] : [];
  const effectiveOp = op || (ops.length === 0 ? '_' : null);
  const showForm = cat && effectiveOp;

  const setP = (key: keyof Params, val: string) => setParams(prev => ({ ...prev, [key]: val }));

  const selectCat = (id: string) => {
    setCat(id);
    setOp(null);
    setParams({ ...defaults });
    if (OPS[id].length === 0) setOp('_');
    if (OPS[id].length === 1) setOp(OPS[id][0].id);
  };

  const code = cat && effectiveOp
    ? LANGS.find(l => l.id === lang)!.gen(cat, effectiveOp, params)
    : '';

  return (
    <section id="wizard" className="py-24 px-6">
      <div className="max-w-4xl mx-auto">
        <h2 className="font-mono font-bold text-3xl sm:text-4xl text-center mb-4">
          Build an Assertion
        </h2>
        <p className="text-center text-[var(--color-ink-2)] text-lg mb-12 max-w-2xl mx-auto">
          Configure your assertion and get ready-to-use code in your language.
        </p>

        <div className="rounded-2xl border border-[var(--color-ink-3)]/15 bg-[var(--color-surface-2)] overflow-hidden">
          {/* Category picker */}
          <div className="p-6 border-b border-[var(--color-ink-3)]/10">
            <label className="block text-xs font-mono uppercase tracking-wider text-[var(--color-ink-3)] mb-4">
              What do you want to assert?
            </label>
            <div className="flex flex-col gap-5">
              {CATEGORIES.map(group => (
                <div key={group.group}>
                  <span className="text-xs text-[var(--color-ink-3)] mb-2 block">{group.group}</span>
                  <div className="flex flex-wrap gap-2">
                    {group.items.map(item => (
                      <button
                        key={item.id}
                        onClick={() => selectCat(item.id)}
                        className={`px-3.5 py-2 rounded-lg text-sm font-mono transition-all cursor-pointer border ${
                          cat === item.id
                            ? 'bg-[var(--color-bp-500)] text-white border-[var(--color-bp-500)]'
                            : 'border-[var(--color-ink-3)]/20 hover:border-[var(--color-bp-400)]/50 hover:bg-[var(--color-bp-500)]/5'
                        }`}
                      >
                        {item.label}
                      </button>
                    ))}
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Operator picker */}
          {cat && ops.length > 0 && (
            <div className="p-6 border-b border-[var(--color-ink-3)]/10 animate-fade-up">
              <label className="block text-xs font-mono uppercase tracking-wider text-[var(--color-ink-3)] mb-4">
                Comparison
              </label>
              <div className="flex flex-wrap gap-2">
                {ops.map(o => (
                  <button
                    key={o.id}
                    onClick={() => setOp(o.id)}
                    className={`px-4 py-2 rounded-lg font-mono text-base transition-all cursor-pointer border ${
                      op === o.id
                        ? 'bg-[var(--color-bp-500)] text-white border-[var(--color-bp-500)]'
                        : 'border-[var(--color-ink-3)]/20 hover:border-[var(--color-bp-400)]/50 hover:bg-[var(--color-bp-500)]/5'
                    }`}
                  >
                    {o.symbol}
                  </button>
                ))}
              </div>
            </div>
          )}

          {/* Parameters */}
          {showForm && (
            <div className="p-6 border-b border-[var(--color-ink-3)]/10 animate-fade-up">
              <label className="block text-xs font-mono uppercase tracking-wider text-[var(--color-ink-3)] mb-4">
                Parameters
              </label>
              <div className="grid gap-4 sm:grid-cols-2">
                {needsTarget(cat) && (
                  <div className="sm:col-span-2">
                    <label className="block text-sm text-[var(--color-ink-2)] mb-1.5">Target address</label>
                    <input
                      type="text"
                      value={params.target}
                      onChange={e => setP('target', e.target.value)}
                      placeholder="0xdAC17F958D2ee523a2206206994597C13D831ec7"
                      className="w-full px-4 py-2.5 rounded-lg bg-[var(--color-surface-3)] border border-[var(--color-ink-3)]/15 font-mono text-sm placeholder:text-[var(--color-ink-3)]/50 focus:outline-none focus:border-[var(--color-bp-400)] transition-colors"
                    />
                  </div>
                )}
                {needsCall(cat) && (
                  <div className="sm:col-span-2">
                    <label className="block text-sm text-[var(--color-ink-2)] mb-1.5">Function signature</label>
                    <input
                      type="text"
                      value={params.fnSig}
                      onChange={e => setP('fnSig', e.target.value)}
                      placeholder="IERC20.totalSupply, ()"
                      className="w-full px-4 py-2.5 rounded-lg bg-[var(--color-surface-3)] border border-[var(--color-ink-3)]/15 font-mono text-sm placeholder:text-[var(--color-ink-3)]/50 focus:outline-none focus:border-[var(--color-bp-400)] transition-colors"
                    />
                  </div>
                )}
                {needsExpected(cat) && !isCallBoolSimple(cat, effectiveOp!) && (
                  <div>
                    <label className="block text-sm text-[var(--color-ink-2)] mb-1.5">Expected value</label>
                    <input
                      type="text"
                      value={params.expected}
                      onChange={e => setP('expected', e.target.value)}
                      placeholder={cat.includes('address') ? '0x...' : cat === 'chain' ? '1' : '1000000'}
                      className="w-full px-4 py-2.5 rounded-lg bg-[var(--color-surface-3)] border border-[var(--color-ink-3)]/15 font-mono text-sm placeholder:text-[var(--color-ink-3)]/50 focus:outline-none focus:border-[var(--color-bp-400)] transition-colors"
                    />
                  </div>
                )}
                {needsDelta(cat, effectiveOp!) && (
                  <div>
                    <label className="block text-sm text-[var(--color-ink-2)] mb-1.5">Max delta</label>
                    <input
                      type="text"
                      value={params.delta}
                      onChange={e => setP('delta', e.target.value)}
                      placeholder="100"
                      className="w-full px-4 py-2.5 rounded-lg bg-[var(--color-surface-3)] border border-[var(--color-ink-3)]/15 font-mono text-sm placeholder:text-[var(--color-ink-3)]/50 focus:outline-none focus:border-[var(--color-bp-400)] transition-colors"
                    />
                  </div>
                )}
                <div className={needsDelta(cat, effectiveOp!) ? '' : 'sm:col-span-1'}>
                  <label className="block text-sm text-[var(--color-ink-2)] mb-1.5">Error message <span className="text-[var(--color-ink-3)]">(optional)</span></label>
                  <input
                    type="text"
                    value={params.message}
                    onChange={e => setP('message', e.target.value)}
                    placeholder="Assertion failed"
                    className="w-full px-4 py-2.5 rounded-lg bg-[var(--color-surface-3)] border border-[var(--color-ink-3)]/15 text-sm placeholder:text-[var(--color-ink-3)]/50 focus:outline-none focus:border-[var(--color-bp-400)] transition-colors"
                  />
                </div>
              </div>
            </div>
          )}

          {/* Code output */}
          {showForm && (
            <div className="animate-fade-up">
              <div className="flex border-b border-[var(--color-ink-3)]/10 overflow-x-auto">
                {LANGS.map(l => (
                  <button
                    key={l.id}
                    onClick={() => setLang(l.id)}
                    className={`px-5 py-3 text-sm font-mono whitespace-nowrap transition-all cursor-pointer border-b-2 ${
                      lang === l.id
                        ? 'text-[var(--color-bp-400)] border-[var(--color-bp-400)]'
                        : 'text-[var(--color-ink-3)] border-transparent hover:text-[var(--color-ink-2)]'
                    }`}
                  >
                    {l.label}
                  </button>
                ))}
              </div>
              <div className="relative">
                <pre className="p-6 overflow-x-auto text-sm leading-relaxed font-mono text-[var(--color-ink)]">
                  <code>{code}</code>
                </pre>
                <CopyBtn text={code} />
              </div>
            </div>
          )}
        </div>
      </div>
    </section>
  );
}
