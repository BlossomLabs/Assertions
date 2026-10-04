// Argos's eyes are shy. While the pointer is moving, any eye it passes near
// shuts; once the pointer rests or leaves, the eye opens again. No two eyes
// have the same nerve: each has its own reach, takes its own time to react
// and to dare open again, and moves its lid at its own speed. Eyes marked
// data-doze also close on their own now and then.
//
// An eye closes the way a lid does: its upper edge comes down onto the lower
// one, so the outline keeps its stroke and a shut eye is a single curve. A
// field (data-shy-field) gives the shape all its eyes share, drawn around each
// eye's own origin: data-shy-half (half the width) and data-shy-upper and
// data-shy-lower (the control points of the two lids). It may set
// data-shy-radius. Each eye (data-shy-eye, with data-x and data-y giving its
// centre in the field's units) holds its outlines as data-lid paths, one of
// them inside the clip path that hides the pupil, and may hold data-lash paths
// that follow the upper lid alone and vanish when it is shut. Without script, or under reduced motion,
// every eye rests as drawn.
const RESTING_AFTER = 350; // ms without movement before the pointer counts as still

const lerp = (a: number, b: number, t: number) => a + (b - a) * t;

const reduced = matchMedia("(prefers-reduced-motion: reduce)").matches;
for (const field of reduced ? [] : document.querySelectorAll<SVGGElement>("[data-shy-field]")) {
  const radius = Number(field.dataset.shyRadius ?? 110);
  const half = Number(field.dataset.shyHalf);
  const upper = Number(field.dataset.shyUpper);
  const lower = Number(field.dataset.shyLower);
  const eyes = [...field.querySelectorAll<SVGGElement>("[data-shy-eye]")].map((el) => ({
    lids: el.querySelectorAll<SVGElement>("[data-lid]"),
    lashes: [...el.querySelectorAll<SVGElement>("[data-lash]")].map(
      (lash) => [lash, Number(lash.getAttribute("stroke-width"))] as const,
    ),
    x: Number(el.dataset.x),
    y: Number(el.dataset.y),
    dozes: "doze" in el.dataset,
    // data-doze may carry a number: how many times rarer than usual the dozes are
    rarity: Number(el.dataset.doze) || 1,
    dozeAt: (1500 + Math.random() * 6000) * (Number(el.dataset.doze) || 1),
    dozeFor: 700 + Math.random() * 1500,
    reach: radius * (0.65 + Math.random() * 0.7),
    flinchAfter: Math.random() * 280,
    reopenAfter: Math.random() * 700,
    speed: 5 + Math.random() * 9,
    since: 0, // when the eye's situation last changed
    startled: false,
    shut: 0,
    drawn: 0,
  }));
  let pointer: DOMPoint | null = null;
  let movedAt = -Infinity;
  let last = 0;
  let frame = 0;

  addEventListener(
    "pointermove",
    (e) => {
      const toScreen = field.getScreenCTM();
      pointer = toScreen && new DOMPoint(e.clientX, e.clientY).matrixTransform(toScreen.inverse());
      movedAt = performance.now();
    },
    { passive: true },
  );

  const draw = (now: number) => {
    frame = requestAnimationFrame(draw);
    const dt = Math.min(0.05, (now - last) / 1000);
    last = now;
    const moving = pointer !== null && now - movedAt < RESTING_AFTER;

    for (const eye of eyes) {
      if (eye.dozes && now > eye.dozeAt + eye.dozeFor) {
        eye.dozeAt = now + (3000 + Math.random() * 7000) * eye.rarity;
        eye.dozeFor = 700 + Math.random() * 1500;
      }
      const dozing = eye.dozes && now > eye.dozeAt;
      const startled = moving && Math.hypot(pointer!.x - eye.x, pointer!.y - eye.y) < eye.reach;
      if (startled !== eye.startled) {
        eye.startled = startled;
        eye.since = now;
      }
      // The lid follows the change only after this eye's own hesitation.
      const settled = now - eye.since > (startled ? eye.flinchAfter : eye.reopenAfter);
      const closing = (settled ? startled : !startled) || dozing;
      eye.shut = lerp(eye.shut, closing ? 1 : 0, 1 - Math.exp(-dt * eye.speed));
      if (Math.abs(eye.shut - eye.drawn) < 0.002) continue;
      eye.drawn = eye.shut;
      const lid = `M${-half} 0 Q0 ${lerp(upper, lower, eye.shut).toFixed(2)} ${half} 0`;
      for (const el of eye.lids) el.setAttribute("d", `${lid} Q0 ${lower} ${-half} 0 Z`);
      // A lash rides the upper lid and thins away as the eye shuts, leaving the outline.
      for (const [el, width] of eye.lashes) {
        el.setAttribute("d", lid);
        el.setAttribute("stroke-width", (width * (1 - eye.shut)).toFixed(2));
      }
    }
  };

  // Only spend frames while the field is on screen.
  new IntersectionObserver(([entry]) => {
    cancelAnimationFrame(frame);
    if (entry.isIntersecting) {
      last = performance.now();
      frame = requestAnimationFrame(draw);
    }
  }).observe(field);
}
