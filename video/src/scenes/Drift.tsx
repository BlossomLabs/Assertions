import React from 'react';
import { AbsoluteFill, interpolate, useCurrentFrame } from 'remotion';
import { C, MONO, SANS, pop, ramp } from '../theme';
import { cue } from '../timing';

const DAYS = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];

const Chain: React.FC<{ frame: number; speedUpAt: number }> = ({ frame, speedUpAt }) => {
  // Blocks keep arriving from the right; after "the chain has moved" they run faster.
  const slow = Math.min(frame, speedUpAt) * 2.2;
  const fast = Math.max(0, frame - speedUpAt) * 7;
  const x = slow + fast;
  const W = 180;
  const first = Math.floor(x / W);
  return (
    <div style={{ position: 'absolute', left: 0, right: 0, top: 760, height: 96, overflow: 'hidden' }}>
      {Array.from({ length: 16 }, (_, k) => {
        const n = first + k;
        const left = n * W - x;
        return (
          <div
            key={n}
            style={{
              position: 'absolute',
              left,
              top: 10,
              width: W - 30,
              height: 76,
              borderRadius: 12,
              border: `2px solid ${C.bp400}55`,
              background: `${C.surface3}cc`,
              fontFamily: MONO,
              fontSize: 19,
              color: C.ink2,
              display: 'grid',
              placeItems: 'center',
            }}
          >
            #{(21_400_000 + n).toLocaleString('en-US')}
          </div>
        );
      })}
      <div style={{ position: 'absolute', inset: 0, background: `linear-gradient(90deg, ${C.surface} 0%, transparent 12%, transparent 88%, ${C.surface} 100%)` }} />
    </div>
  );
};

const Change: React.FC<{ frame: number; at: number; icon: React.ReactNode; label: string; detail: string; top: number }> = ({
  frame,
  at,
  icon,
  label,
  detail,
  top,
}) => {
  const p = pop(frame, at);
  return (
    <div
      style={{
        position: 'absolute',
        left: 1010,
        top,
        width: 760,
        height: 150,
        borderRadius: 22,
        background: C.surface2,
        border: `2px solid ${C.err}88`,
        display: 'flex',
        alignItems: 'center',
        gap: 30,
        padding: '0 34px',
        opacity: p,
        transform: `translateX(${(1 - p) * 120}px)`,
        boxShadow: '0 18px 40px rgba(0,0,0,0.35)',
      }}
    >
      <div style={{ width: 92, height: 92, flex: 'none' }}>{icon}</div>
      <div>
        <div style={{ fontFamily: SANS, fontWeight: 600, fontSize: 38, color: C.ink }}>{label}</div>
        <div style={{ fontFamily: MONO, fontSize: 24, color: C.err, marginTop: 6 }}>{detail}</div>
      </div>
    </div>
  );
};

