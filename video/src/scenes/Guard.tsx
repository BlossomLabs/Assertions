import React from 'react';
import { AbsoluteFill, interpolate, useCurrentFrame } from 'remotion';
import { Block, Tag } from '../parts';
import { C, MONO, pop, ramp } from '../theme';
import { cue } from '../timing';

// Each action is followed by an assertion asking whether its event happened.
const STEPS = [
  { action: 'Swap', check: 'Swapped?' },
  { action: 'Transfer', check: 'Transferred?' },
  { action: 'Deposit', check: 'Deposited?' },
];

type EyeState = 'idle' | 'ok' | 'fail';

/** An assertion: the logo's eye, opening as it is placed, and its question below. */
const Eye: React.FC<{ state: EyeState; open: number; label: string }> = ({ state, open, label }) => {
  const color = state === 'ok' ? C.ok : state === 'fail' ? C.err : C.bp400;
  const lid = Math.max(open, 0.04);
  return (
    <div style={{ width: 170, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 12 }}>
      <svg width="130" height="130" viewBox="0 0 176 176" style={{ filter: state === 'idle' ? 'none' : `drop-shadow(0 0 22px ${color}aa)` }}>
        <circle cx="88" cy="88" r="84" fill={`${color}22`} stroke={color} strokeWidth="6" />
        <g transform={`translate(0 88) scale(1 ${lid}) translate(0 -88)`}>
          <ellipse cx="88" cy="88" rx="58.5" ry="31.7" fill={C.ink} />
          <circle cx="88" cy="88" r="27" fill={state === 'idle' ? C.surface : color} />
          <circle cx="88" cy="88" r="11" fill={C.surface} />
        </g>
      </svg>
      <div style={{ fontFamily: MONO, fontWeight: 700, fontSize: 28, color: state === 'idle' ? C.ink2 : color, whiteSpace: 'nowrap' }}>{label}</div>
    </div>
  );
};

/** Beat 4: conditions inside the transaction, checked as it runs; one fails and the batch rewinds. */
export const Guard: React.FC = () => {
  const frame = useCurrentFrame();
  const box = pop(frame, 0);
  const beam = interpolate(frame, [cue(4.41), cue(6.7)], [0, 1], { extrapolateLeft: 'clamp', extrapolateRight: 'clamp' });
  const failed = frame >= cue(6.7);
  const rewind = ramp(frame, cue(7.54), 0.9);
  const note = pop(frame, cue(8.2));

  const eyeState = (i: number): EyeState => {
    if (i === 2) return failed ? 'fail' : 'idle';
    if (rewind > 0.6) return 'idle';
    return frame >= cue(5.0 + i * 0.75) ? 'ok' : 'idle';
  };

  const items: React.ReactNode[] = [];
  STEPS.forEach((s, i) => {
    const a = pop(frame, cue(0.25 + i * 0.2));
    // Undone in place, right to left, as the red sweep passes back over it.
    const undone = Math.min(1, Math.max(0, rewind * 3 - (2 - i)));
    items.push(
      <div key={`a${i}`} style={{ opacity: a * (1 - undone * 0.6) }}>
        <Block label={s.action} width={230} style={{ borderStyle: undone > 0.5 ? 'dashed' : 'solid' }} />
      </div>,
    );
    const drop = pop(frame, cue(1.0 + i * 0.5));
    items.push(
      <div key={`e${i}`} style={{ transform: `translateY(${(1 - drop) * -140}px)`, opacity: drop }}>
        <Eye state={eyeState(i)} open={ramp(frame, cue(1.2 + i * 0.5), 0.35)} label={s.check} />
      </div>,
    );
  });

  return (
    <AbsoluteFill>
      <div
        style={{
          position: 'absolute',
          left: 130,
          right: 130,
          top: 220,
          height: 360,
          borderRadius: 32,
          border: `3px ${failed ? 'solid' : 'dashed'} ${failed ? C.err : C.bp400}${failed ? 'cc' : '77'}`,
          background: `${C.surface2}aa`,
          opacity: box,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          gap: 24,
          paddingTop: 30,
          overflow: 'hidden',
        }}
      >
        <div style={{ position: 'absolute', left: 36, top: 22, fontFamily: MONO, fontSize: 24, color: C.ink2, letterSpacing: 2 }}>ONE TRANSACTION</div>
        {items}
        {rewind > 0 && rewind < 1 && (
          <div style={{ position: 'absolute', top: 0, bottom: 0, left: `${96 - rewind * 92}%`, width: 6, background: C.err, boxShadow: `0 0 40px 12px ${C.err}88` }} />
        )}
        {beam > 0 && beam < 1 && (
          <div style={{ position: 'absolute', top: 0, bottom: 0, left: `${4 + beam * 92}%`, width: 6, background: C.bp300, boxShadow: `0 0 40px 12px ${C.bp400}88` }} />
        )}
      </div>
      <div style={{ position: 'absolute', top: 630, left: 0, right: 0, display: 'flex', justifyContent: 'center', opacity: note, transform: `scale(${0.8 + note * 0.2})` }}>
        <Tag color={C.err} style={{ fontSize: 34, padding: '14px 26px' }}>
          reverted · nothing executed
        </Tag>
      </div>
    </AbsoluteFill>
  );
};
