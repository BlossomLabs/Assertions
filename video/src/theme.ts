import { loadFont as loadOutfit } from '@remotion/google-fonts/Outfit';
import { loadFont as loadMono } from '@remotion/google-fonts/JetBrainsMono';
import { Easing, interpolate, spring } from 'remotion';
import { FPS } from './timing';

// The website's dark theme (website/src/styles/global.css, :root.dark).
export const C = {
  surface: '#0a1d40',
  surface2: '#0f2750',
  surface3: '#173463',
  ink: '#e2eaf2',
  ink2: '#8da4b8',
  ink3: '#4a6478',
  bp300: '#93c5fd',
  bp400: '#60a5fa',
  bp500: '#005BA6',
  primary: '#2563eb',
  ok: '#22c55e',
  err: '#ef4444',
  logo: '#1E40AF',
};

export const SANS = loadOutfit('normal', { weights: ['400', '500', '600', '700'], subsets: ['latin'] }).fontFamily;
export const MONO = loadMono('normal', { weights: ['400', '500', '700'], subsets: ['latin'] }).fontFamily;

/** 0 → 1 over `dur` seconds from frame `at`, eased out. */
export const ramp = (frame: number, at: number, dur = 0.45) =>
  interpolate(frame, [at, at + dur * FPS], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
    easing: Easing.out(Easing.cubic),
  });

/** A springy 0 → 1 from frame `at`. */
export const pop = (frame: number, at: number) =>
  spring({ frame: frame - at, fps: FPS, config: { damping: 14, stiffness: 160, mass: 0.7 } });

export const mix = (a: number, b: number, t: number) => a + (b - a) * t;
