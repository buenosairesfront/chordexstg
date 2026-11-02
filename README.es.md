[English](README.md) · **Español** · [Français](README.fr.md) · [Deutsch](README.de.md) · [日本語](README.ja.md) · [中文](README.zh.md) · [हिन्दी](README.hi.md)

# ChordexSTG

Una sección de cuerdas de orquesta para [monome norns](https://monome.org/docs/norns/):
una tecla toca un acorde de cuatro notas (más bajo) frotado por violines,
violas, cellos, contrabajos o la orquesta entera.

![ChordexSTG](docs/sheet.png)

**La pantalla es el instrumento.** En el centro se ven las cuatro cuerdas de
frente, del diapasón al puente, con las efes a los costados. Cada nota del
acorde vibra en su cuerda con el movimiento real de una cuerda frotada
(Helmholtz: una esquina que corre entre el dedo y el puente). El dedo marca
dónde se pisa la nota y se mece con el vibrato. El arco cruza las cuerdas: su
altura es el color (arriba sul tasto, abajo sul ponticello) y su velocidad, la
dinámica. Salta en spiccato, tiembla en trémolo y se levanta en pizzicato. El
polvo de resina muestra la presión; las chispas que suben, el "cielo".

- izquierda: el acorde en la rueda de 12 notas, la envolvente de la
  articulación y los 9 faders
- derecha: osciloscopio, armónicos con la curva del cuerpo encima y patrón
  del arpegio; arriba, sección, articulación y retener
- abajo a la izquierda: el regulador (<) de la dinámica

## Características

- **5 secciones**, cada una en su registro y con su propio cuerpo: VIOLIN
  (una octava arriba), VIOLA, CELLO (una abajo), CONTRABAJO (dos abajo) y
  **TUTTI**, que reparte el acorde en toda la orquesta, sentada como en el
  escenario
- **4 articulaciones**: legato, spiccato, pizzicato, trémolo; valen para el
  acorde y para el arpegio
- **12 acordes**: maj, min, dim, aug, 7, maj7, min7, m7b5, sus2, sus4, 5, add9
- **arpegiador**: up, down, up-down, up x2, down x2, random y *arpa*; con el
  gate al máximo, legato real: el arco se desliza de nota a nota
- **modo acorde** on/off (off = una nota) y **retener**
- crackle de disco viejo con más de dos teclas apretadas
- sigue el clock MIDI entrante para el tempo del arpegio
- todo se guarda solo

## Requisitos

- norns (shield, estándar o fates)
- un teclado o controlador MIDI

## Instalación

Desde maiden:

```
;install https://github.com/buenosairesfront/chordexstg
```

Después **reiniciá la norns** (SYSTEM > RESTART) para que compile el engine
nuevo `ChordexSTG`, y cargá **chordexstg** desde SELECT.

## Controles

| control | acción |
|---|---|
| E1 | dinámica (pp … ff) |
| E2 | elegir fader |
| E3 | ajustar fader |
| K3 + E1 | sección |
| K3 + E2 | articulación |
| K3 + E3 | tipo de acorde |
| K2 (toque) | arpegiador on/off |
| K2 + E1 | gate del arpegio (al máximo, legato) |
| K2 + E2 | patrón del arpegio |
| K2 + E3 | velocidad del arpegio |
| K3 mantenido (sin girar nada) | modo acorde on/off |
| K1 mantenido | retener on/off (rombito arriba a la derecha) |

**Faders:** ataque, release, color, presión del arco, vibrato, velocidad del
vibrato, ensemble, swell (crescendo), cielo.

**Menú PARAMETERS:** canal MIDI (0 = todos, por defecto), divisor del reloj
MIDI, octava, bajo, sala, volumen y todo lo anterior.

## Galería

| | |
|---|---|
| ![violín, legato](docs/1_violin.png) violín · legato | ![tutti](docs/2_tutti.png) tutti |
| ![cello, trémolo](docs/3_cello_tremolo.png) cello · trémolo | ![viola, pizzicato, arpegio](docs/4_viola_pizz_arp.png) viola · pizzicato · arpegio |
| ![contrabajo](docs/5_contrabajo.png) contrabajo | |

## Créditos

Hecho por [Buenos Aires Front](https://github.com/buenosairesfront) / U-MA,
de la familia U-MA / Chordex. Licencia MIT.
