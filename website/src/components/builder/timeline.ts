import { type SimKey, type SimulationState, isFresh } from "./simulation";

/** The pose of the eye that stands for a simulation of the batch. */
export type EyeState = "asleep" | "stale" | "running" | "pass" | "fail";

/** The eye's pose for a simulation of the current batch. */
export function eyeStateFor(
  state: SimulationState,
  key: SimKey,
  hasScript: boolean,
): EyeState {
  if (!hasScript) return "asleep";
  if (state.status === "running") return "running";
  if (!isFresh(state, key)) return "stale";
  return state.status === "success" ? "pass" : "fail";
}
