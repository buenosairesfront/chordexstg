[English](README.md) · [Español](README.es.md) · [Français](README.fr.md) · **Deutsch** · [日本語](README.ja.md) · [中文](README.zh.md) · [हिन्दी](README.hi.md)

# arco

Eine Orchester-Streichergruppe für [monome norns](https://monome.org/docs/norns/):
Eine Taste spielt einen vierstimmigen Akkord (plus Bass), gestrichen von
Violinen, Bratschen, Celli, Kontrabässen oder dem ganzen Orchester.

![arco](docs/sheet.png)

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
- Knistern einer alten Schallplatte, wenn mehr als zwei Tasten gehalten werden
- folgt eingehender MIDI-Clock für das Arpeggio-Tempo
- alle Einstellungen werden automatisch gespeichert

## Voraussetzungen

- norns (shield, Standard oder fates)
- ein MIDI-Keyboard oder -Controller

## Installation

In maiden:

```
;install https://github.com/buenosairesfront/arco
```

Danach **norns neu starten** (SYSTEM > RESTART), damit die neue Engine `Arco`
kompiliert wird, und **arco** über SELECT laden.

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

**Menü PARAMETERS:** MIDI-Kanal (0 = alle, Standard), MIDI-Clock-Teiler,
Oktave, Basspegel, Raum, Lautstärke und alles oben Genannte.

## Galerie

| | |
|---|---|
| ![Violine, Legato](docs/1_violin.png) Violine · Legato | ![Tutti](docs/2_tutti.png) Tutti |
| ![Cello, Tremolo](docs/3_cello_tremolo.png) Cello · Tremolo | ![Bratsche, Pizzicato, Arpeggio](docs/4_viola_pizz_arp.png) Bratsche · Pizzicato · Arpeggio |
| ![Kontrabass](docs/5_contrabajo.png) Kontrabass | |

## Credits

Erstellt von [Buenos Aires Front](https://github.com/buenosairesfront) / U-MA,
aus der U-MA- / Chordex-Familie. MIT-Lizenz.
