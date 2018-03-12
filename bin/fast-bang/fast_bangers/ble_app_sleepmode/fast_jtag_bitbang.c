#include "user_periph_setup.h"
#include "uart.h"
#include "datasheet.h"
#include "gpio.h"
#include "fast_jtag_bitbang.h"
#include "systick.h"
#include "arch_console.h"




#if defined(JTAG_BIT_BANG_TEST)

//All global definitions
//uint32_t fast_scantile_before[FAST_ROW_COUNT][FAST_COL_COUNT];
//uint32_t fast_scantile_after[FAST_ROW_COUNT][FAST_COL_COUNT];

static tap_state_t tap_global_current_state = TAP_RESET;


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

#define ZEUS_A1_SITIME_BMM150_ROW_COUNT 191
#define ZEUS_A1_SITIME_BMM150_COL_COUNT 2

#define ZEUS_A1_SITIME_ROW_COUNT  45
static const uint32_t sitime_only[ZEUS_A1_SITIME_ROW_COUNT][ZEUS_A1_SITIME_BMM150_COL_COUNT] = {
{11532	,0x38 },{11534	,0x38 },{11536	,0x38 },{11276	,0x38 },{11278	,0x38 },
{11280	,0x38 },{11020	,0x38 },{11022	,0x38 },{11024	,0x38 },{10508	,0x38 },
{10510	,0x38 },{10512	,0x38 },{10252	,0x38 },{10254	,0x38 },{10256	,0x38 },
{9996	  ,0x38 },{9998	  ,0x38 },{10000	,0x38 },{11552	,0x3C },{11554	,0x3C },
{11556	,0x3C },{11296	,0x3C },{11298	,0x3C },{11300	,0x3C },{11040	,0x3C },
{11042	,0x3C },{11044	,0x3C },{10528	,0xC  },{10530	,0xC  },{10532	,0xC  },
{10272	,0xC  },{10274	,0xC  },{10276	,0xC  },{10016	,0xC  },{10018	,0xC  },
{10020	,0xC  },{10536	,0x1  },{10280	,0x1  },{10024	,0x1  },{5672		,0x1  },
{5416		,0x1  },{5692		,0xC  },{5694		,0xC  },{5436		,0xC  },{5438		,0xC  }
};

#define ZEUS_A1_BMM150_ROW_COUNT  61
static const uint32_t bmm150_spi_only[ZEUS_A1_BMM150_ROW_COUNT][ZEUS_A1_SITIME_BMM150_COL_COUNT] = {
{8260		,0x3C},{8262	,0x3C},{8516	,0x3C},{8518	,0x3C},{10580	,0x3C},
{10582	,0x3C},{10836	,0x3C},{10838	,0x3C},{11076	,0x38},{11078	,0x38},
{11332	,0x38},{11334	,0x38},{11588	,0x38},{11590	,0x38},{8270	,0x38},
{8272		,0x38},{8526	,0x38},{8528	,0x38},{9796	,0x38},{9798	,0x38},
{10052	,0x38},{10054	,0x38},{11098	,0x38},{11100	,0x38},{11354	,0x38},
{11356	,0x38},{11610	,0x38},{11612	,0x38},{9044	,0x14},{9046	,0x14},
{9300		,0x14},{9302	,0x14},{9004	,0x1 },{9260	,0x1 },{11086	,0x18},
{11088	,0x18},{11342	,0x18},{11344	,0x18},{11598	,0x18},{11600	,0x18},
{11054	,0x1 },{11310	,0x1 },{11566	,0x1 },{9818	,0x8 },{9820	,0x8 },
{10074	,0x8 },{10076	,0x8 },{9778	,0x1 },{10034	,0x1 },
//chip select
{1340	,0x10}	, {1342		,0x10},{1596	,0x10},{1598	,0x10},{1322	,0x1 },
{1578	,0x1 }	, {8282		,0x10},{8284	,0x10},{8538	,0x10},{8540	,0x10},
{8234	,0x1 }	, {8490		,0x1 },
};

#define ZEUS_A1_BMM150_I2C_ROW_COUNT  48
static const uint32_t bmm150_i2c_only[ZEUS_A1_BMM150_I2C_ROW_COUNT][ZEUS_A1_SITIME_BMM150_COL_COUNT] = {
{8260		,0x3C},{8262	,0x3C},{8516	,0x3C},{8518	,0x3C},{10580	,0x3C},
{10582	,0x3C},{10836	,0x3C},{10838	,0x3C},{11076	,0x38},{11078	,0x38},
{11332	,0x38},{11334	,0x38},{11588	,0x38},{11590	,0x38},{8270	,0x38},
{8272		,0x38},{8526	,0x38},{8528	,0x38},{9796	,0x38},{9798	,0x38},
{10052	,0x38},{10054	,0x38},{11098	,0x3C},{11100	,0x3C},{11354	,0x3C},
{11356	,0x3C},{11610	,0x3C},{11612	,0x3C},{9044	,0x5} ,{9046	,0x4},
{9300		,0x5}	,{9302	,0x4}	,{11086	,0x38},{11088	,0x38},{11342	,0x38},
{11344	,0x38},{11598	,0x38},{11600	,0x38},{9818	,0x18},{9820	,0x18},
{10074	,0x18},{10076	,0x18},{9810	,0x1}	,{10066	,0x1}	,{8282	,0x38},
{8284		,0x38},{8538	,0x38},{8540	,0x38},
};

