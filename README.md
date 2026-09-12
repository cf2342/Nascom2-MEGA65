# NASCOM 2 for MEGA65 — R3 and R6 builds

This source snapshot contains the files required to build FPGA bitstreams for
MEGA65 R3/R3A and R6. It uses the current VHDL sources, including the embedded
ROM images. No existing Vivado project, checkpoint, external ROM file or
third-party source download is needed.

## Requirements

- AMD Vivado with support for Artix-7 `xc7a200tfbg484-2`.
- Vivado 2025.2.1 was used for source/elaboration checks of this snapshot.
- The `vivado` command must be available in your shell (for example, use the
  Vivado command prompt on Windows).

Vivado provides the UNISIM primitives and XPM memory components. They are not
redistributed here. All VHDL files are configured as VHDL 2008 by the scripts.

## Build

Run from this directory:

```sh
vivado -mode batch -source build_mega65_r3.tcl
vivado -mode batch -source build_mega65_r6.tcl
```

Run the commands separately when building only one board. Each build recreates
its generated project directory, runs synthesis and implementation, writes the
bitstream, and checks the final setup/hold timing. Do not keep hand-edited
project settings inside the generated directories. A timing-check failure is
a failed build even if a `.bit` file has been written.

| Board | Top entity | Generated bitstream |
| --- | --- | --- |
| R3 / R3A | `Mega65_Nascom2_R3` | `Nascom2_mega65_r3/Nascom2_mega65_r3.runs/impl_1/Mega65_Nascom2_R3.bit` |
| R6 | `Mega65_Nascom2` | `Nascom2_mega65/Nascom2_mega65.runs/impl_1/Mega65_Nascom2.bit` |

The scripts use 12 jobs. Adjust `-jobs 12` in the build scripts if necessary.
The optional `NASCOM2_R3_PROJECT_DIR` environment variable changes the R3 output
location; leave it unset for the path shown above. No incremental checkpoints
are required for a clean build.

## Layout

- `Nascom2.rtl/`: T80 CPU sources.
- `Nascom2.srcs/sources_1/new/`: board wrappers, NASCOM core, peripherals and ROM packages.
- `Nascom2.srcs/sources_1/new/tyto2_hdmi/`: required video/audio sources.
- `Nascom2.srcs/constrs_1/new/`: R3 and R6 board constraints.
- `create_mega65*_project.tcl`: project creation.
- `build_mega65_r*.tcl`: complete bitstream builds.

This is a build-source snapshot. SD-card software, manuals, simulation results,
old releases and generated Vivado projects are not included. Building `.cor`
files for the MEGA65 core menu is a separate packaging step; these scripts
produce `.bit` files and do not program hardware.

## Source notices

Copyright and license notices in the source files are preserved. The T80,
Tyto-derived and other imported sources carry their respective notices; this
snapshot does not replace them with a blanket license. The original project
manual states GPL v3, while several VHDL headers state LGPL v3-or-later.
The embedded ROM packages contain the firmware used by the build; no new
license is asserted for those images here.

Project: https://nascom2.de
