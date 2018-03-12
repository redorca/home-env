/**
 ****************************************************************************************
 *
 * @file jtag.h
 *
 * @brief jtag interface driver header file.
 *
 * Copyright (C) 2012 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 * <bluetooth.support@diasemi.com> and contributors.
 *
 ****************************************************************************************
 */

#ifndef _JTAG_H_
#define _JTAG_H_

/*
 * INCLUDE FILES
 ****************************************************************************************
 */

#include "gpio.h"

/*
 * DEFINES
 ****************************************************************************************
 */

#define JTAG_INSTRUCTION_SIZE 4
#define JTAG_DATA_SIZE 				32

#define JTAG_INSTRUCTION_EXIT_IR_TMS_SEQUENCE 0x08
#define JTAG_DATA_EXIT_DR_TMS_SEQUENCE 0x80000000

//JTAG COMMANDS
#define JTAG_IDCODE_INSTRUCTION 	0x02

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

/*
 * TYPE DEFINITIONS
 ****************************************************************************************
 */


typedef enum tap_state {
		  TAP_INVALID 		= -1,
		  TAP_RESET    		= 0,
			TAP_IDLE 			  = 1,
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
}tap_state_t;

struct tms_sequences {
       uint8_t bits;
       uint8_t bit_count;
};

/*
 * FUNCTION DECLARATIONS
 ****************************************************************************************
 */

#endif // _JTAG_H_
