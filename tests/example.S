#include "riscv_test.h"
#include "test_macros.h"

RVTEST_RV64U
RVTEST_CODE_BEGIN


example_test:

    la x1, _data1
    la x2, _data2
    la x3, _data3
    lw a0, 0(x1)
    lw a1, 0(x2)
    lw a2, 0(x3)
    add x5, a0, a1
    bne a2, x5, fail

    RVTEST_PASS
fail:
    RVTEST_FAIL

RVTEST_CODE_END

    .data
    _data1:
    .word 0x5
    _data2:
    .word 0x7
    _data3:
    .word 0xC
RVTEST_DATA_BEGIN
    .align 3

result:
    .dword -1

RVTEST_DATA_END