static const uint32_t cfgave_pwr[ZEUS_A1_SITIME_BMM150_ROW_COUNT][ZEUS_A1_SITIME_BMM150_COL_COUNT] = {
{784	,0x030D},{786	,0x000C},{798	,0x003C},{800	,0x003C},{818	,0x0000},{1040	,0x000D},
{1042	,0x000C},{1054	,0x003C},{1056	,0x003C},{1074	,0x0000},{1296	,0x0001},{1302	,0x0019},
{1304	,0x0018},{1306	,0x0018},{1314	,0x0002},{1324	,0x0000},{1330	,0x0000},{1332	,0x000C},
{1334	,0x000C},{1338	,0x0000},{1340	,0x0030},{1342	,0x0030},{1364	,0x0008},{1366	,0x0009},
{1368	,0x0000},{1552	,0x0001},{1558	,0x0019},{1560	,0x0018},{1562	,0x0018},{1570	,0x0002},
{1580	,0x0000},{1586	,0x0000},{1588	,0x000C},{1590	,0x000C},{1594	,0x0000},{1596	,0x0030},
{1598	,0x0030},{1620	,0x0008},{1622	,0x0009},{1624	,0x0000},{1808	,0x003C},{1810	,0x003C},
{1820	,0x0001},{1822	,0x000C},{1824	,0x000C},{1838	,0x0000},{2064	,0x003C},{2066	,0x003C},
{2076	,0x0001},{2078	,0x000C},{2080	,0x000C},{2094	,0x0000},{2336	,0x0002},{2352	,0x0000},
{2356	,0x002C},{2358	,0x002C},{2364	,0x0008},{2366	,0x0009},{2368	,0x0000},{2388	,0x0005},
{2390	,0x0004},{2396	,0x0015},{2398	,0x0014},{2592	,0x0002},{2608	,0x0000},{2612	,0x002C},
{2614	,0x002C},{2620	,0x0008},{2622	,0x0009},{2624	,0x0000},{2644	,0x0005},{2646	,0x0004},
{2652	,0x0015},{2654	,0x0014},{2846	,0x0094},{2848	,0x0015},{2864	,0x0000},{3102	,0x0014},
{3104	,0x0015},{3120	,0x0000},{3356	,0x0001},{3358	,0x0001},{3374	,0x0000},{3380	,0x000C},
{3382	,0x000C},{3386	,0x0002},{3388	,0x0030},{3390	,0x0030},{3412	,0x0090},{3414	,0x0090},
{3420	,0x0018},{3422	,0x0019},{3612	,0x0001},{3614	,0x0001},{3630	,0x0000},{3636	,0x000C},
{3638	,0x000C},{3642	,0x0002},{3644	,0x0030},{3646	,0x0030},{3668	,0x0090},{3670	,0x0010},
{3676	,0x0018},{3678	,0x0019},{4374	,0x0001},{4390	,0x0001},{4396	,0x0000},{4404	,0x0018},
{4406	,0x0018},{4434	,0x0000},{4436	,0x0088},{4438	,0x0088},{4630	,0x0001},{4646	,0x0001},
{4652	,0x0000},{4660	,0x0018},{4662	,0x0018},{4690	,0x0000},{4692	,0x0088},{4694	,0x0008},
{5400	,0x003C},{5402	,0x003C},{5410	,0x0008},{5412	,0x0009},{5414	,0x0001},{5436	,0x0004},
{5438	,0x0004},{5458	,0x0000},{5656	,0x003C},{5658	,0x003C},{5666	,0x0008},{5668	,0x0009},
{5670	,0x0001},{5692	,0x0004},{5694	,0x0004},{5714	,0x0000},{6164	,0x0038},{6166	,0x0038},
{6174	,0x0011},{6176	,0x0010},{6228	,0x0000},{6420	,0x0038},{6422	,0x0038},{6430	,0x0011},
{6432	,0x0010},{6484	,0x0000},{6676	,0x0038},{6678	,0x0038},{6686	,0x0011},{6688	,0x0010},
{6740	,0x0000},{7202	,0x0019},{7226	,0x0000},{7458	,0x0019},{7482	,0x0000},{9996	,0x0038},
{9998	,0x0038},{10000	,0x0038},{10016	,0x0004},{10018	,0x0004},{10020	,0x0005},{10252	,0x0038},
{10254	,0x0038},{10256	,0x0038},{10272	,0x0004},{10274	,0x0004},{10276	,0x0005},{10508	,0x0038},
{10510	,0x0038},{10512	,0x0038},{10528	,0x0004},{10530	,0x0004},{10532	,0x0005},{11020	,0x0038},
{11022	,0x0038},{11024	,0x0038},{11040	,0x003C},{11042	,0x003C},{11044	,0x003C},{11276	,0x0038},
{11278	,0x0038},{11280	,0x0038},{11296	,0x003C},{11298	,0x003C},{11300	,0x003C},{11532	,0x0038},
{11534	,0x0038},{11536	,0x0038},{11552	,0x003C},{11554	,0x003C},{11556	,0x003C}
};



