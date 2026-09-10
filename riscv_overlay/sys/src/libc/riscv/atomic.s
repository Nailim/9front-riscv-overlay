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

/* long agetl(Along *p); void *agetp(Aptr *p) */
TEXT agetl(SB), 1, $-4
TEXT agetp(SB), 1, $-4
	FENCE
	MOVW	(R(ARG)), R(ARG)
	FENCE
	RET

/* long aswapl(Along *p, long v); void *aswapp(Aptr *p, void *v); returns old */
TEXT aswapl(SB), 1, $-4
TEXT aswapp(SB), 1, $-4
	MOVW	v+4(FP), R9
	MOVW	R(ARG), R12
	FENCE
_swapl:
	LRW(12, ARG)			/* (R12) -> R(ARG), the old value */
	SCW(9, 12, 14)			/* R9 -> (R12) maybe, R14=0 if ok */
	BNE	R14, _swapl
	FENCE
	RET

/* long aincl(Along *p, long v); returns NEW value */
TEXT aincl(SB), 1, $-4
	MOVW	v+4(FP), R9
	MOVW	R(ARG), R12
	FENCE
_incl:
	LRW(12, ARG)
	ADD	R9, R(ARG)		/* new value */
	SCW(ARG, 12, 14)
	BNE	R14, _incl
	FENCE
	RET

/* int acasl(Along *p, long ov, long nv); int acasp(Aptr *p, void *ov, void *nv) */
TEXT acasl(SB), 1, $-4
TEXT acasp(SB), 1, $-4
	MOVW	ov+4(FP), R12
	MOVW	nv+8(FP), R13
	FENCE
_casl:
	LRW(ARG, 14)			/* (R(ARG)) -> R14 */
	BNE	R12, R14, _caslf
	SCW(13, ARG, 14)		/* R13 -> (R(ARG)) maybe, R14=0 if ok */
	BNE	R14, _casl		/* R14 != 0 means store failed */
	MOVW	$1, R(ARG)
	FENCE
	RET
_caslf:
	MOVW	R0, R(ARG)
	FENCE
	RET

/* barriers */
TEXT coherence(SB), 1, $-4
	FENCE
	RET
