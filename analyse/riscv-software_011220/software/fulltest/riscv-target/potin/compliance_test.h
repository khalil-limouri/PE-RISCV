#ifndef _COMPLIANCE_TEST_H
#define _COMPLIANCE_TEST_H

#include "riscv_test.h"

//-----------------------------------------------------------------------
// RV Compliance Macros
//-----------------------------------------------------------------------
//
//#define TESTUTIL_BASE 0x20000000
//#define TESTUTIL_ADDR_HALT (TESTUTIL_BASE + 0x10)
//#define TESTUTIL_ADDR_BEGIN_SIGNATURE (TESTUTIL_BASE + 0x8)
//#define TESTUTIL_ADDR_END_SIGNATURE (TESTUTIL_BASE + 0xc)
//
//#define RV_COMPLIANCE_HALT                                                    \
//        /* tell simulation about location of begin_signature */               \
//        la t0, begin_signature;                                               \
//        li t1, TESTUTIL_ADDR_BEGIN_SIGNATURE;                                 \
//        sw t0, 0(t1);                                                         \
//        /* tell simulation about location of end_signature */                 \
//        la t0, end_signature;                                                 \
//        li t1, TESTUTIL_ADDR_END_SIGNATURE;                                   \
//        sw t0, 0(t1);                                                         \
//        /* dump signature and terminate simulation */                         \
//        li t0, 1;                                                             \
//        li t1, TESTUTIL_ADDR_HALT;                                            \
//        sw t0, 0(t1);                                                         \
//        RVTEST_PASS                                                           \

#define RV_COMPLIANCE_HALT                                                    \
        RVTEST_IO_WRITE_STR(x31,"SIGNATURE BEGIN\n"); \
        la t0, begin_signature; \
        addi t0,t0,-4; \
        la t1, end_signature; \
        addi t1,t1,-4; \
signatureloop: \
        addi t0,t0,4; \
        lw t2, 0(t0); \
        LOCAL_SIGNATURE_PUTC(t2); \
        bne t0,t1,signatureloop; \
        RVTEST_IO_WRITE_STR(x31,"SIGNATURE END\n"); \

//#define RV_COMPLIANCE_RV32M                                                   \
//        RVTEST_RV32M                                                          \
//

#define RV_COMPLIANCE_RV32M

//#define RV_COMPLIANCE_CODE_BEGIN                                              \
//        RVTEST_CODE_BEGIN                                                     \
//

#define RV_COMPLIANCE_CODE_BEGIN  \
.global main; \
  main: \
    la t0,main_return_addr; \
    sw ra,0(t0);

//#define RV_COMPLIANCE_CODE_END                                                \
//        RVTEST_CODE_END                                                       \
//

#define RV_COMPLIANCE_CODE_END  \
  la t0,main_return_addr; \
  lw ra,0(t0); \
  li a0,0 ; \
  ret \

#define RV_COMPLIANCE_DATA_BEGIN                                              \
        RVTEST_DATA_BEGIN                                                     \

#define RV_COMPLIANCE_DATA_END                                                \
        RVTEST_DATA_END                                                       \
        .align 8; .global main_return_addr; main_return_addr:                 \
        .word 1;



#endif
