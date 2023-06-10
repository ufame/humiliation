# Humiliation | Owned | Head Splash

<p align="center" width="100%">
  <img src="https://dev-cs.ru/data/resource_icons/1/1609.jpg?1686378990">
</p>

TT can humiliate a player for CT by jumping on his head.\
Designed for HNS servers.

## Requirements

- [Amx Mod X 1.9.0](https://dev-cs.ru/resources/405/) or higher
- [Reapi](https://dev-cs.ru/resources/73/)

## Usage

1. Put the contents of the `cstrike` folder in the directory of your server (your_server_folder/cstrike/);
2. Compile `hns_humiliation.sma` [how to compile?](https://dev-cs.ru/threads/246/);
4. Add `hns_humiliation.amxx` into your `plugins.ini` file;
5. Restart server or change map;
6. Configure `hns_humiliation.cfg`
6. Dominate.

## Config

<details>
<summary>hns_humiliation.cfg</summary>
This config will be locate in `addons/amxmodx/configs/plugins/` folder.

```Pawn
// Cooldown between possible humiliations
// Minimum: "5.000000"
hns_humiliation_delay "10.0"

// Damage a TT will inflict on a CT
// 0 - disabled
hns_humiliation_damage "15.0"

// Killing icon, will be shown when humiliated
// 0 - disabled
hns_humiliation_death_icon "tracktrain"

// Screenfade time to the humiliated
// 0 - disabled
hns_humiliation_screenfade_duration "0.7"

// screenfade color in HEX
hns_humiliation_screenfade_color "#FF0000"
```
</details>
