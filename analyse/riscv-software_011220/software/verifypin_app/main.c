#include <stdint.h>
#include <stdbool.h>
#include "verifypin_types.h"

extern SBYTE g_ptc;
extern UBYTE g_userPin[PIN_SIZE];
extern UBYTE g_cardPin[PIN_SIZE];

int main() {
  g_ptc = 3;
  for(uint8_t i = 0; i < PIN_SIZE; i++){
    g_userPin[i] = i;
    g_cardPin[i] = 0;
  }
  return(verifyPIN());
}



