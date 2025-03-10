/* @(#) pf_cglue.c 98/02/11 1.4 */
/***************************************************************
** 'C' Glue support for Forth based on 'C'
**
** Author: Phil Burk
** Copyright 1994 3DO, Phil Burk, Larry Polansky, David Rosenboom
**
** Permission to use, copy, modify, and/or distribute this
** software for any purpose with or without fee is hereby granted.
**
** THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL
** WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
** WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL
** THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR
** CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING
** FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF
** CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
** OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
**
***************************************************************/

#include "pf_all.h"

extern CFunc0 CustomFunctionTable[];

/***************************************************************/
extern CFunc0* ExtendedFunctionTable;

/***************************************************************/
cell_t CallUserFunction( cell_t Index, int32_t ReturnMode, int32_t NumParams )
{
    cell_t P1, P2, P3, P4, P5, P6, P7, P8, P9, P10, P11, P12, P13, P14, P15;
    cell_t Result = 0;
    CFunc0 CF;

DBUG(("CallUserFunction: Index = %d, ReturnMode = %d, NumParams = %d\n",
    Index, ReturnMode, NumParams ));

    CF = ExtendedFunctionTable[Index];

    switch( NumParams )
    {
    case 0:
        Result = ((CFunc0) CF) ( );
        break;
    case 1:
        P1 = POP_DATA_STACK;
        Result = ((CFunc1) CF) ( P1 );
        break;
    case 2:
        P2 = POP_DATA_STACK;
        P1 = POP_DATA_STACK;
        Result = ((CFunc2) CF) ( P1, P2 );
        break;
    case 3:
        P3 = POP_DATA_STACK;
        P2 = POP_DATA_STACK;
        P1 = POP_DATA_STACK;
        Result = ((CFunc3) CF) ( P1, P2, P3 );
        break;
    case 4:
        P4 = POP_DATA_STACK;
        P3 = POP_DATA_STACK;
        P2 = POP_DATA_STACK;
        P1 = POP_DATA_STACK;
        Result = ((CFunc4) CF) ( P1, P2, P3, P4 );
        break;
    case 5:
        P5 = POP_DATA_STACK;
        P4 = POP_DATA_STACK;
        P3 = POP_DATA_STACK;
        P2 = POP_DATA_STACK;
        P1 = POP_DATA_STACK;
        Result = ((CFunc5) CF) ( P1, P2, P3, P4, P5 );
        break;
    case 6:
        P6 = POP_DATA_STACK;
        P5 = POP_DATA_STACK;
        P4 = POP_DATA_STACK;
        P3 = POP_DATA_STACK;
        P2 = POP_DATA_STACK;
        P1 = POP_DATA_STACK;
        Result = ((CFunc6) CF) ( P1, P2, P3, P4, P5, P6 );
        break;
    case 7:
        P7 = POP_DATA_STACK;
        P6 = POP_DATA_STACK;
        P5 = POP_DATA_STACK;
        P4 = POP_DATA_STACK;
        P3 = POP_DATA_STACK;
        P2 = POP_DATA_STACK;
        P1 = POP_DATA_STACK;
        Result = ((CFunc7) CF) ( P1, P2, P3, P4, P5, P6, P7 );
        break;
    case 8:
        P8 = POP_DATA_STACK;
        P7 = POP_DATA_STACK;
        P6 = POP_DATA_STACK;
        P5 = POP_DATA_STACK;
        P4 = POP_DATA_STACK;
        P3 = POP_DATA_STACK;
        P2 = POP_DATA_STACK;
        P1 = POP_DATA_STACK;
        Result = ((CFunc8) CF) ( P1, P2, P3, P4, P5, P6, P7, P8 );
        break;
    case 9:
        P9 = POP_DATA_STACK;
        P8 = POP_DATA_STACK;
        P7 = POP_DATA_STACK;
        P6 = POP_DATA_STACK;
        P5 = POP_DATA_STACK;
        P4 = POP_DATA_STACK;
        P3 = POP_DATA_STACK;
        P2 = POP_DATA_STACK;
        P1 = POP_DATA_STACK;
        Result = ((CFunc9) CF) ( P1, P2, P3, P4, P5, P6, P7, P8, P9 );
        break;
    case 10:
        P10 = POP_DATA_STACK;
        P9 = POP_DATA_STACK;
        P8 = POP_DATA_STACK;
        P7 = POP_DATA_STACK;
        P6 = POP_DATA_STACK;
        P5 = POP_DATA_STACK;
        P4 = POP_DATA_STACK;
        P3 = POP_DATA_STACK;
        P2 = POP_DATA_STACK;
        P1 = POP_DATA_STACK;
        Result = ((CFunc10) CF) ( P1, P2, P3, P4, P5, P6, P7, P8, P9, P10 );
        break;
    case 11:
        P11 = POP_DATA_STACK;
        P10 = POP_DATA_STACK;
        P9 = POP_DATA_STACK;
        P8 = POP_DATA_STACK;
        P7 = POP_DATA_STACK;
        P6 = POP_DATA_STACK;
        P5 = POP_DATA_STACK;
        P4 = POP_DATA_STACK;
        P3 = POP_DATA_STACK;
        P2 = POP_DATA_STACK;
        P1 = POP_DATA_STACK;
        Result = ((CFunc11) CF) ( P1, P2, P3, P4, P5, P6, P7, P8, P9, P10, P11 );
        break;
    case 12:
        P12 = POP_DATA_STACK;
        P11 = POP_DATA_STACK;
        P10 = POP_DATA_STACK;
        P9 = POP_DATA_STACK;
        P8 = POP_DATA_STACK;
        P7 = POP_DATA_STACK;
        P6 = POP_DATA_STACK;
        P5 = POP_DATA_STACK;
        P4 = POP_DATA_STACK;
        P3 = POP_DATA_STACK;
        P2 = POP_DATA_STACK;
        P1 = POP_DATA_STACK;
        Result = ((CFunc12) CF) ( P1, P2, P3, P4, P5, P6, P7, P8, P9, P10, P11, P12 );
        break;
    case 13:
        P13 = POP_DATA_STACK;
        P12 = POP_DATA_STACK;
        P11 = POP_DATA_STACK;
        P10 = POP_DATA_STACK;
        P9 = POP_DATA_STACK;
        P8 = POP_DATA_STACK;
        P7 = POP_DATA_STACK;
        P6 = POP_DATA_STACK;
        P5 = POP_DATA_STACK;
        P4 = POP_DATA_STACK;
        P3 = POP_DATA_STACK;
        P2 = POP_DATA_STACK;
        P1 = POP_DATA_STACK;
        Result = ((CFunc13) CF) ( P1, P2, P3, P4, P5, P6, P7, P8, P9, P10, P11, P12, P13 );
        break;
    case 14:
        P14 = POP_DATA_STACK;
        P13 = POP_DATA_STACK;
        P12 = POP_DATA_STACK;
        P11 = POP_DATA_STACK;
        P10 = POP_DATA_STACK;
        P9 = POP_DATA_STACK;
        P8 = POP_DATA_STACK;
        P7 = POP_DATA_STACK;
        P6 = POP_DATA_STACK;
        P5 = POP_DATA_STACK;
        P4 = POP_DATA_STACK;
        P3 = POP_DATA_STACK;
        P2 = POP_DATA_STACK;
        P1 = POP_DATA_STACK;
        Result = ((CFunc14) CF) ( P1, P2, P3, P4, P5, P6, P7, P8, P9, P10, P11, P12, P13, P14 );
        break;
    case 15:
        P15 = POP_DATA_STACK;
        P14 = POP_DATA_STACK;
        P13 = POP_DATA_STACK;
        P12 = POP_DATA_STACK;
        P11 = POP_DATA_STACK;
        P10 = POP_DATA_STACK;
        P9 = POP_DATA_STACK;
        P8 = POP_DATA_STACK;
        P7 = POP_DATA_STACK;
        P6 = POP_DATA_STACK;
        P5 = POP_DATA_STACK;
        P4 = POP_DATA_STACK;
        P3 = POP_DATA_STACK;
        P2 = POP_DATA_STACK;
        P1 = POP_DATA_STACK;
        Result = ((CFunc15) CF) ( P1, P2, P3, P4, P5, P6, P7, P8, P9, P10, P11, P12, P13, P14, P15 );
        break;
    default:
        pfReportError("CallUserFunction", PF_ERR_NUM_PARAMS);
        EXIT(1);
    }

/* Push result on Forth stack if requested. */
    if(ReturnMode == C_RETURNS_VALUE) PUSH_DATA_STACK( Result );

    return Result;
}

#if (!defined(PF_NO_INIT)) && (!defined(PF_NO_SHELL))
/***************************************************************/
Err CreateGlueToC( const char *CName, ucell_t Index, cell_t ReturnMode, int32_t NumParams )
{
    ucell_t Packed;
    char FName[LONGEST_WORD_NAME+9];    /* +1 for length, up to +9 should not be used, but is here for safety */

    CStringToForth( FName, CName, sizeof(FName) );
    Packed = (Index & 0xFFFF) | 0 | (NumParams << 24) |
        (ReturnMode << 31);
    DBUG(("Packed = 0x%8x\n", Packed));

    ffCreateSecondaryHeader( FName );
    CODE_COMMA( ID_CALL_C );
    CODE_COMMA(Packed);
    ffFinishSecondary();

    return 0;
}
#endif