/**
 ****************************************************************************************
 * @brief jtag_pins_init. We need 4 JTAG pins. TDI,TDO,TMS and TCK
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
void jtag_pins_init(void)
{
	GPIO_SetActive(GPIO_PORT_0,JTAG_TCK);		//Set TCK to 1
	GPIO_SetInactive(GPIO_PORT_0,JTAG_TMS); //Set TMS to 0
	GPIO_SetInactive(GPIO_PORT_1,JTAG_TDI); //Set TMS to 0
	GPIO_SetInactive(GPIO_PORT_1,JTAG_TDO); //Set TMS to 0
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
		(jtag_local_instruction & 0x01) ? (GPIO_SetActive(GPIO_PORT_1,JTAG_TDI)) : (GPIO_SetInactive(GPIO_PORT_1,JTAG_TDI));
		(tms_sequence & 0x01) ? (GPIO_SetActive(GPIO_PORT_0,JTAG_TMS)) : (GPIO_SetInactive(GPIO_PORT_0,JTAG_TMS));
		 GPIO_SetInactive(GPIO_PORT_0,JTAG_TCK);
		 systick_wait(10);
		 GPIO_SetActive(GPIO_PORT_0,JTAG_TCK);
		 jtag_local_instruction = jtag_local_instruction>>1;
		 tms_sequence = tms_sequence>>1;
		 systick_wait(10);
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
		 GPIO_SetInactive(GPIO_PORT_0,JTAG_TCK);
		 local_data |= (GPIO_GetPinStatus(GPIO_PORT_1,JTAG_TDO) << count);
		 systick_wait(10);
		 GPIO_SetActive(GPIO_PORT_0,JTAG_TCK);
		 systick_wait(10);
	}
	*data = local_data;
}

void send_jtag_data(uint32_t data,uint32_t tms_sequence)
{
	int count = 0;
	for(count = 0; count < JTAG_DATA_SIZE; count++)
	{
		 GPIO_SetInactive(GPIO_PORT_0,JTAG_TCK);
		 (data & 0x01) ? (GPIO_SetActive(GPIO_PORT_1,JTAG_TDI)) : (GPIO_SetInactive(GPIO_PORT_1,JTAG_TDI));
		 (tms_sequence & 0x01) ? (GPIO_SetActive(GPIO_PORT_0,JTAG_TMS)) : (GPIO_SetInactive(GPIO_PORT_0,JTAG_TMS));
		 data >>= 1;
		 tms_sequence >>= 1;
		 systick_wait(10);
		 GPIO_SetActive(GPIO_PORT_0,JTAG_TCK);
		 systick_wait(10);
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
void switch_tap_state(tap_state_t current_state,tap_state_t next_state)
{
		int count = 0;
	  uint8_t tms_sequence = short_tms_seqs[current_state][next_state].bits;
	  for(count = 0; count < short_tms_seqs[current_state][next_state].bit_count;count++)
	  {
			(tms_sequence & 0x01) ? (GPIO_SetActive(GPIO_PORT_0,JTAG_TMS)) : (GPIO_SetInactive(GPIO_PORT_0,JTAG_TMS));
			GPIO_SetInactive(GPIO_PORT_0,JTAG_TCK);
			systick_wait(10);
			GPIO_SetActive(GPIO_PORT_0,JTAG_TCK);
			tms_sequence = tms_sequence>>1;
			systick_wait(10);
		}
		tap_global_current_state = next_state;
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

#define FAST_JTAG_IDCODE 0x149511C3
/**
 ****************************************************************************************
 * @brief gets the jtag idcode and prints it to the UART.
 * @param bool - returns true of the JTAG idcode matches FAST_JTAG_IDCODE. else returns
					false
  *
 ****************************************************************************************
 */
int get_jtag_idcode(void)
{
	uint32_t jtag_idcode = 0;
	jtag_32b_read(JTAG_IDCODE_INSTRUCTION,&jtag_idcode);
	arch_puts("\n\rJTAG IDCODE = 0x");
	//print_word(jtag_idcode);
	if(jtag_idcode == FAST_JTAG_IDCODE)
		return true;
	else
		return false;
}

/**
 ****************************************************************************************
 * @brief Writes the data to the JTAG address register
 * @param data - 32bit data to write to the address register
  *
 ****************************************************************************************
 */
void jtag_address_reg_write(uint32_t data)
{
	//uint32_t jtag_addr_reg = 0;
	jtag_32b_write(JTAG_JAR_INSTRUCTION,data);
	/*arch_puts("\n\rJTAG ADDRESS REGISTER = 0x");
	jtag_32b_read(JTAG_JAR_INSTRUCTION,&jtag_addr_reg);
	print_word(jtag_addr_reg);*/
}


/**
 ****************************************************************************************
 * @brief Writes the data to the JTAG data register
 * @param data - 32bit data to write to the data register
  *
 ****************************************************************************************
 */
void jtag_data_reg_write(uint32_t data)
{
	//uint32_t jtag_data_reg = 0;
	jtag_32b_write(JTAG_JDR_INSTRUCTION,data);
	/*arch_puts("\n\rJTAG DATA REGISTER = 0x");
	jtag_32b_read(JTAG_JDR_INSTRUCTION,&jtag_data_reg);
	print_word(jtag_data_reg);*/
}


/**
 ****************************************************************************************
 * @brief Clears the JCMD register of the JTAG by writing 0 to it
 * @param None
  *
 ****************************************************************************************
 */
void clear_jcmd_register(void)
{
	//uint32_t jtag_cmd_reg = 0;
	jtag_32b_write(JTAG_JCMD_INSTRUCTION,0);
	/*arch_puts("\n\rJTAG COMMAND REGISTER = 0x");
	jtag_32b_read(JTAG_JCMD_INSTRUCTION,&jtag_cmd_reg);
	print_word(jtag_cmd_reg);*/
}


/**
 ****************************************************************************************
 * @brief Wait till jtag status done. This command is used to check the status of JTAG
					command. This will wait till the done or error status becomes set to 1
 * @param bool- true if successful and false if command failed
  *
 ****************************************************************************************
 */
bool wait_till_jtag_status(uint32_t* status)
{
	jtag_status_reg_t jtag_status_reg;
	jtag_status_reg.mAsU32 = 0;

	while(1)
	{
			jtag_32b_read(JTAG_JSTS_INSTRUCTION,(uint32_t*)&jtag_status_reg.mAsU32);
		  *status = jtag_status_reg.mAsU32;
			//arch_puts("\n\rJTAG STATUS REGISTER = 0x");
			//print_word(jtag_status_reg.mAsU32);
			if(jtag_status_reg.mBits.jtag_request_done == 1)
			{
				return true;
			}
			else if(jtag_status_reg.mBits.jtag_request_fault == 1)
			{
				return false;
			}
	}
}

/**
 ****************************************************************************************
 * @brief Tile read command. This command is used to read the value of the tile at a
					particular row or column.
 * @param row - tile row to read
					column - tile column to read
					tile_data - pointer which contains the tile data
  *
 ****************************************************************************************
 */
