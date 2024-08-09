/**************************************************************************/
/*                                                                        */
/*  This file is part of FISSC.                                           */
/*                                                                        */
/*  you can redistribute it and/or modify it under the terms of the GNU   */
/*  Lesser General Public License as published by the Free Software       */
/*  Foundation, version 3.0.                                              */
/*                                                                        */
/*  It is distributed in the hope that it will be useful,                 */
/*  but WITHOUT ANY WARRANTY; without even the implied warranty of        */
/*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         */
/*  GNU Lesser General Public License for more details.                   */
/*                                                                        */
/*  See the GNU Lesser General Public License version 3.0                 */
/*  for more details (enclosed in the file LICENSE).                      */
/*                                                                        */
/**************************************************************************/

// #include "interface.h"
// #include "types.h"
// #include "commons.h"
#include "verifypin_types.h"

SBYTE g_ptc;
BOOL g_authenticated;
UBYTE g_userPin[PIN_SIZE];
UBYTE g_cardPin[PIN_SIZE];
UBYTE g_countermeasure;

// activate countermeasure, i.e. set g_authenticated to BOOL_FALSE
void countermeasure()
{
  g_authenticated = BOOL_FALSE;  
}

// compare two tabs
#ifdef LAZART
  __attribute__((always_inline)) inline BOOL byteArrayCompare(UBYTE* a1, UBYTE* a2, UBYTE size)
#else
  BOOL byteArrayCompare(UBYTE* a1, UBYTE* a2, UBYTE size)
#endif
{
    int i;
    BOOL status = BOOL_FALSE;
    BOOL diff = BOOL_FALSE;
    for(i = 0; i < size; i++) {
        if(a1[i] != a2[i]) {
            diff = BOOL_TRUE;
        }
    }
    if(i != size) {
        countermeasure();
    }
    if (diff == BOOL_FALSE) {    //possible attack //AZ //04 December 2020
        status = BOOL_TRUE;
    } else {
        status = BOOL_FALSE;
    }

    return status;
}

// verify pin function with hardened bools and fixed-time loop (cf. SERTIF project)
BOOL verifyPIN()
{
    g_authenticated = BOOL_FALSE;

    if(g_ptc > 0) {
        if(byteArrayCompare(g_userPin, g_cardPin, PIN_SIZE) == BOOL_TRUE) {
            g_ptc = 3;
            g_authenticated = BOOL_TRUE; // Authentication();
            return BOOL_TRUE;
        } else {

            g_ptc--;
            return BOOL_FALSE;
        }
    }
    return BOOL_FALSE;
}
