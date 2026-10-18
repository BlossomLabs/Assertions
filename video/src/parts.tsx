import React from 'react';
import { AbsoluteFill, interpolate, useCurrentFrame } from 'remotion';
import { C, MONO, SANS } from './theme';
import { FPS } from './timing';

/** The blueprint sheet behind every scene, drifting slowly. */
export const Grid: React.FC = () => {
  const frame = useCurrentFrame();
  const shift = (frame * 0.25) % 64;
  return (
    <AbsoluteFill style={{ background: `radial-gradient(ellipse at 50% 40%, ${C.surface2} 0%, ${C.surface} 70%)` }}>
      <AbsoluteFill
        style={{
          backgroundImage: `linear-gradient(rgba(59,130,246,0.09) 1px, transparent 1px), linear-gradient(90deg, rgba(59,130,246,0.09) 1px, transparent 1px), linear-gradient(rgba(59,130,246,0.15) 1px, transparent 1px), linear-gradient(90deg, rgba(59,130,246,0.15) 1px, transparent 1px)`,
          backgroundSize: '64px 64px, 64px 64px, 320px 320px, 320px 320px',
          backgroundPosition: `${-shift}px 0, ${-shift}px 0, ${-shift}px 0, ${-shift}px 0`,
        }}
      />
    </AbsoluteFill>
  );
};

/** Fades a scene in at its start and out before `length` frames. */
export const Scene: React.FC<{ length: number; children: React.ReactNode }> = ({ length, children }) => {
  const frame = useCurrentFrame();
  const opacity = interpolate(frame, [0, 8, length - 8, length], [0, 1, 1, 0], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });
  return <AbsoluteFill style={{ opacity }}>{children}</AbsoluteFill>;
};

/** The logo's eye mark (website/public/logo.svg). */
export const Mark: React.FC<{ size: number }> = ({ size }) => (
  <svg width={size} height={size} viewBox="0 0 176 176">
    <circle opacity="0.9" cx="88" cy="88" r="88" fill={C.logo} />
    <ellipse cx="88" cy="88" rx="58.5" ry="31.7" fill="white" />
    <circle cx="88" cy="88" r="29.25" fill={C.surface} />
  </svg>
);

export type GateState = 'idle' | 'ok' | 'fail';

/** An assertion: a diamond gate that is idle, green or red. */
export const Gate: React.FC<{ state: GateState; size?: number; scale?: number }> = ({ state, size = 64, scale = 1 }) => {
  const color = state === 'ok' ? C.ok : state === 'fail' ? C.err : C.bp400;
  return (
    <div style={{ width: size, height: size, display: 'grid', placeItems: 'center', transform: `scale(${scale})` }}>
      <div
        style={{
          width: size * 0.7,
          height: size * 0.7,
          transform: 'rotate(45deg)',
          borderRadius: size * 0.12,
          border: `4px solid ${color}`,
          background: state === 'idle' ? `${C.bp500}55` : `${color}33`,
          boxShadow: state === 'idle' ? 'none' : `0 0 ${size * 0.5}px ${color}88`,
          display: 'grid',
          placeItems: 'center',
        }}
      >
        <span style={{ transform: 'rotate(-45deg)', color, fontFamily: SANS, fontWeight: 700, fontSize: size * 0.38 }}>
          {state === 'ok' ? '✓' : state === 'fail' ? '✕' : ''}
        </span>
      </div>
    </div>
  );
};

/** An action in a batch. */
export const Block: React.FC<{ label: string; width?: number; style?: React.CSSProperties; done?: boolean }> = ({
  label,
  width = 260,
  style,
  done,
}) => (
  <div
    style={{
      width,
      padding: '22px 26px',
      borderRadius: 18,
      background: C.surface3,
      border: `2px solid ${done ? C.ok : C.bp400}66`,
      color: C.ink,
      fontFamily: SANS,
      fontWeight: 600,
      fontSize: 30,
      boxShadow: '0 18px 40px rgba(0,0,0,0.35)',
      display: 'flex',
      alignItems: 'center',
      gap: 14,
      ...style,
    }}
  >
    <span style={{ width: 14, height: 14, borderRadius: 7, background: done ? C.ok : C.bp400, flex: 'none' }} />
    {label}
  </div>
);

/** A small mono label. */
export const Tag: React.FC<{ children: React.ReactNode; color?: string; style?: React.CSSProperties }> = ({
  children,
  color = C.bp300,
  style,
}) => (
  <div
    style={{
      fontFamily: MONO,
      fontSize: 26,
      color,
      padding: '8px 16px',
      borderRadius: 10,
      border: `2px solid ${color}55`,
      background: `${color}14`,
      whiteSpace: 'nowrap',
      ...style,
    }}
  >
    {children}
  </div>
);

export const sec = (s: number) => Math.round(s * FPS);
