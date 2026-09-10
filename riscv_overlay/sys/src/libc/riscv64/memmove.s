/*
 *	RISC-V memmove/memcpy
 *
 *	TODO: The C906 (used for testing) handles misaligned 8-byte access in 
 *  hardware at a ~1 cycle penalty (measured), so this makes no attempt to
 *	align either pointer - no head loop, no (src^dst)&7 test, no
 *	shift-and-merge path.
 *
 *	usize is 32 bits on this port, so n is a 4-byte slot.
 *
 *	R8  to (return value, never modified)
 *	R9  loop limit		R10 temp / n
 *	R11 dst walker		R12 src walker
 *	R13 dst end (fwd) / dst start (back)
 *	R14 temp / compare result
 */

	TEXT	memcpy(SB), 1, $-4
	TEXT	memmove(SB), 1, $-4

	MOV	from+8(FP), R12
	MOVWU	n+16(FP), R10
	MOV	R8, R11

	BEQ	R10, ret		/* n == 0 */
	BEQ	R11, R12, ret		/* to == from */

	SLTU	R11, R12, R14		/* R14 = from < to */
	BNE	R14, back

/*
 * forward
 */
	ADD	R10, R11, R13		/* dst end; R10 free from here */
	ADD	$-31, R13, R9		/* last start for a 32-byte block */
f32:
	SLTU	R9, R11, R14
	BEQ	R14, f8
	MOV	0(R12), R10
	MOV	8(R12), R14
	MOV	R10, 0(R11)
	MOV	R14, 8(R11)
	MOV	16(R12), R10
	MOV	24(R12), R14
	MOV	R10, 16(R11)
	MOV	R14, 24(R11)
	ADD	$32, R12
	ADD	$32, R11
	JMP	f32

f8:
	ADD	$-7, R13, R9
f8l:
	SLTU	R9, R11, R14
	BEQ	R14, f1
	MOV	0(R12), R10
	MOV	R10, 0(R11)
	ADD	$8, R12
	ADD	$8, R11
	JMP	f8l

f1:
	SLTU	R13, R11, R14
	BEQ	R14, ret
	MOVB	0(R12), R10
	MOVB	R10, 0(R11)
	ADD	$1, R12
	ADD	$1, R11
	JMP	f1

ret:
	RET

/*
 * backward - walk both pointers down from the end
 */
back:
	ADD	R10, R11, R11		/* dst end */
	ADD	R10, R12, R12		/* src end */
	MOV	R8, R13			/* dst start */
	ADD	$31, R13, R9
b32:
	SLTU	R11, R9, R14
	BEQ	R14, b8
	MOV	-8(R12), R10
	MOV	-16(R12), R14
	MOV	R10, -8(R11)
	MOV	R14, -16(R11)
	MOV	-24(R12), R10
	MOV	-32(R12), R14
	MOV	R10, -24(R11)
	MOV	R14, -32(R11)
	ADD	$-32, R12
	ADD	$-32, R11
	JMP	b32

b8:
	ADD	$7, R13, R9
b8l:
	SLTU	R11, R9, R14
	BEQ	R14, b1
	MOV	-8(R12), R10
	MOV	R10, -8(R11)
	ADD	$-8, R12
	ADD	$-8, R11
	JMP	b8l

b1:
	SLTU	R11, R13, R14
	BEQ	R14, ret
	MOVB	-1(R12), R10
	MOVB	R10, -1(R11)
	ADD	$-1, R12
	ADD	$-1, R11
	JMP	b1

	END