void tile_read(uint32_t row, uint32_t column, uint32_t* tile_data)
{
	uint32_t status=0;

	//Clear JCMD Register
	clear_jcmd_register();

	//Set JCMD.RM Sets Read mode in the JCMD status register
	jtag_command_reg_t jtag_tile_read_command;
	jtag_tile_read_command.mAsU32 = 0;
	jtag_tile_read_command.mBits.read_mode = 1;
	jtag_32b_write(JTAG_JCMD_INSTRUCTION,jtag_tile_read_command.mAsU32);
	//arch_puts("\n\rTILE SETTING RM MODE = 0x");
	//print_word(jtag_tile_read_command.mAsU32);

	//Write the address in the JAR register
	jtag_addr_reg_t jtag_tile_addr;
	jtag_tile_addr.mAsU32 = 0;
	jtag_tile_addr.mBits.tile_address_selector = 1;
	jtag_tile_addr.mBits.row = row;
	jtag_tile_addr.mBits.column = column;
	jtag_address_reg_write(jtag_tile_addr.mAsU32);
	//arch_puts("\n\rTILE ADDRESS = 0x");
	//print_word(jtag_tile_addr.mAsU32);

	//Set JCMD.RM Sets Read mode in the JCMD status register and also set the enable
	jtag_tile_read_command.mAsU32 = 0;
	jtag_tile_read_command.mBits.read_mode = 1;
	jtag_tile_read_command.mBits.jtag_enable = 1;
	jtag_32b_write(JTAG_JCMD_INSTRUCTION,jtag_tile_read_command.mAsU32);
	//arch_puts("\n\rTILE SETTING ENABLE = 0x");
	//print_word(jtag_tile_read_command.mAsU32);

	if(wait_till_jtag_status(&status) == true)
	{
		__nop();
		//arch_puts("\n\rJTAG TILE READ SUCCESSFUL");
	}
	else
	{
		arch_puts("\n\rJTAG TILE READ UNSUCCESSFUL");
	}

	jtag_32b_read(JTAG_JMMDR_INSTRUCTION,tile_data);

	//Clear JCMD Register
	clear_jcmd_register();

}

/**
 ****************************************************************************************
 * @brief Tile global command. This command is used to turn on all VSS and VDD connects
 * @param tile_cmd . can be either PAD_RSEL_CONNECT_VSS or PAD_RSEL_CONNECT_VDD
  *
 ****************************************************************************************
 */
void tile_global(uint8_t tile_cmd)
{
	uint32_t status=0;

	//Clear JCMD Register
	clear_jcmd_register();

	//Set JCMD.WM Sets Read mode in the JCMD status register
	jtag_command_reg_t jtag_tile_global_command;
	jtag_tile_global_command.mAsU32 = 0;
	jtag_tile_global_command.mBits.tile_test_mode = 1;
	jtag_tile_global_command.mBits.test_mode_vector = tile_cmd;
	jtag_tile_global_command.mBits.jtag_enable = 1;
	jtag_32b_write(JTAG_JCMD_INSTRUCTION,jtag_tile_global_command.mAsU32);
	//arch_puts("\n\rTILE GLOBAL COMMAND= 0x");
	//print_word(jtag_tile_global_command.mAsU32);

	//Wait for JTAG Status
	if(wait_till_jtag_status(&status) == true)
	{
		  __nop();
			//arch_puts("\n\rTILE GLOBAL STATUS= 0x");
			//print_word(status);
	}
	else
	{
		arch_puts("\n\rJTAG TILE WRITE UNSUCCESSFUL");
	}

	//Clear JCMD Register
	clear_jcmd_register();
}

/**
 ****************************************************************************************
 * @brief Tile write. This function is just a simpler modification of the tile_write
					function. where it takes just address and data
 * @param address - tile address to write to.
								0	 	reserved
								1:7 column
								8:15 row
					data    - tile data. It is split as shown below
								0:1  csel
								2:5  rsel
								6:7  pullup
								8:9  pulldown
  *
 ****************************************************************************************
 */

void simple_tile_write(uint32_t address, uint32_t data)
{
	uint32_t status=0;

	//Clear JCMD Register
	clear_jcmd_register();

	//Set JCMD.WM Sets write mode in the JCMD status register
	jtag_command_reg_t jtag_tile_write_command;
	jtag_tile_write_command.mAsU32 = 0;
	jtag_tile_write_command.mBits.write_mode = 1;
	jtag_32b_write(JTAG_JCMD_INSTRUCTION,jtag_tile_write_command.mAsU32);
	//arch_puts("\n\rTILE SETTING RM MODE = 0x");
	//print_word(jtag_tile_read_command.mAsU32);

	//Write the address in the JAR register
	jtag_addr_reg_t jtag_tile_addr;
	jtag_tile_addr.mAsU32 = 0;
	jtag_tile_addr.mAsU32 = address;
	jtag_tile_addr.mBits.tile_address_selector = 1;
	jtag_address_reg_write(jtag_tile_addr.mAsU32);
	//arch_puts("\n\rTILE ADDRESS = 0x");
	//print_word(jtag_tile_addr.mAsU32);

	//Write the Data in the JDR register. Data coming in is in the format
	/*
	0:1  csel
	2:5  rsel
	6:7  pullup
	8:9  pulldown
	*/
	jtag_data_reg_t jtag_data_reg;
	jtag_data_reg.mAsU32 = 0;
	jtag_data_reg.mBits.pad_csel = 					 (data & 0x03);
	jtag_data_reg.mBits.pad_rsel = 					((data >> 2) & 0xF);
	jtag_data_reg.mBits.pad_pullup_sel = 		((data >> 6) & 0x3);
	jtag_data_reg.mBits.pad_pulldown_sel = 	((data >> 8) & 0x3);
	jtag_data_reg_write(jtag_data_reg.mAsU32);
	//arch_puts("\n\rTILE DATA = 0x");
	//print_word(jtag_data_reg.mAsU32);

	//Set JCMD.WM Sets Read mode in the JCMD status register and also set the enable
	jtag_tile_write_command.mAsU32 = 0;
	jtag_tile_write_command.mBits.write_mode = 1;
	jtag_tile_write_command.mBits.jtag_enable = 1;
	jtag_32b_write(JTAG_JCMD_INSTRUCTION,jtag_tile_write_command.mAsU32);
	//arch_puts("\n\rTILE SETTING ENABLE = 0x");
	//print_word(jtag_tile_read_command.mAsU32);

	if(wait_till_jtag_status(&status) == true)
	{
		/*arch_puts("\n\rJTAG TILE WRITE SUCCESSFUL : ");
		print_unsigned_number(address);
		arch_puts(",");
		print_unsigned_number(jtag_tile_addr.mBits.row);
		arch_puts(",");
		print_unsigned_number(jtag_tile_addr.mBits.column);
		arch_puts(",");
		print_word(data);
		arch_puts(",");
		print_word(jtag_data_reg.mAsU32);*/
		__nop();
	}
	else
	{
		arch_puts("\n\rJTAG TILE WRITE UNSUCCESSFUL");
	}

	//Clear JCMD Register
	clear_jcmd_register();
}

