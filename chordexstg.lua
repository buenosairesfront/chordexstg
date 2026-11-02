-- ChordexSTG
-- cuerdas de orquesta, de la familia U-MA / Chordex: una tecla = un
-- acorde de 4 tonos (+ bajo) tocado por una sección de cuerdas, arpegio,
-- retener, modo acorde, crackle de disco viejo con más de 2 teclas.
--
-- Secciones (K3 + E1): VIOLIN, VIOLA, CELLO, CONTRABAJO, TUTTI
--   cada una en su registro (violín una octava arriba, cello una abajo,
--   contrabajo dos) y con su propio cuerpo. TUTTI reparte el acorde en
--   toda la orquesta: cellos abajo, violas al medio, violines arriba y
--   contrabajos en el bajo, sentados como en el escenario.
-- Articulaciones (K3 + E2): LEGATO, SPICCATO, PIZZICATO, TREMOLO
--   valen para el acorde y para el arpegio. Gate del arpegio al máximo =
--   legato real (el arco se desliza de nota a nota).
--
-- La pantalla ES el instrumento:
--   centro: las 4 cuerdas de frente, del diapasón al puente, con las efes
--     a los costados. Cada voz del acorde vibra en su cuerda con el
--     movimiento real de una cuerda frotada (Helmholtz: una esquina que
--     corre entre el dedo y el puente). El dedo marca dónde se pisa la
--     nota y se mece con el vibrato. El arco cruza las cuerdas: su altura
--     es el color (arriba sul tasto, abajo sul ponticello), su velocidad
--     la dinámica; salta en spiccato, tiembla en trémolo y se levanta en
--     pizzicato. Polvo de resina = presión, chispas que suben = cielo.
--     Abajo a la izquierda, el regulador (<) de la dinámica.
--   izquierda: el acorde en la rueda de 12 notas, la envolvente de la
--     articulación y los 9 faders.
--   derecha: osciloscopio, armónicos con la curva del cuerpo encima,
--     patrón del arpegio; arriba sección, articulación y retener.
--
-- Controles:
--   E1: dinámica (pp..ff)        K3 + E1: sección
--   E2: elige fader              K3 + E2: articulación
--   E3: ajusta fader             K3 + E3: tipo de acorde
--   faders: ataque, release, color, presión del arco, vibrato,
--           velocidad del vibrato, ensemble, swell (crescendo), cielo
--   K2: tap = arpegiador on/off
--   K2 + E1: gate del arpegio (al máximo = legato)
--   K2 + E2: patrón              K2 + E3: velocidad
--   K3 mantenido (sin girar nada): modo acorde on/off (off = una nota)
--   K1 mantenido: retener on/off (rombito arriba a la derecha)
--   clock MIDI entrante: solo marca el tempo del arpegio

engine.name = 'ChordexSTG'

local musicutil = require 'musicutil'

local midi_in
local current_note = nil
local current_vel = 0.8
local last_note = nil
local held_stack = {}
-- teclas que arpegia el modo simple (quedan con HOLD hasta la próxima tecla)
local arp_keys = {}
local function update_arp_keys()
  if #held_stack == 0 then return end
  arp_keys = {}
  for i, n in ipairs(held_stack) do arp_keys[i] = n end
  table.sort(arp_keys)
end
local last_midi_clock = nil
local CLOCK_TIMEOUT = 0.5
local tick_sec = nil
local ext_ticks = 0
local hold_on = false
local loading = false

local chord_types = {"maj", "min", "dim", "aug", "7", "maj7", "min7", "m7b5", "sus2", "sus4", "5", "add9"}
local chord_suffix = {maj = "", min = "m", dim = "dim", aug = "+", ["7"] = "7",
  maj7 = "maj7", min7 = "m7", m7b5 = "m7b5", sus2 = "sus2", sus4 = "sus4",
  ["5"] = "5", add9 = "add9"}
local chord_intervals = {
  maj = {0, 4, 7}, min = {0, 3, 7}, dim = {0, 3, 6}, aug = {0, 4, 8},
  ["7"] = {0, 4, 7, 10}, maj7 = {0, 4, 7, 11}, min7 = {0, 3, 7, 10},
  m7b5 = {0, 3, 6, 10}, sus2 = {0, 2, 7}, sus4 = {0, 5, 7},
  -- quintas abiertas (el sonido de las cuerdas al aire) y add9
  ["5"] = {0, 7, 12, 19}, add9 = {0, 4, 7, 14},
}
local note_names = {"C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"}
local arp_pattern_names = {"up", "down", "up-down", "up x2", "down x2", "random", "arpa"}
local arp_rate_mult = {4, 2, 1, 0.5}
local arp_rate_names = {"x1/4", "x1/2", "x1", "x2"}

-- ============================================================
-- la orquesta
-- ============================================================

-- off = octava respecto de la tecla, low = nota más grave del
-- instrumento, open = cuerdas al aire, sb = separación de cuerdas en el
-- puente (px), fh = alto de las efes, th = grosor de cada cuerda
local SEC = {
  {name = "VIOLIN",     off = 12,  low = 55, open = {55, 62, 69, 76}, sb = 7,   fh = 11, th = {1, 1, 1, 1}},
  {name = "VIOLA",      off = 0,   low = 48, open = {48, 55, 62, 69}, sb = 7.5, fh = 12, th = {2, 1, 1, 1}},
  {name = "CELLO",      off = -12, low = 36, open = {36, 43, 50, 57}, sb = 8.5, fh = 13, th = {2, 2, 1, 1}},
  {name = "CONTRABAJO", off = -24, low = 28, open = {28, 33, 38, 43}, sb = 9.5, fh = 14, th = {2, 2, 2, 1}},
  {name = "TUTTI",      off = 0,   low = 28, open = {36, 48, 55, 62}, sb = 8,   fh = 12, th = {2, 2, 1, 1}},
}
local SEC_NAMES = {}
for i, s in ipairs(SEC) do SEC_NAMES[i] = s.name end
local ART = {"LEGATO", "SPICCATO", "PIZZICATO", "TREMOLO"}

-- cuerpo de cada instrumento (igual que el engine):
-- f1, dB1, f2, dB2, f3, dB3, hpf, decay pizz, vibrato x, ataque x
local BODY = {
  {290, 5, 460, 4, 2800, 6, 180, 0.7, 1.0, 1.0},
  {230, 5, 380, 4, 2100, 5, 120, 0.9, 0.95, 1.1},
  {110, 5, 220, 5, 1500, 4, 55, 1.4, 0.88, 1.25},
  {62, 5, 115, 4, 850, 4, 32, 2.2, 0.82, 1.5},
}

-- faders (E2 elige, E3 ajusta)
local P = {
  {id = "atk",      min = 0.001, max = 3,  step = 0.02},
  {id = "rel",      min = 0.05,  max = 5,  step = 0.04},
  {id = "color",    min = 0,     max = 1,  step = 0.02},
  {id = "presion",  min = 0,     max = 1,  step = 0.02},
  {id = "vibrato",  min = 0,     max = 1,  step = 0.02},
  {id = "vib_vel",  min = 0,     max = 1,  step = 0.02},
  {id = "ensemble", min = 0,     max = 1,  step = 0.02},
  {id = "swell",    min = 0,     max = 1,  step = 0.02},
  {id = "shimmer",  min = 0,     max = 1,  step = 0.02},
}
local focus_index = 1

local arp_on = false
local arp_clock_id = nil
local arp_step_lit = 0
local k2_held, k2_turned, k3_held = false, false, false
local k3_turned = false
local k3_press = nil
local K3_LONG = 0.5   -- segundos manteniendo K3 para alternar el modo acorde

-- animación
local PULSE = 24
local pulse = {}          -- pulso por nombre de control
local flash = 0
local chord_flash = 0
local model_flash = 0
local art_flash = 0
local hold_flash = 0
local last_t = nil

-- las 4 cuerdas que se ven: qué nota suena en cada una y desde cuándo
local STR = {}
-- arco: posición, dirección, altura (color), levantado (pizz), salto (spiccato)
local BOW = {x = 0, dir = 1, y = 40, lift = 0, hop_t = -9, act = 0, jit = 0}

local function pv(id) return params:get(id) end
local function note_to_hz(n) return musicutil.note_num_to_freq(n) end
local function bump(name) pulse[name] = PULSE end

local function four_tone_intervals(name)
  -- modo acorde apagado: suena solo la nota tocada
  if params:get("chord_on") == 1 then return {0} end
  local iv = chord_intervals[name]
  if #iv >= 4 then return iv end
  return {iv[1], iv[2], iv[3], iv[1] + 12}
end

local function chord_name() return chord_types[pv("chord")] end

local function fold_up(n, low)
  while n < low do n = n + 12 end
  return n
end

-- una tecla en el registro de la sección
local function transpose(k)
  local s = pv("seccion")
  local base = k + 12 * pv("octava")
  if s == 5 then return base end
  return fold_up(base + SEC[s].off, SEC[s].low)
end

