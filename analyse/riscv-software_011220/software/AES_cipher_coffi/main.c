#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include "aes.h"

uint8_t key[16] = "0123456789abcdef";

 uint8_t cipher[16] = {0x76, 0x65, 0x72, 0x69,
                       0x6c, 0x61, 0x74, 0x6f,
                       0x72, 0x20, 0x72, 0x69,
                       0x73, 0x63, 0x79, 0x00};
//uint8_t cipher[16] = {0x63, 0x76, 0x33, 0x32,
//                      0x65, 0x34, 0x30, 0x70,
//                      0x20, 0x64, 0x66, 0x61,
//                      0x20, 0x61, 0x65, 0x73};

int main(int argc, char *argv[])
{
    struct AES_ctx ctx;
    AES_init_ctx(&ctx, key);
    AES_ECB_encrypt(&ctx, cipher);
    return EXIT_SUCCESS;
}
