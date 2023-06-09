#include <amxmodx>
#include <reapi>
#include <hamsandwich>

new const HUMILIATION_SOUNDS[][] = {
  "humiliation/owned.wav"
}

enum Settings {
  Float: Setting_HumiliationDelay,
  Float: Setting_HumiliationDamage,

  //effects
  Setting_DeathIcon[32],
  Float: Setting_ScreenfadeDuration,
  Setting_ScreenfadeHEXColor[16],
  Setting_ScreenfadeRGBColors[3]
}

new g_globalSettings[Settings]

new g_msgDeathMsg
new g_msgScoreAttrib
new g_msgScreenFade

new Float: g_humiliationDelay[MAX_PLAYERS + 1][MAX_PLAYERS + 1]

public plugin_precache() {
  for (new i; i < sizeof HUMILIATION_SOUNDS; i++)
    precache_sound(HUMILIATION_SOUNDS[i])
}

public plugin_init() {
  register_plugin("HNS: Humiliation", "1.0.0", "ufame")

  registerCvars()
  AutoExecConfig(.name = "hns_humiliation")

  g_msgDeathMsg = get_user_msgid("DeathMsg")
  g_msgScoreAttrib = get_user_msgid("ScoreAttrib")
  g_msgScreenFade = get_user_msgid("ScreenFade")

  if (g_globalSettings[Setting_ScreenfadeDuration])
    g_globalSettings[Setting_ScreenfadeRGBColors] = parseHEXColor(g_globalSettings[Setting_ScreenfadeHEXColor])

  RegisterHookChain(RG_CBasePlayer_PostThink, "playerPostThink", true)
}

public playerPostThink(id) {
  if (!is_user_alive(id) || get_member(id, m_iTeam) != TEAM_TERRORIST)
    return

  new groundEntity = get_entvar(id, var_groundentity)

  if (!(1 <= groundEntity <= MaxClients))
    return

  new Float: gametime = get_gametime()

  if (g_humiliationDelay[id][groundEntity] > gametime)
    return

  if (rg_is_player_can_takedamage(groundEntity, id)) {
    if (g_globalSettings[Setting_DeathIcon][0] != EOS)
      sendDeathMessage(groundEntity, id)

    if (g_globalSettings[Setting_ScreenfadeDuration]) {
      sendScreenfade(
        groundEntity,
        g_globalSettings[Setting_ScreenfadeDuration],
        g_globalSettings[Setting_ScreenfadeRGBColors]
      )
    }
  
    if (g_globalSettings[Setting_HumiliationDamage])
      ExecuteHam(Ham_TakeDamage, groundEntity, id, id, g_globalSettings[Setting_HumiliationDamage], DMG_GENERIC)

    rg_send_audio(0, HUMILIATION_SOUNDS[random_num(0, sizeof HUMILIATION_SOUNDS - 1)])

    g_humiliationDelay[id][groundEntity] = gametime + g_globalSettings[Setting_HumiliationDelay]
  }
}

registerCvars() {
  bind_pcvar_float(
    create_cvar(
      "hns_humiliation_delay",
      "10.0",
      _,
      "Cooldown between possible humiliations",
      .has_min = true,
      .min_val = 5.0
    ),
    g_globalSettings[Setting_HumiliationDelay]
  )

  bind_pcvar_float(
    create_cvar(
      "hns_humiliation_damage",
      "15.0",
      _,
      "Damage a TT will inflict on a CT^n0 - disabled"
    ),
    g_globalSettings[Setting_HumiliationDamage]
  )

  bind_pcvar_string(
    create_cvar(
      "hns_humiliation_death_icon",
      "tracktrain",
      _,
      "Killing icon, will be shown when humiliated^n0 - disabled"
    ),
    g_globalSettings[Setting_DeathIcon],
    charsmax(g_globalSettings[Setting_DeathIcon])
  )

  bind_pcvar_float(
    create_cvar(
      "hns_humiliation_screenfade_duration",
      "0.7",
      _,
      "Screenfade time to the humiliated^n0 - disabled"
    ),
    g_globalSettings[Setting_ScreenfadeDuration]
  )

  bind_pcvar_string(
    create_cvar(
      "hns_humiliation_screenfade_color",
      "#FF0000",
      _,
      "screenfade color in HEX"
    ),
    g_globalSettings[Setting_ScreenfadeHEXColor],
    charsmax(g_globalSettings[Setting_ScreenfadeHEXColor])
  )
}

sendDeathMessage(victim, attacker) {
  message_begin(MSG_BROADCAST, g_msgDeathMsg)
  write_byte(attacker)
  write_byte(victim)
  write_byte(0)
  write_string(g_globalSettings[Setting_DeathIcon])
  message_end()

  message_begin(MSG_BROADCAST, g_msgScoreAttrib)
  write_byte(victim)
  write_byte(0)
  message_end()
}

const FFADE_IN = 0x0000 // Just here so we don't pass 0 into the function

sendScreenfade(id, Float: duration, colors[3], alpha = 70, flags = FFADE_IN) {
  message_begin(MSG_ONE, g_msgScreenFade, .player = id)
  write_short(UTIL_FixedUnsigned16(duration, 1<<12))
  write_short(UTIL_FixedUnsigned16(duration, 1<<12))
  write_short(flags)
  write_byte(colors[0])
  write_byte(colors[1])
  write_byte(colors[2])
  write_byte(alpha)
  message_end()
}

UTIL_FixedUnsigned16(Float: value, scale) {
  return clamp(floatround(value * scale), 0, 0xFFFF)
}

//https://dev-cs.ru/threads/222/page-3#post-33411
parseHEXColor(const value[]) {
  new result[3];
  if (value[0] != '#' && strlen(value) != 7) {
    return result;
  }

  result[0] = parse16bit(value[1], value[2]);
  result[1] = parse16bit(value[3], value[4]);
  result[2] = parse16bit(value[5], value[6]);

  return result;
}

stock parse16bit(ch1, ch2) {
  return parseHex(ch1) * 16 + parseHex(ch2);
}

stock parseHex(const ch) {
  switch (ch) {
    case '0'..'9': {
      return ch - '0';
    }

    case 'a'..'f': {
      return 10 + ch - 'a';
    }

    case 'A'..'F': {
      return 10 + ch - 'A';
    }
  }

  return 0;
}

