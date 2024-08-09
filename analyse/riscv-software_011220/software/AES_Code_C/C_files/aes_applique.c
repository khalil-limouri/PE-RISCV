
#define AZ _ASM
#define STR(x) #x
#define EXPAND(x) STR(x)
#define r_type_insn(_f7, _rs2, _rs1, _f3, _rd, _opc) \
(((_f7) << 25) | ((_rs2) << 20) | ((_rs1) << 15) | ((_f3) << 12) | ((_rd) << 7) | ((_opc) << 0))
// Revision : 29 July 2020 - 21 August 2020 - 31 August 2020

#define VAES_AZ(_f7, _rs1, _rd)  \
r_type_insn(_f7, 0b00000, _rs1, 0b111, _rd, 0b0001011) //Added f7 to the instruction instead of 0b0000000 //Date:14/5/2020
//Note: _f7 (Roundn <<28, Operation << 25 //Date : 10/7/2020)
// Operation :  001 : Store data in AES Registers
//		000-011 : Read data from AES Registers
//		1xx : Mode + EnableRoundComputing 


/* Functions used in the main :  1- Hardware AES Ciphering with the IBEX Core
				 2- Software Tiny AES ciphering
				 3- Software SSL AES ciphering   */

// Includes
#include <stdint.h>
//Tiny AES 
#ifdef TinyAES
#include "../H_files/tiny_aes.h"
// use only ECB AES encryption
#define ECB 1
#define CBC 0
#define CTR 0
#endif
//OpenSSL AES
#ifdef OpenSSLAES
#include <string.h>
#include "../H_files/aes_ssl.h"

//#include "aes_local_ssl.h"
#endif
//AES IBEX
#ifdef AESIBEX
void aes_mode_ecb(void);
 #endif

