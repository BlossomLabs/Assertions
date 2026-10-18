// Every time in the video comes from the voiceover. Beat starts are derived
// from the clip lengths and the silences between them (the timing sheet in
// SCRIPT.md), and each phrase is a span of speech that
// ffmpeg's silencedetect found inside its clip.

export const FPS = 30;

const LEAD = 0.5;
const CLIPS = [3.07, 5.94, 8.82, 8.96, 12.12, 4.6, 14.95, 8.87, 6.92, 5.85];
const GAPS = [1.0, 0.8, 0.8, 1.5, 0.8, 1.5, 1.0, 0.8, 1.0, 2.5];

/** Start of each beat's voice clip, in seconds from the top of the video. */
export const BEAT: number[] = [];
{
  let t = LEAD;
  for (let i = 0; i < CLIPS.length; i++) {
    BEAT.push(t);
    t += CLIPS[i] + GAPS[i];
  }
}
export const TOTAL = BEAT[9] + CLIPS[9] + GAPS[9];
export const DURATION = Math.ceil(TOTAL * FPS);

/** Beat n (1-based) starts at this frame. */
export const beatFrame = (n: number) => Math.round(BEAT[n - 1] * FPS);

type Phrase = { beat: number; from: number; to: number; text: string };

// Offsets are seconds inside the beat's clip.
const PHRASES: Phrase[] = [
  { beat: 1, from: 0.0, to: 1.59, text: 'Introducing Assertions 2.0.' },
  { beat: 1, from: 2.22, to: 2.67, text: 'Byakko.' },
  { beat: 2, from: 0.0, to: 2.31, text: 'You sign a Safe or DAO transaction on Monday.' },
  { beat: 2, from: 2.69, to: 3.81, text: 'It executes on Friday.' },
  { beat: 2, from: 4.45, to: 5.61, text: 'By then, the chain has moved.' },
  { beat: 3, from: 0.0, to: 0.96, text: 'A price shifts.' },
  { beat: 3, from: 1.53, to: 2.52, text: 'A signer is swapped.' },
  { beat: 3, from: 3.06, to: 5.92, text: 'An earlier proposal upgrades a contract yours depends on.' },
  { beat: 3, from: 6.68, to: 8.42, text: 'Your simulation was only valid on Monday.' },
  { beat: 4, from: 0.0, to: 3.45, text: 'Assertions put your conditions inside the transaction itself.' },
  { beat: 4, from: 4.41, to: 5.9, text: "They're checked the moment it runs." },
  { beat: 4, from: 6.54, to: 8.64, text: 'If one fails, the whole batch reverts.' },
  { beat: 5, from: 0.0, to: 3.84, text: 'Take a DAO vote that upgrades a vault and hands it to a council Safe.' },
  { beat: 5, from: 4.61, to: 7.9, text: 'Right after both actions, the proposer adds four checks.' },
  { beat: 5, from: 8.55, to: 9.7, text: 'The council owns the vault.' },
  { beat: 5, from: 10.3, to: 11.71, text: 'Its code is the audited build.' },
  { beat: 6, from: 0.0, to: 1.64, text: 'Every signer is on the approved list.' },
  { beat: 6, from: 2.4, to: 4.17, text: 'And it takes at least three of them to sign.' },
  { beat: 7, from: 0.0, to: 2.86, text: 'Version 1 compared a live value with a constant.' },
  { beat: 7, from: 3.52, to: 5.47, text: 'Version 2 makes both sides live.' },
  { beat: 7, from: 6.12, to: 7.42, text: 'And it chains reads together:' },
  { beat: 7, from: 7.95, to: 8.71, text: 'do math on them,' },
  { beat: 7, from: 9.08, to: 10.6, text: 'read an address and call into it,' },
  { beat: 7, from: 11.21, to: 12.7, text: 'fall back when a call fails,' },
  { beat: 7, from: 13.16, to: 14.61, text: 'or check every item in a list.' },
  { beat: 8, from: 0.0, to: 1.31, text: "You don't write this by hand." },
  { beat: 8, from: 1.69, to: 2.93, text: 'Tell the builder what to watch.' },
  { beat: 8, from: 3.56, to: 6.22, text: 'It suggests the checks, previews each live value,' },
  { beat: 8, from: 6.45, to: 8.48, text: 'and simulates the batch on a copy of the chain.' },
  { beat: 9, from: 0.0, to: 2.29, text: 'Then it ships the batch as a Safe transaction,' },
  { beat: 9, from: 2.66, to: 3.71, text: 'a Governor proposal,' },
  { beat: 9, from: 3.95, to: 4.84, text: 'or a wallet batch.' },
  { beat: 9, from: 5.53, to: 6.5, text: "There's nothing to deploy." },
  // Beat 10 has no caption: the end card spells out the closing line.
];

/** Caption phrases on the video's own clock, in frames. */
export const CAPTIONS = PHRASES.map((p) => ({
  text: p.text,
  from: Math.round((BEAT[p.beat - 1] + p.from) * FPS),
  to: Math.round((BEAT[p.beat - 1] + p.to + 0.2) * FPS),
}));

/** A cue inside beat n, as a frame relative to that beat's scene. */
export const cue = (seconds: number) => Math.round(seconds * FPS);
