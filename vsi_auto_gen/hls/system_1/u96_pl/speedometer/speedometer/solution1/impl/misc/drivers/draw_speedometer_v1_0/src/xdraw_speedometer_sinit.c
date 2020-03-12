// ==============================================================
// Vivado(TM) HLS - High-Level Synthesis from C, C++ and SystemC v2019.2 (64-bit)
// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// ==============================================================
#ifndef __linux__

#include "xstatus.h"
#include "xparameters.h"
#include "xdraw_speedometer.h"

extern XDraw_speedometer_Config XDraw_speedometer_ConfigTable[];

XDraw_speedometer_Config *XDraw_speedometer_LookupConfig(u16 DeviceId) {
	XDraw_speedometer_Config *ConfigPtr = NULL;

	int Index;

	for (Index = 0; Index < XPAR_XDRAW_SPEEDOMETER_NUM_INSTANCES; Index++) {
		if (XDraw_speedometer_ConfigTable[Index].DeviceId == DeviceId) {
			ConfigPtr = &XDraw_speedometer_ConfigTable[Index];
			break;
		}
	}

	return ConfigPtr;
}

int XDraw_speedometer_Initialize(XDraw_speedometer *InstancePtr, u16 DeviceId) {
	XDraw_speedometer_Config *ConfigPtr;

	Xil_AssertNonvoid(InstancePtr != NULL);

	ConfigPtr = XDraw_speedometer_LookupConfig(DeviceId);
	if (ConfigPtr == NULL) {
		InstancePtr->IsReady = 0;
		return (XST_DEVICE_NOT_FOUND);
	}

	return XDraw_speedometer_CfgInitialize(InstancePtr, ConfigPtr);
}

#endif