/**
 ****************************************************************************************
 * @brief Tile write. This function is used to write to a particular tile row and column
					and that particular address can be to connect to another row/coumn, VSS or VDD
					and pull up or pull down resistors.
 * @param row 		- tile row to write to.
					column  - tile col to write to.
					tile_csel - tile coumn select
				  tile_rsel - tile row select
					tile_pup  - tile pull up
					tile_pdown - tile pull down
					tile_align - tile alignemnt
  *
 ****************************************************************************************
 */

void tile_write(uint32_t row, uint32_t column, uint32_t tile_csel,uint32_t tile_rsel, uint32_t tile_pup, uint32_t tile_pdown, uint32_t tile_align)
{
	uint32_t status=0;

	//Clear JCMD Register
	clear_jcmd_register();

	//Set JCMD.WM Sets write mode in the JCMD status register
	jtag_command_reg_t jtag_tile_write_command;
	jtag_tile_write_command.mAsU32 = 0;
	jtag_tile_write_command.mBits.write_mode = 1;
	jtag_32b_write(JTAG_JCMD_INSTRUCTION,jtag_tile_write_command.mAsU32);
	//arch_puts("\n\rTILE SETTING RM MODE = 0x");
	//print_word(jtag_tile_read_command.mAsU32);

	//Write the address in the JAR register
	jtag_addr_reg_t jtag_tile_addr;
	jtag_tile_addr.mAsU32 = 0;
	jtag_tile_addr.mBits.tile_address_selector = 1;
	jtag_tile_addr.mBits.row = row;
	jtag_tile_addr.mBits.column = column;
	jtag_address_reg_write(jtag_tile_addr.mAsU32);
	//arch_puts("\n\rTILE ADDRESS = 0x");
	//print_word(jtag_tile_addr.mAsU32);

	//Write the Data in the JDR register
	jtag_data_reg_t jtag_data_reg;
	jtag_data_reg.mAsU32 = 0;
	jtag_data_reg.mBits.pad_csel = tile_csel;
	jtag_data_reg.mBits.pad_rsel = tile_rsel;
	jtag_data_reg.mBits.pad_alignment_mode = tile_align;
	jtag_data_reg.mBits.actual_pad_data = 0; //Hardcode to 0. ??
	jtag_data_reg.mBits.pad_pullup_sel = tile_pup;
	jtag_data_reg.mBits.pad_pulldown_sel = tile_pdown;
	jtag_data_reg_write(jtag_data_reg.mAsU32);
	//arch_puts("\n\rTILE DATA = 0x");
	//print_word(jtag_data_reg.mAsU32);

	//Set JCMD.WM Sets Read mode in the JCMD status register and also set the enable
	jtag_tile_write_command.mAsU32 = 0;
	jtag_tile_write_command.mBits.write_mode = 1;
	jtag_tile_write_command.mBits.jtag_enable = 1;
	jtag_32b_write(JTAG_JCMD_INSTRUCTION,jtag_tile_write_command.mAsU32);
	//arch_puts("\n\rTILE SETTING ENABLE = 0x");
	//print_word(jtag_tile_read_command.mAsU32);

	if(wait_till_jtag_status(&status) == true)
	{
		__nop();
		//arch_puts("\n\rJTAG TILE WRITE SUCCESSFUL");
	}
	else
	{
		arch_puts("\n\rJTAG TILE WRITE UNSUCCESSFUL");
	}

	//Clear JCMD Register
	clear_jcmd_register();

}

/**
 ****************************************************************************************
 * @brief Run a scantile of the FAST. This will read the state of all the tiles on the
					FAST array
 * @param 2d array with FAST_COL_COUNT columns and FAST_ROW_COUNT rows
  *
 ****************************************************************************************
 */

void jtag_scantile(uint32_t (*fast_scantile)[FAST_COL_COUNT])
{
	arch_puts("\n\rRUNNING SCANTILE...");
	uint16_t row = 0,col = 0;
	for(row = 0; row < FAST_ROW_COUNT; row++)
	{
		for(col = 0; col < FAST_COL_COUNT ; col++)
		{
			tile_read(row,col,&fast_scantile[row][col]);
		}
	}
	arch_puts("\n\rSCAN TILE COMPLETED SUCCESSFULLY");
}

/**
 ****************************************************************************************
 * @brief Run a comparison of scantile arrays and prints put the diffences to the UART
					between the two scantiles. This is used for debigging where you program certain
					tiles and find out if the tiles were programmed correctly
 * @param None.
  *
 ****************************************************************************************
 */
