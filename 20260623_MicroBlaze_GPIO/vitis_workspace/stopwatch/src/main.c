#include <stdint.h>
#include "sleep.h"
#include "xil_printf.h"
#include "HAL/GPIO/GPIO.h"


#define LED_LOW_GPIO 	GPIOC
#define LED_HIGH_GPIO 	GPIOD

void LED_Init()
{
	GPIO_SetMode(LED_LOW_GPIO, 0xff);
	GPIO_SetMode(LED_HIGH_GPIO, 0xff);
}

void LED_Port(uint16_t led)
{
	uint32_t ledTemp;

	ledTemp = led & 0x00ff;
	GPIO_WritePort(LED_LOW_GPIO, ledTemp);
	ledTemp = (led>>8) & 0x00ff;
	GPIO_WritePort(LED_HIGH_GPIO, ledTemp);
}

void LED_PinOn(uint16_t ledPin)
{
	uint16_t ledPinTemp;
	uint32_t ledPortState;

	ledPinTemp = 1 << ledPin;

	ledPortState = GPIO_ReadPort(LED_LOW_GPIO);
	ledPortState |= (ledPinTemp & 0x00ff);
	GPIO_WritePort(LED_LOW_GPIO, ledPortState);

	ledPortState = GPIO_ReadPort(LED_HIGH_GPIO);
	ledPortState |= ((ledPinTemp>>8) & 0x00ff);
	GPIO_WritePort(LED_HIGH_GPIO, ledPortState);
}

void LED_PinOff(uint16_t ledPin)
{
	uint16_t ledPinTemp;
	uint32_t ledPortState;

	ledPinTemp = 1 << ledPin;

	ledPortState = GPIO_ReadPort(LED_LOW_GPIO);
	ledPortState &= ~(ledPinTemp & 0x00ff);
	GPIO_WritePort(LED_LOW_GPIO, ledPortState);

	ledPortState = GPIO_ReadPort(LED_HIGH_GPIO);
	ledPortState &= ~((ledPinTemp>>8) & 0x00ff);
	GPIO_WritePort(LED_HIGH_GPIO, ledPortState);
}


void LED_Toggle(uint16_t ledPin)
{
	uint16_t ledPinTemp;
	uint32_t ledPortState;

	ledPinTemp = 1 << ledPin;

	ledPortState = GPIO_ReadPort(LED_LOW_GPIO);
	ledPortState ^= (ledPinTemp & 0x00ff);
	GPIO_WritePort(LED_LOW_GPIO, ledPortState);

	ledPortState = GPIO_ReadPort(LED_HIGH_GPIO);
	ledPortState ^= (ledPinTemp>>8 & 0xff00);
	GPIO_WritePort(LED_HIGH_GPIO, ledPortState);
}


int main()
{
    int counter = 0;

//    GPIO_SetMode(GPIOC, 0xff);
//    GPIO_SetMode(GPIOD, 0xff);
    LED_Init();

    while (1)
    {
        xil_printf("counter = %d\n", counter++);

//        GPIO_WritePin(GPIOC, GPIO_PIN_0, GPIO_SET);
//        GPIO_WritePin(GPIOD, GPIO_PIN_0, GPIO_SET);
        LED_Port(0xffff);
        usleep(100000);

//        GPIO_WritePin(GPIOC, GPIO_PIN_0, GPIO_RESET);
//        GPIO_WritePin(GPIOD, GPIO_PIN_0, GPIO_RESET);
        LED_Port(0x0000);
        usleep(100000);
    }

    return 0;
}







//GPIOC -> CR = 0xff; // output mode
//GPIOD -> CR = 0xff; // output mode


//#define GPIOA_CR  (*(uint32_t *)(GPIOA_BASEADDR + 0x00))
//#define GPIOA_IDR (*(uint32_t *)(GPIOA_BASEADDR + 0x04))
//#define GPIOA_ODR (*(uint32_t *)(GPIOA_BASEADDR + 0x08))
//
//#define GPIOB_CR  (*(uint32_t *)(GPIOB_BASEADDR + 0x00))
//#define GPIOB_IDR (*(uint32_t *)(GPIOB_BASEADDR + 0x04))
//#define GPIOB_ODR (*(uint32_t *)(GPIOB_BASEADDR + 0x08))
//
//#define GPIOC_CR  (*(uint32_t *)(GPIOC_BASEADDR + 0x00))
//#define GPIOC_IDR (*(uint32_t *)(GPIOC_BASEADDR + 0x04))
//#define GPIOC_ODR (*(uint32_t *)(GPIOC_BASEADDR + 0x08))
//
//#define GPIOD_CR  (*(uint32_t *)(GPIOD_BASEADDR + 0x00))
//#define GPIOD_IDR (*(uint32_t *)(GPIOD_BASEADDR + 0x04))
//#define GPIOD_ODR (*(uint32_t *)(GPIOD_BASEADDR + 0x08))


//    GPIOC_CR = 0xff;
//    GPIOD_CR = 0xff;

//        GPIOC_ODR = 0xff;
//        GPIOD_ODR = 0x00;
//        GPIOC -> ODR = 0xff; //led on
//        GPIOD -> ODR = 0xff; //led on
//        GPIO_WritePort(GPIOC,0xff);
//        GPIO_WritePort(GPIOD,0xff);

//        GPIOC_ODR = 0x00;
//        GPIOD_ODR = 0xff;
//        GPIOC -> ODR = 0x00; //led off
//        GPIOD -> ODR = 0x00; //led off
//        GPIO_WritePort(GPIOC,0x00);
//        GPIO_WritePort(GPIOD,0x00);
