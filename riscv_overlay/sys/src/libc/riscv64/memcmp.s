/*
 *	RISC-V memcmp
 *
 *	Eight bytes per compare; on a difference, a byte loop over that
 *	word finds the first differing byte - so no endian reasoning and
 *	no bit-scan.
 *
 *	No alignment head loop: the C906 handles misaligned 8-byte access
 *	in hardware at ~1 cycle (measured in 10d), same reasoning as
 *	memmove.s.  A word is only loaded while 8 bytes remain, so this
 *	never reads past a1+n or a2+n.
 *
 *	usize is 32 bits on this port, so n is a 4-byte slot at 16(FP).
 *
 *	R8  a1 walker (also the return value)	R9  a2 walker
 *	R10 bytes remaining			R12, R13 loaded values
 *	R14 temp
 */

	TEXT	memcmp(SB), 1, $-4

	MOV	a2+8(FP), R9
	MOVWU	n+16(FP), R10
	BEQ	R10, eq

w8:
	SLT	$8, R10, R14
	BNE	R14, b1
	MOV	0(R8), R12
	MOV	0(R9), R13
	BNE	R12, R13, b1		/* differ somewhere in this word */
	ADD	$8, R8
	ADD	$8, R9
	ADD	$-8, R10
	JMP	w8

/*
 * byte at a time: the tail, and the eight bytes of a differing word
 */
b1:
	BEQ	R10, eq
	MOVBU	0(R8), R12
	MOVBU	0(R9), R13
	BNE	R12, R13, diff
	ADD	$1, R8
	ADD	$1, R9
	ADD	$-1, R10
	JMP	b1

diff:
	MOV	$1, R8
	SLTU	R13, R12, R14		/* R14 = c1 < c2 */
	BEQ	R14, ret
	MOV	$-1, R8
ret:
	RET

eq:
	MOV	R0, R8
	RET
	END
