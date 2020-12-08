#include <stdlib.h>
#include <stdbool.h>
#include "stm32f4xx.h"
#include "board.h"
#include "uart.h"
#include "FreeRTOS.h"
#include "task.h"
#include "SEGGER_SYSVIEW_FreeRTOS.h"

/* MACROS */
#define AVAILABLE 1
#define NON_AVAILABLE 0


TaskHandle_t xTaskHande1 = NULL;
TaskHandle_t xTaskHande2 = NULL;

bool actual_bp_state = false;
bool actual_led_state = false;

void vTask1_handler(void *params);
void vTask2_handler(void *params);

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
        /* Create 2 tasks */
        xTaskCreate(
            vTask1_handler,
            "Task-1",
            configMINIMAL_STACK_SIZE,
            NULL,
            2,
            &xTaskHande1);
        xTaskCreate(
            vTask2_handler,
            "Task-2",
            configMINIMAL_STACK_SIZE,
            NULL,
            2,
            &xTaskHande2);

        /* Start scheduler */
        vTaskStartScheduler();
    }

    return 0;
}

void vTask1_handler(void *params)
{
	while(1)
	{
        if(actual_bp_state != is_button_pressed())
        {
            actual_bp_state = !actual_bp_state;
            SEGGER_SYSVIEW_Print(actual_bp_state ? "pressed" : "not pressed");
        }
        taskYIELD();
	}
}

void vTask2_handler(void *params)
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