/**
 ****************************************************************************************
 *
 * @file spi.c
 *
 * @brief spi interface driver. V2_0
 *
 * Copyright (C) 2012 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 * <bluetooth.support@diasemi.com> and contributors.
 *
 ****************************************************************************************
 */

/*
 * INCLUDE FILES
 ****************************************************************************************
 */

//#if defined(AUSTIN_BOARD)

#include <stdint.h>
#include "jtag.h"
#include "gpio.h"
#include "user_periph_setup.h"       // peripheral configuration
#include "datasheet.h"
#include "adc.h"
#include "systick.h"

static const struct tms_sequences short_tms_seqs[7][7] = { /* [from_state_ndx][to_state_ndx] */
   /* to state: */
   /*  RESET        IDLE            DRSHIFT         DRPAUSE         IRSHIFT         IRPAUSE         CAPTUREDR*/ 						/* from state: */
   {B8(1111111, 7), B8(0000000, 7), B8(0010111, 7), B8(0001010, 7), B8(0011011, 7), B8(0010110, 7) ,B8(010111, 6)				}, 	/* RESET */
   {B8(1111111, 7), B8(0000000, 7), B8(001, 3),     B8(0101, 4),    B8(0011, 4),    B8(01011, 5)	 ,B8(01, 2)						}, 	/* IDLE */
   {B8(1111111, 7), B8(011, 3),     B8(00111, 5),   B8(01, 2),      B8(001111, 6),  B8(0101111, 7) ,B8(0111, 4),				}, 	/* DRSHIFT */
   {B8(1111111, 7), B8(011, 3),     B8(01, 2),      B8(0, 1),       B8(001111, 6),  B8(0101111, 7) ,B8(0111, 4),				}, 	/* DRPAUSE */
   {B8(1111111, 7), B8(011, 3),     B8(00111, 5),   B8(010111, 6),  B8(001111, 6),  B8(01, 2)			 ,B8(0111, 4),				}, 	/* IRSHIFT */
   {B8(1111111, 7), B8(011, 3),     B8(00111, 5),   B8(010111, 6),  B8(01, 2),      B8(0, 1)			 ,B8(0111, 4),				}, 	/* IRPAUSE */
   {B8(1111111, 7), B8(01, 2),      B8(0011, 4),    B8(01011, 5),   B8(00111, 5),   B8(0, 1)			 ,B8(011, 3),					}, 	/* IR1EXIT */
};



/**
 ****************************************************************************************
 * @brief jtag_pins_init. We need 4 JTAG pins. TDI,TDO,TMS and TCK
					Be caureful and make sure that the above pins are not being used for any
					other purpose like I2C, SPI, UART or GPIOs
 * @param None
  *
 ****************************************************************************************
 */
void jtag_pins_init(void)
{
	GPIO_SetActive(JTAG_TCK_PORT,JTAG_TCK_PIN);		//Set TCK to 1
	GPIO_SetInactive(JTAG_TMS_PORT,JTAG_TMS_PIN); //Set TMS to 0
	GPIO_SetInactive(JTAG_TDI_PORT,JTAG_TDI_PIN); //Set TMS to 0
	GPIO_SetInactive(JTAG_TDO_PORT,JTAG_TDO_PIN); //Set TMS to 0
}

/**
 ****************************************************************************************
 * @brief jtag_pins_release. We need 4 JTAG pins. TDI,TDO,TMS and TCK
					TDI: Port 1 Pin 2
					TDO: Port 1 Pin 3
					TMS: Port 0 Pin 4
					TCK: Port 0 Pin 7
					Be caureful and make sure that the above pins are not being used for any
					other purpose like I2C, SPI, UART or GPIOs
 * @param None
  *
 ****************************************************************************************
 */
void jtag_pins_release(void)
{
	GPIO_SetInactive(JTAG_TCK_PORT,JTAG_TCK_PIN);		//Set TCK to 1
	GPIO_SetActive(JTAG_TMS_PORT,JTAG_TMS_PIN); //Set TMS to 1
	GPIO_SetInactive(JTAG_TDI_PORT,JTAG_TDI_PIN); //Set TMS to 0
	GPIO_SetInactive(JTAG_TDO_PORT,JTAG_TDO_PIN); //Set TMS to 0
}

/**
 ****************************************************************************************
 * @brief send_jtag_instruction. sends an 4 bit JTAG instruction by bit banging the
					TMS, TCK and TDI pins.
 * @param jtag_instruction - 4 bit instruction to send to the FAST
					tms_sequence     - TMS sequence to use. since the JTAG needs to be correct to
														 the exact clock cycle
  *
 ****************************************************************************************
 */
void send_jtag_instruction(uint8_t jtag_instruction,uint8_t tms_sequence)
{
	int count = 0;
	uint8_t jtag_local_instruction = jtag_instruction;
	for(count = 0; count < JTAG_INSTRUCTION_SIZE; count++)
	{
		(jtag_local_instruction & 0x01) ? (GPIO_SetActive(JTAG_TDI_PORT,JTAG_TDI_PIN)) : (GPIO_SetInactive(JTAG_TDI_PORT,JTAG_TDI_PIN));
		(tms_sequence & 0x01) ? (GPIO_SetActive(JTAG_TMS_PORT,JTAG_TMS_PIN)) : (GPIO_SetInactive(JTAG_TMS_PORT,JTAG_TMS_PIN));
		 GPIO_SetInactive(JTAG_TCK_PORT,JTAG_TCK_PIN);
		 adc_usDelay(20);
		 //systick_wait(10);
		 GPIO_SetActive(JTAG_TCK_PORT,JTAG_TCK_PIN);
		 jtag_local_instruction = jtag_local_instruction>>1;
		 tms_sequence = tms_sequence>>1;
		 adc_usDelay(20);
		 //systick_wait(10);
	}

}


