#ifndef __BOARD_H
#define __BOARD_H

#include <stdbool.h>


void board_hardware_init(void);
bool is_button_pressed(void);
void set_led(bool value);



#endif