#include "xil_printf.h"
#include "common/delay/delay.h"
#include "ap/StopWatch.h"
#include "common/interrupt/interrupt.h"
#include "HAL/TMR/TMR.h"
#include "HAL/UART/UART.h"
#include "driver/Button/Button.h"

int main() {

	//int counter = 0;
	//uint16_t ledState = 1;
	TMR_SetPSC(TMR0, 100-1);
	TMR_SetARR(TMR0, 1000-1); //1kHz 속도로 인터럽트 걸린다.
	TMR_StartInterrupt(TMR0);
	TMR_StartTimer(TMR0);

	UART_StartInterrupt(UART0);

	StopWatch_Init();
	SetupInterrupSystem();

	//uint32_t curTime, prevTime;
	//uint32_t prevTime = 0;

	while (1) {
		StopWatch_Excute();

		if(Button_GetState(&hbtnLeft) == ACT_RELEASED){
			UART_Transmit(UART0, 'r');
		}
		if(Button_GetState(&hbtnRight) == ACT_RELEASED){
			UART_Transmit(UART0, 'c');
		}
//		UART_Transmit(UART0, 'a');
//
//		if(UART_Receive(UART0) == 'a')
//			LED_PinToggle(3);
//
//		delay_ms(200);
//
//		if(millis() - prevTime > 1000){
//			prevTime = millis();
//			//LED_PinOn(2);
//			LED_PinToggle(2);
//		}



		// ********polling service routine ***********************/
		//FND_Excute();
		//incTick();
		//delay_ms(1);
	}
	return 0;
}

/*if(millis() - prevTime > 1000){
	prevTime = millis();
	//LED_PinOn(2);
	LED_PinToggle(2);



}*/
