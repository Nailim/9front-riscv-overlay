/*
 *	RISC-V 64-bit atomic operations
 *	assumes A extension; LR/SC only work on cached regions
 */

#define ARG	8

#define MASK(w)	((1<<(w))-1)
#define FENCE	WORD $(0xf | MASK(8)<<20)  /* all i/o, mem ops before & after */
#define AQ	(1<<26)			/* acquire */
#define RL	(1<<25)			/* release */
#define LRD(rs1, rd) \
	WORD $((2<<27)|(    0<<20)|((rs1)<<15)|(3<<12)|((rd)<<7)|057|AQ)
#define SCD(rs2, rs1, rd) \
	WORD $((3<<27)|((rs2)<<20)|((rs1)<<15)|(3<<12)|((rd)<<7)|057|AQ|RL)

/* vlong agetv(Avlong *p) */
TEXT agetv(SB), 1, $-4
	FENCE
	MOV	(R(ARG)), R(ARG)
	FENCE
	RET

/* vlong aswapv(Avlong *p, vlong v); returns old */
TEXT aswapv(SB), 1, $-4
	MOV	v+XLEN(FP), R9
	MOV	R(ARG), R12
	FENCE
_swapv:
	LRD(12, ARG)			/* (R12) -> R(ARG), the old value */
	SCD(9, 12, 14)
	BNE	R14, _swapv
	FENCE
	RET

/* vlong aincv(Avlong *p, vlong v); returns NEW */
TEXT aincv(SB), 1, $-4
	MOV	v+XLEN(FP), R9
	MOV	R(ARG), R12
	FENCE
_incv:
	LRD(12, ARG)
	ADD	R9, R(ARG)		/* new value; full 64 bits, no re-extension */
	SCD(ARG, 12, 14)
	BNE	R14, _incv
	FENCE
	RET

/* int acasv(Avlong *p, vlong ov, vlong nv) */
TEXT acasv(SB), 1, $-4
	MOV	ov+XLEN(FP), R12
	MOV	nv+(2*XLEN)(FP), R13
	FENCE
_casv:
	LRD(ARG, 14)
	BNE	R12, R14, _casvf
	SCD(13, ARG, 14)
	BNE	R14, _casv		/* store failed, retry */
	MOV	$1, R(ARG)
	FENCE
	RET
_casvf:
	MOV	R0, R(ARG)
	FENCE
	RET
