import React from 'react';
import { AbsoluteFill, Img, staticFile, useCurrentFrame } from 'remotion';
import { Mark } from '../parts';
import { C, MONO, SANS, pop, ramp } from '../theme';
import { cue } from '../timing';

// The stripes of the Byakko banner (website/src/components/ReleaseBanner.astro),
// drawn with the same seeded randomness. The seated tiger takes the place of
// the banner's eye.
const rand = (seed: number) => {
  const x = Math.sin(seed * 9301 + 49297) * 233280;
  return x - Math.floor(x);
};
const STRIPES = Array.from({ length: 16 }, (_, i) => {
  const x = -40 + i * 82 + (rand(i) - 0.5) * 24;
  const w = 14 + rand(i + 5) * 16;
  const h = 150 + rand(i + 9) * 150;
  const lean = 70 + rand(i + 3) * 40;
  const y0 = (i % 2) * -30;
  return `${x},${y0} ${x + w},${y0} ${x + w + lean * 0.5},${y0 + h * 0.6} ${x + lean},${y0 + h}`;
});

/** Beat 1: "Introducing Assertions two point oh. Byakko." The scene starts at the top of the video, `lead` frames before the voice. */
export const Title: React.FC<{ lead: number }> = ({ lead }) => {
  const frame = useCurrentFrame();
  const v = (s: number) => lead + cue(s);
  // The banner wipes in from the west, the side Byakko guards.
  const wipe = ramp(frame, 0, 1.4) * 1300;
  const word = pop(frame, v(0.15));
  // The seated tiger (the release figure) comes in after the stripes.
  const tiger = ramp(frame, cue(0.6), 1.0);
  const name = pop(frame, v(2.22));

  return (
    <AbsoluteFill>
      <svg viewBox="0 0 1200 300" style={{ position: 'absolute', top: 70, left: 0, width: 1920, height: 480 }}>
        <defs>
          <clipPath id="wipe">
            <rect x={-60} y={0} width={wipe} height={300} />
          </clipPath>
        </defs>
        <g clipPath="url(#wipe)">
          {STRIPES.map((p, i) => (
            <polygon key={i} points={p} fill={C.bp400} fillOpacity="0.22" />
          ))}
        </g>
      </svg>

      <Img
        src={staticFile('byakko-tiger.svg')}
        style={{
          position: 'absolute',
          left: 1110,
          top: 210,
          height: 690,
          opacity: tiger,
          transform: `translateY(${(1 - tiger) * 40}px)`,
          filter: 'drop-shadow(0 30px 50px rgba(0,0,0,0.45))',
        }}
      />
      <div
        style={{
          position: 'absolute',
          left: 150,
          top: 430,
          display: 'flex',
          alignItems: 'center',
          gap: 40,
          opacity: word,
          transform: `translateY(${(1 - word) * 40}px)`,
        }}
      >
        <Mark size={150} />
        <div style={{ fontFamily: SANS, fontWeight: 700, fontSize: 150, color: C.ink, letterSpacing: -3 }}>
          Assertions <span style={{ color: C.bp400 }}>2.0</span>
        </div>
      </div>
      <div
        style={{
          position: 'absolute',
          left: 340,
          top: 630,
          fontFamily: MONO,
          fontWeight: 500,
          fontSize: 64,
          letterSpacing: 18,
          color: C.bp300,
          opacity: name,
          transform: `translateX(${(1 - name) * -60}px)`,
        }}
      >
        BYAKKO
      </div>
    </AbsoluteFill>
  );
};
