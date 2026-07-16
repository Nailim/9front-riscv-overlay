# 9front-riscv-overlay
A port of [Richard Millers](http://9p.io/sources/contrib/miller/) [RiscV](http://9p.io/sources/contrib/miller/riscv.tar) [Plan9 compiler](https://www.youtube.com/watch?v=LHJqdXGb0uc) to 9front.

## about

More accurately, a rebase of Richard Millers RiscV Plan9 compiler source onto 9front codebase with fixes that make example programs run on [MangoPi](https://mangopi.org/mqpro) SBC.

## requirements

A 9front ["THIS TIME DEFINITELY"](https://9front.org/releases/2025/01/19/0/) release.

Might work with newers.

## usage

Go to riscv_overlay directory:

`cd risc_overlay`

Run the bind script to bind the overlay to file system:

`./bind.rc`

Rebuild the source tree.

## notes

Tested with [various examples](https://github.com/Nailim/LanguageTestingPlayground/tree/master/RV/mango-pi-plan9).

Compiled with objtype=riscv64 and loaded on MangoPi trough U-Boot.

Good luck with the rest.
