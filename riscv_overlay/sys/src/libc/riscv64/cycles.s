/*
 *	RISC-V cycle counter
 *
 *	Requires the kernel to have set scounteren.CY; without it this
 *	traps as an illegal instruction in user mode.
 */

#define ARG		8
#define CSR_CYCLE	0xC00

TEXT cycles(SB), 1, $-4		/* void cycles(uvlong*) */
	MOVW	CSR(CSR_CYCLE), R9
	MOV	R9, (R(ARG))
	RET
