import { useLayoutEffect, useRef, useState } from "react";

type Phase = { current: number; previous: number | null };

/**
 * Cycles through words with a staggered per-letter rise animation and a
 * smooth width transition, in the style of reactbits' RotatingText.
 */
export default function RotatingText({
  words,
  interval = 2600,
}: {
  words: string[];
  interval?: number;
}) {
  const [phase, setPhase] = useState<Phase>({ current: 0, previous: null });
  const [width, setWidth] = useState<number>();
  const measureRefs = useRef<(HTMLSpanElement | null)[]>([]);

  useLayoutEffect(() => {
    const el = measureRefs.current[phase.current];
    if (el) setWidth(el.offsetWidth);
  }, [phase]);

  useLayoutEffect(() => {
    const id = setInterval(() => {
      setPhase((p) => ({
        current: (p.current + 1) % words.length,
        previous: p.current,
      }));
    }, interval);
    return () => clearInterval(id);
  }, [words.length, interval]);

  const letters = (word: string) =>
    word.split("").map((ch, i) => (
      <span
        key={i}
        className="rt-letter"
        style={{ animationDelay: `${i * 25}ms` }}
      >
        {ch}
      </span>
    ));

  return (
    <span className="rt" style={width ? { width } : undefined}>
      <style>{`
        .rt {
          display: inline-flex;
          position: relative;
          overflow: hidden;
          vertical-align: bottom;
          transition: width 0.35s cubic-bezier(0.22, 1, 0.36, 1);
        }
        .rt-word { display: inline-flex; white-space: pre; }
        .rt-word.rt-prev { position: absolute; inset: 0; }
        .rt-measure {
          position: absolute;
          visibility: hidden;
          pointer-events: none;
          white-space: pre;
        }
        .rt-letter {
          display: inline-block;
          animation: rt-in 0.4s cubic-bezier(0.22, 1, 0.36, 1) both;
        }
        .rt-prev .rt-letter {
          animation: rt-out 0.3s cubic-bezier(0.55, 0, 0.55, 0.2) both;
        }
        @keyframes rt-in {
          from { transform: translateY(110%); opacity: 0; }
          to { transform: none; opacity: 1; }
        }
        @keyframes rt-out {
          from { transform: none; opacity: 1; }
          to { transform: translateY(-110%); opacity: 0; }
        }
        @media (prefers-reduced-motion: reduce) {
          .rt { transition: none; }
          .rt-letter { animation: none; }
          .rt-prev { display: none; }
        }
      `}</style>
      {words.map((word, i) => (
        <span
          key={word}
          ref={(el) => {
            measureRefs.current[i] = el;
          }}
          className="rt-measure"
          aria-hidden="true"
        >
          {word}
        </span>
      ))}
      {phase.previous !== null && (
        <span
          key={`prev-${phase.previous}`}
          className="rt-word rt-prev"
          aria-hidden="true"
        >
          {letters(words[phase.previous])}
        </span>
      )}
      <span key={`cur-${phase.current}`} className="rt-word">
        {letters(words[phase.current])}
      </span>
    </span>
  );
}
