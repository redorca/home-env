#include <stdbool.h>

#include "fast_jtag_bitbang.h"
#include "fast_api.h"

#ifdef CFG_PRINTF_UART2	
#include "common_uart.h"
#endif


/*#ifdef BMM150_INTERFACE_I2C
#include "i2c_core.h"
#include "bosch_bmm150.h"
#endif

#ifdef BMM150_INTERFACE_I2C
#include "spi.h"
#include "bosch_bmm150.h"
#endif
*/


#define AFTER_PROGRAM_DELAY 10

//Global variable to Set the alignemnt
unsigned int  global_aligment = 0;

#define ZEUS_A1_COL_COUNT 2

#if defined(ENABLE_AD8233_HR)

#define ZEUS_A1_AD8233_ENABLE_ROW_COUNT  99
static const uint16_t ad8233_enable[ZEUS_A1_AD8233_ENABLE_ROW_COUNT][ZEUS_A1_COL_COUNT] = { 
{7982	,	0x8} ,{7984	,	0x8} ,{7986	,	0x9} ,{7988	,	0x1} ,
{7990	,	0xC} ,{7992	,	0xC} ,{7994	,	0xC} ,{7998	,	0x10} ,
{8000	,	0x10} ,{8002	,	0x11} ,{8984	,	0x2 } ,{8998	,	0x1C} ,
{9000	,	0x1C} ,{9002	,	0x1C} ,{9014	,	0x11} ,{9016	,	0x10} ,
{9018	,	0x10} ,{9020	,	0x1 } ,{9022	,	0x4 } ,{9024	,	0x4 } ,
{9026	,	0x4 } ,{10016	,	0x1 } ,{10020	,	0x1 } ,{10022	,	0x4 } ,
{10024	,	0x4 } ,{10026	,	0x4 } ,{10030	,	0x14} ,{10032	,	0x14} ,
{10034	,	0x14} ,{10046	,	0xC } ,{10048	,	0xD } ,{10050	,	0xC } ,
{11046	,	0x10} ,{11048	,	0x10} ,{11050	,	0x11} ,{12070	,	0xC } ,
{12072	,	0xD } ,{12074	,	0xC } ,{12086	,	0x14} ,{12088	,	0x14} ,
{12090	,	0x14} ,{12112	,	0x1 } ,{9782	,	0x38} ,{9784	,	0x38} ,
{9786	,	0x38} ,{10038	,	0x38} ,{10040	,	0x38} ,{10042	,	0x38} ,
{10294	,	0x38} ,{10296	,	0x38} ,{10298	,	0x38} ,{10798	,	0x38} ,
{10800	,	0x38} ,{10802	,	0x38} ,{10806	,	0x38} ,{10808	,	0x38} ,
{10810	,	0x38} ,{10798	,	0x38} ,{10800	,	0x38} ,{10802	,	0x38} ,
{10806	,	0x38} ,{10808	,	0x38} ,{10810	,	0x38} ,{11054	,	0x38} ,
{11056	,	0x38} ,{11058	,	0x38} ,{11062	,	0x38} ,{11064	,	0x38} ,
{11066	,	0x38} ,{11310	,	0x38} ,{11312	,	0x38} ,{11314	,	0x38} ,
{11318	,	0x38} ,{11320	,	0x38} ,{11322	,	0x38} ,{11838	,	0x38} ,
{11840	,	0x38} ,{11842	,	0x38} ,{12094	,	0x38} ,{12096	,	0x38} ,
{12098	,	0x38} ,{12350	,	0x38} ,{12352	,	0x38} ,{12354	,	0x38} ,
{11326	,	0x3C} ,{11328	,	0x3C} ,{11330	,	0x3C} ,{10814	,	0x3C} ,
{10816	,	0x3C} ,{10818	,	0x3C} ,{10814	,	0x3C} ,{10816	,	0x3C} ,
{10818	,	0x3C} ,{11070	,	0x3C} ,{11072	,	0x3C} ,{11074	,	0x3C} ,
{10814	,	0x3C} ,{10816	,	0x3C} ,{10818	,	0x3C} 
};

#endif

#if defined(ENABLE_AD8233_HR_WEAK_ROWS)

#define ZEUS_A1_AD8233_ENABLE_WEAK_ROW_COUNT  87
static const uint16_t ad8233_enable_weak_row[ZEUS_A1_AD8233_ENABLE_WEAK_ROW_COUNT][ZEUS_A1_COL_COUNT] = { 
{7982	,	0x20 },{7984	,	0x20 },{7986	,	0x22 },{7988	,	0x2  },
{7990	,	0x24 },{7992	,	0x24 },{7994	,	0x24 },{7998	,	0x28 },
{8000	,	0x28 },{8002	,	0x2A },{8984	,	0x1  },{8998	,	0x4  },
{9000	,	0x4  },{9002	,	0x4  },{9014	,	0x2A },{9016	,	0x28 },
{9018	,	0x28 },{9020	,	0x2  },{9022	,	0x1C },{9024	,	0x1C },
{9026	,	0x1C },{10016	,	0x2  },{10020	,	0x2  },{10022	,	0x1C },
{10024	,	0x1C },{10026	,	0x1C },{10030	,	0x2C },{10032	,	0x2C },
{10034	,	0x2C },{10046	,	0x24 },{10048	,	0x26 },{10050	,	0x24 },
{11046	,	0x28 },{11048	,	0x28 },{11050	,	0x2A },{12072	,	0x26 },
{12112	,	0x2  },{12070	,	0x24 },{12074	,	0x24 },{12086	,	0x2C },
{12088	,	0x2C },{12090	,	0x2C },{9782	,	0x38 },{9784	,	0x38 },
{9786	,	0x38 },{10038	,	0x38 },{10040	,	0x38 },{10042	,	0x38 },
{10294	,	0x38 },{10296	,	0x38 },{10298	,	0x38 },{10798	,	0x38 },
{10800	,	0x38 },{10802	,	0x38 },{10806	,	0x38 },{10808	,	0x38 },
{10810	,	0x38 },{11054	,	0x38 },{11056	,	0x38 },{11058	,	0x38 },
{11062	,	0x38 },{11064	,	0x38 },{11066	,	0x38 },{11310	,	0x38 },
{11312	,	0x38 },{11314	,	0x38 },{11318	,	0x38 },{11320	,	0x38 },
{11322	,	0x38 },{11838	,	0x38 },{11840	,	0x38 },{11842	,	0x38 },
{12094	,	0x38 },{12096	,	0x38 },{12098	,	0x38 },{12350	,	0x38 },
{12352	,	0x38 },{12354	,	0x38 },{10814	,	0x3C },{10816	,	0x3C },
{10818	,	0x3C },{11070	,	0x3C },{11072	,	0x3C },{11074	,	0x3C },
{11326	,	0x3C },{11328	,	0x3C },{11330	,	0x3C }
};

