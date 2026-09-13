/*
 *	RISC-V memchr
 *
 *	SWAR, eight bytes per load: x = w ^ (c in every lane) holds a zero
 *	byte exactly where w held c, and (x - 0x0101..) & ~x & 0x8080.. is
 *	non-zero iff x has a zero byte.  That test is exact - no false
 *	positives - so a hit always means c really is in the word, and a
 *	byte loop over those eight bytes finds which one.
 *
 *	No alignment head loop (C906, as above).  A word is only loaded
 *	while 8 bytes remain, so this never reads past ap+n - which also
 *	means no page-crossing risk.
 *
 *	usize is 32 bits on this port, so n is a 4-byte slot at 12(FP).
 *
 *	R8  pointer walker (also the return value)
 *	R9  bytes remaining		R10 c
 *	R11 c in all eight lanes	R12 0x0101010101010101
 *	R13 0x8080808080808080		R14, R15 temps
 */

	TEXT	memchr(SB), 1, $-4

	MOVWU	c+8(FP), R10
	MOVWU	n+12(FP), R9
	AND	$0xff, R10
	BEQ	R9, none

	SLT	$16, R9, R14		/* too short to pay for the setup */
	BNE	R14, b1

	MOV	R10, R11
	SLL	$8, R11, R14
	OR	R14, R11
	SLL	$16, R11, R14
	OR	R14, R11
	SLL	$32, R11, R14
	OR	R14, R11		/* c in all eight lanes */

	MOV	$1, R12
	SLL	$8, R12, R14
	OR	R14, R12
	SLL	$16, R12, R14
	OR	R14, R12
	SLL	$32, R12, R14
	OR	R14, R12		/* 0x0101010101010101 */
	SLL	$7, R12, R13		/* 0x8080808080808080 */

w8:
	SLT	$8, R9, R14
	BNE	R14, b1
	MOV	0(R8), R14
	XOR	R11, R14		/* x: zero byte where c matched */
	SUB	R12, R14, R15		/* x - 0x0101.. */
	XOR	$-1, R14		/* ~x */
	AND	R14, R15
	AND	R13, R15
	BNE	R15, b1			/* c is in this word */
	ADD	$8, R8
	ADD	$-8, R9
	JMP	w8

/*
 * byte at a time: the tail, and the eight bytes of a hit word
 */
b1:
	BEQ	R9, none
	MOVBU	0(R8), R14
	BEQ	R14, R10, ret
	ADD	$1, R8
	ADD	$-1, R9
	JMP	b1

none:
	MOV	R0, R8
ret:
	RET
	END
