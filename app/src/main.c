#include <stdlib.h>
#include "stm32f4xx.h"
#include "board.h"
#include "uart.h"

int main(void)
{
    /* Hardware board init */
    board_hardware_init();

    while(1)
    {
        send_data("Hello world ! \r\n");
    }

    return 0;
}