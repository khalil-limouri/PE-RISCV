#include <stdint.h>

void* coffi_memcpy(void* dst0, void* src0, uint32_t len0) {
  char *dst = (char *) dst0;
  char *src = (char *) src0;

  void *save = dst0;

  while (len0--)
  {
    *dst++ = *src++;
  }

  return save;
}


#define SIZE 10

uint8_t src[] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9};
uint8_t dest[SIZE];

int main() {
    coffi_memcpy(dest, src, SIZE);
}
