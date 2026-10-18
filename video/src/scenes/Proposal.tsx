import React from 'react';
import { AbsoluteFill, interpolate, useCurrentFrame } from 'remotion';
import { Block, Gate, GateState } from '../parts';
import { C, MONO, SANS, pop } from '../theme';
import { cue } from '../timing';

/** One check the proposer writes for this vote: its claim, a picture of it, and the assert line being typed. */
const Check: React.FC<{ frame: number; at: number; okAt: number; title: string; code: string; message: string; children?: React.ReactNode }> = ({
  frame,
  at,
  okAt,
  title,
  code,
  message,
  children,
}) => {
  const p = pop(frame, at);
  const line = `${code}\n"${message}"`;
  const typed = Math.floor(interpolate(frame, [at, at + cue(1.1)], [0, line.length], { extrapolateLeft: 'clamp', extrapolateRight: 'clamp' }));
  const [l1, l2 = ''] = line.slice(0, typed).split('\n');
  const state: GateState = frame >= okAt ? 'ok' : 'idle';
  return (
    <div
      style={{
        width: 400,
        height: 360,
        borderRadius: 24,
        background: C.surface2,
        border: `2px solid ${state === 'ok' ? C.ok : C.bp400}66`,
        padding: 26,
        opacity: p,
        transform: `translateY(${(1 - p) * 60}px)`,
        display: 'flex',
        flexDirection: 'column',
        gap: 14,
        boxShadow: '0 18px 40px rgba(0,0,0,0.35)',
      }}
    >
      <div style={{ display: 'flex', alignItems: 'center', gap: 14 }}>
        <Gate state={state} size={58} scale={state === 'ok' ? 1 + 0.25 * Math.max(0, 1 - (frame - okAt) / 10) : 1} />
        <div style={{ fontFamily: SANS, fontWeight: 600, fontSize: 32, color: C.ink, lineHeight: 1.1 }}>{title}</div>
      </div>
      <div style={{ flex: 1, display: 'grid', placeItems: 'center' }}>{children}</div>
      <div style={{ fontFamily: MONO, fontSize: 19, lineHeight: 1.35, color: state === 'ok' ? C.ok : C.bp300, minHeight: 52 }}>
        {l1}
        <br />
        <span style={{ color: state === 'ok' ? C.ok : C.ink2 }}>{l2}</span>
        {typed < line.length && <span style={{ color: C.bp400 }}>▍</span>}
      </div>
    </div>
  );
};

const AVATARS = ['#f59e0b', '#a78bfa', '#34d399', '#f472b6', '#38bdf8'];

