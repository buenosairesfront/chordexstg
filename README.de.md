[English](README.md) · [Español](README.es.md) · [Français](README.fr.md) · **Deutsch** · [日本語](README.ja.md) · [中文](README.zh.md) · [हिन्दी](README.hi.md)

# ChordexSTG

Eine Orchester-Streichergruppe für [monome norns](https://monome.org/docs/norns/):
Eine Taste spielt einen vierstimmigen Akkord (plus Bass), gestrichen von
Violinen, Bratschen, Celli, Kontrabässen oder dem ganzen Orchester.

![ChordexSTG](docs/sheet.png)

**Das Display ist das Instrument.** In der Mitte sieht man die vier Saiten von
vorne, vom Griffbrett bis zum Steg, mit den F-Löchern an den Seiten. Jeder Ton
des Akkords schwingt auf seiner Saite mit der echten Bewegung einer
gestrichenen Saite (Helmholtz-Bewegung: ein Knick, der zwischen Finger und
Steg hin- und herläuft). Der Finger zeigt, wo der Ton gegriffen wird, und
wiegt sich mit dem Vibrato. Der Bogen kreuzt die Saiten: Seine Höhe ist die
Klangfarbe (oben sul tasto, unten sul ponticello), seine Geschwindigkeit die
Dynamik. Er springt im Spiccato, zittert im Tremolo und hebt im Pizzicato ab.
Kolophoniumstaub zeigt den Bogendruck, aufsteigende Funken den „Himmel“.

- links: der Akkord auf einem 12-Ton-Rad, die Hüllkurve der Artikulation und
  die 9 Fader
- rechts: Oszilloskop, Obertöne mit der Resonanzkurve des Korpus,
  Arpeggio-Muster; oben Gruppe, Artikulation und Halten
- unten links: die Dynamik-Gabel (<)

## Funktionen

- **5 Gruppen**, jede in ihrem Register und mit eigenem Korpus: VIOLIN (eine
  Oktave höher), VIOLA, CELLO (eine Oktave tiefer), CONTRABAJO (Kontrabass,
  zwei Oktaven tiefer) und **TUTTI**, das den Akkord wie auf der Bühne über das
  ganze Orchester verteilt
- **4 Artikulationen**: Legato, Spiccato, Pizzicato, Tremolo — für Akkorde und
  Arpeggien
- **12 Akkorde**: maj, min, dim, aug, 7, maj7, min7, m7b5, sus2, sus4, 5, add9
- **Arpeggiator**: up, down, up-down, up x2, down x2, random und *arpa*
  (Harfe); Gate auf Maximum = echtes Legato, der Bogen gleitet von Ton zu Ton
- **Akkordmodus** an/aus (aus = Einzeltöne) und **Halten**
- folgt eingehender MIDI-Clock für das Arpeggio-Tempo
- alle Einstellungen werden automatisch gespeichert

<!-- u-ma:family -->
## Die Chordex-Familie

Gleiche Bedienung, andere Engines. Probier die anderen aus:

| | |
|---|---|
| <a href="https://github.com/buenosairesfront/chordex80/blob/main/README.de.md"><img src="https://raw.githubusercontent.com/buenosairesfront/chordex80/main/docs/1_d50.png" width="200" alt="Chordex 80"></a> | **[Chordex 80](https://github.com/buenosairesfront/chordex80/blob/main/README.de.md)**<br>80er-Polysynth mit Outrun-Sonnenuntergang<br>`;install https://github.com/buenosairesfront/chordex80` |
| <a href="https://github.com/buenosairesfront/chordexfm/blob/main/README.de.md"><img src="https://raw.githubusercontent.com/buenosairesfront/chordexfm/main/docs/3_metal.png" width="200" alt="Chordex FM"></a> | **[Chordex FM](https://github.com/buenosairesfront/chordexfm/blob/main/README.de.md)**<br>FM mit 4 Operatoren, als Blume gezeichnet<br>`;install https://github.com/buenosairesfront/chordexfm` |
| <a href="https://github.com/buenosairesfront/chordexwt/blob/main/README.de.md"><img src="https://raw.githubusercontent.com/buenosairesfront/chordexwt/main/docs/2_vocal.png" width="200" alt="Chordex WT"></a> | **[Chordex WT](https://github.com/buenosairesfront/chordexwt/blob/main/README.de.md)**<br>Wavetable: 8 Bänke mit je 8 Wellen, als 3D-Tabelle gezeichnet<br>`;install https://github.com/buenosairesfront/chordexwt` |
| <a href="https://github.com/buenosairesfront/chordexchip/blob/main/README.de.md"><img src="https://raw.githubusercontent.com/buenosairesfront/chordexchip/main/docs/1_nes.png" width="200" alt="Chordex CHIP"></a> | **[Chordex CHIP](https://github.com/buenosairesfront/chordexchip/blob/main/README.de.md)**<br>Chiptune: 8 Konsolenchips × 8 Presets, als Tracker gezeichnet<br>`;install https://github.com/buenosairesfront/chordexchip` |
| <a href="https://github.com/buenosairesfront/chordexabnt/blob/main/README.de.md"><img src="https://raw.githubusercontent.com/buenosairesfront/chordexabnt/main/docs/1_warm_pad.png" width="200" alt="Chordex ABNT"></a> | **[Chordex ABNT](https://github.com/buenosairesfront/chordexabnt/blob/main/README.de.md)**<br>Pads, Ambient, Leads und Texturen: 4 Familien × 8 Presets, mit BEWEGUNG statt Arpeggiator<br>`;install https://github.com/buenosairesfront/chordexabnt` |

**Mehr von U-MA:** alle Instrumente und Werkzeuge an einem Ort → [U-MA-Übersicht](https://github.com/buenosairesfront/U-ma/blob/main/README.de.md)
<!-- /u-ma:family -->

## Voraussetzungen

- norns (shield, Standard oder fates)
- ein MIDI-Keyboard oder -Controller

## Installation

In maiden:

```
;install https://github.com/buenosairesfront/chordexstg
```

Danach **norns neu starten** (SYSTEM > RESTART), damit die neue Engine `ChordexSTG`
kompiliert wird, und **chordexstg** über SELECT laden.

## Bedienung

| Bedienelement | Funktion |
|---|---|
| E1 | Dynamik (pp … ff) |
| E2 | Fader wählen |
| E3 | Fader einstellen |
| K3 + E1 | Gruppe |
| K3 + E2 | Artikulation |
| K3 + E3 | Akkordtyp |
| K2 (antippen) | Arpeggiator an/aus |
| K2 + E1 | Arpeggio-Gate (Maximum = Legato) |
| K2 + E2 | Arpeggio-Muster |
| K2 + E3 | Arpeggio-Geschwindigkeit |
| K3 halten (ohne zu drehen) | Akkordmodus an/aus |
| K1 halten | Halten an/aus (kleine Raute oben rechts) |

**Fader:** Attack, Release, Klangfarbe, Bogendruck, Vibrato,
Vibrato-Geschwindigkeit, Ensemble, Swell (Crescendo), Himmel.

**Menü PARAMETERS:** MIDI-Kanal (Standard 1; 0 = alle), MIDI-Clock-Teiler,
Oktave, Basspegel, Raum, Lautstärke und alles oben Genannte.

## arc und crow

Beide sind optional: ohne angeschlossenes arc oder crow ändert sich nichts.

**arc** (4 Ringe, als Drehregler dargestellt): 1 Dynamik · 2 Klangfarbe · 3 Arpeggio-Tempo · 4 Raum

**crow**: IN1 = Tonhöhe (V/Okt., 0 V = C4), IN2 = Gate (spielt und lässt los) · OUT1 = Grundton des Akkords (V/Okt.) · OUT2 = Hüllkurve (0–8 V, mit Attack und Release des Klangs) · OUT3 = tempo-synchroner LFO (1 Takt) · OUT4 = ein Puls bei jedem Akkord oder Arpeggio-Schritt. Abschaltbar unter PARAMETERS > ARC / CROW.

**Tempo:** beim ersten Start ist das interne Tempo 50 BPM. Eingehende MIDI-Clock (an jedem MIDI-Port) bestimmt das Tempo, sobald sie anliegt.

## Galerie

| | |
|---|---|
| ![Violine, Legato](docs/1_violin.png) Violine · Legato | ![Tutti](docs/2_tutti.png) Tutti |
| ![Cello, Tremolo](docs/3_cello_tremolo.png) Cello · Tremolo | ![Bratsche, Pizzicato, Arpeggio](docs/4_viola_pizz_arp.png) Bratsche · Pizzicato · Arpeggio |
| ![Kontrabass](docs/5_contrabajo.png) Kontrabass | |

## Credits

Erstellt von [Buenos Aires Front](https://github.com/buenosairesfront) / U-MA,
aus der U-MA- / Chordex-Familie. MIT-Lizenz.
