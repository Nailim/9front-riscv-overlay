/*
 *	RISC-V cycle counter
 */

#define ARG		8
#define CSR_CYCLE	0xC00

TEXT cycles(SB), 1, $-4		/* void cycles(uvlong*) */
	MOVW	CSR(CSR_CYCLE), R9
	MOV	R9, (R(ARG))
	RET
