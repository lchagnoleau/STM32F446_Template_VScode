#include "board.h"
#include "stm32f4xx_rcc.h"
#include "stm32f4xx_gpio.h"
#include "stm32f4xx_usart.h"
#include <string.h>

static void board_uart_init(void);

void board_hardware_init(void)
{
    /* Set default RCC clock -> 16MHz */
    RCC_DeInit();
    SystemCoreClockUpdate();

    /* Init UART */
    board_uart_init();
}

static void board_uart_init(void)
{
    /* USART2 (PA2 & PA3)
    *
    * PA2 -> TX (AF7)
    * PA3 -> RX (AF7)
    * 
    */

    /* Init struct */
    GPIO_InitTypeDef gpio_init_struct;
    USART_InitTypeDef uart2_init_struct;
    USART_ClockInitTypeDef uart2_init_clock_struct;

    memset(&gpio_init_struct, 0, sizeof(gpio_init_struct));
    memset(&uart2_init_struct, 0, sizeof(uart2_init_struct));
    memset(&uart2_init_clock_struct, 0, sizeof(uart2_init_clock_struct));

    GPIO_StructInit(&gpio_init_struct);
    USART_StructInit(&uart2_init_struct);
    USART_ClockStructInit(&uart2_init_clock_struct);

    /* Start clock APB1 (UART2) and AHB1 (GPIOA) */
    RCC_AHB1PeriphClockCmd(RCC_AHB1Periph_GPIOA, ENABLE);
    RCC_APB1PeriphClockCmd(RCC_APB1Periph_USART2, ENABLE);

    /* Init GPIO PA2 & PA3 */
    gpio_init_struct.GPIO_Pin = GPIO_Pin_2 | GPIO_Pin_3;
    gpio_init_struct.GPIO_Mode = GPIO_Mode_AF;
    GPIO_Init(GPIOA, &gpio_init_struct);

    GPIO_PinAFConfig(GPIOA, GPIO_PinSource2, GPIO_AF_USART2);
    GPIO_PinAFConfig(GPIOA, GPIO_PinSource3, GPIO_AF_USART2);

    /* Init UART 2 */
    uart2_init_struct.USART_BaudRate = 115200;
    USART_Init(USART2, &uart2_init_struct);

    USART_ClockInit(USART2, &uart2_init_clock_struct);

    USART_Cmd(USART2, ENABLE);
}