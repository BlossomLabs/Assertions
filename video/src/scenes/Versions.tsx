import React from 'react';
import { AbsoluteFill, interpolate, useCurrentFrame } from 'remotion';
import { C, MONO, SANS, pop, ramp } from '../theme';
import { cue } from '../timing';

/** A value read from the chain when the batch runs: a pulsing dot and a number that moves. */
const Live: React.FC<{ frame: number; label: string; base: number; seed: number; active?: boolean }> = ({ frame, label, base, seed, active = true }) => {
  const value = active ? Math.round(base + Math.sin(frame / 9 + seed) * 14 + Math.sin(frame / 23 + seed * 3) * 9) : base;
  const pulse = active ? 0.5 + 0.5 * Math.sin(frame / 5) : 0;
  return (
    <div style={{ padding: '18px 24px', borderRadius: 16, background: C.surface3, border: `2px solid ${C.bp400}88`, minWidth: 210 }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 10, fontFamily: MONO, fontSize: 20, color: C.bp300, letterSpacing: 2 }}>
        <span style={{ width: 12, height: 12, borderRadius: 6, background: C.bp400, boxShadow: `0 0 ${6 + pulse * 14}px ${C.bp400}` }} />
        LIVE · {label}
      </div>
      <div style={{ fontFamily: MONO, fontWeight: 700, fontSize: 46, color: C.ink, marginTop: 6 }}>{value.toLocaleString('en-US')}</div>
    </div>
  );
};

const Fixed: React.FC<{ value: string }> = ({ value }) => (
  <div style={{ padding: '18px 24px', borderRadius: 16, border: `2px dashed ${C.ink3}`, minWidth: 160 }}>
    <div style={{ fontFamily: MONO, fontSize: 20, color: C.ink3, letterSpacing: 2 }}>CONSTANT</div>
    <div style={{ fontFamily: MONO, fontWeight: 700, fontSize: 46, color: C.ink2, marginTop: 6 }}>{value}</div>
  </div>
);

const Op: React.FC<{ children: React.ReactNode }> = ({ children }) => (
  <div style={{ fontFamily: MONO, fontWeight: 700, fontSize: 52, color: C.bp300 }}>{children}</div>
);

const Panel: React.FC<{ title: string; dim?: boolean; children: React.ReactNode; style?: React.CSSProperties }> = ({ title, dim, children, style }) => (
  <div
    style={{
      borderRadius: 28,
      background: C.surface2,
      border: `2px solid ${dim ? C.ink3 : C.bp400}66`,
      padding: '30px 36px',
      boxShadow: '0 24px 50px rgba(0,0,0,0.35)',
      ...style,
    }}
  >
    <div style={{ fontFamily: SANS, fontWeight: 700, fontSize: 40, color: dim ? C.ink2 : C.bp400 }}>{title}</div>
    <div style={{ display: 'flex', alignItems: 'center', gap: 24, marginTop: 24 }}>{children}</div>
  </div>
);

const Vignette: React.FC<{ frame: number; at: number; title: string; children: React.ReactNode }> = ({ frame, at, title, children }) => {
  const p = pop(frame, at);
  const lit = frame >= at;
  return (
    <div
      style={{
        width: 780,
        height: 300,
        borderRadius: 26,
        background: C.surface2,
        border: `2px solid ${lit ? C.bp400 : C.ink3}${lit ? 'aa' : '44'}`,
        padding: '24px 30px',
        opacity: 0.25 + p * 0.75,
        transform: `scale(${0.94 + p * 0.06})`,
        boxShadow: lit ? `0 0 50px ${C.bp400}33` : 'none',
      }}
    >
      <div style={{ fontFamily: MONO, fontSize: 24, color: lit ? C.bp300 : C.ink3, letterSpacing: 2 }}>{title}</div>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 20, height: 210 }}>{children}</div>
    </div>
  );
};

const Arrow: React.FC<{ color?: string }> = ({ color = C.bp400 }) => (
  <svg width="70" height="30" viewBox="0 0 70 30">
    <path d="M2 15 H58" stroke={color} strokeWidth="5" />
    <path d="M52 5 L68 15 L52 25 Z" fill={color} />
  </svg>
);

