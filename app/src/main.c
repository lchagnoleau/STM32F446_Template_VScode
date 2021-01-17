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

void vTask_Led_handler(void *params);
void EXTI15_10_IRQHandler(void);
void rtos_delay(uint32_t delay_in_ms);

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
        xTaskNotifyWait(0, 0, NULL, portMAX_DELAY);

        toggle_led();
        rtos_delay(100);
	}
}

void rtos_delay(uint32_t delay_in_ms)
{
    uint32_t current_delay = xTaskGetTickCount();
    while(xTaskGetTickCount() < current_delay + pdMS_TO_TICKS(delay_in_ms));
}

void EXTI15_10_IRQHandler(void)
{
    /* SEGGER SysView trace */
    traceISR_ENTER();

    /* Clear Interupt pending flag */
    EXTI_ClearITPendingBit(EXTI_Line13);

    /* Notify Task */
    xTaskNotifyFromISR(xTaskLedHandle, 0, eNoAction, NULL);
}