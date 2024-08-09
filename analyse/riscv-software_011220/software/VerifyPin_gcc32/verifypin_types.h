#include <stdint.h>
#include <stdbool.h>

#ifndef __VERIFYPIN_TYPES_H
#define __VERIFYPIN_TYPES_H

#define PIN_SIZE 4
typedef short SBYTE;
typedef unsigned char BOOL;
typedef unsigned char UBYTE;
#define BOOL_TRUE 0xAA
#define BOOL_FALSE 0x55

extern BOOL verifyPIN();

#endif