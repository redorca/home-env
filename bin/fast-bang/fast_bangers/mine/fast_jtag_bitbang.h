#ifndef __FAST_JTAG_BITBANG__H__
#define __FAST_JTAG_BITBANG__H__

#include "stdint.h"

#undef DALLAS_LOW_POWER_MODE
#define AUSTIN_LOW_POWER_MODE
#undef ENABLE_SITIME
#undef DALLAS_REPROGRAM_MCUBE
#undef BMM150_INTERFACE_I2C
#undef  BMM150_INTERFACE_SPI
#define ENABLE_AD8233_HR
#undef ENABLE_AD8233_HR_WEAK_ROWS

#define FAST_JTAG_IDCODE 0x149511C3

//JTAG COMMANDS
#define JTAG_IDCODE_INSTRUCTION 	0x02
#define JTAG_JCMD_INSTRUCTION 		0x08
#define JTAG_JSTS_INSTRUCTION 		0x09
#define JTAG_JAR_INSTRUCTION 		0x0A
#define JTAG_JDR_INSTRUCTION 		0x0B
#define JTAG_JMMDR_INSTRUCTION 		0x0C

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

#define SB_ALL_ON   0x01
#define SB_NETS_ON	0x02
#define SB_VDD_ON	0x03
#define SB_VSS_ON	0x04
#define SB_ALG_ON	0x05
#define SB_ALG_RST	0x06


#define FAST_ROW_COUNT 50
#define FAST_COL_COUNT 50


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





#endif //__FAST_JTAG_BITBANG__H__


extern void adc_usDelay(uint32_t nof_us);
