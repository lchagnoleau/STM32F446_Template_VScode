#include <stdlib.h>
#include <stdbool.h>
#include "stm32f4xx.h"
#include "stm32f4xx_exti.h"
#include "board.h"
#include "uart.h"
#include "FreeRTOS.h"
#include "task.h"
#include "SEGGER_SYSVIEW_FreeRTOS.h"


TaskHandle_t xTaskLedHandle = NULL;

bool actual_bp_state = false;
bool actual_led_state = false;

void vTask_Led_handler(void *params);
void EXTI15_10_IRQHandler(void);
void button_hanlder(void);

int main(void)
{
    /* Enable DWT cycle for SystemView timestamp */
    DWT->CTRL |= (1 << 0);

    /* Hardware board init */
    board_hardware_init();

    /* Start recording of SystemView */
    SEGGER_SYSVIEW_Conf();
    SEGGER_SYSVIEW_Start();

    send_data("Hello world ! \r\n");

    while(1)
    {
        /* Create task */
        xTaskCreate(
            vTask_Led_handler,
            "Task-LED",
            configMINIMAL_STACK_SIZE,
            NULL,
            2,
            &xTaskLedHandle);

        /* Start scheduler */
        vTaskStartScheduler();
    }

    return 0;
}

void vTask_Led_handler(void *params)
{
	while(1)
	{
        if(actual_led_state != actual_bp_state)
        {
            actual_led_state = !actual_led_state;
            set_led(actual_led_state);
            SEGGER_SYSVIEW_Print(actual_led_state ? "led on" : "led off");
        }
        taskYIELD();
	}
}

void button_hanlder(void)
{
    actual_bp_state = !actual_bp_state;
    SEGGER_SYSVIEW_Print(actual_bp_state ? "pressed" : "not pressed");
}

void EXTI15_10_IRQHandler(void)
{
    /* SEGGER SysView trace */
    traceISR_ENTER();

    /* Clear Interupt pending flag */
    EXTI_ClearITPendingBit(EXTI_Line13);

    /* Call Handler */
    button_hanlder();
}