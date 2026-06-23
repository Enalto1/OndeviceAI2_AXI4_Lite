/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h"
#include <stdio.h>
#include "sleep.h"

#define GPIOA_BASEADDR XPAR_GPIO_0_S00_AXI_BASEADDR
#define GPIOB_BASEADDR XPAR_GPIO_1_S00_AXI_BASEADDR

#define GPIOA_CR (*(volatile uint32_t *)(GPIOA_BASEADDR + 0x00))
#define GPIOA_IDR (*(volatile uint32_t *)(GPIOA_BASEADDR + 0x04))
#define GPIOA_ODR (*(volatile uint32_t *)(GPIOA_BASEADDR + 0x08))


#define GPIOB_CR (*(volatile uint32_t *)(GPIOB_BASEADDR + 0x00))
#define GPIOB_IDR (*(volatile uint32_t *)(GPIOB_BASEADDR + 0x04))
#define GPIOB_ODR (*(volatile uint32_t *)(GPIOB_BASEADDR + 0x08))


int main()
{
    GPIOA_CR = 0xff;
    GPIOB_CR = 0xff;
    init_platform();

    print("Hello World\n\r");
    print("Successfully ran Hello World application");

	GPIOA_ODR = 0x01;
	usleep(200000);

    while(1){
    	for(int i = 0; i < 7; i++){
    		GPIOA_ODR = 0x02<<i;
    		usleep(200000);
    	}
    	GPIOA_ODR = 0;
    	for(int i = 0; i < 8; i++){
    		GPIOB_ODR = 1<<i;
    		usleep(200000);
    	}
    	for(int i = 0; i < 7; i++){
    		GPIOB_ODR = 0x40>>i;
    		usleep(200000);
    	}
    	GPIOB_ODR = 0;
    	for(int i = 0; i < 8; i++){
    		GPIOA_ODR = 0x80>>i;
    		usleep(200000);
    	}
    }

    cleanup_platform();
    return 0;
}
