//Anthony ZGHEIB //Date: 22/04/2021
//COFFI PROJECT


#include <stdint.h>

int coffi_memcmp(const void *m1, const void *m2, uint32_t n) {
  unsigned char *s1 = (unsigned char *) m1;
  unsigned char *s2 = (unsigned char *) m2;

  while (n--)
  {
    if (*s1 != *s2)
    {
      return *s1 - *s2;
    }
    s1++;
    s2++;
  }
  return 0;
}


#define SIZE 10

uint8_t src[] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9};
uint8_t dest[] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9};

int main() {
    return coffi_memcmp(dest, src, SIZE);
}
