# 9front-riscv-overlay
A port of [Richard Millers](http://9p.io/sources/contrib/miller/) [RiscV](http://9p.io/sources/contrib/miller/riscv.tar) [Plan9 compiler](https://www.youtube.com/watch?v=LHJqdXGb0uc) to 9front.

## about

More accurately, a rebase of Richard Millers RiscV Plan9 compiler source onto 9front codebase.

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

It appears only 32bit RiscV targets works.

Good luck with the rest.
