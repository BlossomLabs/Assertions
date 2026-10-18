import React from 'react';
import { AbsoluteFill, Audio, Sequence, interpolate, staticFile, useCurrentFrame } from 'remotion';
import { Grid, Scene } from './parts';
import { Builder } from './scenes/Builder';
import { Drift } from './scenes/Drift';
import { End } from './scenes/End';
import { Guard } from './scenes/Guard';
import { Proposal } from './scenes/Proposal';
import { Ship } from './scenes/Ship';
import { Title } from './scenes/Title';
import { Versions } from './scenes/Versions';
import { C, SANS } from './theme';
import { CAPTIONS, DURATION, beatFrame } from './timing';

/** Burned-in captions, one phrase at a time, for muted autoplay on X. */
const Captions: React.FC = () => {
  const frame = useCurrentFrame();
  const c = CAPTIONS.find((p) => frame >= p.from && frame < p.to);
  if (!c) return null;
  const opacity = interpolate(frame, [c.from, c.from + 4, c.to - 4, c.to], [0, 1, 1, 0], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });
  return (
    <div style={{ position: 'absolute', left: 0, right: 0, bottom: 70, display: 'flex', justifyContent: 'center', opacity }}>
      <div
        style={{
          maxWidth: 1500,
          padding: '14px 30px',
          borderRadius: 14,
          background: 'rgba(5, 12, 28, 0.82)',
          color: C.ink,
          fontFamily: SANS,
          fontWeight: 500,
          fontSize: 46,
          lineHeight: 1.25,
          textAlign: 'center',
        }}
      >
        {c.text}
      </div>
    </div>
  );
};

// Scenes run from their beat's voice start to the next scene's start.
const SCENES: { from: number; to: number; render: () => React.ReactNode }[] = [
  { from: 0, to: beatFrame(2), render: () => <Title lead={beatFrame(1)} /> },
  { from: beatFrame(2), to: beatFrame(4), render: () => <Drift b3={beatFrame(3) - beatFrame(2)} /> },
  { from: beatFrame(4), to: beatFrame(5), render: () => <Guard /> },
  { from: beatFrame(5), to: beatFrame(7), render: () => <Proposal b6={beatFrame(6) - beatFrame(5)} /> },
  { from: beatFrame(7), to: beatFrame(8), render: () => <Versions /> },
  { from: beatFrame(8), to: beatFrame(9), render: () => <Builder /> },
  { from: beatFrame(9), to: beatFrame(10), render: () => <Ship /> },
  { from: beatFrame(10), to: DURATION, render: () => <End /> },
];

export const Launch: React.FC<{ captions: boolean }> = ({ captions }) => (
  <AbsoluteFill style={{ background: C.surface }}>
    <Grid />
    {SCENES.map((s, i) => (
      <Sequence key={i} from={s.from} durationInFrames={s.to - s.from}>
        <Scene length={s.to - s.from}>{s.render()}</Scene>
      </Sequence>
    ))}
    <Audio src={staticFile('voiceover-full.wav')} />
    {captions && <Captions />}
  </AbsoluteFill>
);
