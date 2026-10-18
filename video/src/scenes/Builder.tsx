import React from 'react';
import { AbsoluteFill, interpolate, useCurrentFrame } from 'remotion';
import { Gate, Tag } from '../parts';
import { C, MONO, SANS, mix, pop, ramp } from '../theme';
import { cue } from '../timing';

const WATCH = 'Vault owner after the upgrade';

const Row: React.FC<{ children: React.ReactNode; style?: React.CSSProperties }> = ({ children, style }) => (
  <div
    style={{
      display: 'flex',
      alignItems: 'center',
      gap: 16,
      padding: '18px 22px',
      borderRadius: 14,
      background: C.surface3,
      fontFamily: SANS,
      fontSize: 28,
      color: C.ink,
      ...style,
    }}
  >
    {children}
  </div>
);

/** Beat 8: tell the builder what to watch; it suggests checks, previews live values and simulates. */
export const Builder: React.FC = () => {
  const frame = useCurrentFrame();
  const win = pop(frame, 0);
  const typed = Math.floor(interpolate(frame, [cue(1.8), cue(3.0)], [0, WATCH.length], { extrapolateLeft: 'clamp', extrapolateRight: 'clamp' }));
  const sug = [0, 1, 2].map((i) => pop(frame, cue(3.6 + i * 0.25)));
  // The first suggestion moves into the batch with its live value.
  const move = ramp(frame, cue(4.6), 0.7);
  const preview = pop(frame, cue(5.3));
  const sim = ramp(frame, cue(6.5), 1.4);
  const passed = pop(frame, cue(7.9));

  return (
    <AbsoluteFill>
      <div
        style={{
          position: 'absolute',
          left: 130,
          right: 130,
          top: 50,
          height: 720,
          borderRadius: 28,
          background: C.surface2,
          border: `2px solid ${C.bp400}55`,
          opacity: win,
          transform: `scale(${0.94 + win * 0.06})`,
          boxShadow: '0 30px 70px rgba(0,0,0,0.45)',
          overflow: 'hidden',
        }}
      >
        <div style={{ height: 64, background: C.surface3, display: 'flex', alignItems: 'center', gap: 12, padding: '0 28px' }}>
          {[C.err, '#f59e0b', C.ok].map((c) => (
            <span key={c} style={{ width: 16, height: 16, borderRadius: 8, background: c, opacity: 0.7 }} />
          ))}
          <span style={{ fontFamily: MONO, fontSize: 24, color: C.ink2, marginLeft: 20 }}>assertions.eth.limo/builder</span>
        </div>

        <div style={{ display: 'flex', gap: 30, padding: 30 }}>
          <div style={{ width: 760, display: 'flex', flexDirection: 'column', gap: 14 }}>
            <div style={{ fontFamily: MONO, fontSize: 22, color: C.ink2, letterSpacing: 2 }}>BATCH</div>
            <Row>
              <span style={{ width: 12, height: 12, borderRadius: 6, background: C.bp400 }} />
              Upgrade the vault
            </Row>
            <Row>
              <span style={{ width: 12, height: 12, borderRadius: 6, background: C.bp400 }} />
              Admin → council Safe
            </Row>
            <div style={{ height: 92 * move, opacity: move, overflow: 'hidden' }}>
              <Row style={{ border: `2px solid ${C.bp400}88` }}>
                <Gate state={passed > 0.5 ? 'ok' : 'idle'} size={44} />
                Vault owner is the council Safe
                <span style={{ marginLeft: 'auto', opacity: preview }}>
                  <Tag style={{ fontSize: 20 }}>live: 0xC0c1…1A5e</Tag>
                </span>
              </Row>
            </div>
            <div style={{ marginTop: 18, height: 70, borderRadius: 14, border: `2px solid ${C.ink3}66`, overflow: 'hidden', position: 'relative', opacity: sim > 0 ? 1 : 0.3 }}>
              <div style={{ position: 'absolute', inset: 0, width: `${sim * 100}%`, background: `${C.bp400}33` }} />
              <div style={{ position: 'absolute', inset: 0, display: 'flex', alignItems: 'center', gap: 14, padding: '0 22px', fontFamily: MONO, fontSize: 24, color: C.ink }}>
                <svg width="34" height="34" viewBox="0 0 34 34">
                  <circle cx="8" cy="8" r="5" fill="none" stroke={C.bp300} strokeWidth="3" />
                  <circle cx="8" cy="26" r="5" fill="none" stroke={C.bp300} strokeWidth="3" />
                  <circle cx="26" cy="12" r="5" fill="none" stroke={C.bp300} strokeWidth="3" />
                  <path d="M8 13 V21 M8 18 C8 14 26 20 26 17" fill="none" stroke={C.bp300} strokeWidth="3" />
                </svg>
                Simulating on a fork…
              </div>
            </div>
            <div style={{ opacity: passed, transform: `scale(${mix(0.8, 1, passed)})`, transformOrigin: 'left center' }}>
              <Tag color={C.ok} style={{ fontSize: 28, display: 'inline-block' }}>
                ✓ Simulation passed · 2 actions, 1 assertion
              </Tag>
            </div>
          </div>

          <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: 14 }}>
            <div style={{ fontFamily: MONO, fontSize: 22, color: C.ink2, letterSpacing: 2 }}>WHAT SHOULD BE TRUE?</div>
            <div
              style={{
                padding: '18px 22px',
                borderRadius: 14,
                border: `2px solid ${frame >= cue(1.7) ? C.bp400 : C.ink3}`,
                fontFamily: SANS,
                fontSize: 28,
                color: C.ink,
                minHeight: 34,
              }}
            >
              {WATCH.slice(0, typed)}
              {frame >= cue(1.7) && typed < WATCH.length && <span style={{ color: C.bp400 }}>|</span>}
            </div>
            <div style={{ fontFamily: MONO, fontSize: 22, color: C.ink2, letterSpacing: 2, marginTop: 14, opacity: sug[0] }}>SUGGESTED FOR THIS BATCH</div>
            {['Vault owner is the council Safe', 'Implementation is the audited build', 'Council threshold is at least 3'].map((t, i) => (
              <div key={t} style={{ opacity: sug[i] * (i === 0 ? 1 - move : 1), transform: `translateX(${(1 - sug[i]) * 40 - (i === 0 ? move * 120 : 0)}px)` }}>
                <Row>
                  <Gate state="idle" size={40} />
                  {t}
                  <span style={{ marginLeft: 'auto', fontFamily: MONO, fontSize: 22, color: C.bp300 }}>+ Add</span>
                </Row>
              </div>
            ))}
          </div>
        </div>
      </div>
    </AbsoluteFill>
  );
};
