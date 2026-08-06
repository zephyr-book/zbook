# ZBook Board (Zephyr module)

Out-of-tree board support for the **ZBook** (Raspberry Pi **RP2350B**,
Cortex-**M33**), packaged as a [Zephyr module](https://docs.zephyrproject.org/latest/develop/modules.html).

<p align="center">
<img width="500" height="500" alt="image" src="https://github.com/user-attachments/assets/ff653269-7267-4117-9a28-a77d24d0403e" />
</p>

## Contents

```
boards/zbook/                 # board definition
  zbook_rp2350b_m33.dts       #   standalone variant + partitions
  zbook_rp2350b_m33_mcuboot.dts  # MCUboot variant + partitions
  zbook_rp2350b_m33-common.dtsi  # shared hardware (both variants) + LittleFS fstab
  zbook_rp2350b_m33_p2*.overlay/.yaml + ..._p2-common.dtsi  # P2 revision (see below)
  *_defconfig / *.yaml / board.yml / board.cmake / Kconfig* / zbook-pinctrl.dtsi
boards/shields/zbook_wifi/    # attachable ESP8266 / onboard Wi-Fi module
snippets/                     # board-provided snippets (zbook-wifi-credentials-littlefs)
zephyr/module.yml             # registers boards/ (board_root) and snippets/ (snippet_root)
```

## Hardware revisions

The board comes in two hardware revisions, selected with `@<revision>` on the
board target. `p1` is the default (no suffix needed) and matches the original
pinout; `p2` re-pins almost every peripheral and adds new ones (hall sensor,
temperature sensor, rotary encoder, motor driver, a 4-LED addressable strip,
a second white LED, and an onboard Wi-Fi header) per `zbook-p2-schematics.pdf`.
P2 also has an onboard RP2040 used purely as a debug probe (SWD + UART bridge,
like a Pico's separate debug probe) — it is not a Zephyr build target.

```bash
west build -b zbook/rp2350b/m33          # P1 (default)
west build -b "zbook@p2/rp2350b/m33"     # P2
```

## Usage

Add this repo to your west manifest. `zephyr/module.yml` sets `board_root` and
`snippet_root`, so both the board target and the board-provided snippets are
discovered automatically — no `BOARD_ROOT` needed in your app's CMake:

```yaml
# west.yml (excerpt)
projects:
  - name: zbook
    remote: zephyr-book
    revision: main
```

Then build for the board target:

```bash
west build -b zbook/rp2350b/m33                       # standalone, P1 (default)
west build -b "zbook@p2/rp2350b/m33"                  # standalone, P2
west build -b zbook/rp2350b/m33 --shield zbook_wifi   # + Wi-Fi
west build -b zbook/rp2350b/m33 --shield zbook_wifi -S zbook-wifi-credentials-littlefs  # + LittleFS creds
west build -b zbook/rp2350b/m33/mcuboot --sysbuild    # MCUboot layout
```

## Board targets

| Target                              | Layout                                            |
|--------------------------------------|---------------------------------------------------|
| `zbook/rp2350b/m33`                  | Standalone (boots directly), `storage` partition, P1 |
| `zbook@p2/rp2350b/m33`               | Same as above, P2 hardware revision                |
| `zbook/rp2350b/m33/mcuboot`          | MCUboot layout, app in slot-0, P1                  |
| `zbook@p2/rp2350b/m33/mcuboot`       | MCUboot layout, app in slot-0, P2                  |

The `zbook_wifi` shield works on both revisions; on P2 it uses the onboard
Wi-Fi header's WIFI_NRST/WIFI_EN pins automatically (see
`boards/shields/zbook_wifi/boards/`).

## Snippets

`zephyr/module.yml` sets `snippet_root: .`, so snippets under `snippets/` are
auto-discovered by any app that uses this board — apply one with `-S <name>`.

| Snippet                           | Effect                                                          |
|-----------------------------------|-----------------------------------------------------------------|
| `zbook-wifi-credentials-littlefs` | Persist Wi-Fi credentials via the settings **FILE** backend on **LittleFS** (mounted at `/lfs` on the `storage` partition), instead of the NVS backend used by the upstream `-S wifi-credentials` snippet. |

```bash
west build -b zbook/rp2350b/m33 --shield zbook_wifi -S zbook-wifi-credentials-littlefs
```

Notes:

- The LittleFS mount is the `zephyr,fstab` node in
  `zbook_rp2350b_m33-common.dtsi`; it is inert unless `CONFIG_FILE_SYSTEM_LITTLEFS=y`,
  so it does not affect builds that don't use this snippet.
- The application must still pull the `littlefs` module into its own west
  manifest (a module cannot extend the app's manifest), e.g. add `littlefs` to
  the Zephyr import `name-allowlist`.
