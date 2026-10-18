# Assertions 2.0 launch video: script

```
Title (working):   Assertions 2.0 (Byakko): keep an eye on what needs watching
Promise:           For anyone about to sign a big transaction, this video shows a batch
                   that reverts when the chain moved after signing, and the builder
                   adding those checks for them.
Shape:             motion design explainer, cut to release-clip length
Audience:          Safe signers and DAO delegates ("anyone signing a big transaction")
Surface:           YouTube + X launch post (16:9 master; sound-off autoplay on X)
Target runtime:    1:30        Measured runtime: 1:33 (see Runtime)
Voice:             AI voiceover, ElevenLabs "Eric"; the narration column is the final audio, word for word
Voiceover files:   video/voiceover/ (01-10.mp3 per beat, voiceover-full.mp3/.wav assembled)
Speaking rate:     about 175 wpm (Eric, measured)
Companion:         the builder, assertions.eth.limo/builder
Off-limits:        real people's Safes or addresses, Cerberus and later releases,
                   anything that promises an audit
```

## Why this shape

The effort ceiling allows everything (full motion design), and the release
(October 9) has already shipped, so there is no embargo. The shapes ranked by
efficiency are error/fix > changelog clip > short-form > walkthrough > motion design.
Error/fix doesn't apply because there is no error to fix. A changelog clip and a
short-form clip only reach existing users or casual scrollers, and this viewer
first has to *feel* the problem. A walkthrough needs a demo environment that
survives a clean take, and an AI voice can't recover from a fluffed one. So the
pick is a motion design explainer, held to 90 seconds. Real product screens appear
only as stylised builder panels, so the compliance cost is mostly the claims, and
those are all taken from the published release notes and docs.

## Beats

Each music cue and transition is marked ♪ in the action column. On-screen text
stays to labels and short phrases, and the narration never reads them aloud.
`[pause]` is a beat of silence for the synthesis engine to respect.