/** Beats 2 and 3: signed on Monday, executed on Friday, and what moved in between. `b3` is beat 3's start inside this scene. */
export const Drift: React.FC<{ b3: number }> = ({ b3 }) => {
  const frame = useCurrentFrame();
  const sign = ramp(frame, cue(0.2), 1.8);
  // The week advances on "It executes on Friday."
  const day = interpolate(frame, [cue(2.6), cue(3.7)], [0, 4], { extrapolateLeft: 'clamp', extrapolateRight: 'clamp' });
  const card = pop(frame, 0);
  const stale = pop(frame, b3 + cue(6.68));

  return (
    <AbsoluteFill>
      <div style={{ position: 'absolute', top: 80, left: 0, right: 0, display: 'flex', justifyContent: 'center', gap: 26 }}>
        {DAYS.map((d, i) => {
          const on = Math.max(0, 1 - Math.abs(day - i));
          return (
            <div
              key={d}
              style={{
                width: 150,
                padding: '16px 0',
                textAlign: 'center',
                borderRadius: 14,
                fontFamily: MONO,
                fontSize: 30,
                fontWeight: 500,
                color: on > 0.5 ? C.surface : C.ink2,
                background: `rgba(96,165,250,${0.12 + on * 0.88})`,
              }}
            >
              {d}
            </div>
          );
        })}
      </div>

      <div
        style={{
          position: 'absolute',
          left: 150,
          top: 230,
          width: 760,
          height: 470,
          borderRadius: 28,
          background: C.surface2,
          border: `2px solid ${C.bp400}55`,
          padding: 44,
          opacity: card,
          transform: `scale(${0.9 + card * 0.1})`,
          boxShadow: '0 30px 60px rgba(0,0,0,0.4)',
        }}
      >
        <div style={{ fontFamily: MONO, fontSize: 26, color: C.ink2, letterSpacing: 2 }}>SAFE OR DAO TRANSACTION</div>
        <div style={{ fontFamily: SANS, fontWeight: 600, fontSize: 44, color: C.ink, marginTop: 14 }}>Treasury batch · 3 actions</div>
        <svg width="560" height="150" viewBox="0 0 560 150" style={{ marginTop: 30 }}>
          <path
            d="M10 110 C 60 20, 90 20, 110 90 S 160 140, 190 70 S 240 20, 270 90 S 330 120, 360 60 S 420 40, 450 95 L 540 95"
            fill="none"
            stroke={C.bp300}
            strokeWidth="5"
            strokeLinecap="round"
            pathLength={1}
            strokeDasharray={1}
            strokeDashoffset={1 - sign}
          />
          <line x1="0" y1="130" x2="560" y2="130" stroke={C.ink3} strokeWidth="2" />
        </svg>
        <div style={{ display: 'flex', gap: 16, marginTop: 24, alignItems: 'center' }}>
          <div style={{ fontFamily: MONO, fontSize: 26, color: C.ok, opacity: sign }}>Signed · Mon</div>
          <div
            style={{
              fontFamily: MONO,
              fontSize: 26,
              color: C.ink2,
              padding: '6px 14px',
              borderRadius: 10,
              border: `2px dashed ${C.ink3}`,
              opacity: stale,
              transform: `rotate(-4deg) scale(${1.4 - stale * 0.4})`,
            }}
          >
            Simulation · valid Mon only
          </div>
        </div>
      </div>

      <Change
        frame={frame}
        at={b3}
        top={230}
        label="Price"
        detail="ETH/USD −18%"
        icon={
          <svg viewBox="0 0 92 92">
            <rect width="92" height="92" rx="18" fill={`${C.err}22`} />
            <polyline
              points={`12,30 30,${interpolate(frame, [b3, b3 + 20], [34, 40], { extrapolateLeft: 'clamp', extrapolateRight: 'clamp' })} 48,32 64,${interpolate(frame, [b3, b3 + 20], [36, 70], { extrapolateLeft: 'clamp', extrapolateRight: 'clamp' })} 80,${interpolate(frame, [b3, b3 + 20], [34, 76], { extrapolateLeft: 'clamp', extrapolateRight: 'clamp' })}`}
              fill="none"
              stroke={C.err}
              strokeWidth="6"
              strokeLinejoin="round"
            />
          </svg>
        }
      />
      <Change
        frame={frame}
        at={b3 + cue(1.53)}
        top={400}
        label="Signers"
        detail="1 owner swapped"
        icon={
          <svg viewBox="0 0 92 92">
            <rect width="92" height="92" rx="18" fill={`${C.err}22`} />
            <circle cx="34" cy="34" r="13" fill={C.ink2} />
            <path d="M12 76 C12 54, 56 54, 56 76 Z" fill={C.ink2} />
            <circle cx="66" cy="44" r="12" fill={C.err} />
            <path d="M46 84 C46 64, 86 64, 86 84 Z" fill={C.err} />
          </svg>
        }
      />
      <Change
        frame={frame}
        at={b3 + cue(3.06)}
        top={570}
        label="Contract upgraded"
        detail="by an earlier proposal"
        icon={
          <svg viewBox="0 0 92 92">
            <rect width="92" height="92" rx="18" fill={`${C.err}22`} />
            <rect x="20" y="16" width="44" height="58" rx="6" fill="none" stroke={C.ink2} strokeWidth="5" />
            <circle cx="62" cy="62" r="16" fill={C.surface2} stroke={C.err} strokeWidth="6" strokeDasharray="7 5" />
          </svg>
        }
      />

      <Chain frame={frame} speedUpAt={cue(4.45)} />
    </AbsoluteFill>
  );
};
