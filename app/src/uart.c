#include "uart.h"
#include "stm32f4xx_usart.h"
#include <stdint.h>
#include <string.h>


void send_data(char* msg)
{
    for(uint32_t i=0; i<strlen(msg); i++)
    {
        while(USART_GetFlagStatus(USART2, USART_FLAG_TXE) != SET);
        USART_SendData(USART2, msg[i]);
    }
}