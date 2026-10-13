import { describe, expect, it } from "vitest";

import { compileAssertionLine } from "../compile-adapter";
import { evml } from "../evml";
import { HELPER_MODULES, HELPER_OWNER, REGISTRIES, ownerOf } from "../helper-owners";
import { type ExecutionContext, contextVariables } from "../context";
import { type Naming, insertAssertionLines, isHelperLoad } from "../script-ops";
import { prepareSuggestion } from "../suggested-checks";
import { buildFinalScript } from "../wrap";
import { NATIVE, OWNER as OWNED_BY, RECEIVED, SPENT } from "./helpers/suggestions";

// Only modules registered with the builder's tag are asked for suggested
// checks (see suggestFromRun in @evmcrispr/module-sim).
const SAFE = "0x5Afe000000000000000000000000000000005afe";
const PROXY = "0x00000000000000000000000000000000000000cc";
const IMPL = "0x00000000000000000000000000000000000000dd";
const REGISTRY = "0x00000000000000000000000000000000000000bb";
const ACTION = `exec ${PROXY} "upgradeTo(address)" ${IMPL}`;
const UPGRADED = `assert @proxies:implementation!(${PROXY}) == ${IMPL}`;
const ENS_OWNER = `assert ${REGISTRY}::!{owner(bytes32)(address) 0x${"ab".repeat(32)}} == ${IMPL}`;
const tag = evml.with({ chainId: 1, account: SAFE });

describe("the modules suggestions come from", () => {
  it("registers every module that declares events, ens and proxies included", () => {
    for (const module of ["token", "acl", "safe", "governor", "aragonosx", "ens", "proxies"])
      expect(evml.registry.has(module), module).toBe(true);
  });

  it("loads the two modules and finds their event declarations", async () => {
    for (const module of ["ens", "proxies"]) {
      const { default: ctor } = await evml.registry.get(module)!();
      expect(Object.keys((ctor as { events?: object }).events ?? {}).length, module)
        .toBeGreaterThan(0);
    }
  });

  it("owns the proxy faces a suggestion uses, so their load is scaffolding", () => {
    expect(Object.keys(REGISTRIES)).toContain("proxies");
    for (const face of ["implementation!", "admin!", "beacon!"])
      expect(HELPER_OWNER[face]).toBe("proxies");
    expect(HELPER_MODULES).toContain("proxies");
    expect(isHelperLoad("load proxies")).toBe(true);
  });

  it("keeps ens out of the unprefixed faces: its owner! would be acl's too", () => {
    expect(Object.keys(REGISTRIES)).not.toContain("ens");
    expect(ownerOf({ name: "owner!" })).toBe("acl");
    // Written with its prefix it is still loaded.
    expect(ownerOf({ module: "ens", name: "owner!" })).toBe("ens");
  });

  it("compiles a proxy check and an ENS check added to a batch", async () => {
    const proxy = await compileAssertionLine(tag, ACTION, UPGRADED, [], "post");
    expect(proxy.diagnostics).toEqual([]);
    expect(proxy.candidate.split("\n")).toEqual(["load proxies", ACTION, UPGRADED]);
    const ens = await compileAssertionLine(tag, ACTION, ENS_OWNER, [], "post");
    expect(ens.diagnostics).toEqual([]);
    expect(ens.candidate.split("\n")).toEqual([ACTION, ENS_OWNER]);
  });

  it("validates the final script with both, the load hoisted above the wrapper", async () => {
    let block = insertAssertionLines(ACTION, UPGRADED, "post").script;
    block = insertAssertionLines(block, ENS_OWNER, "post").script;
    const final = buildFinalScript(block, { kind: "safe", address: SAFE }, 1);
    expect(final.split("\n").slice(0, 2)).toEqual(["load safe", "load proxies"]);
    const { valid, diagnostics } = await tag.script(final).validate();
    expect(diagnostics.filter((d) => d.severity === "error")).toEqual([]);
    expect(valid).toBe(true);
  });

  describe("a batch with added suggestions, wrapped for each executor", () => {
    // As the builder adds them: the account that executes has the name
    // the context gives it.
    const blockFor = (context: ExecutionContext) => {
      let managed: Naming["managed"];
      return [SPENT, RECEIVED, OWNED_BY, NATIVE].reduce((script, check) => {
        const bound = prepareSuggestion(script, check, {
          managed,
          context: contextVariables(context, { connected: SAFE, resolved: SAFE }),
        });
        managed = bound.managed;
        return insertAssertionLines(bound.script, bound.line, "post", bound.sets).script;
      }, ACTION);
    };
    const block = blockFor({ kind: "eoa" });
    const contexts = [
      [{ kind: "eoa" }, "batch ("],
      [{ kind: "safe", address: SAFE }, "safe:propose $safe ("],
      [{ kind: "governor", address: SAFE, description: "d" }, 'governor:propose $proposalId $governor "d" ('],
      [{ kind: "aragonosx", address: SAFE, plugin: "token-voting" }, "aragonosx:connect $dao ("],
    ] as const;

    it("keeps a variable inside the block when the executor's own name uses that name", () => {
      const named = `set $dao ${SAFE}\n${ACTION}\nassert $dao::!{paused()(bool)} == false`;
      const final = buildFinalScript(named, { kind: "safe", address: "dao.eth" }, 1);
      const lines = final.split("\n");
      const opener = lines.findIndex((l) => l.startsWith("safe:propose"));
      expect(lines.indexOf("set $dao @ens(dao.eth)")).toBeLessThan(opener);
      expect(lines.indexOf(`  set $dao ${SAFE}`)).toBeGreaterThan(opener);
    });

    it("is valid as the builder simulates it, on its own", async () => {
      expect(block.split("\n").slice(0, 2)).toEqual(["load token", "load acl"]);
      const { valid, diagnostics } = await tag.script(block).validate();
      expect(diagnostics.filter((d) => d.severity === "error")).toEqual([]);
      expect(valid).toBe(true);
    });

    it.each(contexts)("is valid for %o", async (context, opener) => {
      const final = buildFinalScript(blockFor(context), context, 1);
      const lines = final.split("\n");
      // Loads above the wrapper, each once; the variables set before the
      // checks that use them.
      expect(lines.filter((l) => l === "load token")).toHaveLength(1);
      expect(lines.indexOf("load token")).toBeLessThan(lines.indexOf(opener));
      const at = (text: string) => lines.findIndex((l) => l.trim() === text);
      const account = { eoa: "executor", safe: "safe", governor: "governor", aragonosx: "dao" }[context.kind];
      expect(final).toContain(`@balance!($usdc $${account})`);
      // Who received is also the new owner: neither role names it.
      for (const name of ["usdc", account, "address", "contract"])
        expect(lines.filter((l) => l.trim().startsWith(`set $${name} `))).toHaveLength(1);
      // Addresses are pinned once, above the wrapper, after the loads.
      const set = at(`set $usdc ${SPENT.vars![0].value}`);
      expect(set).toBeGreaterThan(lines.indexOf("load token"));
      expect(set).toBeLessThan(lines.indexOf(opener));
      expect(lines[set]).toBe(lines[set].trim());
      expect(at(SPENT.line.replace("$executor", `$${account}`))).toBeGreaterThan(lines.indexOf(opener));
      const { valid, diagnostics } = await tag.script(final).validate();
      expect(diagnostics.filter((d) => d.severity === "error")).toEqual([]);
      expect(valid).toBe(true);
    });
  });
});