int main(void) {

#ifdef AESIBEX
    asm (    
        "addi    t5,a0,0x1"
);
// AES - IBEX 32bits variables.
uint32_t data[4]     ={0x6BC1BEE2,0x2E409F96,0xE93D7E11,0x7393172A};
uint32_t key[4]      ={0x2B7E1516,0x28AED2A6,0xABF71588,0x09CF4F3C};
//uint32_t result[2][4]   ={{0x3ad77bb4,0x0d7a3660,0xa89ecaf3,0x2466ef97}};


///////////////////////////////////////////////////////////////
/////////////// Store the key in the AES registers ///////////
///////////////////////////////////////////////////////////////

////////////////////
//Store //Address3//
////////////////////

	asm (
	        "lw	a7,0(sp);"
	//        ".word 0x0206500b;"  
	".word " EXPAND(VAES_AZ(0b0000001,17,0b00111)) ";"); //Stores the value a in the AES register, adress 3.

////////////////////
//Store //Address2//
////////////////////

	asm (
	        "lw	s2,4(sp);"
	//        ".word 0x0206d08b;"  
	".word " EXPAND(VAES_AZ(0b0000001,18,0b00110)) ";"); //Store the value b in the AES register, adress 2.

////////////////////
//Store //Address1//
////////////////////

	asm (
	        "lw	s3,8(sp);"
	//        ".word 0x0207510b;"  
	".word " EXPAND(VAES_AZ(0b0000001,19,0b00101)) ";"); //Stores the value c in the AES register, adress 1.

////////////////////
//Store //Address0//
////////////////////

	asm (
	        "lw	s4,12(sp);"
	//        ".word 0x0207d18b;"  
	".word " EXPAND(VAES_AZ(0b0000001,20,0b00100)) ";"); //Stores the value d in the AES register, adress 0.



aes_mode_ecb();
    asm (    
        "addi    t5,a0,0x0"
);
    asm (    
        "addi    t5,a0,0x1"
);
 data[0]     =0xAE2D8A57;
  data[1]     =0x1E03AC9C;
   data[2]     =0x9EB76FAC;
    data[3]     =0x45AF8E51;
//aes_mode_ecb_chainage();
aes_mode_ecb();
    asm (    
        "addi    t5,a0,0x0"
);
 #endif


#ifdef TinyAES
    asm (    
        "addi    t5,a0,0x1"
);
// AES - Tiny - SSL
uint8_t data_tiny[16]     ={0x6B,0xC1,0xBE,0xE2,0x2E,0x40,0x9F,0x96,0xE9,0x3D,0x7E,0x11,0x73,0x93,0x17,0x2A};
uint8_t key_tiny[16]      ={0x2B,0x7E,0x15,0x16,0x28,0xAE,0xD2,0xA6,0xAB,0xF7,0x15,0x88,0x09,0xCF,0x4F,0x3C};
struct AES_ctx ctx;
AES_init_ctx(&ctx, key_tiny);
AES_ECB_encrypt(&ctx, data_tiny);
//Read the outputs
    asm (    
        "lw	a6,192(sp);"
          "lw	a7,196(sp);"
        "lw	s2,200(sp);"
          "lw	s3,204(sp)"
);
    asm (    
        "addi    t5,a0,0x0"
);

    asm (    
        "addi    t5,a0,0x1"
);
 data_tiny[0]     =0xAE;
  data_tiny[1]     =0x2D;
   data_tiny[2]     =0x8A;
    data_tiny[3]     =0x57;
     data_tiny[4]     =0x1E;
  data_tiny[5]     =0x03;
   data_tiny[6]     =0xAC;
    data_tiny[7]     =0x9C;
     data_tiny[8]     =0x9E;
  data_tiny[9]     =0xB7;
   data_tiny[10]     =0x6F;
    data_tiny[11]     =0xAC;
         data_tiny[12]     =0x45;
  data_tiny[13]     =0xAF;
   data_tiny[14]     =0x8E;
    data_tiny[15]     =0x51;
    
AES_ECB_encrypt(&ctx, data_tiny);

//Read the outputs
    asm (    
        "lw	a6,192(sp);"
          "lw	a7,196(sp);"
        "lw	s2,200(sp);"
          "lw	s3,204(sp)"
);
    asm (    
        "addi    t5,a0,0x0"
);

 #endif

#ifdef OpenSSLAES
//AES - SSL
    asm (    
        "addi    t5,a0,0x1"
);
uint8_t data_tiny[16]     ={0x6B,0xC1,0xBE,0xE2,0x2E,0x40,0x9F,0x96,0xE9,0x3D,0x7E,0x11,0x73,0x93,0x17,0x2A};
uint8_t key_tiny[16]      ={0x2B,0x7E,0x15,0x16,0x28,0xAE,0xD2,0xA6,0xAB,0xF7,0x15,0x88,0x09,0xCF,0x4F,0x3C};
  uint8_t out[16] = { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 };
  AES_KEY key_ssl;
  AES_set_encrypt_key(key_tiny, 128, &key_ssl);
  AES_ecb_encrypt(data_tiny, out, &key_ssl, AES_ENCRYPT);
//Read the outputs
    asm (    
        "lw	a6,256(sp);"
          "lw	a7,260(sp);"
        "lw	s2,264(sp);"
          "lw	s3,268(sp)"
);
    asm (    
        "addi    t5,a0,0x0"
);

    asm (    
        "addi    t5,a0,0x1"
);
 data_tiny[0]     =0xAE;
  data_tiny[1]     =0x2D;
   data_tiny[2]     =0x8A;
    data_tiny[3]     =0x57;
     data_tiny[4]     =0x1E;
  data_tiny[5]     =0x03;
   data_tiny[6]     =0xAC;
    data_tiny[7]     =0x9C;
     data_tiny[8]     =0x9E;
  data_tiny[9]     =0xB7;
   data_tiny[10]     =0x6F;
    data_tiny[11]     =0xAC;
   data_tiny[12]     =0x45;
  data_tiny[13]     =0xAF;
   data_tiny[14]     =0x8E;
    data_tiny[15]     =0x51;
  AES_ecb_encrypt(data_tiny, out, &key_ssl, AES_ENCRYPT);
//Read the outputs
    asm (    
        "lw	a6,256(sp);"
          "lw	a7,260(sp);"
        "lw	s2,264(sp);"
          "lw	s3,268(sp)"
);
    asm (    
        "addi    t5,a0,0x0"
);

#endif

////////////////////
///End Of Program///
////////////////////
  return(0);
}

