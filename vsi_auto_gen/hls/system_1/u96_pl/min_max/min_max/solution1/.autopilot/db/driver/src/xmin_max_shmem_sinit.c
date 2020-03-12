// ==============================================================
// Vivado(TM) HLS - High-Level Synthesis from C, C++ and SystemC v2019.2 (64-bit)
// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// ==============================================================
#ifndef __linux__

#include "xstatus.h"
#include "xparameters.h"
#include "xmin_max_shmem.h"

extern XMin_max_shmem_Config XMin_max_shmem_ConfigTable[];

XMin_max_shmem_Config *XMin_max_shmem_LookupConfig(u16 DeviceId) {
	XMin_max_shmem_Config *ConfigPtr = NULL;

	int Index;

	for (Index = 0; Index < XPAR_XMIN_MAX_SHMEM_NUM_INSTANCES; Index++) {
		if (XMin_max_shmem_ConfigTable[Index].DeviceId == DeviceId) {
			ConfigPtr = &XMin_max_shmem_ConfigTable[Index];
			break;
		}
	}

	return ConfigPtr;
}

int XMin_max_shmem_Initialize(XMin_max_shmem *InstancePtr, u16 DeviceId) {
	XMin_max_shmem_Config *ConfigPtr;

	Xil_AssertNonvoid(InstancePtr != NULL);

	ConfigPtr = XMin_max_shmem_LookupConfig(DeviceId);
	if (ConfigPtr == NULL) {
		InstancePtr->IsReady = 0;
		return (XST_DEVICE_NOT_FOUND);
	}

	return XMin_max_shmem_CfgInitialize(InstancePtr, ConfigPtr);
}

#endif

