// Engine_Arco.sc
// ARCO — cuerdas de orquesta. Mismo instrumento de acordes que la familia
// Chordex (una tecla = un acorde de 4 tonos + bajo, arpegio, retener,
// crackle de disco viejo), pero cada voz es una SECCIÓN de cuerdas.
//
// Voz de arco (\ar_arco / \ar_arcoDur / \ar_arcoLeg):
//   3 atriles por nota (3 sierras), cada uno con su propio vibrato
//   (arranca tarde, como un músico real), su afinación y su arco.
//   -> ruido de arco (presión) -> color (sul tasto oscuro / normal /
//   sul ponticello vidrioso) -> cuerpo del instrumento (3 resonancias:
//   aire, madera y "bridge hill") -> dinámica (pp..ff, también abre el
//   brillo como en una orquesta de verdad).
//   Articulaciones: 0 legato, 1 spiccato, 2 pizzicato (\ar_pizz*), 3 trémolo.
// Secciones: 0 violín, 1 viola, 2 cello, 3 contrabajo, 4 TUTTI
//   (en tutti cada voz del acorde es una sección distinta, sentadas como
//   en el escenario: violines a la izquierda, cellos y bajos a la derecha).
// FX (\ar_fx): disco viejo -> ensemble -> cielo (shimmer) -> sala de
//   conciertos (reflexiones tempranas + cola larga) -> compresor.

