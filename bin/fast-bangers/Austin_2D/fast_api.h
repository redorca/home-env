#ifndef __FAST_API__H__
#define __FAST_API__H__

bool verify_jtag_idcode(void);

void jtag_32b_read(uint8_t jtag_instruction, uint32_t* data);
void jtag_32b_write(uint8_t jtag_instruction, uint32_t data);

//Dallas APIs
void dallas_fast_enter_low_power_mode(void);
void dallas_reprogram_mcube(void);
void zeus_a1_program_sitime(void);

//Austin APIs
//void austin_fast_enter_low_power_mode(void);
//void fast_all_nets_on(void);
//void connect_ad8233_chip(void);

#endif //__FAST_API__H__
