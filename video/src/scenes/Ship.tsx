import React from 'react';
import { AbsoluteFill, interpolate, useCurrentFrame } from 'remotion';
import { Gate } from '../parts';
import { C, MONO, SANS, pop, ramp } from '../theme';
import { cue } from '../timing';

const DEST = [
  { at: 1.0, label: 'Safe transaction', x: 380 },
  { at: 2.7, label: 'Governor proposal', x: 960 },
  { at: 4.0, label: 'Wallet batch', x: 1540 },
];

const Icon: React.FC<{ i: number; color: string }> = ({ i, color }) => (
  <svg width="120" height="120" viewBox="0 0 120 120">
    {i === 0 && (
      <>
        <rect x="18" y="22" width="84" height="76" rx="12" fill="none" stroke={color} strokeWidth="6" />
        <circle cx="60" cy="60" r="18" fill="none" stroke={color} strokeWidth="6" />
        <path d="M60 42 V50 M60 70 V78 M42 60 H50 M70 60 H78" stroke={color} strokeWidth="5" />
      </>
    )}
    {i === 1 && (
      <>
        <rect x="20" y="52" width="80" height="50" rx="8" fill="none" stroke={color} strokeWidth="6" />
        <path d="M44 52 L44 22 L80 22 L80 52" fill="none" stroke={color} strokeWidth="6" />
        <path d="M52 36 L60 44 L74 30" fill="none" stroke={color} strokeWidth="6" />
      </>
    )}
    {i === 2 && (
      <>
        <rect x="16" y="30" width="88" height="64" rx="12" fill="none" stroke={color} strokeWidth="6" />
        <path d="M16 46 H90" stroke={color} strokeWidth="6" />
        <circle cx="84" cy="70" r="6" fill={color} />
      </>
    )}
  </svg>
);

/** Beat 9: the batch ships as a Safe transaction, a Governor proposal or a wallet batch; nothing to deploy. */
export const Ship: React.FC = () => {
  const frame = useCurrentFrame();
  const batch = pop(frame, 0);
  const none = pop(frame, cue(5.6));

  return (
    <AbsoluteFill>
      <div
        style={{
          position: 'absolute',
          left: 960 - 230,
          top: 90,
          width: 460,
          padding: 28,
          borderRadius: 24,
          background: C.surface2,
          border: `2px solid ${C.bp400}66`,
          opacity: batch,
          transform: `scale(${0.85 + batch * 0.15})`,
          display: 'flex',
          alignItems: 'center',
          gap: 18,
        }}
      >
        <Gate state="ok" size={60} />
        <div>
          <div style={{ fontFamily: MONO, fontSize: 22, color: C.ink2, letterSpacing: 2 }}>PROTECTED BATCH</div>
          <div style={{ fontFamily: SANS, fontWeight: 600, fontSize: 32, color: C.ink }}>2 actions · 4 assertions</div>
        </div>
      </div>

      {DEST.map((d, i) => {
        const arrive = pop(frame, cue(d.at));
        const fly = ramp(frame, cue(d.at - 0.5), 0.5);
        const fromX = 960;
        const fromY = 200;
        const toY = 470;
        const x = interpolate(fly, [0, 1], [fromX, d.x]);
        const y = interpolate(fly, [0, 1], [fromY, toY]) - Math.sin(fly * Math.PI) * 80;
        const lit = frame >= cue(d.at);
        return (
          <React.Fragment key={d.label}>
            {fly > 0 && fly < 1 && (
              <div style={{ position: 'absolute', left: x - 18, top: y - 18, width: 36, height: 36, borderRadius: 10, background: C.bp400, boxShadow: `0 0 30px ${C.bp400}` }} />
            )}
            <div
              style={{
                position: 'absolute',
                left: d.x - 200,
                top: 400,
                width: 400,
                height: 300,
                borderRadius: 26,
                background: C.surface2,
                border: `2px solid ${lit ? C.ok : C.ink3}${lit ? 'aa' : '55'}`,
                display: 'flex',
                flexDirection: 'column',
                alignItems: 'center',
                justifyContent: 'center',
                gap: 18,
                opacity: 0.35 + arrive * 0.65,
                transform: `scale(${0.95 + arrive * 0.05})`,
              }}
            >
              <Icon i={i} color={lit ? C.ok : C.ink2} />
              <div style={{ fontFamily: SANS, fontWeight: 600, fontSize: 36, color: C.ink }}>{d.label}</div>
            </div>
          </React.Fragment>
        );
      })}

      <div style={{ position: 'absolute', top: 740, left: 0, right: 0, display: 'flex', justifyContent: 'center', opacity: none, transform: `translateY(${(1 - none) * 30}px)` }}>
        <div style={{ fontFamily: MONO, fontSize: 32, color: C.bp300, padding: '14px 28px', borderRadius: 14, border: `2px solid ${C.bp400}55` }}>
          contracts already on-chain · 0 to deploy
        </div>
      </div>
    </AbsoluteFill>
  );
};
