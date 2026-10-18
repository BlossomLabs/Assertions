import React from 'react';
import { AbsoluteFill, useCurrentFrame } from 'remotion';
import { Mark } from '../parts';
import { C, MONO, SANS, pop } from '../theme';
import { cue } from '../timing';

/** Beat 10: the homepage's closing line, "Before you sign, keep an eye on what needs watching.", and "Use it at assertions dot eth dot limo." over the call to action. */
export const End: React.FC = () => {
  const frame = useCurrentFrame();
  const logo = pop(frame, 0);
  const line1 = pop(frame, cue(0.08));
  const line2 = pop(frame, cue(1.28));
  const cta = pop(frame, cue(3.33));
  const pulse = frame > cue(4.2) && frame < cue(5.2) ? 1 + 0.05 * Math.sin(((frame - cue(4.2)) / cue(1)) * Math.PI) : 1;

  return (
    <AbsoluteFill style={{ alignItems: 'center', justifyContent: 'center' }}>
      <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 36, marginTop: -120 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 32, opacity: logo, transform: `scale(${0.8 + logo * 0.2})` }}>
          <Mark size={130} />
          <div style={{ fontFamily: SANS, fontWeight: 700, fontSize: 110, color: C.ink, letterSpacing: -2 }}>assertions.eth</div>
        </div>
        <div style={{ fontFamily: SANS, fontWeight: 500, fontSize: 60, color: C.ink, display: 'flex', flexDirection: 'column', alignItems: 'center', lineHeight: 1.2 }}>
          <span style={{ opacity: line1, transform: `translateY(${(1 - line1) * 20}px)`, display: 'inline-block' }}>Before you sign,</span>
          <span style={{ opacity: line2, transform: `translateY(${(1 - line2) * 20}px)`, display: 'inline-block', color: C.bp400 }}>keep an eye on what needs watching.</span>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 30, marginTop: 20, opacity: cta }}>
          <div
            style={{
              padding: '24px 44px',
              borderRadius: 18,
              background: C.primary,
              color: 'white',
              fontFamily: SANS,
              fontWeight: 600,
              fontSize: 40,
              transform: `scale(${pulse})`,
              boxShadow: `0 20px 50px ${C.primary}66`,
            }}
          >
            Build an assertion
          </div>
          <div style={{ fontFamily: MONO, fontSize: 36, color: C.bp300 }}>assertions.eth.limo</div>
        </div>
      </div>
    </AbsoluteFill>
  );
};