/** Beat 7: version 1 against version 2, then four ways reads chain together. */
export const Versions: React.FC = () => {
  const frame = useCurrentFrame();
  const v1 = pop(frame, 0);
  const v2 = pop(frame, cue(3.52));
  const swap = ramp(frame, cue(6.0), 0.6);
  const fail = frame >= cue(11.7);
  const items = Math.floor(interpolate(frame, [cue(13.4), cue(14.6)], [0, 8], { extrapolateLeft: 'clamp', extrapolateRight: 'clamp' }));

  return (
    <AbsoluteFill>
      <div
        style={{
          position: 'absolute',
          top: 180,
          left: 0,
          right: 0,
          display: 'flex',
          justifyContent: 'center',
          gap: 50,
          opacity: 1 - swap,
          transform: `translateY(${-swap * 80}px)`,
        }}
      >
        <div style={{ opacity: v1, transform: `translateY(${(1 - v1) * 40}px)` }}>
          <Panel title="Version 1" dim>
            <Live frame={frame} label="balance" base={1204} seed={1} />
            <Op>≥</Op>
            <Fixed value="1,000" />
          </Panel>
        </div>
        <div style={{ opacity: v2, transform: `translateY(${(1 - v2) * 40}px)` }}>
          <Panel title="Version 2">
            <Live frame={frame} label="price A" base={2431} seed={2} />
            <Op>≥</Op>
            <Live frame={frame} label="price B" base={2418} seed={5} />
          </Panel>
        </div>
      </div>

      {swap > 0 && (
        <div
          style={{
            position: 'absolute',
            top: 70,
            left: 0,
            right: 0,
            display: 'grid',
            gridTemplateColumns: '780px 780px',
            justifyContent: 'center',
            gap: 30,
            opacity: swap,
          }}
        >
          <Vignette frame={frame} at={cue(7.95)} title="DO MATH">
            <Live frame={frame} label="a" base={512} seed={3} />
            <Op>+</Op>
            <Live frame={frame} label="b" base={377} seed={7} />
          </Vignette>
          <Vignette frame={frame} at={cue(9.08)} title="FOLLOW AN ADDRESS">
            <div style={{ fontFamily: MONO, fontSize: 30, color: C.ink, padding: '16px 20px', borderRadius: 14, background: C.surface3 }}>registry</div>
            <Arrow />
            <div style={{ fontFamily: MONO, fontSize: 30, color: C.bp300 }}>0x7a3f…</div>
            <Arrow />
            <div style={{ fontFamily: MONO, fontSize: 30, color: C.ink, padding: '16px 20px', borderRadius: 14, background: C.surface3 }}>vault</div>
          </Vignette>
          <Vignette frame={frame} at={cue(11.21)} title="FALL BACK">
            <div style={{ display: 'flex', flexDirection: 'column', gap: 18 }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 16, opacity: fail ? 0.5 : 1 }}>
                <div style={{ fontFamily: MONO, fontSize: 30, color: C.ink, padding: '12px 18px', borderRadius: 14, background: C.surface3, textDecoration: fail ? 'line-through' : 'none' }}>
                  oracle
                </div>
                {fail && <div style={{ fontFamily: SANS, fontWeight: 700, fontSize: 40, color: C.err }}>✕</div>}
              </div>
              <div style={{ display: 'flex', alignItems: 'center', gap: 16, opacity: fail ? 1 : 0.3 }}>
                <Arrow color={fail ? C.ok : C.ink3} />
                <div style={{ fontFamily: MONO, fontSize: 30, color: C.ink, padding: '12px 18px', borderRadius: 14, background: C.surface3, border: `2px solid ${fail ? C.ok : 'transparent'}` }}>
                  backup oracle
                </div>
              </div>
            </div>
          </Vignette>
          <Vignette frame={frame} at={cue(13.16)} title="EVERY ITEM IN A LIST">
            {Array.from({ length: 8 }, (_, i) => (
              <div
                key={i}
                style={{
                  width: 62,
                  height: 62,
                  borderRadius: 12,
                  background: i < items ? `${C.ok}33` : C.surface3,
                  border: `2px solid ${i < items ? C.ok : C.ink3}`,
                  display: 'grid',
                  placeItems: 'center',
                  fontFamily: SANS,
                  fontWeight: 700,
                  fontSize: 30,
                  color: C.ok,
                }}
              >
                {i < items ? '✓' : ''}
              </div>
            ))}
          </Vignette>
        </div>
      )}
    </AbsoluteFill>
  );
};