/** Beats 5 and 6: a DAO vote and the four checks that run right after it. `b6` is beat 6's start inside this scene. */
export const Proposal: React.FC<{ b6: number }> = ({ b6 }) => {
  const frame = useCurrentFrame();
  const card = pop(frame, 0);
  const a1 = pop(frame, cue(0.9));
  const a2 = pop(frame, cue(2.45));
  const ran = frame >= cue(4.61);
  const author = pop(frame, cue(6.1));
  // Signers are ticked against the list across "Every signer is on the approved list."
  const ticked = Math.floor(interpolate(frame, [b6 + cue(0.1), b6 + cue(1.5)], [0, 5], { extrapolateLeft: 'clamp', extrapolateRight: 'clamp' }));
  const dial = interpolate(frame, [b6 + cue(2.5), b6 + cue(3.6)], [0, 3], { extrapolateLeft: 'clamp', extrapolateRight: 'clamp' });

  return (
    <AbsoluteFill>
      <div
        style={{
          position: 'absolute',
          left: 160,
          right: 160,
          top: 60,
          height: 150,
          borderRadius: 24,
          background: C.surface2,
          border: `2px solid ${C.bp400}55`,
          display: 'flex',
          alignItems: 'center',
          gap: 30,
          padding: '0 36px',
          opacity: card,
        }}
      >
        <div style={{ fontFamily: MONO, fontSize: 24, color: C.ink2, letterSpacing: 2, width: 170 }}>DAO VOTE</div>
        <div style={{ opacity: a1, transform: `scale(${0.8 + a1 * 0.2})` }}>
          <Block label="Upgrade the vault" width={430} done={ran} />
        </div>
        <div style={{ fontFamily: SANS, fontSize: 44, color: C.ink3, opacity: a2 }}>→</div>
        <div style={{ opacity: a2, transform: `scale(${0.8 + a2 * 0.2})` }}>
          <Block label="Admin → council Safe" width={480} done={ran} />
        </div>
      </div>

      <div style={{ position: 'absolute', top: 236, left: 0, right: 0, display: 'flex', justifyContent: 'center', opacity: author }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 14, fontFamily: MONO, fontSize: 26, color: C.bp300, letterSpacing: 1 }}>
          <svg width="30" height="30" viewBox="0 0 30 30">
            <path d="M4 26 L6 19 L20 5 L25 10 L11 24 Z" fill="none" stroke={C.bp300} strokeWidth="2.5" strokeLinejoin="round" />
          </svg>
          written by the proposer, for this vote
        </div>
      </div>
      <div style={{ position: 'absolute', top: 290, left: 0, right: 0, display: 'flex', justifyContent: 'center', gap: 30 }}>
        <Check frame={frame} at={cue(6.3)} okAt={cue(8.6)} title="Council owns the vault" code="assert owner == $councilSafe" message="handover didn't land">
          <svg width="300" height="130" viewBox="0 0 300 130">
            <rect x="10" y="30" width="90" height="80" rx="12" fill="none" stroke={C.ink2} strokeWidth="5" />
            <circle cx="55" cy="70" r="14" fill="none" stroke={C.ink2} strokeWidth="5" />
            <path d="M120 70 H190" stroke={C.bp400} strokeWidth="6" markerEnd="url(#arr)" />
            <defs>
              <marker id="arr" markerWidth="8" markerHeight="8" refX="4" refY="4" orient="auto">
                <path d="M0 0 L8 4 L0 8 Z" fill={C.bp400} />
              </marker>
            </defs>
            <path d="M210 40 L245 22 L280 40 V80 C280 100 262 112 245 118 C228 112 210 100 210 80 Z" fill={`${C.ok}22`} stroke={C.ok} strokeWidth="5" />
          </svg>
        </Check>
        <Check frame={frame} at={cue(6.6)} okAt={cue(10.35)} title="Code is the audited build" code="assert code == 0xdfff…9ca9" message="unaudited code">
          <svg width="300" height="130" viewBox="0 0 300 130">
            {Array.from({ length: 6 }, (_, i) => (
              <path
                key={i}
                d={`M${150 - 20 - i * 12} ${120} C ${150 - 20 - i * 12} ${40 - i * 6}, ${150 + 20 + i * 12} ${40 - i * 6}, ${150 + 20 + i * 12} 120`}
                fill="none"
                stroke={frame >= cue(10.35) ? C.ok : C.ink2}
                strokeWidth="4"
                strokeLinecap="round"
              />
            ))}
          </svg>
        </Check>
        <Check frame={frame} at={cue(6.9)} okAt={b6 + cue(1.6)} title="Every signer approved" code="assert all owners on $council" message="unknown signer">
          <div style={{ display: 'flex', gap: 12 }}>
            {AVATARS.map((c, i) => (
              <div key={c} style={{ position: 'relative' }}>
                <div style={{ width: 46, height: 46, borderRadius: 23, background: c, opacity: 0.9 }} />
                {i < ticked && (
                  <div style={{ position: 'absolute', right: -6, bottom: -6, width: 24, height: 24, borderRadius: 12, background: C.ok, color: C.surface, fontFamily: SANS, fontWeight: 700, fontSize: 18, display: 'grid', placeItems: 'center' }}>
                    ✓
                  </div>
                )}
              </div>
            ))}
          </div>
        </Check>
        <Check frame={frame} at={cue(7.2)} okAt={b6 + cue(3.7)} title="At least three to sign" code="assert threshold >= 3" message="threshold too low">
          <svg width="200" height="130" viewBox="0 0 200 130">
            <path d="M20 110 A80 80 0 0 1 180 110" fill="none" stroke={C.surface3} strokeWidth="16" strokeLinecap="round" />
            <path
              d="M20 110 A80 80 0 0 1 180 110"
              fill="none"
              stroke={dial >= 3 ? C.ok : C.bp400}
              strokeWidth="16"
              strokeLinecap="round"
              pathLength={1}
              strokeDasharray={1}
              strokeDashoffset={1 - dial / 5}
            />
            <text x="100" y="112" textAnchor="middle" fontFamily={SANS} fontWeight="700" fontSize="56" fill={C.ink}>
              {Math.round(dial)}
            </text>
          </svg>
        </Check>
      </div>
    </AbsoluteFill>
  );
};