Engine_Arco : CroneEngine {

  var voiceBus, dynBus;
  var fxSynth, bodies;
  var noteGroup, releasingGroup, padSynth, legatoSynth, plucks;

  var atk = 0.25, rel = 1.2, color = 0.45, presion = 0.3, vib = 0.5, vibvel = 0.5;
  var ens = 0.6, swell = 0.2, bajo = 0.4;
  var section = 0, artic = 0;

  alloc {
    var mkArco, mkPizz;
    plucks = List.new;

    // cuerpo de cada instrumento:
    // f1, dB1 (aire), f2, dB2 (madera), f3, dB3 (puente), hpf,
    // decay del pizzicato, nivel, vibrato x, ataque x, nivel del pizzicato
    // (medido: los pulsados graves tienen menos pico)
    bodies = [
      [290, 5, 460, 4, 2800, 6, 180, 0.7, 1.0, 1.0, 1.0, 1.4],    // violín
      [230, 5, 380, 4, 2100, 5, 120, 0.9, 1.0, 0.95, 1.1, 1.3],  // viola
      [110, 5, 220, 5, 1500, 4, 55, 1.4, 1.0, 0.88, 1.25, 1.3],  // cello
      [62, 5, 115, 4, 850, 4, 32, 2.2, 1.0, 0.82, 1.5, 1.2]       // contrabajo
    ];

    voiceBus = Bus.audio(context.server, 2);
    dynBus = Bus.control(context.server, 1);
    dynBus.set(0.6);

    // mode 0 = acorde (gate), 1 = nota del arpegio (dur), 2 = legato (glissando)
    mkArco = { |name, mode|
      SynthDef(name, {
        arg out = 0, freq = 440, gate = 1, vel = 0.8, amp = 0.2, pan = 0, dur = 0.3,
            atk = 0.25, rel = 1.2, color = 0.45, presion = 0.3, vib = 0.5, vibvel = 0.5,
            ens = 0.6, swell = 0.2, art = 0, dynBus = 0,
            b1 = 290, g1 = 5, b2 = 460, g2 = 4, b3 = 2800, g3 = 6, hp = 180, lvl = 1,
            vx = 1, ax = 1;
        var dyn, fv, isSpic, isTrem, envL, envS, env, master, sw, vdel, vdep, vrate,
            sig, bright, fc, nz, scr, lev, at;

        dyn = Lag.kr(In.kr(dynBus, 1), 0.08);
        fv = if (mode == 2) { Lag.kr(freq, 0.09) } { freq };
        isSpic = (art - 1).abs < 0.5;
        isTrem = (art - 3).abs < 0.5;
        at = (atk * ax) + 0.015;

        if (mode == 1) {
          envL = EnvGen.kr(Env([0, 1, 0.8, 0], [at.min(dur * 0.35), dur * 0.55, (dur * 0.5) + 0.12], [-2, -2, -4]));
          envS = EnvGen.kr(Env.perc(0.004, ((dur * 0.8) + 0.05).min(0.28), 1.4, -5));
          env = Select.kr(isSpic, [envL, envS]);
          master = EnvGen.kr(Env([1, 1, 0], [at.min(dur * 0.35) + (dur * 1.05) + 0.12, 0.05]), doneAction: 2)
            * EnvGen.kr(Env.asr(0, 1, 0.06), gate, doneAction: 2);
          sw = 1;
        } {
          envL = EnvGen.kr(Env.adsr(at, 1.2, 0.85, rel), gate);
          envS = EnvGen.kr(Env.perc(0.004, 0.24, 1.4, -5));
          env = if (mode == 2) { envL } { Select.kr(isSpic, [envL, envS]) };
          master = EnvGen.kr(Env.asr(0, 1, rel + 0.08), gate, doneAction: 2);
          // swell: messa di voce, la nota crece (y se abre) mientras se sostiene
          sw = EnvGen.kr(Env([1 - (swell * 0.75), 1], [1.5 + (swell * 3)], \sin));
        };

        // vibrato: arranca tarde y crece, distinto en cada atril
        vdel = EnvGen.kr(Env([0, 0, 1], [0.2, 0.7], \sin));
        vdep = vib * 0.014 * vdel;
        vrate = (4.6 + (vibvel * 2.6)) * vx;

        sig = [[-1, -0.7], [0, 0], [1, 0.7]].collect({ |p|
          var det, vr, vb, drift, f, s, tr;
          det = 1 + (p[0] * ens * 0.0045) + Rand(-0.0007, 0.0007);
          vr = (vrate * Rand(0.92, 1.08)) + LFNoise1.kr(0.6).range(-0.25, 0.25);
          vb = SinOsc.kr(vr, Rand(0, 2pi)) * vdep * Rand(0.8, 1.15);
          drift = LFNoise2.kr(Rand(0.2, 0.4)).range(-0.0012, 0.0012);
          f = fv * det * (1 + vb + drift);
          s = Saw.ar(f);
          // trémolo de arco: cada atril a su propio ritmo
          tr = 1 - (isTrem * 0.9 * LFTri.kr(Rand(11.5, 14.5), Rand(0, 4)).range(0, 1).squared);
          s = s * tr * LFNoise2.kr(Rand(0.3, 0.7)).range(0.82, 1);
          Pan2.ar(s, p[1] * ens * 0.4)
        }).sum * 0.5;

        // presión del arco: soplo de crin, raspado al atacar, aspereza
        nz = BPF.ar(WhiteNoise.ar([1, 1]), (fv * 2.5).clip(150, 9000), 0.7) * presion * 0.22;
        scr = HPF.ar(WhiteNoise.ar([1, 1]), 1800) * EnvGen.kr(Env.perc(0.004, 0.09)) * presion * 0.5;
        sig = (sig * (1 + (LFNoise1.ar(fv * 0.37) * presion * 0.18))) + nz + scr;

        // color: sul tasto (oscuro, flautando) .. sul ponticello (vidrio)
        bright = (color + ((dyn - 0.6) * 0.35) + ((vel - 0.6) * 0.25) + (presion * 0.1)
          + ((sw - 1) * 0.6)).clip(0, 1);
        fc = (fv * (1.4 + (bright.squared * 28))).clip(220, 15000);
        sig = BLowPass.ar(sig, fc, 0.85);
        sig = BHiShelf.ar(sig, 2600, 1, ((color - 0.55) * 28).clip(0, 12));
        sig = BLowShelf.ar(sig, (fv * 1.6).clip(40, 2000), 1, ((color - 0.6) * -22).clip(-9, 0));

        // cuerpo del instrumento
        sig = BPeakEQ.ar(sig, b1, 1.1, g1);
        sig = BPeakEQ.ar(sig, b2, 1.3, g2);
        sig = BPeakEQ.ar(sig, b3, 1.5, g3);
        sig = HPF.ar(sig, hp);
        sig = LPF.ar(sig, 11000);

        lev = ((dyn * 0.85) + 0.15) ** 1.6;
        sig = sig * env * master * sw * lev * amp * lvl * (0.5 + (vel * 0.5)) * 4;
        Out.ar(out, Balance2.ar(sig[0], sig[1], if (mode == 2) { Lag.kr(pan, 0.05) } { pan }));
      }).add;
    };
    mkArco.(\ar_arco, 0);
    mkArco.(\ar_arcoDur, 1);
    mkArco.(\ar_arcoLeg, 2);

    // pizzicato: dos atriles pulsando (Karplus-Strong) por el mismo cuerpo
    mkPizz = { |name, mode|
      SynthDef(name, {
        arg out = 0, freq = 440, gate = 1, vel = 0.8, amp = 0.2, pan = 0, dur = 0.3,
            rel = 1.2, color = 0.45, ens = 0.6, dynBus = 0,
            b1 = 290, g1 = 5, b2 = 460, g2 = 4, b3 = 2800, g3 = 6, hp = 180, lvl = 1, dec = 0.8, pz = 1;
        var dyn, bright, dt, sig, fc, lev, master, coef, f0;

        dyn = Lag.kr(In.kr(dynBus, 1), 0.08);
        f0 = freq.max(21);
        bright = (color + ((dyn - 0.6) * 0.3) + ((vel - 0.6) * 0.3)).clip(0, 1);
        dt = dec * (0.55 + (rel * 0.22)) * (0.6 + (vel * 0.5));
        coef = 0.55 - (bright * 0.45);
        sig = [[-1, -0.5, 0], [1, 0.5, 1]].collect({ |p|
          var f, tr, s;
          f = f0 * (1 + (p[0] * ens * 0.003) + Rand(-0.0005, 0.0005));
          tr = if (p[2] == 0) { Impulse.ar(0) } { DelayN.ar(Impulse.ar(0), 0.03, Rand(0.006, 0.02)) };
          s = Pluck.ar(WhiteNoise.ar(1), tr, 0.05, 1 / f, dt, coef);
          Pan2.ar(s, p[1] * ens * 0.5)
        }).sum * 0.6;
        fc = (f0 * (2.5 + (bright.squared * 24))).clip(300, 14000);
        sig = BLowPass.ar(sig, fc, 0.8);
        sig = BPeakEQ.ar(sig, b1, 1.1, g1 + 1);
        sig = BPeakEQ.ar(sig, b2, 1.3, g2 + 1);
        sig = BPeakEQ.ar(sig, b3, 1.5, g3);
        sig = HPF.ar(sig, hp);

        if (mode == 1) {
          master = EnvGen.kr(Env([1, 1, 0], [dt, 0.05]), doneAction: 2)
            * EnvGen.kr(Env.asr(0, 1, 0.06), gate, doneAction: 2);
        } {
          master = EnvGen.kr(Env([1, 1, 0], [dt, 0.05]), doneAction: 2)
            * EnvGen.kr(Env.asr(0, 1, rel.max(0.3)), gate, doneAction: 2);
        };
        lev = ((dyn * 0.85) + 0.15) ** 1.6;
        sig = sig * master * lev * amp * lvl * (0.45 + (vel * 0.55)) * 6.4 * pz;
        Out.ar(out, Balance2.ar(sig[0], sig[1], pan));
      }).add;
    };
    mkPizz.(\ar_pizz, 0);
    mkPizz.(\ar_pizzDur, 1);

    SynthDef(\ar_fx, {
      arg in, out, ens = 0.6, shimmer = 0, crackle = 0, space = 0.35, gain = 1.0;
      var dry, sig, lfo1, lfo2, cmix, wet, sh, verb, er, hs, cn, cg, comp;

      dry = In.ar(in, 2);
      sig = dry;

      // disco viejo (más de 2 teclas apretadas)
      cn = HPF.ar(Crackle.ar(1.85, mul: [1, 1]), 1600);
      cg = Amplitude.kr(Mix(dry), 0.01, 0.08) > 0.02;
      sig = sig + (cn * crackle * 0.3 * cg);

      // ensemble: de cuarteto a orquesta grande
      lfo1 = LFTri.kr(0.31);
      lfo2 = LFTri.kr(0.53);
      cmix = LPF.ar(Mix(sig) * 0.5, 9000);
      wet = [DelayC.ar(cmix, 0.03, 0.009 + (lfo1 * 0.0022) + (lfo2 * 0.0009)),
             DelayC.ar(cmix, 0.03, 0.012 - (lfo1 * 0.0022) - (lfo2 * 0.0009))];
      sig = (sig * (1 - (ens * 0.2))) + (LPF.ar(wet, 7000) * ens * 0.45);

      // cielo: una octava arriba dentro de la reverb
      sh = PitchShift.ar(sig, 0.15, 2.0, 0.008, 0.01);
      sh = FreeVerb2.ar(sh[0], sh[1], 1, 0.92, 0.3);
      sig = sig + (sh * shimmer * 0.8);

      // sala de conciertos: reflexiones tempranas + cola larga
      hs = HPF.ar(sig, 180);
      er = [(DelayN.ar(hs[0], 0.05, 0.017) * 0.5) + (DelayN.ar(hs[1], 0.05, 0.029) * 0.35),
            (DelayN.ar(hs[1], 0.05, 0.021) * 0.5) + (DelayN.ar(hs[0], 0.05, 0.037) * 0.35)];
      verb = DelayN.ar(er + (hs * 0.5), 0.06, 0.03) * (space + (shimmer * 0.3));
      verb = FreeVerb2.ar(verb[0], verb[1], 1, 0.96, 0.5);
      verb = LPF.ar(verb, 6500);
      sig = sig + (er * space * 0.6) + (verb * 1.1);

      comp = Compander.ar(sig, Mix(sig) * 0.5, 0.25, 1, 0.5, 0.008, 0.18);
      sig = comp * 1.5 * gain;
      sig = Limiter.ar(LeakDC.ar(sig), 0.92, 0.002);
      Out.ar(out, sig);
    }).add;

    context.server.sync;

    fxSynth = Synth.tail(context.xg, \ar_fx, [
      \in, voiceBus, \out, context.out_b, \ens, ens
    ]);

    // f1..f4 (0 = voz apagada), bajo, velocidad
    this.addCommand("noteOn", "ffffff", { |msg|
      var freqs = [msg[1], msg[2], msg[3], msg[4]];
      var subf = msg[5], vel = msg[6], nv, def;

      if (releasingGroup.notNil) { releasingGroup.free; releasingGroup = nil };
      if (noteGroup.notNil) {
        noteGroup.set(\gate, 0);
        releasingGroup = noteGroup;
      };
      noteGroup = Group.head(context.xg);

      nv = freqs.count({ |f| f > 0 }).max(1);
      def = if (artic == 2) { \ar_pizz } { \ar_arco };
      freqs.do({ |f, i|
        var b;
        if (f > 0) {
          // tutti: cello, viola, violín II, violín I
          b = if (section == 4) { [2, 1, 0, 0][i] } { section };
          Synth.new(def, this.voiceArgs(b) ++ [
            \freq, f, \vel, vel, \amp, 0.2 * ((4 / nv) ** 0.5), \pan, this.panFor(b, i, nv)
          ], noteGroup);
        };
      });
      if ((subf > 0) && (bajo > 0.001)) {
        Synth.new(def, this.voiceArgs(this.subBody) ++ [
          \freq, subf, \vel, vel, \amp, 0.2 * bajo, \pan, if (section == 4) { 0.6 } { 0.1 }
        ], noteGroup);
      };
    });

    this.addCommand("noteOff", "", { |msg|
      var g;
      if (releasingGroup.notNil) { releasingGroup.free; releasingGroup = nil };
      if (noteGroup.notNil) {
        g = noteGroup;
        g.set(\gate, 0);
        releasingGroup = g;
        noteGroup = nil;
        SystemClock.sched(rel.max(0.3) + 0.6, {
          if (releasingGroup === g) { g.free; releasingGroup = nil };
          nil
        });
      };
    });

    // bajo sostenido mientras corre el arpegio
    this.addCommand("padOn", "f", { |msg|
      if (bajo < 0.001) {
        if (padSynth.notNil) { padSynth.set(\gate, 0); padSynth = nil };
      } {
        if (padSynth.notNil) {
          padSynth.set(\freq, msg[1]);
        } {
          padSynth = Synth.new(\ar_arcoLeg, this.voiceArgs(this.subBody) ++ [
            \freq, msg[1], \vel, 0.7, \amp, 0.24 * bajo,
            \art, if (artic == 3) { 3 } { 0 }, \pan, if (section == 4) { 0.6 } { 0.1 }
          ], context.xg);
        };
      };
    });

    this.addCommand("padOff", "", { |msg|
      if (padSynth.notNil) { padSynth.set(\gate, 0); padSynth = nil };
    });

    // freq, dur, vel, pan
    this.addCommand("arpStep", "ffff", { |msg|
      var p, b, def, pan;
      while { plucks.size >= 8 } { plucks.removeAt(0).set(\gate, 0) };
      b = this.bodyForFreq(msg[1]);
      def = if (artic == 2) { \ar_pizzDur } { \ar_arcoDur };
      pan = if (section == 4) { (this.seat(b) + (msg[4] * 0.4)).clip(-0.9, 0.9) } { msg[4] };
      p = Synth.new(def, this.voiceArgs(b) ++ [
        \freq, msg[1], \dur, msg[2], \vel, msg[3], \pan, pan, \amp, 0.28
      ], context.xg);
      plucks.add(p);
      p.onFree { plucks.remove(p) };
    });

    // freq, vel, pan: la primera vez crea la voz, después solo la desliza
    this.addCommand("arpLegato", "fff", { |msg|
      var b;
      if (legatoSynth.notNil) {
        legatoSynth.set(\freq, msg[1], \vel, msg[2], \pan, msg[3]);
      } {
        b = this.bodyForFreq(msg[1]);
        legatoSynth = Synth.new(\ar_arcoLeg, this.voiceArgs(b) ++ [
          \freq, msg[1], \vel, msg[2], \pan, msg[3], \amp, 0.36,
          \art, if (artic == 3) { 3 } { 0 }
        ], context.xg);
      };
    });
    this.addCommand("arpLegatoOff", "", { |msg|
      if (legatoSynth.notNil) { legatoSynth.set(\gate, 0); legatoSynth = nil };
    });

    this.addCommand("atk", "f", { |msg| atk = msg[1] });
    this.addCommand("rel", "f", { |msg| rel = msg[1]; this.setLive([\rel, rel]) });
    this.addCommand("color", "f", { |msg| color = msg[1]; this.setLive([\color, color]) });
    this.addCommand("presion", "f", { |msg| presion = msg[1]; this.setLive([\presion, presion]) });
    this.addCommand("vib", "f", { |msg| vib = msg[1]; this.setLive([\vib, vib]) });
    this.addCommand("vibvel", "f", { |msg| vibvel = msg[1]; this.setLive([\vibvel, vibvel]) });
    this.addCommand("ens", "f", { |msg|
      ens = msg[1];
      fxSynth.set(\ens, ens);
      this.setLive([\ens, ens]);
    });
    this.addCommand("swell", "f", { |msg| swell = msg[1] });
    this.addCommand("bajo", "f", { |msg| bajo = msg[1] });
    this.addCommand("dyn", "f", { |msg| dynBus.set(msg[1]) });
    this.addCommand("section", "i", { |msg| section = msg[1].clip(0, 4) });
    this.addCommand("artic", "i", { |msg| artic = msg[1].clip(0, 3) });
    this.addCommand("shimmer", "f", { |msg| fxSynth.set(\shimmer, msg[1]) });
    this.addCommand("space", "f", { |msg| fxSynth.set(\space, msg[1]) });
    this.addCommand("gain", "f", { |msg| fxSynth.set(\gain, msg[1]) });
    this.addCommand("crackle", "f", { |msg| fxSynth.set(\crackle, msg[1]) });
  }

  voiceArgs { |b|
    var x = bodies[b];
    ^[\out, voiceBus, \dynBus, dynBus.index, \atk, atk, \rel, rel, \color, color,
      \presion, presion, \vib, vib, \vibvel, vibvel, \ens, ens, \swell, swell, \art, artic,
      \b1, x[0], \g1, x[1], \b2, x[2], \g2, x[3], \b3, x[4], \g3, x[5], \hp, x[6],
      \dec, x[7], \lvl, x[8], \vx, x[9], \ax, x[10], \pz, x[11]]
  }

  // asientos en el escenario (de izquierda a derecha)
  seat { |b| ^[-0.5, 0.15, 0.45, 0.65][b] }

  panFor { |b, i, nv|
    if (section == 4) { ^[0.45, 0.15, -0.25, -0.55][i] };
    if (nv == 1) { ^0 };
    ^((i - 1.5) * 0.28 * (0.5 + ens)).clip(-0.8, 0.8)
  }

  // el bajo: cello debajo de violines / violas, contrabajo debajo del resto
  subBody { ^if (section < 2) { 2 } { 3 } }

  bodyForFreq { |f|
    if (section != 4) { ^section };
    ^if (f < 196) { 2 } { if (f < 294) { 1 } { 0 } }
  }

  setLive { |args|
    if (noteGroup.notNil) { noteGroup.set(*args) };
    if (legatoSynth.notNil) { legatoSynth.set(*args) };
    if (padSynth.notNil) { padSynth.set(*args) };
  }

  free {
    if (noteGroup.notNil) { noteGroup.free };
    if (releasingGroup.notNil) { releasingGroup.free };
    if (padSynth.notNil) { padSynth.free };
    if (legatoSynth.notNil) { legatoSynth.free };
    plucks.do(_.free);
    fxSynth.free;
    voiceBus.free;
    dynBus.free;
  }
}
