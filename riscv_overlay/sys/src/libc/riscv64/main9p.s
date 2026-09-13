/* _mainp - profiling _main */

#define NPRIVATES	16

#define LINK	R1
#define RARG	R8

TEXT	_mainp(SB), 1, $(4*XLEN + NPRIVATES*XLEN)
	MOV	$setSB(SB), R3
	/* _tos = arg */
	MOV	RARG, _tos(SB)

	MOV	$p-(NPRIVATES*XLEN)(SP), R9
	MOV	R9, _privates(SB)
	MOV	$NPRIVATES, R9
	MOV	R9, _nprivates(SB)

	/* _profmain(argc, argv) -- it calls main() itself */
	MOV	inargc-XLEN(FP), RARG
	MOV	$inargv+0(FP), R10
	MOV	RARG, XLEN(R2)
	MOV	R10, (2*XLEN)(R2)
	JAL	LINK, _profmain(SB)
loop:
	/* exits("main") */
	MOV	$_exitstr<>(SB), RARG
	MOV	RARG, XLEN(R2)
	JAL	LINK, exits(SB)
	MOV	$_profin(SB), R0	/* force loading of profile */
	JMP	loop

TEXT	_callpc(SB), 1, $-4
	MOV	0(R2), RARG		/* _profin's saved LINK: the profiled call site */
TEXT	_saveret(SB), 1, $-4
TEXT	_savearg(SB), 1, $-4
	RET

DATA	_exitstr<>+0(SB)/4, $"main"
GLOBL	_exitstr<>+0(SB), $5
