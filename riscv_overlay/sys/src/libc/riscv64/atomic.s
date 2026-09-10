/*
 *	RISC-V atomic operations
 *	assumes A extension; LR/SC only work on cached regions
 */

#define ARG	8

#define MASK(w)	((1<<(w))-1)
#define FENCE	WORD $(0xf | MASK(8)<<20)  /* all i/o, mem ops before & after */
#define AQ	(1<<26)			/* acquire */
#define RL	(1<<25)			/* release */
#define LRW(rs1, rd) \
	WORD $((2<<27)|(    0<<20)|((rs1)<<15)|(2<<12)|((rd)<<7)|057|AQ)
#define SCW(rs2, rs1, rd) \
	WORD $((3<<27)|((rs2)<<20)|((rs1)<<15)|(2<<12)|((rd)<<7)|057|AQ|RL)
#define LRD(rs1, rd) \
	WORD $((2<<27)|(    0<<20)|((rs1)<<15)|(3<<12)|((rd)<<7)|057|AQ)
#define SCD(rs2, rs1, rd) \
	WORD $((3<<27)|((rs2)<<20)|((rs1)<<15)|(3<<12)|((rd)<<7)|057|AQ|RL)

/* long agetl(Along *p) */
TEXT agetl(SB), 1, $-4
	FENCE
	MOVW	(R(ARG)), R(ARG)
	FENCE
	RET

/* void *agetp(Aptr *p) */
TEXT agetp(SB), 1, $-4
	FENCE
	MOV	(R(ARG)), R(ARG)
	FENCE
	RET

/* long aswapl(Along *p, long v); returns old */
TEXT aswapl(SB), 1, $-4
	MOVW	v+XLEN(FP), R9
	MOV	R(ARG), R12
	FENCE
_swapl:
	LRW(12, ARG)			/* (R12) -> R(ARG), the old value */
	SCW(9, 12, 14)
	BNE	R14, _swapl
	FENCE
	RET

/* void *aswapp(Aptr *p, void *v); returns old */
TEXT aswapp(SB), 1, $-4
	MOV	v+XLEN(FP), R9
	MOV	R(ARG), R12
	FENCE
_swapp:
	LRD(12, ARG)
	SCD(9, 12, 14)
	BNE	R14, _swapp
	FENCE
	RET

/* long aincl(Along *p, long v); returns NEW */
TEXT aincl(SB), 1, $-4
	MOVW	v+XLEN(FP), R9
	MOV	R(ARG), R12
	FENCE
_incl:
	LRW(12, ARG)
	ADD	R9, R(ARG)		/* new value */
	SCW(ARG, 12, 14)
	BNE	R14, _incl
	FENCE
	MOVW	R(ARG), R(ARG)		/* re-sign-extend after 64-bit ADD */
	RET

/* int acasl(Along *p, long ov, long nv) */
TEXT acasl(SB), 1, $-4
	MOVW	ov+XLEN(FP), R12
	MOVW	nv+(XLEN+4)(FP), R13
	FENCE
_casl:
	LRW(ARG, 14)			/* lr.w sign-extends */
	BNE	R12, R14, _caslf
	SCW(13, ARG, 14)
	BNE	R14, _casl		/* store failed, retry */
	MOV	$1, R(ARG)
	FENCE
	RET
_caslf:
	MOV	R0, R(ARG)
	FENCE
	RET

/* int acasp(Aptr *p, void *ov, void *nv) */
TEXT acasp(SB), 1, $-4
	MOV	ov+XLEN(FP), R12
	MOV	nv+(2*XLEN)(FP), R13
	FENCE
_casp:
	LRD(ARG, 14)
	BNE	R12, R14, _caspf
	SCD(13, ARG, 14)
	BNE	R14, _casp
	MOV	$1, R(ARG)
	FENCE
	RET
_caspf:
	MOV	R0, R(ARG)
	FENCE
	RET

/* barrier */
TEXT coherence(SB), 1, $-4
	FENCE
	RET
