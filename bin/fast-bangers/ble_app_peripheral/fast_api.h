
#ifndef __FAST_API__H__
#define __FAST_API__H__

//JTAG. JTAG pins are port 0, pins 4 and 7 and port 1 pins 2 and 3
#define JTAG_TCK_PIN  7
//#define JTAG_TMS_PIN  GPIO_PIN_4
//#define JTAG_TDI_PIN  GPIO_PIN_2
#define JTAG_TMS_PIN  2
#define JTAG_TDI_PIN  4
#define JTAG_TDO_PIN  3

#define JTAG_TCK_PORT  0
//#define JTAG_TMS_PORT  GPIO_PORT_0
//#define JTAG_TDI_PORT  GPIO_PORT_1
#define JTAG_TMS_PORT  1
#define JTAG_TDI_PORT  0
#define JTAG_TDO_PORT  1

void bit_bang_main(void);
void jtag_32b_read(uint8_t jtag_instruction, uint32_t* data);
void jtag_32b_write(uint8_t jtag_instruction, uint32_t data);
bool get_jtag_idcode(void);
void switch_tap_state(uint8_t current_state,uint8_t next_state);
void send_jtag_data(uint32_t data,uint32_t tms_sequence);
#endif //__FAST_API__H__
