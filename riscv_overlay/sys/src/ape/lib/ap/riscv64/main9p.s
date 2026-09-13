GLOBL	_tos(SB), $XLEN

	TEXT	_mainp(SB), 1, $(3*XLEN)

	MOV	$setSB(SB), R3
	MOV	R8, _tos(SB)
	JAL	R1, _envsetup(SB)

	JAL	R1, _profmain(SB)

	MOV	_tos(SB), R9
	MOV	XLEN(R9), R10
	MOV	R10, 0(R9)

	MOV	inargc-XLEN(FP), R8
	MOV	R8, XLEN(R2)
	MOV	$inargv+0(FP), R9
	MOV	R9, (2*XLEN)(R2)
	MOV	environ(SB), R9
	MOV	R9, (3*XLEN)(R2)
	JAL	R1, main(SB)

	MOVW	R8, XLEN(R2)
	JAL	R1, exit(SB)
	MOV	$_profin(SB), R0
	RET
