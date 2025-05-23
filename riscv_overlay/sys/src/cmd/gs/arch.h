#ifndef _ARCH_H
#define _ARCH_H
#ifdef T386
#include "386.h"
#elif Tmips
#include "mips.h"
#elif Tspim
#include "spim.h"
#elif Tpower
#include "power.h"
#elif Tpower64
#include "power64.h"
#elif Tarm
#include "arm.h"
#elif Tarm64
#include "arm64.h"
#elif Tamd64
#include "amd64.h"
#elif Triscv
#include "riscv.h"
#elif Triscv64
#include "riscv64.h"
#else
	I do not know about your architecture.
	Update switch in arch.h with new architecture.
#endif	/* T386 */
#endif /* _ARCH_H */
