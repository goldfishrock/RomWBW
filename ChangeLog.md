# Changelog

All notable changes to Sid's customised RomWBW firmware for the RC2014 are documented here.

## [3.7.0-dev.15] - 2026-10-16

### Added
- Support for two simultaneous IDE storage interfaces.
- Updated `RC2014_sid.asm` with:
  ```asm
  IDECNT .SET 2
  ```
- Second IDE controller configured at I/O address `0x18`.

### Changed
- Updated customised RomWBW source to upstream version `v3.7.0-dev.15`.
- Retained the custom firmware identification banner:
  `Sid's RC2014 - 16 Oct 2026`
- Reconfigured the Pico MicroSD IDE module address jumper from `P16` to `P24` (hexadecimal `0x18`).
- Retained the CompactFlash module at its original I/O address of `0x10`.

### Hardware Configuration

| Device | RomWBW Device | I/O Address | Capacity |
|---|---|---|---|
| CompactFlash Module | IDE0 | `0x10` | 977 MB |
| Pico MicroSD IDE Module | IDE2 | `0x18` | 65 MB |

### Build and Verification
- Successfully rebuilt firmware using `Build.cmd` with the `RC2014_sid` configuration.
- Generated `RC2014_sid.rom` (512 KB).
- Programmed ROM using XGPro.
- Confirmed successful ROM verification at startup.
- Confirmed both IDE controllers and storage devices were detected simultaneously.
- Confirmed RomWBW initialisation completed successfully.

### Notes
- Existing CompactFlash and MicroSD card contents were preserved.
- No storage formatting or repartitioning was performed.
- Booting CP/M from both storage devices in the new configuration remains to be verified.

### Firmware Details
- **RomWBW:** v3.7.0-dev.15
- **Platform:** RC2014 Z80
- **CPU:** Z80 @ 7.376 MHz
- **Memory:** 512 KB ROM / 512 KB RAM
- **Memory Manager:** Z2 MMU
- **Interrupt Mode:** IM 1
- **Custom Configuration:** `RC2014_sid.asm`