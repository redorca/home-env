#ifndef __FAST_JTAG_BITBANG__H__
#define __FAST_JTAG_BITBANG__H__

#include "stdint.h"

typedef union __attribute__((packed)) _jtag_command_reg_t
{
    struct __attribute__((packed))
    {
				 //LSB
			 unsigned int     read_mode    					:1;
			 unsigned int     write_mode    				:1;
			 unsigned int     otp_test_mode    			:1;
			 unsigned int     tile_test_mode    		:1;
			 unsigned int     test_mode_vector    	:3;
			 unsigned int     hw_realignment_mode   :1;
			 unsigned int     jtag_enable    				:1;
			 unsigned int     reserved    					:23;
				 //MSB
    } mBits;
    unsigned int   mAsU32;
} jtag_command_reg_t;


typedef union __attribute__((packed)) _jtag_status_reg_t
{
    struct __attribute__((packed))
    {
				 //LSB
			 unsigned int     read_mode_status    				:1;
			 unsigned int     write_mode_status    				:1;
			 unsigned int     otp_test_mode_status    		:1;
			 unsigned int     tile_test_mode_status    		:1;
			 unsigned int     test_mode_vector_status    	:3;
			 unsigned int     hw_realignment_mode_status  :1;
			 unsigned int     jtag_request_done    				:1;
			 unsigned int     jtag_request_fault    			:1;
			 unsigned int     reserved    								:22;
				 //MSB
    } mBits;
    unsigned int   mAsU32;
} jtag_status_reg_t;

typedef union __attribute__((packed)) _jtag_addr_reg_t
{
    struct __attribute__((packed))
    {
				 //LSB
			 unsigned int     reserved								:1;
			 unsigned int     column    							:7;
			 unsigned int     row    									:8;
			 unsigned int     tile_address_selector   :1;
			 unsigned int     reserved1   						:15;
				 //MSB
    } mBits;
    unsigned int   mAsU32;
} jtag_addr_reg_t;


typedef union __attribute__((packed)) _jtag_data_reg_t
{
    struct __attribute__((packed))
    {
				 //LSB
			 unsigned int     actual_pad_data    				:1;
			 unsigned int     pad_csel    							:2;
			 unsigned int     reserved    							:1;
			 unsigned int     pad_rsel    							:4;
			 unsigned int     reserved3    							:1;
			 unsigned int     pad_alignment_mode    		:1;
			 unsigned int     reserved1    							:2;
			 unsigned int     pad_pullup_sel   					:2;
			 unsigned int     pad_pulldown_sel   				:2;
			 unsigned int     reserved2    							:16;
				 //MSB
    } mBits;
    unsigned int   mAsU32;
} jtag_data_reg_t;


//
#define PAD_RSEL_CONNECT_VSS 0xE
#define PAD_RSEL_CONNECT_VDD 0xF
#define PAD_RSEL_NO_CONNECT  0

#define PAD_NO_ALIGNMENT 		 0

#define PAD_CSEL_NO_CONNECT  0

#define PAD_PULLDOWN_NO_CONNECT     0
#define PAD_PULLUP_NO_CONNECT    		0
#define PAD_PSEL_NO_CONNECT    			0
#define PAD_PSEL_1K_RESISTOR   			0x1
#define PAD_PSEL_10K_RESISTOR  			0x2
#define PAD_PSEL_50K_RESISTOR  			0x3

#define JTAG_INSTRUCTION_SIZE 4
#define JTAG_DATA_SIZE 				32

#define SB_NETS_ON	0x02
#define SB_VDD_ON	0x03
#define SB_VSS_ON	0x04
#define SB_ALG_ON	0x05
#define SB_ALG_RST	0x06


//JTAG COMMANDS
#define JTAG_IDCODE_INSTRUCTION 	0x02
#define JTAG_JCMD_INSTRUCTION 		0x08
#define JTAG_JSTS_INSTRUCTION 		0x09
#define JTAG_JAR_INSTRUCTION 			0x0A
#define JTAG_JDR_INSTRUCTION 			0x0B
#define JTAG_JMMDR_INSTRUCTION 		0x0C

#define FAST_ROW_COUNT 50
#define FAST_COL_COUNT 50

#define JTAG_INSTRUCTION_EXIT_IR_TMS_SEQUENCE 0x08
#define JTAG_DATA_EXIT_DR_TMS_SEQUENCE 0x80000000


struct tms_sequences {
       uint8_t bits;
       uint8_t bit_count;
};

#define HEX__(n) 0x##n##LU

#define B8__(x) \
       ((((x) & 0x0000000FLU) ? (1 << 0) : 0) \
       +(((x) & 0x000000F0LU) ? (1 << 1) : 0) \
       +(((x) & 0x00000F00LU) ? (1 << 2) : 0) \
       +(((x) & 0x0000F000LU) ? (1 << 3) : 0) \
       +(((x) & 0x000F0000LU) ? (1 << 4) : 0) \
       +(((x) & 0x00F00000LU) ? (1 << 5) : 0) \
       +(((x) & 0x0F000000LU) ? (1 << 6) : 0) \
       +(((x) & 0xF0000000LU) ? (1 << 7) : 0))

#define B8(bits, count) {((uint8_t)B8__(HEX__(bits))), (count)}

typedef enum tap_state {
      TAP_INVALID 		= -1,
      TAP_RESET    		= 0,
			TAP_IDLE 				= 1,
			TAP_DRSHIFT 		= 2,
			TAP_DRPAUSE  		= 3,
			TAP_IRSHIFT 		= 4,
			TAP_IRPAUSE  		= 5,
			TAP_IREXIT1 		= 6,
      /*TAP_DRSELECT 		= 1,
			TAP_DRCAPTURE 	= 2,
			TAP_DREXIT1 		= 4,
			TAP_DREXIT2 		= 6,
			TAP_DRUPDATE 		= 7,
      TAP_IRSELECT 		= 9,
			TAP_IRCAPTURE 	= 10,
			TAP_IREXIT1 		= 12,
			TAP_IREXIT2 		= 14,
			TAP_IRUPDATE 		= 15,*/
}tap_state_t;;

void bit_bang_main(void);
void jtag_32b_read(uint8_t jtag_instruction, uint32_t* data);
void jtag_32b_write(uint8_t jtag_instruction, uint32_t data);
bool get_jtag_idcode(void);
void switch_tap_state(tap_state_t current_state,tap_state_t next_state);
void send_jtag_data(uint32_t data,uint32_t tms_sequence);

#endif //__FAST_JTAG_BITBANG__H__