-- instrumento (1..4) que toca una nota: en tutti depende del registro
local function body_for(n)
  local s = pv("seccion")
  if s ~= 5 then return s end
  local hz = note_to_hz(n)
  if hz < 196 then return 3 elseif hz < 294 then return 2 end
  return 1
end

-- notas del acorde (MIDI) + bajo + instrumento de cada voz
local function chord_voices(note)
  local s = pv("seccion")
  local base = note + 12 * pv("octava")
  local iv = four_tone_intervals(chord_name())
  local v, bod = {}, {}
  local sub
  if pv("chord_on") == 1 and not arp_on and #arp_keys > 1 then
    -- modo normal con varias teclas: suena cada tecla (hasta 4, las últimas)
    local keys = {}
    if #arp_keys > 4 and #held_stack >= 4 then
      for i = #held_stack - 3, #held_stack do keys[#keys + 1] = held_stack[i] end
      table.sort(keys)
    else
      for i = math.max(1, #arp_keys - 3), #arp_keys do keys[#keys + 1] = arp_keys[i] end
    end
    if s == 5 then
      local tb = {3, 2, 1, 1}
      for i, k in ipairs(keys) do v[i] = fold_up(k + 12 * pv("octava"), 36); bod[i] = tb[i] end
      sub = fold_up(keys[1] + 12 * pv("octava") - 24, 28)
    else
      for i, k in ipairs(keys) do v[i] = transpose(k); bod[i] = s end
      sub = fold_up(v[1] - 12, 28)
    end
    table.sort(v)
    return v, sub, bod
  end
  if s == 5 then
    -- tutti: cello, viola, violines; contrabajos en el bajo
    if #iv == 1 then
      v = {fold_up(base - 12, 36), fold_up(base, 48), fold_up(base + 12, 55)}
      bod = {3, 2, 1}
    else
      v = {fold_up(base - 12 + iv[1], 36), fold_up(base + iv[2], 48),
           fold_up(base + iv[3], 55), fold_up(base + iv[4], 55)}
      bod = {3, 2, 1, 1}
    end
    sub = fold_up(base - 24, 28)
  else
    local r = fold_up(base + SEC[s].off, SEC[s].low)
    for i, x in ipairs(iv) do v[i] = r + x; bod[i] = s end
    sub = fold_up(r - 12, 28)
  end
  return v, sub, bod
end

-- en qué cuerda se toca una nota: la más aguda que esté al aire debajo
local function string_rule(n, opens)
  local s = 1
  for i = 1, 4 do if opens[i] <= n then s = i end end
  return s
end

-- dónde va el dedo (0 = cuerda al aire, desde la cejuela hacia el puente)
local function finger_u(n, opens)
  local o = opens[string_rule(n, opens)]
  if n < opens[1] then return 0 end
  return util.clamp(1 - 2 ^ (-(n - o) / 12), 0, 0.62)
end

local function assign_strings(v, opens)
  local out = {}
  if #v >= 4 then
    for i = 1, 4 do out[i] = i end
    return out
  end
  local prev = 0
  for i, n in ipairs(v) do
    local s = string_rule(n, opens)
    s = math.max(s, prev + 1)
    s = math.min(s, 4 - (#v - i))
    out[i] = s
    prev = s
  end
  return out
end

local function art_kind() return pv("artic") end   -- 1 legato 2 spic 3 pizz 4 trem

local comets = {}
local function spawn_comet(note, lv)
  if #comets > 20 then table.remove(comets, 1) end
  comets[#comets + 1] = {pc = note % 12, r = 0, lv = lv}
end

local function bow_stroke(now)
  BOW.dir = -BOW.dir
  BOW.hop_t = now
end

-- ============================================================
-- sonido
-- ============================================================

local function sound_chord(note)
  local v, sub, bod = chord_voices(note)
  local f = {0, 0, 0, 0}
  for i, n in ipairs(v) do f[i] = note_to_hz(n) end
  engine.noteOn(f[1], f[2], f[3], f[4], note_to_hz(sub), current_vel)
  local now = util.time()
  for i = 1, 4 do
    if STR[i] and not STR[i].t1 and not STR[i].dur then STR[i].t1 = now end
  end
  local strs = assign_strings(v, SEC[pv("seccion")].open)
  for i, n in ipairs(v) do
    STR[strs[i]] = {note = n, t0 = now, vel = current_vel, kind = art_kind(),
      body = bod[i], fu = finger_u(n, SEC[bod[i]].open), ph = math.random()}
  end
  bow_stroke(now)
  flash = 1
end

local function release_chord_vs()
  local now = util.time()
  for i = 1, 4 do
    local s = STR[i]
    if s and not s.t1 and not s.dur then s.t1 = now end
  end
end

local function step_order(pat, n)
  local t = {}
  if pat == 1 or pat == 7 then for i = 1, n do t[#t + 1] = i end
  elseif pat == 2 then for i = n, 1, -1 do t[#t + 1] = i end
  elseif pat == 3 then
    for i = 1, n do t[#t + 1] = i end
    for i = n - 1, 2, -1 do t[#t + 1] = i end
  elseif pat == 4 then for i = 1, n do t[#t + 1] = i; t[#t + 1] = i end
  elseif pat == 5 then for i = n, 1, -1 do t[#t + 1] = i; t[#t + 1] = i end
  end
  return t
end

-- notas del arpegio (MIDI, ya en el registro); "arpa" recorre dos octavas
local function arp_notes()
  local t = {}
  if pv("chord_on") == 1 and #arp_keys > 0 then
    for i, k in ipairs(arp_keys) do t[i] = transpose(k) end
  else
    local v = chord_voices(current_note)
    for i, n in ipairs(v) do t[i] = n end
  end
  if pv("arp_pattern") == 7 then
    local n = #t
    for i = 1, n do t[#t + 1] = t[i] + 12 end
  end
  return t
end

local function sub_hz(note)
  local _, sub = chord_voices(note)
  return note_to_hz(sub)
end

local function ext_clock_on()
  return last_midi_clock ~= nil and (util.time() - last_midi_clock) < CLOCK_TIMEOUT
end

local function ticks_per_step()
  local div = ({1, 2, 4, 8})[params:get("midi_clock_div")]
  return math.max(1, 24 * (1 / 16) * div * arp_rate_mult[pv("arp_rate")])
end

local function step_seconds()
  if ext_clock_on() and tick_sec then return tick_sec * ticks_per_step() end
  return clock.get_beat_sec() * (1 / 16) * arp_rate_mult[pv("arp_rate")]
end

local function arp_note_dur(step_sec)
  local g = params:get("arp_gate")
  return util.clamp(step_sec * 0.25 * (32 ^ g), 0.03, 4)
end

local legato_str = nil
local step_i = 1
local function arp_step()
  if current_note == nil then return end
  local notes = arp_notes()
  local pat = pv("arp_pattern")
  local idx, pos
  if pat == 6 then
    idx = math.random(1, #notes); pos = 1
  else
    local order = step_order(pat, #notes)
    pos = ((step_i - 1) % #order) + 1
    idx = order[pos]
  end
  step_i = step_i + 1
  local step_sec = step_seconds()
  local n = notes[idx]
  local vel = (pos == 1 and 1 or 0.72) * (0.55 + current_vel * 0.45)
  local pan = ((idx - 1) % 4 - 1.5) * 0.22
  local dur = arp_note_dur(step_sec)
  local now = util.time()
  local b = body_for(n)
  local si = string_rule(n, SEC[pv("seccion")].open)
  if params:get("arp_gate") >= 0.995 and art_kind() ~= 3 then
    engine.arpLegato(note_to_hz(n), vel, pan)
    -- legato: la cuerda sigue sonando, el dedo se desliza
    local prev = legato_str and STR[legato_str]
    if prev and prev.leg and not prev.t1 and legato_str == si then
      prev.note = n; prev.vel = vel; prev.fu = finger_u(n, SEC[b].open)
    else
      if prev and prev.leg and not prev.t1 then prev.t1 = now end
      STR[si] = {note = n, t0 = (prev and prev.leg) and now - 1 or now, vel = vel,
        kind = art_kind() == 4 and 4 or 1, body = b, fu = finger_u(n, SEC[b].open),
        ph = math.random(), leg = true}
      legato_str = si
    end
  else
    engine.arpLegatoOff()
    engine.arpStep(note_to_hz(n), dur, vel, pan)
    STR[si] = {note = n, t0 = now, vel = vel, kind = art_kind(), dur = dur, body = b,
      fu = finger_u(n, SEC[b].open), ph = math.random()}
    bow_stroke(now)
  end
  arp_step_lit = idx
  spawn_comet(n, 6 + vel * 9)
  flash = math.max(flash, 0.35 * vel)
end

local function arp_legato_off()
  engine.arpLegatoOff()
  local s = legato_str and STR[legato_str]
  if s and s.leg and not s.t1 then s.t1 = util.time() end
  legato_str = nil
end

-- el loop termina solo (generación) en vez de clock.cancel: cancelar un
-- coroutine que ya estaba por despertarse tira "resume (thread expected)"
local arp_gen = 0
local function arp_loop(gen)
  while arp_on and current_note and gen == arp_gen do
    if ext_clock_on() then
      clock.sleep(0.05)
    else
      local quantum = (1 / 16) * arp_rate_mult[pv("arp_rate")]
      if params:get("clock_source") == 1 then clock.sync(quantum)
      else clock.sleep(clock.get_beat_sec() * quantum) end
      if arp_on and current_note and gen == arp_gen and not ext_clock_on() then arp_step() end
    end
  end
  if gen == arp_gen then
    arp_step_lit = 0
    arp_legato_off()
    arp_clock_id = nil
  end
end

local function start_arp_if_needed()
  if arp_clock_id == nil and current_note then
    engine.padOn(sub_hz(current_note))
    step_i = 1
    ext_ticks = 0
    arp_step()
    arp_gen = arp_gen + 1
    arp_clock_id = clock.run(arp_loop, arp_gen)
  end
end

local function stop_arp()
  if arp_clock_id ~= nil then
    arp_gen = arp_gen + 1
    arp_clock_id = nil
  end
  arp_step_lit = 0
  engine.padOff()
  arp_legato_off()
end

-- cambió la sección / articulación / acorde con algo sonando: se vuelve a
-- tocar con lo nuevo (aunque esté retenido o arpegiando)
local function revoice()
  if loading or current_note == nil then return end
  if arp_on then
    arp_legato_off()
    engine.padOff()
    engine.padOn(sub_hz(current_note))
  else
    sound_chord(current_note)
  end
end

local function lowest_held()
  local m = nil
  for _, n in ipairs(held_stack) do
    if m == nil or n < m then m = n end
  end
  return m
end

local crackle_amt = 0
local function update_crackle()
  crackle_amt = util.clamp((#held_stack - 2) * 0.35, 0, 1)
  engine.crackle(crackle_amt)
end

-- con clock MIDI, algunos equipos repiten la nota apretada a tempo: el
-- soltar espera un poco y si vuelve la misma nota no se redispara
local release_id = nil

local function cancel_release()
  if release_id then clock.cancel(release_id); release_id = nil end
end

local function release_now()
  release_id = nil
  if #held_stack == 0 and not hold_on and current_note ~= nil then
    if arp_on then stop_arp() else engine.noteOff(); release_chord_vs() end
    current_note = nil
  end
end

local function release_grace()
  return util.clamp((tick_sec or 0.02) * 13, 0.05, 0.8)
end

local function on_note_on(note, vel)
  cancel_release()
  local prev = current_note
  local fresh = hold_on and #held_stack == 0 and prev ~= nil
  local added = hold_on and #held_stack > 0
  table.insert(held_stack, note)
  if added then
    -- con HOLD, una tecla más mientras hay otras apretadas se suma a lo
    -- retenido (aunque alguna ya se haya soltado)
    local dup = false
    for _, n in ipairs(arp_keys) do if n == note then dup = true end end
    if not dup then table.insert(arp_keys, note); table.sort(arp_keys) end
  else
    update_arp_keys()
  end
  -- sin arpegio manda la última tecla apretada (aunque sea más aguda)
  local low = note
  if arp_on then low = hold_on and arp_keys[1] or lowest_held() end
  if low ~= prev or fresh then
    current_note = low
    last_note = low
    current_vel = vel / 127
    if arp_on then
      if arp_clock_id == nil then start_arp_if_needed()
      else engine.padOn(sub_hz(current_note)) end
    else
      sound_chord(current_note)
    end
  end
  update_crackle()
end

local function on_note_off(note)
  for i = #held_stack, 1, -1 do
    if held_stack[i] == note then table.remove(held_stack, i); break end
  end
  -- con HOLD, soltar teclas no cambia nada
  if hold_on then update_crackle(); return end
  update_arp_keys()
  local low = arp_on and lowest_held() or held_stack[#held_stack]
  if low == nil then
    if not hold_on and current_note ~= nil then
      if ext_clock_on() then
        cancel_release()
        local wait = release_grace()
        release_id = clock.run(function() clock.sleep(wait); release_now() end)
      else
        release_now()
      end
    end
  elseif low ~= current_note or (not arp_on and pv("chord_on") == 1) then
    -- en modo normal soltar una tecla del acorde la saca del acorde
    current_note = low
    last_note = low
    if arp_on then engine.padOn(sub_hz(current_note))
    else sound_chord(current_note) end
  end
  update_crackle()
end

local function set_hold(on)
  hold_on = on
  hold_flash = PULSE
  if not on then cancel_release(); release_now() end
end

local function midi_event(data)
  local msg = midi.to_msg(data)
  if msg.type == "clock" then
    local now = util.time()
    if last_midi_clock then
      local d = now - last_midi_clock
      if d > 0.002 and d < 0.25 then
        tick_sec = tick_sec and (tick_sec * 0.9 + d * 0.1) or d
      end
    end
    last_midi_clock = now
    if arp_on and arp_clock_id and current_note then
      local tps = ticks_per_step()
      ext_ticks = ext_ticks + 1
      if ext_ticks >= tps then
        ext_ticks = math.min(ext_ticks - tps, tps - 1)
        arp_step()
      end
    end
    return
  elseif msg.type == "start" then
    ext_ticks = 0
    step_i = 1
    return
  elseif msg.type == "stop" or msg.type == "continue" then
    return
  end
  local ch = params:get("midi_channel")
  if ch ~= 0 and msg.ch ~= ch then return end
  if msg.type == "note_on" and msg.vel > 0 then
    on_note_on(msg.note, msg.vel)
  elseif msg.type == "note_off" or (msg.type == "note_on" and msg.vel == 0) then
    on_note_off(msg.note)
  end
end

-- ============================================================
-- parámetros (se guardan solos en data/arco/estado.pset)
-- ============================================================

local STATE_FILE

local function add_params()
  params:add_separator("chordexstg", "CHORDEX STG")
  params:add_number("midi_channel", "canal MIDI (0=todos)", 0, 16, 0)
  params:add_option("midi_clock_div", "divisor reloj MIDI", {"1x", "2x", "4x", "8x"}, 3)
  params:add_option("seccion", "sección", SEC_NAMES, 1)
  params:set_action("seccion", function(v) engine.section(v - 1); revoice() end)
  params:add_option("artic", "articulación", ART, 1)
  params:set_action("artic", function(v) engine.artic(v - 1); revoice() end)
  params:add_number("octava", "octava", -2, 2, 0)
  params:set_action("octava", function() revoice() end)
  params:add_option("chord", "acorde", chord_types, 1)
  params:set_action("chord", function() if not arp_on then revoice() end end)
  params:add_option("chord_on", "modo acorde", {"no", "sí"}, 2)
  params:set_action("chord_on", function() if not arp_on then revoice() end end)
  params:add_option("arp_pattern", "patrón arp", arp_pattern_names, 1)
  params:add_option("arp_rate", "velocidad arp", arp_rate_names, 3)
  params:add_control("arp_gate", "gate arp (1=legato)", controlspec.new(0, 1, "lin", 0, 0.6, ""))

  params:add_separator("arco_arco", "ARCO")
  params:add_control("dinamica", "dinámica", controlspec.new(0, 1, "lin", 0, 0.6, ""))
  params:set_action("dinamica", function(v) engine.dyn(v) end)
  params:add_control("color", "color", controlspec.new(0, 1, "lin", 0, 0.45, ""))
  params:set_action("color", function(v) engine.color(v) end)
  params:add_control("presion", "presión", controlspec.new(0, 1, "lin", 0, 0.3, ""))
  params:set_action("presion", function(v) engine.presion(v) end)
  params:add_control("vibrato", "vibrato", controlspec.new(0, 1, "lin", 0, 0.5, ""))
  params:set_action("vibrato", function(v) engine.vib(v) end)
  params:add_control("vib_vel", "velocidad vibrato", controlspec.new(0, 1, "lin", 0, 0.45, ""))
  params:set_action("vib_vel", function(v) engine.vibvel(v) end)
  params:add_control("ensemble", "ensemble", controlspec.new(0, 1, "lin", 0, 0.6, ""))
  params:set_action("ensemble", function(v) engine.ens(v) end)
  params:add_control("swell", "swell", controlspec.new(0, 1, "lin", 0, 0.2, ""))
  params:set_action("swell", function(v) engine.swell(v) end)

  params:add_separator("arco_tono", "TONO")
  params:add_control("atk", "ataque", controlspec.new(0.001, 3, "lin", 0, 0.25, "s"))
  params:set_action("atk", function(v) engine.atk(v) end)
  params:add_control("rel", "release", controlspec.new(0.05, 5, "lin", 0, 1.2, "s"))
  params:set_action("rel", function(v) engine.rel(v) end)
  params:add_control("bajo", "bajo", controlspec.new(0, 1, "lin", 0, 0.4, ""))
  params:set_action("bajo", function(v) engine.bajo(v) end)
  params:add_control("shimmer", "cielo", controlspec.new(0, 1, "lin", 0, 0, ""))
  params:set_action("shimmer", function(v) engine.shimmer(v ^ 3) end)
  params:add_control("space", "sala", controlspec.new(0, 0.8, "lin", 0, 0.35, ""))
  params:set_action("space", function(v) engine.space(v) end)
  params:add_control("gain", "volumen", controlspec.new(0, 1.5, "lin", 0, 1.0, ""))
  params:set_action("gain", function(v) engine.gain(v) end)
end

-- ============================================================
-- init / controles
-- ============================================================

local screen_metro
local splash_start = nil
-- primero la intro U-MA de particulas (la de uma_splash/splash), despues ChordexSTG
local SPLASH_IN, SPLASH_HOLD, SPLASH_FADE = 0.5, 1.8, 0.7
local uma_intro = include("lib/uma_splash_particles")
local uma_sound = include("lib/uma_splash") -- base de la intro, maneja el sonido

local function skip_splash()
  if splash_start and util.time() - splash_start < uma_intro.DUR then uma_sound.sound_off() end
  splash_start = nil
end

function init()
  midi_in = {}
  for i = 1, #midi.vports do
    midi_in[i] = midi.connect(i)
    midi_in[i].event = midi_event
  end

  add_params()
  STATE_FILE = norns.state.data .. "estado.pset"
  loading = true
  if util.file_exists(STATE_FILE) then params:read(STATE_FILE) end
  params:bang()
  loading = false

  uma_sound.sound_on(norns.state.path .. "lib/uma_particles.wav")
  splash_start = util.time()
  screen_metro = metro.init(function() redraw() end, 1 / 24, -1)
  screen_metro:start()
end

function cleanup()
  if STATE_FILE then params:write(STATE_FILE, "chordexstg") end
end

local function nudge(p, d)
  params:set(p.id, util.clamp(pv(p.id) + d * p.step, p.min, p.max))
end

function enc(n, d)
  if splash_start then return end
  local dir = d > 0 and 1 or -1
  if n == 1 then
    if k2_held then
      params:set("arp_gate", util.clamp(params:get("arp_gate") + d * 0.02, 0, 1))
      k2_turned = true
      bump("arp")
    elseif k3_held then
      k3_turned = true
      params:set("seccion", util.clamp(pv("seccion") + dir, 1, #SEC))
      model_flash = PULSE * 2
      art_flash = 0
    else
      params:set("dinamica", util.clamp(pv("dinamica") + d * 0.01, 0, 1))
      bump("dinamica")
    end
  elseif n == 2 then
    if k2_held then
      params:set("arp_pattern", ((pv("arp_pattern") - 1 + dir) % #arp_pattern_names) + 1)
      k2_turned = true
      bump("arp")
    elseif k3_held then
      k3_turned = true
      params:set("artic", util.clamp(pv("artic") + dir, 1, #ART))
      art_flash = PULSE * 2
      model_flash = 0
    else
      focus_index = ((focus_index - 1 + dir) % #P) + 1
      bump(P[focus_index].id)
    end
  elseif n == 3 then
    if k2_held then
      params:set("arp_rate", util.clamp(pv("arp_rate") + dir, 1, #arp_rate_names))
      k2_turned = true
      bump("arp")
    elseif k3_held then
      k3_turned = true
      params:set("chord", util.clamp(pv("chord") + dir, 1, #chord_types))
      chord_flash = PULSE * 2
    else
      nudge(P[focus_index], d)
      bump(P[focus_index].id)
    end
  end
end

function key(n, z)
  -- K1 llega acá solo si se mantiene (el toque corto abre el menú de norns)
  if n == 1 then
    if z == 1 then
      if splash_start then skip_splash() end
      set_hold(not hold_on)
    end
  elseif n == 2 then
    if z == 1 then
      k2_held = true; k2_turned = false
    else
      if splash_start then skip_splash()
      elseif k2_held and not k2_turned then
        arp_on = not arp_on
        bump("arp")
        if arp_on then
          engine.noteOff(); release_chord_vs()
          if current_note then start_arp_if_needed() end
        else
          stop_arp()
          if current_note then sound_chord(current_note) end
        end
      end
      k2_held = false
    end
  elseif n == 3 then
    k3_held = (z == 1)
    if z == 1 and splash_start then skip_splash() end
    if z == 1 then
      -- mantener K3 sin girar ningún encoder alterna el modo acorde
      k3_turned = false
      local press = util.time()
      k3_press = press
      clock.run(function()
        clock.sleep(K3_LONG)
        if k3_held and not k3_turned and k3_press == press then
          params:set("chord_on", 3 - params:get("chord_on"))
          chord_flash = PULSE * 2
        end
      end)
    end
  end
end

-- ============================================================
-- GRÁFICOS — acumulador por nivel (mismo esquema que Chordex)
-- ============================================================

local G = {}
do
local bt, b1, b2, b3, b4, bn = {}, {}, {}, {}, {}, {}
for lv = 1, 15 do bt[lv] = {}; b1[lv] = {}; b2[lv] = {}; b3[lv] = {}; b4[lv] = {}; bn[lv] = 0 end

local function add(lv, ty, a, b, c, d)
  lv = math.floor(lv + 0.5)
  if lv < 1 then return end
  if lv > 15 then lv = 15 end
  local n = bn[lv] + 1
  bn[lv] = n
  bt[lv][n] = ty; b1[lv][n] = a; b2[lv][n] = b; b3[lv][n] = c; b4[lv][n] = d
end

function G.px(lv, x, y) add(lv, 0, x, y) end
function G.line(lv, x1, y1, x2, y2) add(lv, 3, x1, y1, x2, y2) end
function G.rect(lv, x, y, w, h) add(lv, 4, x, y, w, h) end

function G.flush()
  local floor = math.floor
  for lv = 1, 15 do
    local n = bn[lv]
    if n > 0 then
      local T, A, B, C, D = bt[lv], b1[lv], b2[lv], b3[lv], b4[lv]
      screen.level(lv)
      local fills, strokes = false, false
      for k = 1, n do
        local ty = T[k]
        if ty == 0 then
          screen.rect(floor(A[k]), floor(B[k]), 1, 1); fills = true
        elseif ty == 4 then
          screen.rect(floor(A[k]), floor(B[k]), C[k], D[k]); fills = true
        else
          strokes = true
        end
      end
      if fills then screen.fill() end
      if strokes then
        for k = 1, n do
          if T[k] == 3 then
            screen.move(floor(A[k]) + 0.5, floor(B[k]) + 0.5)
            screen.line(floor(C[k]) + 0.5, floor(D[k]) + 0.5)
          end
        end
        screen.stroke()
      end
      bn[lv] = 0
    end
  end
end
end

-- ============================================================
-- envolventes y timbre calculados en Lua (las mismas que el engine)
-- ============================================================

local function vib_rate(s)
  return (4.6 + 2.6 * pv("vib_vel")) * BODY[s.body][9]
end

-- amplitud de una cuerda (0..1) en el instante t
local function str_env(s, t)
  if not s then return 0 end
  local x = t - s.t0
  if x < 0 then return 0 end
  local e
  if s.kind == 3 then
    -- pizzicato: decae solo, más largo en los graves
    local dt = BODY[s.body][8] * (0.55 + pv("rel") * 0.22) * (0.6 + s.vel * 0.5)
    e = x < 0.003 and 1 or math.exp(-6.9 * x / dt)
    if s.t1 and not s.dur and t > s.t1 then
      local y = (t - s.t1) / math.max(0.3, pv("rel"))
      if y >= 1 then return 0 end
      e = e * (1 - y)
    end
    return e
  elseif s.kind == 2 then
    -- spiccato: golpe corto
    local d = s.dur and math.min(0.28, s.dur * 0.8 + 0.05) or 0.24
    if x > d + 0.05 then return 0 end
    return math.exp(-4 * x / d)
  end
  local a = pv("atk") * BODY[s.body][10] + 0.015
  if s.dur then
    a = math.min(a, s.dur * 0.35)
    local h = s.dur * 0.55
    if x < a then e = x / a
    elseif x < a + h then e = 1 - 0.2 * (x - a) / h
    else
      local y = (x - a - h) / (s.dur * 0.5 + 0.12)
      if y >= 1 then return 0 end
      e = 0.8 * (1 - y) * (1 - y)
    end
  else
    local function held(xx)
      if xx < a then return xx / a end
      return 0.85 + 0.15 * math.exp(-3.5 * (xx - a) / 1.2)
    end
    if s.t1 and t > s.t1 then
      local y = (t - s.t1) / pv("rel")
      if y >= 1 then return 0 end
      e = held(s.t1 - s.t0) * (1 - y) * (1 - y)
    else
      e = held(x)
    end
    -- swell: crece mientras se sostiene
    local sw = pv("swell")
    local T = 1.5 + sw * 3
    local u = math.min(1, x / T)
    e = e * (1 - sw * 0.75 * (0.5 + 0.5 * math.cos(math.pi * u)))
  end
  if s.kind == 4 then
    local tri = math.abs(((t * 13 + s.ph * 4) % 2) - 1)
    e = e * (1 - 0.9 * tri * tri)
  end
  return e
end

local V = {}
do
  V.H = 24
  V.N = 64
  V.y, V.a, V.curve, V.spec, V.env = {}, {}, {}, {}, {}
  V.S = {}
  for k = 0, V.N - 1 do V.S[k] = math.sin(2 * math.pi * k / V.N) end
  for k = 1, V.N do V.y[k] = 0 end
  for h = 1, V.H do V.a[h] = 0; V.curve[h] = 1 end
  for h = 1, 14 do V.spec[h] = 0 end
  for i = 1, 4 do V.env[i] = 0 end
  V.amp, V.e = 0, 0
end

local function peak(hz, f, db)
  local d = (hz - f) / (f * 0.4)
  return 1 + (10 ^ (db / 20) - 1) * math.exp(-d * d)
end

-- armónicos de la voz más fuerte: sierra (o cuerda pulsada) -> color ->
-- cuerpo, como en el engine; de ahí el osciloscopio y el espectro
local function compute(t)
  local best, be = nil, 0
  for i = 1, 4 do
    local e = str_env(STR[i], t)
    V.env[i] = e
    if e >= be and STR[i] then best, be = STR[i], e end
  end
  V.e = be
  local note = best and best.note or (last_note and transpose(last_note) or 60)
  local B = BODY[best and best.body or math.min(4, pv("seccion"))]
  local vel = best and best.vel or 0.6
  local pizz = best and best.kind == 3
  local f0 = note_to_hz(note)
  local color, dyn = pv("color"), pv("dinamica")
  local bright = util.clamp(color + (dyn - 0.6) * 0.35 + (vel - 0.6) * 0.25 + pv("presion") * 0.1, 0, 1)
  local fc = util.clamp(f0 * (pizz and (2.5 + bright * bright * 24) or (1.4 + bright * bright * 28)), 220, 15000)
  local hsg = 10 ^ (util.clamp((color - 0.55) * 28, 0, 12) / 20)
  local lsg = 10 ^ (util.clamp((color - 0.6) * -22, -9, 0) / 20)
  for h = 1, V.H do
    local hz = h * f0
    local a = pizz and math.abs(math.sin(math.pi * h * 0.3)) / (h ^ 1.2) or 1 / h
    local x = hz / fc
    local lp = 1 / math.sqrt((1 - x * x) ^ 2 + (x / 0.85) ^ 2)
    local x2 = (hz / 2600) ^ 2
    local hs = 1 + (hsg - 1) * x2 / (1 + x2)
    local x3 = (hz / (f0 * 1.6)) ^ 2
    local ls = lsg + (1 - lsg) * x3 / (1 + x3)
    local bd = peak(hz, B[1], B[2]) * peak(hz, B[3], B[4]) * peak(hz, B[5], B[6])
    local hp = 1 / math.sqrt(1 + (B[7] / hz) ^ 4)
    if hz > 20000 then lp = 0 end
    V.curve[h] = bd * hs * ls * hp
    V.a[h] = a * lp * V.curve[h] * ((h % 2 == 1) and 1 or -1)
  end
  -- un ciclo
  local N, S, y = V.N, V.S, V.y
  for k = 1, N do y[k] = 0 end
  for h = 1, V.H do
    local ah = V.a[h]
    if ah > 0.002 or ah < -0.002 then
      local idx = 0
      for k = 1, N do
        y[k] = y[k] + S[idx] * ah
        idx = (idx + h) % N
      end
    end
  end
  local pk = 1e-6
  for k = 1, N do if math.abs(y[k]) > pk then pk = math.abs(y[k]) end end
  for k = 1, N do y[k] = y[k] / pk end
  V.amp = be
  -- espectro: 14 armónicos normalizados
  local m = 1e-6
  for h = 1, 14 do m = math.max(m, math.abs(V.a[h])) end
  for h = 1, 14 do
    V.spec[h] = V.spec[h] * 0.5 + math.abs(V.a[h]) / m * be * 0.5
  end
end

-- ============================================================
-- dibujo: el instrumento
-- ============================================================

local CX, CY = 64, 32
local SCX, YB, YFB = 63, 46, 31     -- centro, puente, fin del diapasón
local sparks = {}
local dust = {}

local function pl(name) return (pulse[name] or 0) / PULSE end
local function sec() return SEC[pv("seccion")] end
local function spacing(y) return sec().sb * (0.42 + 0.58 * y / YB) end
local function sx(i, y) return SCX + (i - 2.5) * spacing(y) end

local function draw_fhole(cx, side, fh)
  local y0, y1 = YB - fh * 0.8, YB + fh * 0.75
  -- efe izquierda: ojo de arriba hacia el centro, ojo de abajo hacia afuera
  local ux, lx = cx - side * 2, cx + side * 2
  G.rect(8, ux - 1, y0 - 1, 2, 2)
  G.rect(8, lx - 1, y1 - 1, 2, 2)
  local px, py
  for k = 0, 8 do
    local v = k / 8
    local s = v * v * (3 - 2 * v)
    local x = ux + (lx - ux) * s
    local y = y0 + (y1 - y0) * v
    if px then G.line(6, px, py, x, y) end
    px, py = x, y
  end
  -- muescas a la altura del puente
  local v = (YB + 1 - y0) / (y1 - y0)
  local s = v * v * (3 - 2 * v)
  local xm = ux + (lx - ux) * s
  G.px(6, xm - 1, YB + 1)
  G.px(6, xm + 1, YB + 1)
end

local function draw_body(t)
  local S = sec()
  local sb = S.sb
  local w0, w1 = spacing(0) * 2.1, spacing(YFB) * 2.1
  -- diapasón (ébano)
  screen.level(1)
  screen.move(SCX - w0, 0)
  screen.line(SCX + w0, 0)
  screen.line(SCX + w1, YFB)
  screen.line(SCX - w1, YFB)
  screen.close()
  screen.fill()
  G.line(2, SCX - w0, 0, SCX - w1, YFB)
  G.line(2, SCX + w0, 0, SCX + w1, YFB)
  G.line(3, SCX - w1, YFB, SCX + w1, YFB)
  -- bordes del cuerpo (las C) con el filete
  for side = -1, 1, 2 do
    local px, py
    for y = 22, 62, 4 do
      local x = SCX + side * (33 - 3 * math.sin(math.pi * (y - 22) / 40))
      if px then G.line(1, px, py, x, y) end
      px, py = x, y
    end
  end
  -- efes
  for side = -1, 1, 2 do draw_fhole(SCX + side * (sb * 2.3 + 7), side, S.fh) end
  -- puente: arco arriba, base abajo, pies
  local xl, xr = sx(1, YB) - 3, sx(4, YB) + 3
  -- cordal (ébano) primero, el puente encima
  local tw0, tw1 = sb * 1.9, sb * 1.1
  screen.level(1)
  screen.move(SCX - tw0, 54)
  screen.line(SCX + tw0, 54)
  screen.line(SCX + tw1, 64)
  screen.line(SCX - tw1, 64)
  screen.close()
  screen.fill()
  G.line(4, SCX - tw0, 54, SCX + tw0, 54)
  G.line(3, SCX - tw0, 54, SCX - tw1, 63)
  G.line(3, SCX + tw0, 54, SCX + tw1, 63)
  screen.level(3)
  screen.move(xl, YB + 3)
  for k = 0, 8 do
    local u = k / 8
    screen.line(xl + (xr - xl) * u, YB - 2 * math.sin(math.pi * u))
  end
  screen.line(xr, YB + 3)
  screen.close()
  screen.fill()
  local px, py
  for k = 0, 8 do
    local u = k / 8
    local x, y = xl + (xr - xl) * u, YB - 2 * math.sin(math.pi * u)
    if px then G.line(10, px, py, x, y) end
    px, py = x, y
  end
  G.rect(6, xl, YB + 2, 2, 2)
  G.rect(6, xr - 1, YB + 2, 2, 2)
  for i = 1, 4 do
    local xt = SCX + (i - 2.5) * sb * 0.5
    G.line(2, sx(i, YB), YB - 1, xt, 54)
    G.px(6, xt, 55)
  end
end

-- las cuerdas: cada voz vibra en la suya
local function draw_strings(t)
  local S = sec()
  local dyn = pv("dinamica")
  local ens = pv("ensemble")
  local vib = pv("vibrato")
  for i = 1, 4 do
    local s = STR[i]
    local e = V.env[i]
    local th = S.th[i]
    local x0, xb = sx(i, 0), sx(i, YB)
    if not s or e < 0.004 then
      -- cuerda quieta
      G.line(3 + th, x0, 0, xb, YB - 1)
      if th > 1 then G.line(2, x0 + 1, 0, xb + 1, YB - 1) end
    else
      -- dedo (con vibrato que arranca tarde)
      local yf = s.fu * YB
      if s.kind ~= 3 and yf > 0 then
        local vd = util.clamp((t - s.t0 - 0.2) / 0.7, 0, 1)
        yf = yf + math.sin(2 * math.pi * vib_rate(s) * t + i) * vib * 1.6 * vd
      end
      local lv = 4 + 11 * math.min(1, e)
      local A = math.min(S.sb * 0.48, e * (1.5 + 3.5 * dyn) * (0.8 + 0.2 * th))
      local rate = 2.2 * 2 ^ ((s.note - 60) / 24)
      local function pt(u, d)
        local y = yf + (YB - 1 - yf) * u
        return sx(i, y) + d, y
      end
      -- tramo pisado (de la cejuela al dedo)
      if yf > 0.5 then
        G.line(3 + th, x0, 0, sx(i, yf), yf)
        if th > 1 then G.line(2, x0 + 1, 0, sx(i, yf) + 1, yf) end
      end
      local ax, ay = pt(0, 0)
      local bx, by = pt(1, 0)
      local c, d
      if s.kind == 3 then
        -- pizzicato: la cuerda se suelta desde donde la pulsó el dedo
        c = util.clamp((YFB + 3 - yf) / (YB - yf), 0.2, 0.8)
        d = A * math.cos(2 * math.pi * (s.ph + (t - s.t0) * rate * 1.3))
        if t - s.t0 < 0.12 then
          local px, py = pt(c, A)
          G.rect(15, px - 1, py - 1, 2, 2)
        end
      else
        -- Helmholtz: una esquina que va y vuelve por la envolvente parabólica
        local p = (s.ph + t * rate) % 1
        local side
        if p < 0.5 then c, side = 2 * p, 1 else c, side = 2 - 2 * p, -1 end
        c = util.clamp(c, 0.04, 0.96)
        d = side * A * 4 * c * (1 - c)
        -- la envolvente (lo que ve el ojo como "cuerda borrosa")
        for k = 1, 9 do
          local u = k / 10
          local g = A * 4 * u * (1 - u)
          local lx, ly = pt(u, -g)
          local rx, ry = pt(u, g)
          G.px(1 + e * 2, lx, ly)
          G.px(1 + e * 2, rx, ry)
        end
        -- los otros atriles de la sección (ensemble)
        if ens > 0.25 then
          local p2 = (p + 0.37) % 1
          local c2, s2
          if p2 < 0.5 then c2, s2 = 2 * p2, 1 else c2, s2 = 2 - 2 * p2, -1 end
          local cx2, cy2 = pt(c2, s2 * A * 4 * c2 * (1 - c2))
          local gl = 1 + ens * 2 * e
          G.line(gl, ax, ay, cx2, cy2)
          G.line(gl, cx2, cy2, bx, by)
        end
      end
      local cx, cy = pt(c, d)
      G.line(lv, ax, ay, cx, cy)
      G.line(lv, cx, cy, bx, by)
      if th > 1 then
        G.line(lv * 0.5, ax + 1, ay, cx + 1, cy)
        G.line(lv * 0.5, cx + 1, cy, bx + 1, by)
      end
      -- yema del dedo
      if s.fu > 0.01 then G.rect(8 + 7 * e, sx(i, yf) - 1, yf - 1, 3, 2) end
    end
  end
end

-- altura del arco sobre la cuerda (y), con el salto del spiccato
local function bow_y(t)
  local off = 0
  if pv("artic") == 2 then
    local h = (t - BOW.hop_t) / 0.15
    off = -5 * math.min(1, h) ^ 0.6
  end
  return BOW.y + off - BOW.lift * 22
end

local function update_bow(t, dt)
  local art = pv("artic")
  local act = 0
  for i = 1, 4 do
    local s = STR[i]
    if s and s.kind ~= 3 then act = math.max(act, V.env[i]) end
  end
  BOW.act = act
  local ty = 33 + pv("color") * 11
  BOW.y = BOW.y + (ty - BOW.y) * math.min(1, dt * 8)
  local tl = (art == 3) and 1 or 0
  BOW.lift = BOW.lift + (tl - BOW.lift) * math.min(1, dt * 6)
  if art == 4 then
    BOW.x = BOW.x + BOW.dir * dt * 4 * act
    BOW.jit = math.sin(t * 2 * math.pi * 13) * 2.5 * act
  else
    BOW.jit = 0
    local spd = (art == 2) and 30 or (5 + 26 * pv("dinamica"))
    BOW.x = BOW.x + BOW.dir * spd * act * dt
  end
  if BOW.x > 16 then BOW.x = 16; BOW.dir = -1
  elseif BOW.x < -16 then BOW.x = -16; BOW.dir = 1 end
end

-- el arco va encima de las cuerdas (se dibuja después, con halo negro)
local function draw_bow(t)
  local y = bow_y(t)
  local x0 = 16 + BOW.x + BOW.jit
  local L = 92
  local function yy(x) return y + (x - x0) / L * 2 - 1 end
  local a, b = math.max(30, x0), math.min(96, x0 + L)
  local floor = math.floor
  screen.level(0)
  for dy = -4, 1 do
    screen.move(a, floor(yy(a) + dy) + 0.5)
    screen.line(b, floor(yy(b) + dy) + 0.5)
  end
  screen.stroke()
  local lvH = floor(util.clamp(5 + BOW.act * 5 - BOW.lift * 3, 2, 15))
  local lvS = floor(util.clamp(10 - BOW.lift * 6, 3, 15))
  -- crin
  screen.level(lvH)
  screen.move(a, floor(yy(a)) + 0.5)
  screen.line(b, floor(yy(b)) + 0.5)
  screen.stroke()
  -- vara (más cerca de la crin en el medio)
  screen.level(lvS)
  local first = true
  for x = a, b, 6 do
    local u = (x - x0) / L
    local ys = floor(yy(x) - 3 + math.sin(math.pi * u) * 1.2) + 0.5
    if first then screen.move(x, ys); first = false else screen.line(x, ys) end
  end
  screen.line(b, floor(yy(b) - 3 + math.sin(math.pi * (b - x0) / L) * 1.2) + 0.5)
  screen.stroke()
  -- talón y punta
  if x0 >= 30 then
    screen.level(lvS)
    screen.rect(floor(x0), floor(yy(x0)) - 4, 4, 5)
    screen.fill()
  end
  if x0 + L <= 96 then
    screen.level(lvS)
    screen.move(floor(x0 + L) + 0.5, floor(yy(x0 + L)) - 3.5)
    screen.line(floor(x0 + L) + 0.5, floor(yy(x0 + L)) + 0.5)
    screen.stroke()
  end
  return yy
end

-- contacto del arco, polvo de resina, cielo, disco viejo, regulador
local function draw_contact(t, dt, yy)
  local pres = pv("presion")
  local sh = pv("shimmer")
  local touching = BOW.lift < 0.3 and (pv("artic") ~= 2 or t - BOW.hop_t < 0.12)
  for i = 1, 4 do
    local s = STR[i]
    local e = V.env[i]
    if s and s.kind ~= 3 and e > 0.02 then
      local by = bow_y(t)
      local x = sx(i, by)
      local y = yy(x)
      if touching then
        G.rect(6 + 9 * e, x - 1, y - 1, 2, 2)
        if math.random() < pres * e * 0.6 then
          dust[#dust + 1] = {x = x + (math.random() - 0.5) * 3, y = y + 1, life = 1}
        end
      end
      if sh > 0.02 and math.random() < sh * e * 0.8 then
        sparks[#sparks + 1] = {x = x, y = y - 2, v = 8 + math.random() * 10, life = 1}
      end
    end
  end
  -- polvo de resina: cae despacio
  for i = #dust, 1, -1 do
    local p = dust[i]
    p.y = p.y + dt * 7
    p.life = p.life - dt * 1.2
    if p.life <= 0 or p.y > 63 then table.remove(dust, i)
    else G.px(2 + p.life * 4, p.x + math.sin(p.y * 0.7) * 0.6, p.y) end
  end
  if #dust > 60 then table.remove(dust, 1) end
  -- cielo: chispas que suben
  for i = #sparks, 1, -1 do
    local s = sparks[i]
    s.y = s.y - s.v * dt
    s.life = s.life - dt * 0.9
    if s.life <= 0 or s.y < 0 then table.remove(sparks, i)
    else G.px(2 + s.life * 12, s.x + math.sin(s.y * 0.4) * 1.5, s.y) end
  end
  if #sparks > 60 then table.remove(sparks, 1) end
  -- disco viejo: polvo suelto sobre el instrumento
  if crackle_amt > 0 then
    for i = 1, math.floor(crackle_amt * 9) do
      G.px(15, 31 + math.random() * 64, math.random() * 63)
    end
  end
  -- regulador de dinámica (<), abajo a la izquierda
  local dn = pv("dinamica")
  local lp = pl("dinamica")
  local op = 0.5 + dn * 3.5
  G.line(3 + lp * 12, 33, 59, 51, 59 - op)
  G.line(3 + lp * 12, 33, 59, 51, 59 + op)
end

-- ============================================================
-- dibujo: paneles
-- ============================================================

-- el acorde en la rueda de 12 notas (arriba a la izquierda)
local WX, WY, WR = 14, 15, 8
local function wheel_xy(pc, rad)
  local a = (pc / 12) * 2 * math.pi - math.pi / 2
  return WX + math.cos(a) * rad, WY + math.sin(a) * rad
end

local function draw_wheel(t, dt)
  local root = current_note or last_note
  local lit = current_note ~= nil
  local tones = {}
  if root then
    for _, iv in ipairs(four_tone_intervals(chord_name())) do
      tones[#tones + 1] = (root + iv) % 12
    end
  end
  for pc = 0, 11 do
    local x, y = wheel_xy(pc, WR)
    G.px(2, x, y)
  end
  if #tones > 0 then
    local base = lit and 1 or 0.35
    local sorted = {}
    for _, pc in ipairs(tones) do sorted[#sorted + 1] = pc end
    table.sort(sorted)
    for i = 1, #sorted do
      local a, b = sorted[i], sorted[i % #sorted + 1]
      if a ~= b then
        local x1, y1 = wheel_xy(a, WR)
        local x2, y2 = wheel_xy(b, WR)
        G.line((4 + 6 * V.e) * base + chord_flash / PULSE * 6, x1, y1, x2, y2)
      end
    end
    for i, pc in ipairs(tones) do
      local x, y = wheel_xy(pc, WR)
      if i == 1 then G.rect(15 * base, x - 1, y - 1, 2, 2)
      else G.px(11 * base, x, y) end
    end
  end
  for i = #comets, 1, -1 do
    local c = comets[i]
    c.r = c.r + dt * 20
    if c.r > 7 then table.remove(comets, i)
    else
      local r0 = WR + c.r
      local x1, y1 = wheel_xy(c.pc, r0)
      local x2, y2 = wheel_xy(c.pc, math.max(WR, r0 - 3))
      G.line(c.lv * (1 - c.r / 8), x2, y2, x1, y1)
    end
  end
end

-- la envolvente según la articulación, con un punto donde está la voz
local function draw_env(t)
  local x0, y0, w, h = 1, 37, 27, 7
  local art = pv("artic")
  local la = 3 + pl("atk") * 12
  local lr = 3 + pl("rel") * 12
  local la2 = 3 + art_flash / PULSE * 10
  if art == 2 then
    -- spiccato: golpe corto
    G.line(la2, x0, y0, x0 + 1, y0 - h)
    G.line(la2, x0 + 1, y0 - h, x0 + 3, y0 - 2)
    G.line(la2, x0 + 3, y0 - 2, x0 + 6, y0)
    G.line(1, x0 + 6, y0, x0 + w, y0)
  elseif art == 3 then
    -- pizzicato: pulsado que se apaga solo
    G.line(la2, x0, y0, x0 + 1, y0 - h)
    local px, py = x0 + 1, y0 - h
    local r = 3 + math.min(1, pv("rel") / 5) * 20
    for k = 1, 8 do
      local x = x0 + 1 + k / 8 * r
      local y = y0 - h * math.exp(-3 * k / 8)
      G.line(lr, px, py, x, y)
      px, py = x, y
    end
  else
    local a = math.min(1, pv("atk") / 3)
    local r = math.min(1, pv("rel") / 5)
    local xa = x0 + 1 + a * 8
    local xs = xa + 3
    local xr = xs + 3 + (w - 16) * 0.45
    local xe = math.min(x0 + w, xr + 1 + r * 10)
    local ys = y0 - h * 0.8
    G.line(la, x0, y0, xa, y0 - h)
    G.line(3, xa, y0 - h, xs, ys)
    if art == 4 then
      -- trémolo: el sostén tiembla
      local px = xs
      for x = xs + 1, xr do
        G.line(la2, px, ys + ((x % 2 == 0) and 1 or -1), x, ys + ((x % 2 == 0) and -1 or 1))
        px = x
      end
    else
      G.line(3, xs, ys, xr, ys)
    end
    G.line(lr, xr, ys, xe, y0)
  end
  if V.e > 0.01 then
    G.rect(15, x0 + 12, y0 - V.e * h - 1, 2, 2)
  end
end

local function fader_norm(p)
  return (pv(p.id) - p.min) / (p.max - p.min)
end

-- indicador de 3x3 bajo cada fader (alternados arriba / abajo)
local FADER_ICON = {
  atk      = {"..#", ".##", "###"},   -- rampa que sube
  rel      = {"#..", "##.", "###"},   -- rampa que cae
  color    = {"..#", ".#.", "#.."},   -- de oscuro a brillante
  presion  = {".#.", ".#.", "###"},   -- el arco aprieta la cuerda
  vibrato  = {".#.", "#.#", ".#."},   -- tiembla
  vib_vel  = {"#.#", "#.#", ".#."},   -- más rápido
  ensemble = {"#.#", "#.#", "#.#"},   -- varios atriles
  swell    = {".##", "#..", ".##"},   -- regulador <
  shimmer  = {".#.", "###", ".#."},   -- destello
}

local function draw_faders()
  for i, p in ipairs(P) do
    local x = 1 + (i - 1) * 3
    local focused = (focus_index == i)
    local pp = pl(p.id)
    local lv = focused and 15 or (pp > 0 and 6 + 9 * pp or 6)
    G.line(focused and 3 or 1, x, 41, x, 55)
    local v = fader_norm(p)
    local cy = math.floor(54 - v * 13 + 0.5)
    G.rect(lv, x - (focused and 1 or 0), cy, focused and 3 or 2, 2)
    local low = (i % 2 == 0)
    local iy = low and 61 or 57
    local il = focused and 15 or math.floor(5 + 8 * pp + 0.5)
    if low then G.px(focused and 5 or 2, x, 57) G.px(focused and 5 or 2, x, 59) end
    local ic = FADER_ICON[p.id]
    for r = 1, 3 do
      local row = ic[r]
      for c = 1, 3 do
        if row:sub(c, c) == "#" then G.px(il, x - 2 + c, iy + r - 1) end
      end
    end
  end
end

-- panel derecho: sección / articulación / retener, osciloscopio,
-- armónicos + cuerpo, arpegio
local function draw_right(t)
  local x0 = 98
  for m = 1, #SEC do
    G.rect(pv("seccion") == m and 12 or 2, x0 + (m - 1) * 3, 0, 2, 1)
  end
  for m = 1, #ART do
    G.px(pv("artic") == m and 13 or 2, 113 + (m - 1) * 2, 0)
  end
  local lk = hold_on and (current_note and 13 or 8) or 3
  lk = math.min(15, lk + hold_flash * 0.25)
  G.px(lk, 125, 0) G.px(lk, 124, 1) G.px(lk, 126, 1) G.px(lk, 125, 2)
  if hold_on then G.px(lk, 125, 1) end

  -- osciloscopio: un ciclo
  local N = V.N
  local mid = 11
  G.line(1, x0, mid, 127, mid)
  local lv = 4 + 11 * math.min(1, V.amp * 1.5)
  local sc = 0.15 + 0.85 * V.e
  local px, py
  for xx = 0, 29 do
    local k = math.floor(xx / 29 * (N - 1)) + 1
    local y = mid - V.y[k] * 7 * sc
    if px then G.line(lv, px, py, x0 + xx, y) end
    px, py = x0 + xx, y
  end

  -- armónicos y la curva del cuerpo / color encima
  local base = 50
  local cp = math.max(pl("color"), pl("presion"))
  local cm = 1e-6
  for h = 1, 14 do cm = math.max(cm, V.curve[h]) end
  for h = 1, 14 do
    local x = x0 + 1 + (h - 1) * 2
    local m = math.sqrt(V.spec[h]) * 26
    local hh = math.min(26, math.floor(m + 0.5))
    G.px(1, x, base)
    if hh > 0 then
      for y = 0, hh - 1 do
        local u = y / 26
        G.px(3 + 12 * (1 - u) * math.min(1, V.amp * 2 + 0.3), x, base - 1 - y)
      end
    end
    local fy = math.floor(base - 1 - (V.curve[h] / cm) * 22 + 0.5)
    G.px(3 + cp * 12, x, fy)
  end

  -- patrón del arpegio
  local pat = pv("arp_pattern")
  local order
  if pat == 6 then
    order = {}
    for i = 1, 6 do order[i] = (math.floor(t * 4) * 7 + i * 5) % 4 + 1 end
  else
    order = step_order(pat, pat == 7 and 8 or 4)
  end
  local top = (pat == 7) and 8 or 4
  local ap = pl("arp")
  local blink = (math.floor(t * 6) % 2 == 0)
  local base_lv = k2_held and (blink and 15 or 8) or (arp_on and 6 + ap * 6 or 2 + ap * 8)
  local gw = math.min(3, math.floor(26 / #order))
  for i, idx in ipairs(order) do
    local x = x0 + 1 + (i - 1) * gw
    local y = 61 - (idx - 1) * (5 / (top - 1))
    local cur = arp_on and arp_step_lit > 0 and idx == arp_step_lit
    G.rect(cur and 15 or base_lv, x, math.floor(y), math.max(1, gw - 1), 1)
  end
  for i = 1, pv("arp_rate") do
    G.px(k2_held and 12 or (arp_on and 5 or 2), x0 + 1 + (i - 1) * 2, 63)
  end
  local gl = math.floor(params:get("arp_gate") * 18 + 0.5)
  if gl > 0 then G.line(k2_held and 10 or (arp_on and 4 or 1), x0 + 10, 63, x0 + 10 + gl, 63) end
end

-- dibujos de secciones y articulaciones (aparecen al cambiar con K3)
local ICON = {
  VIOLIN = {
    "    #    ",
    "   #+#   ",
    "    #    ",
    "    #    ",
    "    #    ",
    "    #    ",
    "  #####  ",
    " #+++++# ",
    " #+.#.+# ",
    "  #+#+#  ",
    "  #+#+#  ",
    " #+.#.+# ",
    "#++.#.++#",
    "#+++#+++#",
    " #+++++# ",
    "  #####  ",
    "    +    ",
  },
  VIOLA = {
    "     #     ",
    "    #+#    ",
    "     #     ",
    "     #     ",
    "     #     ",
    "     #     ",
    "  #######  ",
    " #+++++++# ",
    " #++.#.++# ",
    "  #++#++#  ",
    "  #++#++#  ",
    " #++.#.++# ",
    "#+++.#.+++#",
    "#++++#++++#",
    "#++++#++++#",
    " #+++++++# ",
    "  #######  ",
    "     +     ",
  },
  CELLO = {
    "      #      ",
    "     #+#     ",
    "      #      ",
    "      #      ",
    "      #      ",
    "   #######   ",
    "  #+++#+++#  ",
    " #+++.#.+++# ",
    " #+++.#.+++# ",
    "  #+++#+++#  ",
    "  #+++#+++#  ",
    " #+++.#.+++# ",
    "#++++.#.++++#",
    "#+++++#+++++#",
    "#+++++#+++++#",
    " #++++#++++# ",
    "  #########  ",
    "      #      ",
    "      #      ",
    "      +      ",
  },
  CONTRABAJO = {
    "       #       ",
    "      #+#      ",
    "       #       ",
    "       #       ",
    "       #       ",
    "      ###      ",
    "     #+#+#     ",
    "    #++#++#    ",
    "   #+++#+++#   ",
    "  #++.+#+.++#  ",
    "  #++.+#+.++#  ",
    "   #++.#.++#   ",
    "   #+++#+++#   ",
    "  #+++.#.+++#  ",
    " #++++.#.++++# ",
    "#++++++#++++++#",
    "#++++++#++++++#",
    " #+++++#+++++# ",
    "  ###########  ",
    "       #       ",
    "       +       ",
  },
  -- las cuatro, de la más chica a la más grande
  TUTTI = {
    "                  #  ",
    "             #    #  ",
    "        #    #    #  ",
    "   #    #    #   ### ",
    "   #   ###  ###  #+# ",
    "  ###  #+#  #+# #+++#",
    "  #+#  ###  #+#  #+# ",
    "  ###  #+#  ###  #+# ",
    "   +   ###  #+# #+++#",
    "        +   ### #+++#",
    "             #   ### ",
    "             +    #  ",
  },
  LEGATO = {
    "  ###########  ",
    " #           # ",
    "#             #",
    "               ",
    "            ## ",
    "       ##  #++#",
    "  ##  #++#  ## ",
    " #++#  ##      ",
    "  ##           ",
  },
  SPICCATO = {
    "  #     #     # ",
    "                ",
    "  #     #     # ",
    "  #     #     # ",
    "  #     #     # ",
    "  #     #     # ",
    " ##    ##    ## ",
    "#+#   #+#   #+# ",
    " #     #     #  ",
  },
  PIZZICATO = {
    "    #        ",
    "    #        ",
    "    #        ",
    "     #       ",
    "      #   ## ",
    "       # #++#",
    "      #   ## ",
    "     #       ",
    "    #        ",
    "    #        ",
    "    #        ",
  },
  TREMOLO = {
    "        # ",
    "     ## # ",
    "   ##   # ",
    "     ## # ",
    "   ##   # ",
    "     ## # ",
    "   ##   # ",
    "        # ",
    "    ### # ",
    "   #+++## ",
    "    ###   ",
  },
}
local ICON_LV = {["#"] = 15, ["+"] = 9, ["."] = 4}

local function draw_icon(rows, a)
  local w, h = #rows[1], #rows
  local x0, y0 = math.floor(CX - w / 2), math.floor(CY - h / 2)
  screen.level(0)
  screen.rect(x0 - 2, y0 - 2, w + 4, h + 4)
  screen.fill()
  for ch, l in pairs(ICON_LV) do
    local lv = math.floor(l * a + 0.5)
    if lv > 0 then
      screen.level(lv)
      for y = 1, h do
        local r = rows[y]
        for x = 1, w do
          if r:sub(x, x) == ch then screen.rect(x0 + x - 1, y0 + y - 1, 1, 1) end
        end
      end
      screen.fill()
    end
  end
end

local function draw_overlays()
  if model_flash > 0 then
    draw_icon(ICON[SEC_NAMES[pv("seccion")]], math.min(1, model_flash / PULSE))
  elseif art_flash > 0 then
    draw_icon(ICON[ART[pv("artic")]], math.min(1, art_flash / PULSE))
  elseif chord_flash > 0 or k3_held then
    -- nombre del acorde, solo mientras se elige (K3)
    local root = current_note or last_note
    local txt = (root and note_names[(root % 12) + 1] or "") ..
      (chord_suffix[chord_name()] ~= "" and chord_suffix[chord_name()] or (root and "" or "maj"))
    if params:get("chord_on") == 1 then txt = root and note_names[(root % 12) + 1] or "1" end
    screen.font_face(1)
    screen.font_size(8)
    local w = screen.text_extents(txt)
    local a = k3_held and 1 or math.min(1, chord_flash / PULSE)
    screen.level(0)
    screen.rect(CX - w / 2 - 2, CY - 5, w + 4, 9)
    screen.fill()
    screen.level(math.floor(15 * a))
    screen.move(CX - w / 2, CY + 2)
    screen.text(txt)
  end
end

-- ---- splash: el nombre y un arco que frota cuatro cuerdas ----
local function draw_splash(alpha, t)
  screen.clear()
  local lv = math.max(0, math.min(15, math.floor(15 * alpha)))
  screen.level(lv)
  screen.font_face(1)
  screen.font_size(16)
  local txt = "A R C O"
  local w = screen.text_extents(txt)
  screen.move(64 - w / 2, 22)
  screen.text(txt)
  local bx = 64 + math.sin(t * 2.2) * 20
  for i = 1, 4 do
    local y = 34 + (i - 1) * 6
    local p = (t * (1.5 + i * 0.4)) % 1
    local c, side
    if p < 0.5 then c, side = 2 * p, 1 else c, side = 2 - 2 * p, -1 end
    local A = 2.2 * math.min(1, t / 0.8)
    local cx = 24 + c * 80
    local d = side * A * 4 * c * (1 - c)
    screen.level(math.max(0, math.floor((5 + i) * alpha)))
    screen.move(24, y + 0.5)
    screen.line(cx, y + d + 0.5)
    screen.line(104, y + 0.5)
    screen.stroke()
  end
  -- el arco cruza las cuerdas en diagonal
  screen.level(math.max(0, math.floor(12 * alpha)))
  screen.move(bx - 6, 30.5)
  screen.line(bx + 6, 56.5)
  screen.stroke()
  screen.level(math.max(0, math.floor(6 * alpha)))
  screen.move(bx - 8, 31.5)
  screen.line(bx + 4, 57.5)
  screen.stroke()
  screen.update()
end

local function tick(dt)
  for k, v in pairs(pulse) do pulse[k] = math.max(0, v - 1) end
  model_flash = math.max(0, model_flash - 1)
  art_flash = math.max(0, art_flash - 1)
  chord_flash = math.max(0, chord_flash - 1)
  hold_flash = math.max(0, hold_flash - 1)
  flash = math.max(0, flash - dt * 3)
end

function redraw()
  local now = util.time()
  if splash_start then
    local e = now - splash_start
    if e < uma_intro.DUR then
      uma_intro.render(e)
      screen.update()
      return
    end
    e = e - uma_intro.DUR
    local t1 = SPLASH_IN
    local t2 = t1 + SPLASH_HOLD
    local t3 = t2 + SPLASH_FADE
    if e < t1 then draw_splash(e / SPLASH_IN, e) return
    elseif e < t2 then draw_splash(1, e) return
    elseif e < t3 then draw_splash(1 - (e - t2) / SPLASH_FADE, e) return
    else splash_start = nil end
  end

  local dt = last_t and math.min(0.2, now - last_t) or 1 / 24
  last_t = now
  tick(dt)
  compute(now)
  update_bow(now, dt)

  screen.clear()
  draw_body(now)
  draw_strings(now)
  G.flush()
  local yy = draw_bow(now)
  draw_contact(now, dt, yy)
  draw_wheel(now, dt)
  draw_env(now)
  draw_faders()
  draw_right(now)
  G.flush()
  draw_overlays()
  screen.update()
end