/*void compare_scantile(uint32_t (*fast_scantile_before)[FAST_COL_COUNT],uint32_t (*fast_scantile_after)[FAST_COL_COUNT])
{
	arch_puts("\n\rCOMPARING SCANTILE...");
	uint16_t row = 0,col = 0;
	for(row = 0; row < FAST_ROW_COUNT; row++)
	{
		for(col = 0; col < FAST_COL_COUNT ; col++)
		{
			if(fast_scantile_before[row][col] != fast_scantile_after[row][col])
			{
				arch_puts("\n\rMismatch on row, column :");
				print_word(row);
				arch_puts(",");
				print_word(col);
				arch_puts(",");
				print_word(fast_scantile_after[row][col]);
			}
		}
	}
	arch_puts("\n\rCOMPARING SCANTILE COMPLETED SUCCESSFULLY");
}*/

/**
 ****************************************************************************************
 * @brief Change the mcube sensor address to 0x6C. This is done by connecting the DOUT_A1
					pin of the sensor to VDD
 * @param None.
  *
 ****************************************************************************************
 */
void change_mcube_i2c_address_6C(void)
{
	//
	// ROW  COL     VSS/VDD?
	//
	// 24	10      VSS
	// 24	11      VSS
	// 25	10      VSS
	// 25	11      VSS
	// 26	10      VSS
	// 26	11      VSS


	tile_write(24,10,PAD_CSEL_NO_CONNECT,PAD_RSEL_CONNECT_VDD,PAD_PULLUP_NO_CONNECT,PAD_PULLDOWN_NO_CONNECT,PAD_NO_ALIGNMENT);
	tile_write(24,11,PAD_CSEL_NO_CONNECT,PAD_RSEL_CONNECT_VDD,PAD_PULLUP_NO_CONNECT,PAD_PULLDOWN_NO_CONNECT,PAD_NO_ALIGNMENT);
	tile_write(25,10,PAD_CSEL_NO_CONNECT,PAD_RSEL_CONNECT_VDD,PAD_PULLUP_NO_CONNECT,PAD_PULLDOWN_NO_CONNECT,PAD_NO_ALIGNMENT);
	tile_write(25,11,PAD_CSEL_NO_CONNECT,PAD_RSEL_CONNECT_VDD,PAD_PULLUP_NO_CONNECT,PAD_PULLDOWN_NO_CONNECT,PAD_NO_ALIGNMENT);
	tile_write(26,10,PAD_CSEL_NO_CONNECT,PAD_RSEL_CONNECT_VDD,PAD_PULLUP_NO_CONNECT,PAD_PULLDOWN_NO_CONNECT,PAD_NO_ALIGNMENT);
	tile_write(26,11,PAD_CSEL_NO_CONNECT,PAD_RSEL_CONNECT_VDD,PAD_PULLUP_NO_CONNECT,PAD_PULLDOWN_NO_CONNECT,PAD_NO_ALIGNMENT);

	// Enable these Pwr/Gnd connections with VSS_ON and VDD_ON
	tile_global(SB_VSS_ON);
	tile_global(SB_VDD_ON);
}

/**
 ****************************************************************************************
 * @brief Change the mcube sensorr address to 0x4C. This is done by connecting the DOUT_A1
					pin of the sensor to ground
 * @param None.
  *
 ****************************************************************************************
 */
void change_mcube_i2c_address_4C(void)
{
		//
	// ROW  COL     VSS/VDD?
	//
	// 24	10      VSS
	// 24	11      VSS
	// 25	10      VSS
	// 25	11      VSS
	// 26	10      VSS
	// 26	11      VSS


	//This changes DOUT_A1 pin for the sensor.
	tile_write(24,10,PAD_CSEL_NO_CONNECT,PAD_RSEL_CONNECT_VSS,PAD_PULLUP_NO_CONNECT,PAD_PULLDOWN_NO_CONNECT,PAD_NO_ALIGNMENT);
	tile_write(24,11,PAD_CSEL_NO_CONNECT,PAD_RSEL_CONNECT_VSS,PAD_PULLUP_NO_CONNECT,PAD_PULLDOWN_NO_CONNECT,PAD_NO_ALIGNMENT);
	tile_write(25,10,PAD_CSEL_NO_CONNECT,PAD_RSEL_CONNECT_VSS,PAD_PULLUP_NO_CONNECT,PAD_PULLDOWN_NO_CONNECT,PAD_NO_ALIGNMENT);
	tile_write(25,11,PAD_CSEL_NO_CONNECT,PAD_RSEL_CONNECT_VSS,PAD_PULLUP_NO_CONNECT,PAD_PULLDOWN_NO_CONNECT,PAD_NO_ALIGNMENT);
	tile_write(26,10,PAD_CSEL_NO_CONNECT,PAD_RSEL_CONNECT_VSS,PAD_PULLUP_NO_CONNECT,PAD_PULLDOWN_NO_CONNECT,PAD_NO_ALIGNMENT);
	tile_write(26,11,PAD_CSEL_NO_CONNECT,PAD_RSEL_CONNECT_VSS,PAD_PULLUP_NO_CONNECT,PAD_PULLDOWN_NO_CONNECT,PAD_NO_ALIGNMENT);

	// Enable these Pwr/Gnd connections with VSS_ON and VDD_ON
	tile_global(SB_VSS_ON);
	tile_global(SB_VDD_ON);
}

/**
 ****************************************************************************************
 * @brief Debug function to check the state of the power tiles of the mcube sensor.
					Uncomment if needed to debug
 * @param None.
  *
 ****************************************************************************************
 */

