// @vitest-environment jsdom
import { render, screen } from "@testing-library/react";
import { describe, expect, it } from "vitest";

import { SimRing } from "../SimRing";
import type { EyeState } from "../timeline";

const STATES: EyeState[] = ["asleep", "stale", "running", "pass", "fail"];
/** The play triangle of a failure, and the exclamation mark at its corner. */
const FAIL_PLAY = "M9.5 7.5v9l7-4.5z";
const FAIL_BADGE = "M18.5 16v2.6M18.5 21v.1";
const PLAY = "M10 8.5v7l5.5-3.5z";
const TICK = "m8 12.3 2.7 2.7 5.3-6";

const draw = (state: EyeState) => {
  const { container } = render(<SimRing state={state} />);
  const ring = container.querySelector("svg > circle");
  if (!ring) throw new Error("no ring drawn");
  const paths = [...container.querySelectorAll("svg > path")].map((p) =>
    p.getAttribute("d"),
  );
  return { container, ring, paths };
};

describe("SimRing", () => {
  it.each(STATES)("draws one ring for %s and says which state it is", (state) => {
    const { container } = draw(state);
    expect(container.querySelectorAll("svg")).toHaveLength(1);
    expect(container.querySelectorAll("svg > circle")).toHaveLength(1);
    expect(container.firstElementChild?.getAttribute("data-state")).toBe(state);
  });

  it("is solid only on a pass: every other state keeps the ring dashed", () => {
    const dashed = Object.fromEntries(
      STATES.map((state) => [state, draw(state).ring.hasAttribute("stroke-dasharray")]),
    );
    expect(dashed).toEqual({
      asleep: true,
      stale: true,
      running: true,
      pass: false,
      fail: true,
    });
  });

  it("is empty while asleep", () => {
    expect(draw("asleep").paths).toEqual([]);
  });

  it("shows the play triangle while a run is due or under way", () => {
    expect(draw("stale").paths).toEqual([PLAY]);
    expect(draw("running").paths).toEqual([PLAY]);
  });

  it("turns the ring only while running", () => {
    const spins = (state: EyeState) =>
      (draw(state).ring.getAttribute("class") ?? "").includes("animate-spin");
    expect(STATES.filter(spins)).toEqual(["running"]);
  });

  it("shows a tick on a pass", () => {
    expect(draw("pass").paths).toEqual([TICK]);
  });

  it("shows the play triangle plus the exclamation badge on a failure", () => {
    const { paths, ring, container } = draw("fail");
    expect(paths).toEqual([FAIL_PLAY, FAIL_BADGE]);
    // The badge's corner is cut out of the ring through a mask of its own.
    const mask = container.querySelector("mask");
    expect(mask).not.toBeNull();
    expect(ring.getAttribute("mask")).toBe(`url(#${mask?.id})`);
  });

  it("cuts the ring for the badge on a failure only", () => {
    for (const state of STATES.filter((s) => s !== "fail")) {
      const { ring, container } = draw(state);
      expect(ring.hasAttribute("mask")).toBe(false);
      expect(container.querySelector("mask")).toBeNull();
    }
  });

  it("is decorative without a label", () => {
    const { container } = render(<SimRing state="pass" />);
    expect(screen.queryByRole("img")).toBeNull();
    expect(container.firstElementChild?.getAttribute("aria-hidden")).toBe("true");
  });

  it("is an image named by its label, which hovering also shows", () => {
    render(<SimRing state="fail" label="Simulation of the batch: failed." />);
    const ring = screen.getByRole("img", {
      name: "Simulation of the batch: failed.",
    });
    expect(ring.getAttribute("title")).toBe("Simulation of the batch: failed.");
    expect(ring.hasAttribute("aria-hidden")).toBe(false);
  });

  it("draws at the size asked for", () => {
    const { container } = render(<SimRing state="pass" size={40} />);
    const svg = container.querySelector("svg");
    expect(svg?.getAttribute("width")).toBe("40");
    expect(svg?.getAttribute("height")).toBe("40");
  });
});