/**
 ****************************************************************************************
 * @brief send_jtag_instruction. sends an 4 bit JTAG instruction by bit banging the
					TMS, TCK and TDI pins.
 * @param jtag_instruction - 4 bit instruction to send to the FAST
					tms_sequence     - TMS sequence to use. since the JTAG needs to be correct to
														 exact clock cycle
  *
 ****************************************************************************************
 */
void get_jtag_data(uint32_t* data)
{
	int count = 0;
	unsigned int local_data = 0;
	for(count = 0; count < JTAG_DATA_SIZE; count++)
	{
		 GPIO_SetInactive(JTAG_TCK_PORT,JTAG_TCK_PIN);
		 local_data |= (GPIO_GetPinStatus(JTAG_TDO_PORT,JTAG_TDO_PIN) << count);
		 adc_usDelay(20);
		 //systick_wait(10);
		 GPIO_SetActive(JTAG_TCK_PORT,JTAG_TCK_PIN);
		 adc_usDelay(20);
		 //systick_wait(10);
	}
	*data = local_data;
}

void send_jtag_data(uint32_t data,uint32_t tms_sequence)
{
	int count = 0;
	for(count = 0; count < JTAG_DATA_SIZE; count++)
	{
		 GPIO_SetInactive(JTAG_TCK_PORT,JTAG_TCK_PIN);
		 (data & 0x01) ? (GPIO_SetActive(JTAG_TDI_PORT,JTAG_TDI_PIN)) : (GPIO_SetInactive(JTAG_TDI_PORT,JTAG_TDI_PIN));
		 (tms_sequence & 0x01) ? (GPIO_SetActive(JTAG_TMS_PORT,JTAG_TMS_PIN)) : (GPIO_SetInactive(JTAG_TMS_PORT,JTAG_TMS_PIN));
		 data >>= 1;
		 tms_sequence >>= 1;
		 adc_usDelay(20);
		 //systick_wait(10);
		 GPIO_SetActive(JTAG_TCK_PORT,JTAG_TCK_PIN);
		 adc_usDelay(20);
		 //systick_wait(10);
	}
}


/**
 ****************************************************************************************
 * @brief switch_tap_state from current_state to next_state. The TMS sequence to be
					used is defined in the global variable short_tms_seqs. We then bit bang
					manually through the GPIO PINS JTAG_TMS and JTAG_TCK
 * @param current_state - current state of the JTAG state machine
					next_state - 		state to which the  JTAG state machine should go to
  *
 ****************************************************************************************
 */
void switch_tap_state(uint8_t current_state,uint8_t next_state)
{
		int count = 0;
	  uint8_t tms_sequence = short_tms_seqs[current_state][next_state].bits;
	  for(count = 0; count < short_tms_seqs[current_state][next_state].bit_count;count++)
	  {
			(tms_sequence & 0x01) ? (GPIO_SetActive(JTAG_TMS_PORT,JTAG_TMS_PIN)) : (GPIO_SetInactive(JTAG_TMS_PORT,JTAG_TMS_PIN));
			GPIO_SetInactive(JTAG_TCK_PORT,JTAG_TCK_PIN);
			adc_usDelay(20);
			//systick_wait(10);
			GPIO_SetActive(JTAG_TCK_PORT,JTAG_TCK_PIN);
			tms_sequence = tms_sequence>>1;
			adc_usDelay(20);
			//systick_wait(10);
		}
		//tap_global_current_state = next_state;
}

/**
 ****************************************************************************************
 * @brief jtag_32b_read writes 8 bits to the instrution register followed by 32
					bits  read from the data register. This is  simple jtag read command
 * @param instruction - 8 bit JTAG instruction code
					data - pointer that contains the data
  *
 ****************************************************************************************
 */
void jtag_32b_read(uint8_t jtag_instruction, uint32_t* data)
{
		switch_tap_state(TAP_RESET,TAP_RESET);
		switch_tap_state(TAP_RESET,TAP_IRSHIFT);
		send_jtag_instruction(jtag_instruction,JTAG_INSTRUCTION_EXIT_IR_TMS_SEQUENCE);
		switch_tap_state(TAP_IREXIT1,TAP_DRSHIFT);
		get_jtag_data(data);
		switch_tap_state(TAP_DRSHIFT,TAP_RESET);
}

/**
 ****************************************************************************************
 * @brief jtag_32b_write writes 8 bits to the instrution register followed by 32
					bits to the data register. This is  simple jtag command with its data.
 * @param instruction - 8 bit JTAG instruction code
					data - 32 bit data to the JTAG instruction
  *
 ****************************************************************************************
 */
void jtag_32b_write(uint8_t jtag_instruction, uint32_t data)
{
		switch_tap_state(TAP_RESET,TAP_RESET);
		switch_tap_state(TAP_RESET,TAP_IRSHIFT);
		send_jtag_instruction(jtag_instruction,JTAG_INSTRUCTION_EXIT_IR_TMS_SEQUENCE);
		switch_tap_state(TAP_IREXIT1,TAP_DRSHIFT);
		send_jtag_data(data,JTAG_DATA_EXIT_DR_TMS_SEQUENCE);
		switch_tap_state(TAP_DRSHIFT,TAP_RESET);
}


//#endif //AUSTIN_BOARD