#endif

#if defined(ENABLE_SITIME)
#define ZEUS_A1_SITIME_BMM150_ROW_COUNT 191

#define ZEUS_A1_SITIME_ROW_COUNT  45
static const uint16_t sitime_only[ZEUS_A1_SITIME_ROW_COUNT][ZEUS_A1_COL_COUNT] = { 
{11532	,0x38 },{11534	,0x38 },{11536	,0x38 },{11276	,0x38 },{11278	,0x38 },
{11280	,0x38 },{11020	,0x38 },{11022	,0x38 },{11024	,0x38 },{10508	,0x38 },
{10510	,0x38 },{10512	,0x38 },{10252	,0x38 },{10254	,0x38 },{10256	,0x38 },
{9996	,0x38 },{9998	,0x38 },{10000	,0x38 },{11552	,0x3C },{11554	,0x3C },
{11556	,0x3C },{11296	,0x3C },{11298	,0x3C },{11300	,0x3C },{11040	,0x3C },
{11042	,0x3C },{11044	,0x3C },{10528	,0xC  },{10530	,0xC  },{10532	,0xC  },
{10272	,0xC  },{10274	,0xC  },{10276	,0xC  },{10016	,0xC  },{10018	,0xC  },
{10020	,0xC  },{10536	,0x1  },{10280	,0x1  },{10024	,0x1  },{5672	,0x1  },
{5416	,0x1  },{5692	,0xC  },{5694	,0xC  },{5436	,0xC  },{5438	,0xC  }
};
#endif

#define ZEUS_A1_MC3630_DISCONNECT_ROW_COUNT  110
//All these rows are 0
static const uint16_t mc3630_disconnect[ZEUS_A1_MC3630_DISCONNECT_ROW_COUNT] = { 
5392,5394,5396,5398,5400,5402,5404,5406,5408,5410,5412,5648,5650,5652,
5654,5656,5658,5660,5662,5664,5666,5668,5904,5906,5908,5910,5912,5914,
5916,5918,5920,5922,5924,6160,6162,6164,6166,6168,6170,6172,6174,6176,
6178,6180,6416,6418,6420,6422,6424,6426,6428,6430,6432,6434,6436,6672,
6674,6676,6678,6680,6682,6684,6686,6688,6690,6692,6928,6930,6932,6934,
6936,6938,6940,6942,6944,6946,6948,7184,7186,7188,7190,7192,7194,7196,
7198,7200,7202,7204,7440,7442,7444,7446,7448,7450,7452,7454,7456,7458,
7460,7696,7698,7700,7702,7704,7706,7708,7710,7712,7714,7716,
};


#define ZEUS_A1_MC3630_CONNECT_ROW_COUNT  6
static const uint16_t mc3630_connect[ZEUS_A1_MC3630_CONNECT_ROW_COUNT][ZEUS_A1_COL_COUNT] = { 
//GND and VPP pin to GND
/*{7184	,	0x38},{7186	,	0x38},{7440	,	0x38},{7442	,	0x38},
{5392	,	0x38},{5394	,	0x38},{5648	,	0x38},{5650	,	0x38},*/
//DOUT_A1 pin to VSS
{6164	,	0x3C},{6420	,	0x3C},{6676	,	0x3C},{6166	,	0x3C},
{6422	,	0x3C},{6678	,	0x3C},
//SDA
/*{6174	,	0x4},{6430	,	0x4},{6686	,	0x4},{6176	,	0x4},{6432	,	0x4},{6688	,	0x4},
//SCL
{5410	,	0x18},{5412	,	0x18},{5666	,	0x18},{5668	,	0x18},
//CSN connection
{5400	,	0x3C},{5402	,	0x3C},{5656	,	0x3C},{5658	,	0x3C},
//VDD
{7192	,	0x3C},{7194	,	0x3C},{7448	,	0x3C},{7450	,	0x3C},*/
};


#define ZEUS_A1_OSC_LDO_VDDBYP_DISCONNECT  1
static const uint16_t zeus_a1_osc_ldo_vddbyp_disconnect[ZEUS_A1_OSC_LDO_VDDBYP_DISCONNECT][ZEUS_A1_COL_COUNT] = { 
//Col 10
{532,0x095}, //10smartK pull up
};

#define ZEUS_A1_OSC_LDO_VDDBYP_DISCONNECT  1
static const uint16_t austin_osc_ldo_vddbyp_disconnect[ZEUS_A1_OSC_LDO_VDDBYP_DISCONNECT][ZEUS_A1_COL_COUNT] = { 
{3586,0xc0},
};
//{532,0x055}, //1K pull up