| # | Visual | On-screen action | Narration | Asset needed first | Slot s | Core/cut |
|---|---|---|---|---|---|---|
| | **Opening: the release** | | | | | |
| 1 | Title card: the Byakko banner's stripes, the seated white tiger (the release figure, its head inside the eye's rings) on the right, wordmark "Assertions 2.0" and "Byakko" on the left | ♪ hit on the first frame. Stripes wipe in from the west (left), the tiger rises in, "Byakko" lands after the pause | "Introducing Assertions two point oh. [pause] Byakko." [verbatim] | Banner stripes (`ReleaseBanner.astro`), tiger figure (`video/public/byakko-tiger.svg`), wordmark in Outfit | 4.6 | core |
| | **Segment 1: Between signing and execution** | | | | | |
| 2 | A signature line on a transaction card; a week calendar behind it | Pen signs, ♪ soft pulse under the voice. Calendar pages flip Monday → Friday; the card slides along a chain of blocks that keep arriving | "You sign a Safe or DAO transaction on Monday. It executes on Friday. [pause] By then, the chain has moved." | Transaction card, calendar, block chain loop | 6.1 | core |
| 3 | The same chain of blocks; three small icons ride in on passing blocks: a price chart, a signer avatar, a contract with a gear | Price line jumps; one signer avatar swaps for another; the gear on the contract is replaced. A dashed "Simulation · valid Mon only" stamp lands on the card | "A price shifts. A signer is swapped. An earlier proposal upgrades a contract yours depends on. [pause] Your simulation was only valid on Monday." | Three icon sets, simulation stamp | 9.3 | core |
| 4 | One transaction: each action followed by its assertion, drawn as the logo's eye with a question below: `Swap` → 👁 "Swapped?", `Transfer` → 👁 "Transferred?", `Deposit` → 👁 "Deposited?" | ♪ beat drop. The actions appear, then the eyes drop in and open. A sweep runs left to right: "Swapped?" and "Transferred?" turn green, "Deposited?" turns red; a red sweep runs back, undoing every action in place. Label: "reverted · nothing executed" | "Assertions put your conditions inside the transaction itself. They're checked the moment it runs. [pause] If one fails, the whole batch reverts." | Action blocks, eye assertion (idle, green, red), undo animation | 10.5 | core |
| | **Segment 2: A vote that has to land the way it passed** | | | | | |
| 5 | A proposal card: "Upgrade the vault → Admin → council Safe". Below it, "written by the proposer, for this vote" and four check cards | The two actions appear on their phrases and turn green on "Right after both actions". On "the proposer adds four checks" each card types its own assert line with its revert message (`"handover didn't land"`, `"unaudited code"`, …), so the checks read as written for this vote, not built in. Gates 1 and 2 turn green on their sentences | "Take a DAO vote that upgrades a vault and hands it to a council Safe. Right after both actions, the proposer adds four checks. [pause] The council owns the vault. Its code is the audited build." | Proposal card, four check cards with typed assert lines (the messages are the docs' examples) | 12.9 | core |
| 6 | Gates 3 and 4: a row of signer avatars passing through a list; a "3" threshold dial | Each avatar is ticked against the approved list; the dial settles on 3. All four gates turn green, ♪ resolve | "Every signer is on the approved list. And it takes at least three of them to sign." | Signer avatars, list, threshold dial | 6.1 | core |
| 7 | Split frame. Left, labelled "1.0": one live read → `==` → a fixed number. Right, "2.0": a live read on each side of the comparison | Left stays static while both sides on the right animate. ♪ light tick per vignette: after the pause, four quick vignettes, each on its own phrase: two reads feeding a `+`; an address read from one contract, then an arrow calling into the next; a red ✕ on a call and the path switching to a fallback; a list fanning out into ticks | "Version one compared a live value with a constant. Version two makes both sides live. [pause] And it chains reads together: do math on them, read an address and call into it, fall back when a call fails, or check every item in a list." | Split comparison scene, four vignettes (math, follow an address, fallback, list) | 16.0 | core |
| | **Segment 3: The builder writes them for you** | | | | | |
| 8 | Stylised builder panel: a batch on the left, a "Suggested assertions" list on the right | ♪ transition. One suggestion is clicked; it drops into the batch with its live value previewed beside it; a "Simulation passed" badge appears on a forked copy of the chain | "You don't write this by hand. Tell the builder what to watch. It suggests the checks, previews each live value, and simulates the batch on a copy of the chain." | Builder panel mock (based on the real builder, no real addresses) | 9.7 | core |
| 9 | The finished batch flies into three destinations: a Safe icon, a Governor ballot box, a wallet | Each destination receives it in turn | "Then it ships the batch as a Safe transaction, a Governor proposal, or a wallet batch. [pause] There's nothing to deploy." | Three destination icons | 7.9 | core |
| | **Segment 4: Close** | | | | | |
| 10 | End card: wordmark, "Before you sign, / keep an eye on what needs watching." (the homepage's closing line), "Build an assertion" button, assertions.eth.limo | ♪ final hit; the two lines land on their phrases; the button and URL appear on "Use it at", then the button pulses once. Holds for 2.5 s. No caption: the card shows the line and the URL | "Before you sign, keep an eye on what needs watching. [pause] Use it at assertions dot eth dot limo." [verbatim; normal speed] | End card, assertions.eth.limo | 8.4 | core |

## Chapters

YouTube only (X has no chapters). Timecodes come from the assembled voiceover;
recheck them after the edit.

```
00:00 Assertions 2.0, and the chain that moves after you sign
00:31 Four checks on a DAO vote
01:06 The builder adds them for you
```

## Cut plan

```
If the edit runs past 90 s:   drop the second sentence of beat 3 ("Your simulation was only valid on Monday", about 2 s)
If it is still long:          shorten the end-card hold in beat 10 from 2.5 s to 2 s
Never cut:                    every beat; beat 7 (what 2.0 adds) is core
```

Every beat is core, so the cut plan trims inside beats rather than dropping one.

## Runtime

Measured from the ElevenLabs render (Eric, Multilingual v2, stability 0.5,
similarity 0.75, style 0.05, speaker boost). Each slot is the voice clip plus the
silence after it, which is the time the animation has for that beat.

```
Beat  Start   End    Voice
lead   0.0    0.5     -
01     0.5    4.6    3.1   (1.0 s after: banner settles)
02     4.6   11.3    5.9
03    11.3   20.9    8.8
04    20.9   31.4    9.0   (1.5 s after: actions undone)
05    31.4   44.3   12.1
06    44.3   50.4    4.6   (1.5 s after: gates resolve)
07    50.4   66.4   15.0
08    66.4   76.0    8.9
09    76.0   84.0    6.9
10    84.0   92.3    5.9   (2.5 s end-card hold)

Narration 80.3 s + silence 12.0 s = 92.3 s against a 90 s target (well inside X's 140 s limit).
```

Eric reads at about 175 wpm, faster than the 150 the draft assumed, so the
longer beat 7 still fits. The release is named in the first 4 seconds, and the promise ("the
whole batch reverts") lands at 29.5 s, inside the 30-second window.

## Recording brief

**Voice.** Render beat 1 through two or three candidate voices and pick by ear. Go
for a plain, steady, conversational read, not a trailer voice. With ElevenLabs,
moderate stability and a low style value come closest to that. Check the voice's
licence for commercial use.

**Pronunciation and pacing for the engine.**
- "Assertions two point oh", never "two zero". The narration spells it out on purpose.
- "Governor" is the contract type: no emphasis.
- Every `[pause]` is about 0.4 s. In beat 4, the stress falls on "whole".
- "Byakko" is spelled as written; Eric reads it acceptably (approved by ear).

**Music.** "Xenobiological Forest" by Komiku (CC0, from Wikimedia Commons), in
`video/music/`. Mixed about 10 dB under the voice and ducked further while it
speaks; the cues it should eventually be cut to are the ♪ marks: a hit on the title in beat 1, a soft pulse in
beat 2, a drop in beat 4, a resolve in beat 6, a transition in beat 8 and a final
hit in beat 10. Keep it under the voice.

**Visual system.** The brand fonts are Outfit for text and JetBrains Mono for code
and headings. Gates are the one recurring motif: green means it holds, red means
the batch rewinds. Animate state changes (blocks rewinding, avatars being ticked),
not text fading in. Any EVML fragment on screen is one line at a time, at a size
readable on a phone.

**Captions.** Burn them in for X, where autoplay is muted. Upload corrected captions
to YouTube, checked against the narration column. Words to check: Assertions, Safe,
Governor, DAO.

**Off-limits on screen.** Real Safes or addresses belonging to anyone. The
`0xdfff…9ca9` code hash is the docs' WXDAI example, so it's safe. Nothing about
Cerberus or later releases. Nothing suggesting an audit or a finished builder.

## Description and CTA

```
Between signing and execution, the chain moves. Assertions are conditions inside
your transaction: if one fails when it runs, the whole batch reverts.

Assertions 2.0 (Byakko) compares live values on both sides, checks every item in a
list, and comes with a builder that suggests the checks, previews their live
values and simulates your batch. For Safe batches, DAO proposals and EIP-7702 wallets.

Chapters
00:00 The chain moves after you sign
00:30 Four checks on a DAO vote
00:56 The builder adds them for you

Links
Docs: https://assertions.eth.limo/docs
Release notes: https://assertions.eth.limo/releases/byakko

The builder is in beta. The contracts have not been externally audited; formal
verification is under way: https://assertions.eth.limo/docs/contracts/verification

Music: "Xenobiological Forest" by Komiku, CC0 (public domain)

Build your first assertion: https://assertions.eth.limo/builder
```

On X, use only the first paragraph and the builder link.

## Claims to re-verify before publishing

- "There's nothing to deploy": true wherever the contracts are deployed. Check the
  launch post's chains against Deployments.

## Retention checkpoints

- YouTube intro retention at 30 s grades beats 1-3 and nothing else.
- A dip during beat 7 (0:48 to 1:04) means its list of four is too dense; split it into its own clip.
- On X, compare the 3-second views with the plays that reach the promise (beat 4, about 0:30).
- Builder visits from the description link are the only conversion that counts.
