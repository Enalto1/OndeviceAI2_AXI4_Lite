/*
 * StopWatch.c
 *
 *  Created on: 2026. 6. 24.
 *      Author: kccistc
 */

#include "StopWatch.h"

#define STOP_STATE_LED    5
#define CLEAR_STATE_LED   6
#define RUN_STATE_LED     7
#define STOP_STATE_MASK   (1 << STOP_STATE_LED)
#define CLEAR_STATE_MASK  (1 << CLEAR_STATE_LED)
#define RUN_STATE_MASK    (1 << RUN_STATE_LED)
#define STATE_LED_MASK    (STOP_STATE_MASK | CLEAR_STATE_MASK | RUN_STATE_MASK)
#define COUNT_PERIOD_MS   100
#define RUN_LED_PERIOD_MS 100

static void StopWatch_Clear(void);
static void StopWatch_ControlLed(void);
static void StopWatch_WriteStateLed(uint32_t stateMask);
static void StopWatch_RunLed(void);
static void StopWatch_StopLed(void);

stopWatch_e stopWatchState;
uint32_t counter;
uint32_t stopWatchLed;
int32_t stopWatchLedDir;

void StopWatch_Init(void)
{
	LED_Init();
	FND_Init();
	Button_Init();

	stopWatchState = STOP;
	counter = 0;
	stopWatchLed = 0x01;
	stopWatchLedDir = 1;

	LED_WritePort8(LED_LOW_GPIO, 0x00);
	StopWatch_WriteStateLed(STOP_STATE_MASK);
}

void StopWatch_Excute(void)
{
	StopWatch_ControlState();
	StopWatch_RunTime();
	FND_SetNum(counter);
	StopWatch_ControlLed();
}

void StopWatch_ControlState(void)
{
	button_status_e clearAct = Button_GetState(&hbtnClear);
	button_status_e runStopAct = Button_GetState(&hbtnRunStop);

	if(clearAct == ACT_PUSHED) {
		StopWatch_Clear();
		return;
	}

	if(runStopAct == ACT_PUSHED) {
		if(stopWatchState == RUN) {
			stopWatchState = STOP;
		}
		else {
			stopWatchState = RUN;
		}
	}
}

void StopWatch_RunTime(void)
{
	static uint32_t prevTime = 0;
	uint32_t curTime = millis();

	if(stopWatchState != RUN) {
		prevTime = curTime;
		return;
	}

	if(curTime - prevTime < COUNT_PERIOD_MS) return;
	prevTime = curTime;

	counter++;
}

static void StopWatch_Clear(void)
{
	stopWatchState = STOP;
	counter = 0;
	stopWatchLed = 0x01;
	stopWatchLedDir = 1;
	LED_WritePort8(LED_LOW_GPIO, 0x00);
}

static void StopWatch_ControlLed(void)
{
	if(GPIO_ReadPin(GPIOB, GPIO_PIN_5)) {
		StopWatch_WriteStateLed(CLEAR_STATE_MASK);
		LED_WritePort8(LED_LOW_GPIO, 0x00);
		return;
	}

	switch(stopWatchState) {
	case RUN:
		StopWatch_RunLed();
		break;
	case STOP:
	default:
		StopWatch_StopLed();
		break;
	}
}

static void StopWatch_WriteStateLed(uint32_t stateMask)
{
	LED_WritePort8(LED_HI_GPIO, stateMask & STATE_LED_MASK);
}

static void StopWatch_RunLed(void)
{
	static uint32_t prevTime = 0;
	uint32_t curTime = millis();

	StopWatch_WriteStateLed(RUN_STATE_MASK);
	LED_WritePort8(LED_LOW_GPIO, stopWatchLed);

	if(curTime - prevTime < RUN_LED_PERIOD_MS) return;
	prevTime = curTime;

	if(stopWatchLed == 0x80) {
		stopWatchLedDir = -1;
	}
	else if(stopWatchLed == 0x01) {
		stopWatchLedDir = 1;
	}

	if(stopWatchLedDir > 0) {
		stopWatchLed <<= 1;
	}
	else {
		stopWatchLed >>= 1;
	}
}

static void StopWatch_StopLed(void)
{
	StopWatch_WriteStateLed(STOP_STATE_MASK);
	LED_WritePort8(LED_LOW_GPIO, 0x00);
}