#ifdef AESIBEX
void aes_mode_ecb(void)
{


///////////////////////////////////////////////////////////////
/////////////// Store the data in the AES registers ///////////
///////////////////////////////////////////////////////////////

////////////////////
//Store //Address3//
////////////////////

	asm (
	        "lw	a2,16(sp);"
	//        ".word 0x0206500b;"  
	".word " EXPAND(VAES_AZ(0b0000001,12,0b01011)) ";"); //Stores the value a in the AES register, adress 3.

////////////////////
//Store //Address2//
////////////////////

	asm (
	        "lw	a3,20(sp);"
	//        ".word 0x0206d08b;"  
	".word " EXPAND(VAES_AZ(0b0000001,13,0b01010)) ";"); //Store the value b in the AES register, adress 2.

////////////////////
//Store //Address1//
////////////////////

	asm (
	        "lw	a4,24(sp);"
	//        ".word 0x0207510b;"  
	".word " EXPAND(VAES_AZ(0b0000001,14,0b01001)) ";"); //Stores the value c in the AES register, adress 1.

////////////////////
//Store //Address0//
////////////////////

	asm (
	        "lw	a6,28(sp);"
	//        ".word 0x0207d18b;"  
	".word " EXPAND(VAES_AZ(0b0000001,0b10000,0b01000)) ";"); //Stores the value d in the AES register, adress 0.



////////////////////////////////////////////
/////////////////AES START/////////////////
//////////////////////////////////////////

//////////
//Round0//
//////////
	asm (
	
	//        ".word 0x600208b;"  
	".word " EXPAND(VAES_AZ(0b0000100,0,0)) ";"); //Runs Round0 Calculation

//////////
//Round1//
//////////

	asm (
	//        ".word 0xe00208b;"  
	".word " EXPAND(VAES_AZ(0b0001100,0,0)) ";"); //Runs Round1 Calculation


//////////
//Round2//
//////////

	asm (
	//        ".word 0x1600208b;"  
	".word " EXPAND(VAES_AZ(0b0010100,0,0)) ";"); //Runs Round2 Calculation

//////////
//Round3//
//////////

	asm (
	//        ".word 0x1e00208b;"  
	".word " EXPAND(VAES_AZ(0b0011100,0,0)) ";"); //Runs Round3 Calculation

//////////
//Round4//
//////////

	asm (
	//        ".word 0x2600208b;"  
	".word " EXPAND(VAES_AZ(0b0100100,0,0)) ";"); //Runs Round4 Calculation


//////////
//Round5//
//////////

	asm (
	//        ".word 0x2e00208b;"  
	".word " EXPAND(VAES_AZ(0b0101100,0,0)) ";"); //Runs Round5 Calculation


//////////
//Round6//
//////////

	asm (
	//        ".word 0x3600208b;"  
	".word " EXPAND(VAES_AZ(0b0110100,0,0)) ";"); //Runs Round6 Calculation



//////////
//Round7//
//////////

	asm (
	//        ".word 0x3e00208b;"  
	".word " EXPAND(VAES_AZ(0b0111100,0,0)) ";"); //Runs Round7 Calculation

//////////
//Round8//
//////////

	asm (
	//        ".word 0x4600208b;"  
	".word " EXPAND(VAES_AZ(0b1000100,0,0)) ";"); //Runs Round8 Calculation


//////////
//Round9//
//////////

	asm (
	//        ".word 0x4e00208b;"  
	".word " EXPAND(VAES_AZ(0b1001100,0,0)) ";"); //Runs Round9 Calculation


///////////
//Round10//
///////////

	asm (
	//        ".word 0x5600208b;"  
	".word " EXPAND(VAES_AZ(0b1010100,0,0)) ";"); //Runs Round10 Calculation


////////////////////////////////////////////////////////////////////////////
//Load the data from the AES register and store it in the IBEX registers////
////////////////////////////////////////////////////////////////////////////

////////////////////
//Load //Address3//
////////////////////

	asm (
	//        ".word 0x206500b;"  
	".word " EXPAND(VAES_AZ(0b0000000,0b00011,25)) ";"); //Loads the ciphered data (MSB) in the IBEX register, adress 25.

////////////////////
//Load //Address2//
////////////////////

	asm (
	//        ".word 0x206d08b;"  
	".word " EXPAND(VAES_AZ(0b0000000,0b00010,26)) ";"); //Loads the ciphered data in the IBEX register, adress 26.

////////////////////
//Load //Address1//
////////////////////

	asm (
	//        ".word 0x207510b;"  
	".word " EXPAND(VAES_AZ(0b0000000,0b00001,27)) ";"); //Loads the ciphered data in the IBEX register, adress 27.

////////////////////
//Load //Address0//
////////////////////

	asm (
	//        ".word 0x207d18b;"  
	".word " EXPAND(VAES_AZ(0b0000000,0b00000,28)) ";"); //Loads the ciphered data (LSB) in the IBEX register, adress 28.

}


 #endif
