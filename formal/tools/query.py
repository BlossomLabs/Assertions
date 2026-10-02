"""Find canonical source interfaces by contract, symbol or declaration kind."""
import argparse
import json
from pathlib import Path

LIBRARY = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--contract', choices=['Assertions','Operations','Collections','Expressions','SharedABI','SharedFoundations'])
    parser.add_argument('--kind', choices=['lemma','method','function','predicate','const','type','datatype'])
    parser.add_argument('--search', default='', help='Case-insensitive symbol/interface search.')
    parser.add_argument('--include-intermediates', action='store_true')
    parser.add_argument('--show', action='store_true', help='Print complete logical interfaces.')
    args = parser.parse_args()
    owners = [args.contract] if args.contract else ['Assertions','Operations','Collections','Expressions','SharedABI','SharedFoundations']
    seen = set()
    for owner in owners:
        path = LIBRARY/'source/declarations'/owner/'declarations.json'
        records = json.loads(path.read_text())['records'] if path.exists() else []
        helpers = json.loads((LIBRARY/'helper-interfaces.json').read_text())['records']
        records += [r for r in helpers if r['contract'] == owner]
        for record in records:
            if record.get('selectionRole') == 'generation-intermediate' and not args.include_intermediates:
                continue
            identifier = record['canonicalDeclarationId']
            if identifier in seen:
                continue
            seen.add(identifier)
            if args.kind and record['kind'] != args.kind:
                continue
            if args.search.casefold() not in (record['symbol']+' '+record['logicalInterface']).casefold():
                continue
            print(owner, record['kind'], record['symbol'], record['canonicalFile'])
            if args.show:
                print(record['logicalInterface'])
                print()

if __name__ == '__main__':
    main()
