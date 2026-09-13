/*
 *	RISC-V memccpy
 *
 *	Same SWAR test as memchr: x = w ^ (c in every lane) holds a zero
 *	byte exactly where w held c, and (x - 0x0101..) & ~x & 0x8080.. is
 *	non-zero iff x has a zero byte.  The test is exact, so a clean word
 *	can be copied whole and a hit falls into the byte loop.
 *
 *	The word must be TESTED BEFORE IT IS STORED: memccpy copies up to
 *	and including c and no further, and strcpy passes n = 10000 with a
 *	destination sized for the string.  Storing first would write up to
 *	seven bytes past the NUL.  That is why the word is re-loaded on the
 *	copy path - w, x and x-ones will not all fit alongside the rest
 *	within R8-R15.
 *
 *	Source and destination must not overlap - same contract as memcpy.
 *
 *	No alignment head loop (C906 misaligned access ~1 cycle, 10d).  A
 *	word is only touched while 8 bytes remain, so this never reads or
 *	writes past a2+n / a1+n.
 *
 *	usize is 32 bits on this port: c is at 16(FP), n at 20(FP).
 *
 *	R8  dst walker (also the return value)	R9  src walker
 *	R10 bytes remaining			R11 c, then c in all lanes
 *	R12 0x0101010101010101			R13 0x8080808080808080
 *	R14, R15 temps
 */

	TEXT	memccpy(SB), 1, $-4

	MOV	a2+8(FP), R9
	MOVWU	c+16(FP), R11
	MOVWU	n+20(FP), R10
	AND	$0xff, R11
	BEQ	R10, none

	SLT	$16, R10, R14		/* too short to pay for the setup */
	BNE	R14, b1

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
	SLT	$8, R10, R14
	BNE	R14, b1
	MOV	0(R9), R14
	XOR	R11, R14		/* x: zero byte where c matched */
	SUB	R12, R14, R15		/* x - 0x0101.. */
	XOR	$-1, R14		/* ~x */
	AND	R14, R15
	AND	R13, R15
	BNE	R15, b1			/* c is in this word: finish by byte */
	MOV	0(R9), R14		/* clean: copy the whole word */
	MOV	R14, 0(R8)
	ADD	$8, R9
	ADD	$8, R8
	ADD	$-8, R10
	JMP	w8

/*
 * byte at a time: the tail, and the eight bytes of a hit word
 */
b1:
	AND	$0xff, R11		/* recover c; idempotent if never broadcast */
b1l:
	BEQ	R10, none
	MOVBU	0(R9), R14
	MOVB	R14, 0(R8)
	ADD	$1, R9
	ADD	$1, R8
	ADD	$-1, R10
	BEQ	R14, R11, ret		/* copied c: R8 points just past it */
	JMP	b1l

none:
	MOV	R0, R8
ret:
	RET
	END