/*void mcube_power_tile_status(void)
{
	uint32_t tile_data = 0;
	tile_read(28,12,&tile_data);
	arch_puts("\n\rMCUBE POWER TILE DATA = 0x");
	print_word(tile_data);
	tile_data = 0;
	tile_read(28,13,&tile_data);
	arch_puts("\n\rMCUBE POWER TILE DATA = 0x");
	print_word(tile_data);
	tile_data = 0;
	tile_read(29,12,&tile_data);
	arch_puts("\n\rMCUBE POWER TILE DATA = 0x");
	print_word(tile_data);
	tile_data = 0;
	tile_read(29,13,&tile_data);
	arch_puts("\n\rMCUBE POWER TILE DATA = 0x");
	print_word(tile_data);
}*/

/**
 ****************************************************************************************
 * @brief Turns off power to the mcube sensor on the A1 board. This is done by writing
					the tiles which are connected to the power pin of the mcube sensor. This is
					extremely risky as this turns power off to a live FAST grid.
 * @param None.
  *
 ****************************************************************************************
 */

void power_off_mcube_sensor(void)
{
		//Connect the power pins to GND
	tile_write(28,12,PAD_CSEL_NO_CONNECT,PAD_RSEL_CONNECT_VSS,PAD_PULLUP_NO_CONNECT,PAD_PULLDOWN_NO_CONNECT,PAD_NO_ALIGNMENT);
	tile_write(28,13,PAD_CSEL_NO_CONNECT,PAD_RSEL_CONNECT_VSS,PAD_PULLUP_NO_CONNECT,PAD_PULLDOWN_NO_CONNECT,PAD_NO_ALIGNMENT);
	tile_write(29,12,PAD_CSEL_NO_CONNECT,PAD_RSEL_CONNECT_VSS,PAD_PULLUP_NO_CONNECT,PAD_PULLDOWN_NO_CONNECT,PAD_NO_ALIGNMENT);
	tile_write(29,13,PAD_CSEL_NO_CONNECT,PAD_RSEL_CONNECT_VSS,PAD_PULLUP_NO_CONNECT,PAD_PULLDOWN_NO_CONNECT,PAD_NO_ALIGNMENT);

	// Enable these Pwr/Gnd connections with VSS_ON and VDD_ON. These commands will turn sensor off
	tile_global(SB_VSS_ON);
	tile_global(SB_VDD_ON);

	systick_wait(1000000);
}


/**
 ****************************************************************************************
 * @brief Turns power back to the mcube sensor on the A1 board. This is done by writing
					the tiles which are connected to the power pin of the mcube sensor.This is
					extremely risky as this turns power off to a live FAST grid.
 * @param None.
  *
 ****************************************************************************************
 */

void power_on_mcube_sensor(void)
{
		//Connect the power pins to VDD and power the sensor back on
	tile_write(28,12,PAD_CSEL_NO_CONNECT,PAD_RSEL_CONNECT_VDD,PAD_PULLUP_NO_CONNECT,PAD_PULLDOWN_NO_CONNECT,PAD_NO_ALIGNMENT);
	tile_write(28,13,PAD_CSEL_NO_CONNECT,PAD_RSEL_CONNECT_VDD,PAD_PULLUP_NO_CONNECT,PAD_PULLDOWN_NO_CONNECT,PAD_NO_ALIGNMENT);
	tile_write(29,12,PAD_CSEL_NO_CONNECT,PAD_RSEL_CONNECT_VDD,PAD_PULLUP_NO_CONNECT,PAD_PULLDOWN_NO_CONNECT,PAD_NO_ALIGNMENT);
	tile_write(29,13,PAD_CSEL_NO_CONNECT,PAD_RSEL_CONNECT_VDD,PAD_PULLUP_NO_CONNECT,PAD_PULLDOWN_NO_CONNECT,PAD_NO_ALIGNMENT);

	// Enable these Pwr/Gnd connections with VSS_ON and VDD_ON. These commands will turn sensor back on
	tile_global(SB_VSS_ON);
	tile_global(SB_VDD_ON);

	systick_wait(1000000);
}


/**
 ****************************************************************************************
 * @brief Change the address of the mcube sensor. THe mcube sensor supports two addresses
					0x6C or 0x4C. The address depends on the state of the pin DOUT_A1 at powerup.
					This is done to fix an issue where the mcube sensor came up at the wrong address
 * @param Address. can be either 0x6C or 0x4C
  *
 ****************************************************************************************
 */
//#define MC3630_SLAVE_ADDR_4C 0x4C
//#define MC3630_SLAVE_ADDR 0x6C

/*void change_mcube_i2c_address(uint8_t addr)
{
	//Power off the mcube sensor
	power_off_mcube_sensor();


	if (addr == MC3630_SLAVE_ADDR_4C)
	{
		//Change DOUT_A1 pin to GND
		change_mcube_i2c_address_4C();
	}
	else if(addr == MC3630_SLAVE_ADDR)
	{
		//Change DOUT_A1 pin to VDD
		change_mcube_i2c_address_6C();
	}
	else
	{
		return;
	}

	systick_wait(1000000);

	//Power on the mcube sensor
	power_on_mcube_sensor();
}*/


/**
 ****************************************************************************************
 * @brief Programs the FAST to include the SiTime 32KHz clock. Uses the sequence array
					"sitime_only". This array contains the address and its corresponding
					value. THe Sitime is used for putting the DLialog chip in low power modes
 * @param None
  *
 ****************************************************************************************
 */
void zeus_a1_program_sitime(void)
{
	arch_puts("\n\rSTART PROGRAM SITIME");
	uint32_t row= 0;

	for(row = 0;row < ZEUS_A1_SITIME_ROW_COUNT; row++)
	{
		simple_tile_write(sitime_only[row][0], sitime_only[row][1]);
	}

	// Enable these Pwr/Gnd connections with VSS_ON and VDD_ON. These commands will turn sensor back on
	tile_global(SB_VSS_ON);
	tile_global(SB_VDD_ON);

	systick_wait(1000000);
	arch_puts("\n\rEND PROGRAM SITIME");

}

