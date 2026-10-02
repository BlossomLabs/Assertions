#!/usr/bin/env python3
"""Isolated compiler checks for claims A34 and W27; writes no release artifacts.

Run: python3 scripts/test-claim-structure.py
Set SOLC to override the installed compiler selected from foundry.toml.
"""
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tomllib
import unittest

ROOT = Path(__file__).resolve().parents[1]
PRODUCTION = ("Assertions", "Operations", "Collections", "Expressions")


def compiler():
    version = tomllib.loads((ROOT / "foundry.toml").read_text())["profile"]["default"]["solc_version"]
    candidates = [os.environ.get("SOLC"), shutil.which("solc"),
                  str(Path.home() / ".local/share/svm" / version / f"solc-{version}"),
                  str(Path.home() / ".svm" / version / f"solc-{version}")]
    candidates.extend(str(path) for path in (Path.home() / ".cache/hardhat-nodejs/compilers-v3").glob(
        f"*/solc*{version}+*"))
    for candidate in candidates:
        if candidate and Path(candidate).is_file():
            result = subprocess.run([candidate, "--version"], capture_output=True, text=True, check=True)
            if f"Version: {version}+" not in result.stdout:
                raise RuntimeError(f"Compiler must match foundry.toml ({version}): {result.stdout}")
            return candidate
    raise RuntimeError(f"Set SOLC to an installed Solidity {version} compiler")


def source_closure():
    sources = {}
    pending = [f"contracts/{name}.sol" for name in PRODUCTION]
    while pending:
        key = pending.pop()
        if key in sources:
            continue
        text = (ROOT / key).read_text()
        sources[key] = {"content": text}
        for match in re.finditer(r'import\s+(?:[^;]*?\sfrom\s*)?["\']([^"\']+)["\']\s*;', text):
            target = match.group(1)
            if target.startswith("@openzeppelin/"):
                imported = "node_modules/" + target
            else:
                imported = os.path.normpath(str(Path(key).parent / target))
            pending.append(imported)
    return sources


def compile_sources(sources):
    settings = {
        "optimizer": {"enabled": True, "runs": 200}, "evmVersion": "cancun",
        "remappings": ["@openzeppelin/contracts/=node_modules/@openzeppelin/contracts/"],
        "outputSelection": {"*": {"": ["ast"], "*": ["abi", "metadata", "evm.bytecode.object",
                                                              "evm.deployedBytecode.object"]}},
    }
    result = subprocess.run([compiler(), "--standard-json"],
                            input=json.dumps({"language": "Solidity", "sources": sources, "settings": settings}),
                            capture_output=True, text=True, cwd=ROOT, check=True)
    output = json.loads(result.stdout)
    errors = [e for e in output.get("errors", []) if e["severity"] == "error"]
    if errors:
        raise RuntimeError("\n".join(e["formattedMessage"] for e in errors))
    return output


def executable_hex(bytecode):
    # solc's CBOR trailer has its byte length in the final two bytes.
    trailer_bytes = int(bytecode[-4:], 16) + 2
    if trailer_bytes * 2 >= len(bytecode):
        raise AssertionError("Expected executable code plus metadata trailer")
    return bytecode[:-trailer_bytes * 2]


class ClaimStructureTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.sources = source_closure()
        cls.original = compile_sources(cls.sources)

    def test_A34_imported_comment_changes_metadata_and_bytecode_for_all_four(self):
        changed_sources = {key: dict(value) for key, value in self.sources.items()}
        changed_sources["contracts/lib/AbiCodec.sol"]["content"] += "\n// A34 metadata sensitivity fixture.\n"
        changed = compile_sources(changed_sources)
        for name in PRODUCTION:
            with self.subTest(contract=name):
                key = f"contracts/{name}.sol"
                imports = [node["absolutePath"] for node in self.original["sources"][key]["ast"]["nodes"]
                           if node["nodeType"] == "ImportDirective"]
                self.assertIn("contracts/lib/AbiCodec.sol", imports)
                old = self.original["contracts"][key][name]
                new = changed["contracts"][key][name]
                old_meta, new_meta = json.loads(old["metadata"]), json.loads(new["metadata"])
                self.assertNotEqual(old_meta["sources"]["contracts/lib/AbiCodec.sol"]["keccak256"],
                                    new_meta["sources"]["contracts/lib/AbiCodec.sol"]["keccak256"])
                for kind in ("bytecode", "deployedBytecode"):
                    before, after = old["evm"][kind]["object"], new["evm"][kind]["object"]
                    self.assertNotEqual(before, after)
                    self.assertEqual(executable_hex(before), executable_hex(after))

    def test_W27_judge_uses_execution_encoding_without_payable_executor_interface(self):
        abi = self.original["contracts"]["contracts/Assertions.sol"]["Assertions"]["abi"]
        functions = [entry for entry in abi if entry["type"] == "function"]
        judges = [entry for entry in functions if entry["name"] == "assertBatch"]
        self.assertEqual(len(judges), 2)
        interface = self.original["contracts"]["contracts/lib/ERC8211.sol"]["IComposableExecution"]["abi"]
        executor = next(entry for entry in interface if entry.get("name") == "executeComposable")
        self.assertEqual(executor["stateMutability"], "payable")
        for judge in judges:
            self.assertEqual(judge["stateMutability"], "view")
            self.assertEqual(judge["inputs"][0]["type"], executor["inputs"][0]["type"])
            self.assertEqual(judge["inputs"][0]["components"], executor["inputs"][0]["components"])
        self.assertNotIn("executeComposable", {entry["name"] for entry in functions})
        self.assertFalse(any(entry["stateMutability"] == "payable" for entry in functions))
        self.assertFalse(any(entry["type"] in ("receive", "fallback") for entry in abi))


if __name__ == "__main__":
    unittest.main(verbosity=2)
