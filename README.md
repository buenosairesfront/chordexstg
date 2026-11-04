**English** · [Español](README.es.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [日本語](README.ja.md) · [中文](README.zh.md) · [हिन्दी](README.hi.md)

# ChordexSTG

An orchestral string section for [monome norns](https://monome.org/docs/norns/):
one key plays a four-note chord (plus bass) bowed by violins, violas, cellos,
double basses or the whole orchestra.

![ChordexSTG](docs/sheet.png)

**The screen is the instrument.** In the middle you see the four strings from
the front, from fingerboard to bridge, with the f-holes on the sides. Each note
of the chord vibrates on its string with the real motion of a bowed string
(Helmholtz motion: a corner running between finger and bridge). The finger
marks where the note is stopped and rocks with the vibrato. The bow crosses
the strings: its height is the tone color (top = sul tasto, bottom = sul
ponticello) and its speed is the dynamics. It bounces in spiccato, shakes in
tremolo and lifts off in pizzicato. Rosin dust shows bow pressure; rising
sparks show the "sky" shimmer.

- left: the chord on a 12-note wheel, the articulation envelope and 9 faders
- right: oscilloscope, harmonics with the body resonance curve, arpeggio
  pattern; on top, section, articulation and hold
- bottom left: the dynamics hairpin (<)

## Features

- **5 sections**, each in its own register and with its own body: VIOLIN (an
  octave up), VIOLA, CELLO (an octave down), CONTRABAJO (double bass, two
  octaves down) and **TUTTI**, which spreads the chord across the orchestra
  seated as on stage
- **4 articulations**: legato, spiccato, pizzicato, tremolo — for chords and
  arpeggios
- **12 chords**: maj, min, dim, aug, 7, maj7, min7, m7b5, sus2, sus4, 5, add9
- **arpeggiator**: up, down, up-down, up x2, down x2, random and *arpa* (harp);
  gate at maximum = real legato, the bow slides from note to note
- **chord mode** on/off (off = single notes) and **hold**
- old-record crackle when more than two keys are held
- follows incoming MIDI clock for the arpeggio tempo
- all settings are saved automatically

<!-- u-ma:family -->
## The Chordex family

Same controls, different engines. Try the others:

| | |
|---|---|
| <a href="https://github.com/buenosairesfront/chordex80"><img src="https://raw.githubusercontent.com/buenosairesfront/chordex80/main/docs/1_d50.png" width="200" alt="Chordex 80"></a> | **[Chordex 80](https://github.com/buenosairesfront/chordex80)**<br>'80s polysynth with an outrun sunset<br>`;install https://github.com/buenosairesfront/chordex80` |
| <a href="https://github.com/buenosairesfront/chordexfm"><img src="https://raw.githubusercontent.com/buenosairesfront/chordexfm/main/docs/3_metal.png" width="200" alt="Chordex FM"></a> | **[Chordex FM](https://github.com/buenosairesfront/chordexfm)**<br>4-operator FM, drawn as a flower<br>`;install https://github.com/buenosairesfront/chordexfm` |
| <a href="https://github.com/buenosairesfront/chordexwt"><img src="https://raw.githubusercontent.com/buenosairesfront/chordexwt/main/docs/2_vocal.png" width="200" alt="Chordex WT"></a> | **[Chordex WT](https://github.com/buenosairesfront/chordexwt)**<br>wavetable: 8 banks of 8 waves, drawn as a 3D table<br>`;install https://github.com/buenosairesfront/chordexwt` |
| <a href="https://github.com/buenosairesfront/chordexchip"><img src="https://raw.githubusercontent.com/buenosairesfront/chordexchip/main/docs/1_nes.png" width="200" alt="Chordex CHIP"></a> | **[Chordex CHIP](https://github.com/buenosairesfront/chordexchip)**<br>chiptune: 8 console chips × 8 presets, drawn as a tracker<br>`;install https://github.com/buenosairesfront/chordexchip` |

**More from U-MA:** every instrument and tool in one place → [U-MA showcase](https://github.com/buenosairesfront/U-ma)
<!-- /u-ma:family -->

## Requirements

- norns (shield, standard or fates)
- a MIDI keyboard or controller

## Install

From maiden:

```
;install https://github.com/buenosairesfront/chordexstg
```

Then **restart norns** (SYSTEM > RESTART) so the new engine `ChordexSTG` is
compiled, and load **chordexstg** from SELECT.

## Controls

| control | action |
|---|---|
| E1 | dynamics (pp … ff) |
| E2 | select fader |
| E3 | adjust fader |
| K3 + E1 | section |
| K3 + E2 | articulation |
| K3 + E3 | chord type |
| K2 (tap) | arpeggiator on/off |
| K2 + E1 | arpeggio gate (max = legato) |
| K2 + E2 | arpeggio pattern |
| K2 + E3 | arpeggio speed |
| K3 held (without turning) | chord mode on/off |
| K1 held | hold on/off (small diamond, top right) |

**Faders:** attack, release, color, bow pressure, vibrato, vibrato speed,
ensemble, swell (crescendo), sky.

**PARAMETERS menu:** MIDI channel (0 = all, the default), MIDI clock divider,
octave, bass level, room, volume, and everything above.

## Gallery

| | |
|---|---|
| ![violin, legato](docs/1_violin.png) violin · legato | ![tutti](docs/2_tutti.png) tutti |
| ![cello, tremolo](docs/3_cello_tremolo.png) cello · tremolo | ![viola, pizzicato, arpeggio](docs/4_viola_pizz_arp.png) viola · pizzicato · arpeggio |
| ![double bass](docs/5_contrabajo.png) double bass | |

## Credits

Made by [Buenos Aires Front](https://github.com/buenosairesfront) / U-MA,
part of the U-MA / Chordex family. Released under the MIT license.