/**
 ****************************************************************************************
 * @brief Programs the FAST to include the BMM 150 in I2C mode. Uses the sequence array
					"bmm150_i2c_only". This array contains the address and its corresponding
					value.
 * @param None
  *
 ****************************************************************************************
 */
void zeus_a1_program_bmm150_i2c(void)
{
	arch_puts("\n\rSTART PROGRAM BMM150 I2C");
	uint32_t row= 0;

	for(row = 0;row < ZEUS_A1_BMM150_I2C_ROW_COUNT; row++)
	{
		simple_tile_write(bmm150_i2c_only[row][0], bmm150_i2c_only[row][1]);
	}

	// Enable these Pwr/Gnd connections with VSS_ON and VDD_ON. These commands will turn sensor back on
	tile_global(SB_VSS_ON);
	tile_global(SB_VDD_ON);

	systick_wait(1000000);
	arch_puts("\n\rEND PROGRAM BMM150 I2C");

}


 /**
 ****************************************************************************************
 * @brief Programs the FAST to include the BMM 150 in SPI mode. Uses the sequence array
					"bmm150_spi_only". This array contains the address and its corresponding
					value.
 * @param None
  *
 ****************************************************************************************
 */
void zeus_a1_program_bmm150_spi(void)
{
	arch_puts("\n\rSTART PROGRAM BMM150 SPI");
	uint32_t row= 0;

	for(row = 0;row < ZEUS_A1_BMM150_ROW_COUNT; row++)
	{
		simple_tile_write(bmm150_spi_only[row][0], bmm150_spi_only[row][1]);
	}

	// Enable these Pwr/Gnd connections with VSS_ON and VDD_ON. These commands will turn sensor back on
	tile_global(SB_VSS_ON);
	tile_global(SB_VDD_ON);

	systick_wait(1000000);
	arch_puts("\n\rEND PROGRAM BMM150 SPI");

}


 /**
 ****************************************************************************************
 * @brief tile_read_tests. Reads the value of a set of random tiles. Need not be included
					in final code.
 * @param None
  *
 ****************************************************************************************
 */
/*void tile_read_tests(void)
{
	uint32_t tile_data = 0;
	tile_read(6,11,&tile_data);
	arch_puts("\n\rTILE DATA = 0x");
	print_word(tile_data);
	tile_data = 0;
	tile_read(6,12,&tile_data);
	arch_puts("\n\rTILE DATA = 0x");
	print_word(tile_data);
	tile_data = 0;
	tile_read(6,13,&tile_data);
	arch_puts("\n\rTILE DATA = 0x");
	print_word(tile_data);
	tile_data = 0;
	tile_read(10,11,&tile_data);
	arch_puts("\n\rTILE DATA = 0x");
	print_word(tile_data);
	tile_data = 0;
	tile_read(10,12,&tile_data);
	arch_puts("\n\rTILE DATA = 0x");
	print_word(tile_data);
	tile_data = 0;
	tile_read(10,13,&tile_data);
	arch_puts("\n\rTILE DATA = 0x");
	print_word(tile_data);
	tile_data = 0;
	tile_read(6,30,&tile_data);
	arch_puts("\n\rTILE DATA = 0x");
	print_word(tile_data);
	tile_data = 0;
	tile_read(6,31,&tile_data);
	arch_puts("\n\rTILE DATA = 0x");
	print_word(tile_data);
	tile_data = 0;
	tile_read(10,30,&tile_data);
	arch_puts("\n\rTILE DATA = 0x");
	print_word(tile_data);
	tile_data = 0;
	tile_read(10,31,&tile_data);
	arch_puts("\n\rTILE DATA = 0x");
	print_word(tile_data);
	tile_data = 0;
	tile_read(3,8,&tile_data);
	arch_puts("\n\rTILE DATA = 0x");
	print_word(tile_data);
	tile_data = 0;
	tile_read(3,9,&tile_data);
	arch_puts("\n\rTILE DATA = 0x");
	print_word(tile_data);
}*/

 /**
 ****************************************************************************************
 * @brief Bit bang tests. executes a series of tests on the fast
 * @param None
  *
 ****************************************************************************************
 */

void bit_bang_tests(void)
{
	arch_puts("\n\rEntering Bit bang tests");
	//tile_read_tests();
	//jtag_scantile(fast_scantile_before);
	zeus_a1_program_sitime();
	//zeus_a1_program_bmm150_i2c();
	//zeus_a1_program_bmm150_spi();
	//jtag_scantile(fast_scantile_after);
	//compare_scantile(fast_scantile_before,fast_scantile_after);
	arch_puts("\n\rExiting Bit bang tests");
}

 /**
 ****************************************************************************************
 * @brief main jtag bit bang function. All tests are called from this main function.
					Reads the JTAG idcode. checks if the id code matches the fast JTAG idcode
					and then executes the tests
 * @param None
  *
 ****************************************************************************************
 */
void bit_bang_main(void)
{
	jtag_pins_init();
	systick_wait(100000);
	if(get_jtag_idcode() == true)
	{
		bit_bang_tests();
		systick_wait(1000000);
	}
		/*_M_DRV_MC3630_ValidateSensorIC_Address4C();
	change_mcube_i2c_address(MC3630_SLAVE_ADDR_4C);
	_M_DRV_MC3630_ValidateSensorIC();
	_M_DRV_MC3630_ValidateSensorIC_Address4C();
	arch_puts("\n\rChanging mcube address to 0x6C");
	change_mcube_i2c_address(MC3630_SLAVE_ADDR);
	_M_DRV_MC3630_ValidateSensorIC();
	_M_DRV_MC3630_ValidateSensorIC_Address4C();*/
}

#endif  //(JTAG_BIT_BANG_TEST)
