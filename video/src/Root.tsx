import React from 'react';
import { Composition } from 'remotion';
import { Launch } from './Video';
import { DURATION, FPS } from './timing';

export const Root: React.FC = () => (
  <>
    <Composition id="Launch" component={Launch} durationInFrames={DURATION} fps={FPS} width={1920} height={1080} defaultProps={{ captions: true }} />
    <Composition id="LaunchClean" component={Launch} durationInFrames={DURATION} fps={FPS} width={1920} height={1080} defaultProps={{ captions: false }} />
  </>
);
