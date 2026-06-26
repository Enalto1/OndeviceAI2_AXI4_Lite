/*
 * main.c
 *
 *  Created on: 2026. 6. 25.
 *      Author: kccistc
 */

#include "xil_printf.h"
#include "common/delay/delay.h"
#include "ap/StopWatch.h"

int main() {

	//int counter = 0;
	//uint16_t ledState = 1;
	StopWatch_Init();

	//uint32_t curTime, prevTime;

	while (1) {
		StopWatch_Excute();

		// polling service routine
		FND_Excute();
		incTick();
		delay_ms(1);
	}
	return 0;
}
