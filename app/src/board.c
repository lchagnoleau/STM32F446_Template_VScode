#include "board.h"
#include "stm32f4xx_rcc.h"
#include "stm32f4xx_gpio.h"
#include "stm32f4xx_usart.h"
#include <string.h>

static void board_uart_init(void);
static void led_init(void);
static void button_init(void);

void board_hardware_init(void)
{
    /* Set default RCC clock -> 16MHz */
    RCC_DeInit();
    SystemCoreClockUpdate();

    /* Init UART */
    board_uart_init();

    /* Init Led */
    led_init();

    /* Init button */
    button_init();
}

bool is_button_pressed(void)
{
    return (bool) !GPIO_ReadInputDataBit(GPIOC, GPIO_Pin_13);
}

void set_led(bool value)
{
    BitAction v = (value) ? Bit_SET : Bit_RESET;
    GPIO_WriteBit(GPIOA, GPIO_Pin_5, v);
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

static void led_init(void)
{
    /* GREEN Led to PA5
    * 
    * the I/O is HIGH, the LED is on
    * the I/O is LOW,  the LED is off
    *
    */

    /* Init struct */
    GPIO_InitTypeDef gpio_init_struct;

    memset(&gpio_init_struct, 0, sizeof(gpio_init_struct));

    GPIO_StructInit(&gpio_init_struct);

    /* Start clock APB1 (GPIOA) */
    RCC_AHB1PeriphClockCmd(RCC_AHB1Periph_GPIOA, ENABLE);

    /* Init GPIO PA5 */
    gpio_init_struct.GPIO_Pin = GPIO_Pin_5;
    gpio_init_struct.GPIO_Mode = GPIO_Mode_OUT;
    GPIO_Init(GPIOA, &gpio_init_struct);

    /* Set led to 0 */
    set_led(false);
}

static void button_init(void)
{
    /* B1 to PC13 */

    /* Init struct */
    GPIO_InitTypeDef gpio_init_struct;

    memset(&gpio_init_struct, 0, sizeof(gpio_init_struct));

    GPIO_StructInit(&gpio_init_struct);

    /* Start clock APB1 (GPIOC) */
    RCC_AHB1PeriphClockCmd(RCC_AHB1Periph_GPIOC, ENABLE);

    /* Init GPIO PA5 */
    gpio_init_struct.GPIO_Pin = GPIO_Pin_13;
    gpio_init_struct.GPIO_Mode = GPIO_Mode_IN;
    GPIO_Init(GPIOC, &gpio_init_struct);
}