//col 11 pull up
//534,0x59

#if defined(JTAG_BIT_BANG_TEST)
#define ZEUS_A1_BMM150_ROW_COUNT  61
static const uint32_t bmm150_spi_only[ZEUS_A1_BMM150_ROW_COUNT][ZEUS_A1_COL_COUNT] = { 
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
#endif

#ifdef BMM150_INTERFACE_SPI

#define ZEUS_A1_FLASH_CS_DISCONNECT  4
static const uint16_t zeus_a1_flash_cs_disconnect[ZEUS_A1_FLASH_CS_DISCONNECT][ZEUS_A1_COL_COUNT] = { 
{2846		,0x3C},{2848	,0x3C},{3102	,0x3C},{3104	,0x3C},
};


#define ZEUS_A1_BMM150_ROW_COUNT_FLASH_CS  55
static const uint16_t bmm150_spi_only_cs_flash_cs[ZEUS_A1_BMM150_ROW_COUNT_FLASH_CS][ZEUS_A1_COL_COUNT] = { 
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
{8282 	,0x4},{8284 	,0x4},{8538 	,0x4},{8540 ,0x4},
{8240 	,0x1},{8496 	,0x1},
};
#endif

#ifdef BMM150_INTERFACE_I2C
#define ZEUS_A1_BMM150_I2C_ROW_COUNT  48
static const uint16_t bmm150_i2c_only[ZEUS_A1_BMM150_I2C_ROW_COUNT][ZEUS_A1_COL_COUNT] = { 
//SDO/MISO
{11086	,0x38},{11088	,0x38},{11342	,0x38},{11344	,0x38},{11598	,0x38},{11600	,0x38},	
//CS
{8282	,0x38},{8284		,0x38},{8538	,0x38},{8540	,0x38},
//Mode select
{11098	,0x3C},{11100	,0x3C},{11354	,0x3C},{11356	,0x3C},{11610	,0x3C},{11612	,0x3C},
//GND
{11076	,0x38},{11078	,0x38},{11332	,0x38},{11334	,0x38},{11588	,0x38},{11590	,0x38},{8270	,0x38},
{8272		,0x38},{8526	,0x38},{8528	,0x38},{9796	,0x38},{9798	,0x38},{10052	,0x38},{10054	,0x38},
//SDI/MOSI
{9044	,0x5} ,{9046	,0x4},{9300		,0x5}	,{9302	,0x4}	,
//SCK
{9818	,0x18},{9820	,0x18},{10074	,0x18},{10076	,0x18},{9810	,0x1}	,{10066	,0x1}	,
//VDD
{8260		,0x3C},{8262	,0x3C},{8516	,0x3C},{8518	,0x3C},
//VDDIO
{10580	,0x3C},{10582	,0x3C},{10836	,0x3C},{10838	,0x3C},
};
#endif

#if defined(JTAG_BIT_BANG_TEST)
static const uint32_t cfgave_pwr[ZEUS_A1_SITIME_BMM150_ROW_COUNT][ZEUS_A1_COL_COUNT] = { 
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
#endif   


/**
 ****************************************************************************************
 * @brief gets the jtag idcode and prints it to the UART.
 * @param bool - returns true of the JTAG idcode matches FAST_JTAG_IDCODE. else returns
					false
  * 
 ****************************************************************************************
 */
bool verify_jtag_idcode(void)
{
	uint32_t jtag_idcode = 0;
	jtag_32b_read(JTAG_IDCODE_INSTRUCTION,&jtag_idcode);
#ifdef CFG_PRINTF_UART2	
	printf_string("\n\rJTAG IDCODE = 0x");
	print_word(jtag_idcode);
#endif
	if(jtag_idcode == FAST_JTAG_IDCODE)
		return true;
	else
		return false;
}

/**
 ****************************************************************************************
 * Delay function
  * 
 ****************************************************************************************
 */
void delay(uint32_t nof_us)
{
    while( nof_us-- ){
        __asm__("NOP");
        __asm__("NOP");
        __asm__("NOP");
        __asm__("NOP");
        __asm__("NOP");
        __asm__("NOP");
        __asm__("NOP");
        __asm__("NOP");
        __asm__("NOP");
        __asm__("NOP");
        __asm__("NOP");
    }
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
	jtag_32b_write(JTAG_JAR_INSTRUCTION,data);
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
	jtag_32b_write(JTAG_JDR_INSTRUCTION,data);
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
	jtag_32b_write(JTAG_JCMD_INSTRUCTION,0);
}

/**
 ****************************************************************************************
 * @brief Wait till jtag status done. This command is used to check the status of JTAG
					command. This will wait till the done or error status becomes set to 1
 * @param bool- true if successful and false if command failed
  * 
 ****************************************************************************************
 */
#if defined(JTAG_BIT_BANG_TEST)
bool wait_till_jtag_status(uint32_t* status)
{
	jtag_status_reg_t jtag_status_reg;
	jtag_status_reg.mAsU32 = 0;
	
	while(1)
	{
		jtag_32b_read(JTAG_JSTS_INSTRUCTION,(uint32_t*)&jtag_status_reg.mAsU32);
		*status = jtag_status_reg.mAsU32;

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
#endif

/**
 ****************************************************************************************
 * @brief Wait till jtag status done. This command is used to check the status of JTAG
					command. This will wait till the done or error status becomes set to 1
 * @param bool- true if successful and false if command failed
  * 
 ****************************************************************************************
 */
bool timed_wait_till_jtag_status(uint32_t* status,uint32_t timeout)
{
	jtag_status_reg_t jtag_status_reg;
	jtag_status_reg.mAsU32 = 0;
	
	while(1)
	{
		jtag_32b_read(JTAG_JSTS_INSTRUCTION,(uint32_t*)&jtag_status_reg.mAsU32);
		*status = jtag_status_reg.mAsU32;

		if(jtag_status_reg.mBits.jtag_request_done == 1)
		{
			return true;
		}
		else if(jtag_status_reg.mBits.jtag_request_fault == 1)
		{
			return false;
		}
		
		if (timeout == 0) 
			return false;
		delay(500); 
		timeout--;
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
#if defined(JTAG_BIT_BANG_TEST)
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
	//printf_string("\n\rTILE SETTING RM MODE = 0x");
	//print_word(jtag_tile_read_command.mAsU32);
	
	//Write the address in the JAR register
	jtag_addr_reg_t jtag_tile_addr;
	jtag_tile_addr.mAsU32 = 0;
	jtag_tile_addr.mBits.tile_address_selector = 1;
	jtag_tile_addr.mBits.row = row;
	jtag_tile_addr.mBits.column = column;
	jtag_address_reg_write(jtag_tile_addr.mAsU32);
	//printf_string("\n\rTILE ADDRESS = 0x");
	//print_word(jtag_tile_addr.mAsU32);
	
	//Set JCMD.RM Sets Read mode in the JCMD status register and also set the enable
	jtag_tile_read_command.mAsU32 = 0;
	jtag_tile_read_command.mBits.read_mode = 1;
	jtag_tile_read_command.mBits.jtag_enable = 1;
	jtag_32b_write(JTAG_JCMD_INSTRUCTION,jtag_tile_read_command.mAsU32);
	//printf_string("\n\rTILE SETTING ENABLE = 0x");
	//print_word(jtag_tile_read_command.mAsU32);
	
	if(timed_wait_till_jtag_status(&status,5) == true)
	{
		__nop();
		//printf_string("\n\rJTAG TILE READ SUCCESSFUL");
	}
	else
	{
#ifdef CFG_PRINTF_UART2
		printf_string("\n\rJTAG TILE READ UNSUCCESSFUL");
#endif		
	}
	
	jtag_32b_read(JTAG_JMMDR_INSTRUCTION,tile_data);
	
	//Clear JCMD Register
	clear_jcmd_register();
	
}
#endif
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
	//printf_string("\n\rTILE GLOBAL COMMAND= 0x");
	//print_word(jtag_tile_global_command.mAsU32);
	
	//Wait for JTAG Status
	if(timed_wait_till_jtag_status(&status,5) == true)
	{
		__asm__("NOP");
	}
	else
	{
#ifdef CFG_PRINTF_UART2
		printf_string("\n\rJTAG TILE WRITE UNSUCCESSFUL");
#endif
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

int simple_tile_write(uint16_t address, uint16_t data)
{
	uint32_t status=0;
	
	//Clear JCMD Register
	clear_jcmd_register();
	
	//Set JCMD.WM Sets write mode in the JCMD status register
	jtag_command_reg_t jtag_tile_write_command;
	jtag_tile_write_command.mAsU32 = 0;
	jtag_tile_write_command.mBits.write_mode = 1;
	jtag_32b_write(JTAG_JCMD_INSTRUCTION,jtag_tile_write_command.mAsU32);
	//printf_string("\n\rTILE SETTING RM MODE = 0x");
	//print_word(jtag_tile_read_command.mAsU32);
	
	//Write the address in the JAR register
	jtag_addr_reg_t jtag_tile_addr;
	jtag_tile_addr.mAsU32 = 0;
	jtag_tile_addr.mAsU32 = address;
	jtag_tile_addr.mBits.tile_address_selector = 1;
	jtag_address_reg_write(jtag_tile_addr.mAsU32);
	//printf_string("\n\rTILE ADDRESS = 0x");
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
	jtag_data_reg.mBits.pad_alignment_mode = global_aligment;
	jtag_data_reg_write(jtag_data_reg.mAsU32);
	//printf_string("\n\rTILE DATA = 0x");
	//print_word(jtag_data_reg.mAsU32);
	
	//Set JCMD.WM Sets Read mode in the JCMD status register and also set the enable
	jtag_tile_write_command.mAsU32 = 0;
	jtag_tile_write_command.mBits.write_mode = 1;
	jtag_tile_write_command.mBits.jtag_enable = 1;
	jtag_32b_write(JTAG_JCMD_INSTRUCTION,jtag_tile_write_command.mAsU32);
	//printf_string("\n\rTILE SETTING ENABLE = 0x");
	//print_word(jtag_tile_read_command.mAsU32);
	
	if(timed_wait_till_jtag_status(&status,5) == true)
	{
		/*printf_string("\n\rJTAG TILE WRITE SUCCESSFUL : ");
		print_unsigned_number(address);
		printf_string(",");
		print_unsigned_number(jtag_tile_addr.mBits.row);
		printf_string(",");
		print_unsigned_number(jtag_tile_addr.mBits.column);
		printf_string(",");
		print_word(data);
		printf_string(",");
		print_word(jtag_data_reg.mAsU32);*/
		__asm__("NOP");
	}
	else
	{
		return -1;
#ifdef CFG_PRINTF_UART2
		printf_string("\n\rJTAG TILE WRITE UNSUCCESSFUL");
#endif
	}
	
	//Clear JCMD Register
	clear_jcmd_register();
	
	return 0;
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
#if defined(JTAG_BIT_BANG_TEST)
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
	//printf_string("\n\rTILE SETTING RM MODE = 0x");
	//print_word(jtag_tile_read_command.mAsU32);
	
	//Write the address in the JAR register
	jtag_addr_reg_t jtag_tile_addr;
	jtag_tile_addr.mAsU32 = 0;
	jtag_tile_addr.mBits.tile_address_selector = 1;
	jtag_tile_addr.mBits.row = row;
	jtag_tile_addr.mBits.column = column;
	jtag_address_reg_write(jtag_tile_addr.mAsU32);
	//printf_string("\n\rTILE ADDRESS = 0x");
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
	//printf_string("\n\rTILE DATA = 0x");
	//print_word(jtag_data_reg.mAsU32);
	
	//Set JCMD.WM Sets Read mode in the JCMD status register and also set the enable
	jtag_tile_write_command.mAsU32 = 0;
	jtag_tile_write_command.mBits.write_mode = 1;
	jtag_tile_write_command.mBits.jtag_enable = 1;
	jtag_32b_write(JTAG_JCMD_INSTRUCTION,jtag_tile_write_command.mAsU32);
	//printf_string("\n\rTILE SETTING ENABLE = 0x");
	//print_word(jtag_tile_read_command.mAsU32);
	
	if(timed_wait_till_jtag_status(&status,5) == true)
	{
		__asm__("NOP");
		//printf_string("\n\rJTAG TILE WRITE SUCCESSFUL");
	}
	else
	{
#ifdef CFG_PRINTF_UART2
		printf_string("\n\rJTAG TILE WRITE UNSUCCESSFUL");
#endif		
	}
	
	//Clear JCMD Register
	clear_jcmd_register();
	
}
#endif
/**
 ****************************************************************************************
 * @brief Run a scantile of the FAST. This will read the state of all the tiles on the 
					FAST array
 * @param 2d array with FAST_COL_COUNT columns and FAST_ROW_COUNT rows
  * 
 ****************************************************************************************
 */
#if defined(JTAG_BIT_BANG_TEST)
void jtag_scantile(uint32_t (*fast_scantile)[FAST_COL_COUNT])
{
#ifdef CFG_PRINTF_UART2
	printf_string("\n\rRUNNING SCANTILE...");
#endif
	uint16_t row = 0,col = 0;
	for(row = 0; row < FAST_ROW_COUNT; row++)
	{
		for(col = 0; col < FAST_COL_COUNT ; col++)
		{
			tile_read(row,col,&fast_scantile[row][col]);
		}
	}
#ifdef CFG_PRINTF_UART2	
	printf_string("\n\rSCAN TILE COMPLETED SUCCESSFULLY");
#endif
}
#endif
/**
 ****************************************************************************************
 * @brief Run a comparison of scantile arrays and prints put the diffences to the UART
					between the two scantiles. This is used for debigging where you program certain
					tiles and find out if the tiles were programmed correctly
 * @param None.
  * 
 ****************************************************************************************
 */
#if defined(JTAG_BIT_BANG_TEST)
void compare_scantile(uint32_t (*fast_scantile_before)[FAST_COL_COUNT],uint32_t (*fast_scantile_after)[FAST_COL_COUNT])
{
	printf_string("\n\rCOMPARING SCANTILE...");
	uint16_t row = 0,col = 0;
	for(row = 0; row < FAST_ROW_COUNT; row++)
	{
		for(col = 0; col < FAST_COL_COUNT ; col++)
		{
			if(fast_scantile_before[row][col] != fast_scantile_after[row][col])
			{
				printf_string("\n\rMismatch on row, column :");
				print_word(row);
				printf_string(",");
				print_word(col);
				printf_string(",");
				print_word(fast_scantile_after[row][col]);
			}
		}
	}
	printf_string("\n\rCOMPARING SCANTILE COMPLETED SUCCESSFULLY");
}
#endif
/**
 ****************************************************************************************
 * @brief Change the mcube sensor address to 0x6C. This is done by connecting the DOUT_A1
					pin of the sensor to VDD
 * @param None.
  * 
 ****************************************************************************************
 */
#if defined(JTAG_BIT_BANG_TEST)
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
#endif
/**
 ****************************************************************************************
 * @brief Change the mcube sensorr address to 0x4C. This is done by connecting the DOUT_A1
					pin of the sensor to ground
 * @param None.
  * 
 ****************************************************************************************
 */
#if defined(JTAG_BIT_BANG_TEST)
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
#endif
/**
 ****************************************************************************************
 * @brief Debug function to check the state of the power tiles of the mcube sensor.
					Uncomment if needed to debug
 * @param None.
  * 
 ****************************************************************************************
 */
#if defined(JTAG_BIT_BANG_TEST)
void mcube_power_tile_status(void)
{
	uint32_t tile_data = 0;
	tile_read(28,12,&tile_data);
	printf_string("\n\rMCUBE POWER TILE DATA = 0x");
	print_word(tile_data);
	tile_data = 0;
	tile_read(28,13,&tile_data);
	printf_string("\n\rMCUBE POWER TILE DATA = 0x");
	print_word(tile_data);
	tile_data = 0;
	tile_read(29,12,&tile_data);
	printf_string("\n\rMCUBE POWER TILE DATA = 0x");
	print_word(tile_data);
	tile_data = 0;
	tile_read(29,13,&tile_data);
	printf_string("\n\rMCUBE POWER TILE DATA = 0x");
	print_word(tile_data);
}
#endif
/**
 ****************************************************************************************
 * @brief Turns off power to the mcube sensor on the A1 board. This is done by writing 
					the tiles which are connected to the power pin of the mcube sensor. This is
					extremely risky as this turns power off to a live FAST grid.
 * @param None.
  * 
 ****************************************************************************************
 */
#if defined(JTAG_BIT_BANG_TEST)
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
	
	systick_wait(AFTER_PROGRAM_DELAY*1000);
}
#endif

/**
 ****************************************************************************************
 * @brief Turns power back to the mcube sensor on the A1 board. This is done by writing 
					the tiles which are connected to the power pin of the mcube sensor.This is
					extremely risky as this turns power off to a live FAST grid.
 * @param None.
  * 
 ****************************************************************************************
 */
#if defined(JTAG_BIT_BANG_TEST)
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
	
	systick_wait(AFTER_PROGRAM_DELAY*1000);
}
#endif

/**
 ****************************************************************************************
 * @brief Change the address of the mcube sensor. THe mcube sensor supports two addresses
					0x6C or 0x4C. The address depends on the state of the pin DOUT_A1 at powerup.
					This is done to fix an issue where the mcube sensor came up at the wrong address
 * @param Address. can be either 0x6C or 0x4C
  * 
 ****************************************************************************************
 */
#if defined(JTAG_BIT_BANG_TEST)
void change_mcube_i2c_address(uint8_t addr)
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
	
	systick_wait(AFTER_PROGRAM_DELAY*1000);
	
	//Power on the mcube sensor
	power_on_mcube_sensor();
}
#endif

/**
 ****************************************************************************************
 * @brief Programs the FAST to include the SiTime 32KHz clock. Uses the sequence array 
					"sitime_only". This array contains the address and its corresponding 
					value. THe Sitime is used for putting the DLialog chip in low power modes
 * @param None
  * 
 ****************************************************************************************
 */
#if defined(ENABLE_SITIME)
void zeus_a1_program_sitime(void)
{
#ifdef CFG_PRINTF_UART2	
	printf_string("\n\rStart SiTime");
#endif
	uint32_t row= 0;
	
	for(row = 0;row < ZEUS_A1_SITIME_ROW_COUNT; row++)
	{
		if(simple_tile_write(sitime_only[row][0], sitime_only[row][1]) == -1)
		{
			return;
		}
	}
	
	// Enable these Pwr/Gnd connections with VSS_ON and VDD_ON. These commands will turn sensor back on
	tile_global(SB_VSS_ON);
	tile_global(SB_VDD_ON);
	
	//systick_wait(AFTER_PROGRAM_DELAY*1000);
#ifdef CFG_PRINTF_UART2	
	printf_string("\n\rEnd Sitime");
#endif

}
#endif
/**
 ****************************************************************************************
 * @brief Programs the FAST to include the BMM 150 in I2C mode. Uses the sequence array 
					"bmm150_i2c_only". This array contains the address and its corresponding 
					value. 
 * @param None
  * 
 ****************************************************************************************
 */
#if defined(BMM150_INTERFACE_I2C)
void zeus_a1_program_bmm150_i2c(void)
{
#ifdef CFG_PRINTF_UART2	
	printf_string("\n\rStart BMM150 I2C");
#endif
	uint32_t row= 0;
	
	for(row = 0;row < ZEUS_A1_BMM150_I2C_ROW_COUNT; row++)
	{
		simple_tile_write(bmm150_i2c_only[row][0], bmm150_i2c_only[row][1]);
	}
	
	// Enable these Pwr/Gnd connections with VSS_ON and VDD_ON. These commands will turn sensor back on
	tile_global(SB_VSS_ON);
	tile_global(SB_VDD_ON);
	
	systick_wait(AFTER_PROGRAM_DELAY*1000);
#ifdef CFG_PRINTF_UART2	
	printf_string("\n\rEnd BMM150 I2C");
#endif

}
#endif

 /**
 ****************************************************************************************
 * @brief Programs the FAST to include the BMM 150 in SPI mode. Uses the sequence array 
					"bmm150_spi_only". This array contains the address and its corresponding 
					value. 
 * @param None
  * 
 ****************************************************************************************
 */
#if defined(JTAG_BIT_BANG_TEST)
void zeus_a1_program_bmm150_spi(void)
{
	printf_string("\n\rStart BMM150 SPI");
	uint32_t row= 0;
	
	for(row = 0;row < ZEUS_A1_BMM150_ROW_COUNT; row++)
	{
		simple_tile_write(bmm150_spi_only[row][0], bmm150_spi_only[row][1]);
	}
	
	// Enable these Pwr/Gnd connections with VSS_ON and VDD_ON. These commands will turn sensor back on
	tile_global(SB_VSS_ON);
	tile_global(SB_VDD_ON);
	
	systick_wait(AFTER_PROGRAM_DELAY*1000);
	printf_string("\n\rEnd BMM150 SPI");

}
#endif

 /**
 ****************************************************************************************
 * @brief Programs the FAST to include the BMM 150 in SPI mode. Uses the sequence array 
					"bmm150_spi_only". This array contains the address and its corresponding 
					value. 
 * @param None
  * 
 ****************************************************************************************
 */
#ifdef BMM150_INTERFACE_SPI
void zeus_a1_program_bmm150_spi_flash_cs(void)
{
#ifdef CFG_PRINTF_UART2	
	printf_string("\n\rStart BMM150 SPI FLASH CS");
#endif
	uint32_t row= 0;
	
	for(row = 0;row < ZEUS_A1_BMM150_ROW_COUNT_FLASH_CS; row++)
	{
		simple_tile_write(bmm150_spi_only_cs_flash_cs[row][0], bmm150_spi_only_cs_flash_cs[row][1]);
	}
	
	// Enable these Pwr/Gnd connections with VSS_ON and VDD_ON. These commands will turn sensor back on
	tile_global(SB_VSS_ON);
	tile_global(SB_VDD_ON);
	
	systick_wait(AFTER_PROGRAM_DELAY*1000);
#ifdef CFG_PRINTF_UART2	
	printf_string("\n\rEnd BMM150 SPI FLASH CS");
#endif

}
#endif

 /**
 ****************************************************************************************
 * @brief Programs the FAST to discoonect the flash. Flash is disconnected by connecting
					the chip select to high
 * @param None
  * 
 ****************************************************************************************
 */
#ifdef BMM150_INTERFACE_SPI
void disconnect_flash_cs(void)
{
#ifdef CFG_PRINTF_UART2	
	printf_string("\n\rDISCONNECT FLASH CS");
#endif
	uint32_t row= 0;
	
	for(row = 0;row < ZEUS_A1_FLASH_CS_DISCONNECT; row++)
	{
		simple_tile_write(zeus_a1_flash_cs_disconnect[row][0], zeus_a1_flash_cs_disconnect[row][1]);
	}
	
	// Enable these Pwr/Gnd connections with VSS_ON and VDD_ON. These commands will turn sensor back on
	tile_global(SB_VSS_ON);
	tile_global(SB_VDD_ON);
	
	systick_wait(AFTER_PROGRAM_DELAY*1000);
#ifdef CFG_PRINTF_UART2	
	printf_string("\n\rEND DISCONNECT FLASH CS");
#endif
}
#endif

/**
 ****************************************************************************************
 * @brief Reprogram the MCUBE sensor
 * @param None
 * 
 ****************************************************************************************
 */
#ifdef DALLAS_REPROGRAM_MCUBE
void dallas_reprogram_mcube(void)
{
#ifdef CFG_PRINTF_UART2	
	printf_string("\n\rSTART PROGRAM MCUBE");
#endif
	uint32_t row= 0;
	
	global_aligment = 1;
	for(row = 0;row < ZEUS_A1_MC3630_DISCONNECT_ROW_COUNT; row++)
	{
		if(simple_tile_write(mc3630_disconnect[row], 0x0) == -1)
		{
			return;
		}
	}
	
	//systick_wait(AFTER_PROGRAM_DELAY*1000);
	
	if(_M_DRV_MC3630_ValidateSensorIC() != 0)
	{
			_M_DRV_MC3630_ValidateSensorIC_Address4C();
	}
	
	global_aligment = 0;
	for(row = 0;row < ZEUS_A1_MC3630_CONNECT_ROW_COUNT; row++)
	{
		if(simple_tile_write(mc3630_connect[row][0], mc3630_connect[row][1]) == -1)
		{
			return;
		}
	}
	
	// Enable these Pwr/Gnd connections with VSS_ON and VDD_ON and also turn on the nets. These commands will turn sensor back on
	tile_global(SB_NETS_ON);
	tile_global(SB_VSS_ON);
	tile_global(SB_VDD_ON);
	tile_global(SB_ALG_RST);
	
	//systick_wait(AFTER_PROGRAM_DELAY*1000);
#ifdef CFG_PRINTF_UART2	
	printf_string("\n\rEND PROGRAM MCUBE");
#endif
}
#endif

/**
 ****************************************************************************************
 * @brief Austin chip enters low power mode
 * @param None
  * 
 ****************************************************************************************
 */
#ifdef AUSTIN_LOW_POWER_MODE
void austin_fast_enter_low_power_mode(void)
{
#ifdef CFG_PRINTF_UART2	
	printf_string("\n\rDISCONNECT OSC LDO VDDBYP");
#endif
	uint32_t row= 0;
	
	for(row = 0;row < ZEUS_A1_OSC_LDO_VDDBYP_DISCONNECT; row++)
	{
		simple_tile_write(austin_osc_ldo_vddbyp_disconnect[row][0], austin_osc_ldo_vddbyp_disconnect[row][1]);
	}
	
	// Enable these Pwr/Gnd connections with VSS_ON and VDD_ON. These commands will turn sensor back on
	tile_global(SB_VSS_ON);
	tile_global(SB_VDD_ON);
	
	//systick_wait(AFTER_PROGRAM_DELAY*1000);
#ifdef CFG_PRINTF_UART2	
	printf_string("\n\rEND DISCONNECT OSC LDO VDDBYP");
#endif
}
#endif

/**
 ****************************************************************************************
 * @brief Dallas chip enters low power mode
 * @param None
  * 
 ****************************************************************************************
 */
#ifdef DALLAS_LOW_POWER_MODE
void dallas_fast_enter_low_power_mode(void)
{
#ifdef CFG_PRINTF_UART2	
	printf_string("\n\rDISCONNECT OSC LDO VDDBYP");
#endif
	uint32_t row= 0;
	
	for(row = 0;row < ZEUS_A1_OSC_LDO_VDDBYP_DISCONNECT; row++)
	{
		if(simple_tile_write(zeus_a1_osc_ldo_vddbyp_disconnect[row][0], zeus_a1_osc_ldo_vddbyp_disconnect[row][1]) == -1)
		{
			return;
		}
	}
	
	// Enable these Pwr/Gnd connections with VSS_ON and VDD_ON. These commands will turn sensor back on
	tile_global(SB_VSS_ON);
	tile_global(SB_VDD_ON);
	
	//systick_wait(AFTER_PROGRAM_DELAY*1000);
#ifdef CFG_PRINTF_UART2	
	printf_string("\n\rEND DISCONNECT OSC LDO VDDBYP");
#endif
}
#endif

/**
 ****************************************************************************************
 * @brief Programs the FAST to connect the AD8233 chip.
 * @param None
  * 
 ****************************************************************************************
 */
#ifdef ENABLE_AD8233_HR
void austin_connect_ad8233_chip(void)
{
#ifdef CFG_PRINTF_UART2	
	printf_string("\n\rDISCONNECT OSC LDO VDDBYP");
#endif
	uint32_t row= 0;
	
	for(row = 0;row < ZEUS_A1_AD8233_ENABLE_ROW_COUNT; row++)
	{
		if(simple_tile_write(ad8233_enable[row][0], ad8233_enable[row][1]) == -1)
		{
			return;
		}
	}
	
	// Enable these Pwr/Gnd connections with VSS_ON and VDD_ON. These commands will turn sensor back on
	tile_global(SB_VSS_ON);
	tile_global(SB_VDD_ON);
	
	//systick_wait(AFTER_PROGRAM_DELAY*1000);
#ifdef CFG_PRINTF_UART2	
	printf_string("\n\rEND DISCONNECT OSC LDO VDDBYP");
#endif
}
#endif

/**
 ****************************************************************************************
 * @brief Programs the FAST to conenct the AD8233 chip through weak rows
 * @param None
  * 
 ****************************************************************************************
 */
#ifdef ENABLE_AD8233_HR_WEAK_ROWS
void austin_connect_ad8233_chip_weak_row(void)
{
#ifdef CFG_PRINTF_UART2	
	printf_string("\n\rDISCONNECT OSC LDO VDDBYP");
#endif
	uint32_t row= 0;
	
	for(row = 0;row < ZEUS_A1_AD8233_ENABLE_WEAK_ROW_COUNT; row++)
	{
		if(simple_tile_write(ad8233_enable_weak_row[row][0], ad8233_enable_weak_row[row][1]) == -1)
		{
			return;
		}
	}
	
	// Enable these Pwr/Gnd connections with VSS_ON and VDD_ON. These commands will turn sensor back on
	tile_global(SB_VSS_ON);
	tile_global(SB_VDD_ON);
	
	//systick_wait(AFTER_PROGRAM_DELAY*1000);
#ifdef CFG_PRINTF_UART2	
	printf_string("\n\rEND DISCONNECT OSC LDO VDDBYP");
#endif
}
#endif

 /**
 ****************************************************************************************
 * @brief tile_read_tests. Reads the value of a set of random tiles. Need not be included
					in final code.
 * @param None
  * 
 ****************************************************************************************
 */
#if defined(JTAG_BIT_BANG_TEST)
void tile_read_tests(void)
{
	uint32_t tile_data = 0;
	tile_read(6,11,&tile_data);
	printf_string("\n\rTILE DATA = 0x");
	print_word(tile_data);
	tile_data = 0;
	tile_read(6,12,&tile_data);
	printf_string("\n\rTILE DATA = 0x");
	print_word(tile_data);
	tile_data = 0;
	tile_read(6,13,&tile_data);
	printf_string("\n\rTILE DATA = 0x");
	print_word(tile_data);
	tile_data = 0;
	tile_read(10,11,&tile_data);
	printf_string("\n\rTILE DATA = 0x");
	print_word(tile_data);
	tile_data = 0;
	tile_read(10,12,&tile_data);
	printf_string("\n\rTILE DATA = 0x");
	print_word(tile_data);
	tile_data = 0;
	tile_read(10,13,&tile_data);
	printf_string("\n\rTILE DATA = 0x");
	print_word(tile_data);
	tile_data = 0;
	tile_read(6,30,&tile_data);
	printf_string("\n\rTILE DATA = 0x");
	print_word(tile_data);
	tile_data = 0;
	tile_read(6,31,&tile_data);
	printf_string("\n\rTILE DATA = 0x");
	print_word(tile_data);
	tile_data = 0;
	tile_read(10,30,&tile_data);
	printf_string("\n\rTILE DATA = 0x");
	print_word(tile_data);
	tile_data = 0;
	tile_read(10,31,&tile_data);
	printf_string("\n\rTILE DATA = 0x");
	print_word(tile_data);
	tile_data = 0;
	tile_read(3,8,&tile_data);
	printf_string("\n\rTILE DATA = 0x");
	print_word(tile_data);
	tile_data = 0;
	tile_read(3,9,&tile_data);
	printf_string("\n\rTILE DATA = 0x");
	print_word(tile_data);
}
#endif
 /**
 ****************************************************************************************
 * @brief Bit bang tests. executes a series of tests on the fast
 * @param None
  * 
 ****************************************************************************************
 */
#if defined(JTAG_BIT_BANG_TEST)
void bit_bang_tests(void)
{
#ifdef CFG_PRINTF_UART2	
	printf_string("\n\rEntering Bit bang tests");
#endif
	//tile_read_tests();
	//jtag_scantile(fast_scantile_before);
	//zeus_a1_program_bmm150_spi();
	//jtag_scantile(fast_scantile_after);
	//compare_scantile(fast_scantile_before,fast_scantile_after);
	//zeus_a1_reprogram_mcube();
#ifdef ENABLE_SITIME
	zeus_a1_program_sitime();
#endif
#ifdef BMM150_INTERFACE_I2C
	zeus_a1_program_bmm150_i2c();
#endif
#ifdef BMM150_INTERFACE_SPI
	disconnect_flash_cs();
	zeus_a1_program_bmm150_spi_flash_cs();
#endif
#ifdef ENABLE_AD8233_HR
	connect_ad8233_chip();
#endif
#ifdef ENABLE_AD8233_HR_WEAK_ROWS
	connect_ad8233_chip_weak_row();
#endif
#ifdef CFG_PRINTF_UART2	
	printf_string("\n\rExiting Bit bang tests");
#endif
}
#endif

 /**
 ****************************************************************************************
 * @brief FAST turns all nets on
 * @param None
  * 
 ****************************************************************************************
 */
void fast_all_nets_on(void)
{
	tile_global(SB_ALL_ON);
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
#if defined(JTAG_BIT_BANG_TEST)
void bit_bang_main(void)
{
	verify_jtag_idcode();
	//systick_wait(100*1000);
	if(verify_jtag_idcode() == true)
	{
		bit_bang_tests();
		//systick_wait(AFTER_PROGRAM_DELAY*1000);
	}
}
#endif

