// ==============================================================
// Vivado(TM) HLS - High-Level Synthesis from C, C++ and SystemC v2019.2 (64-bit)
// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// ==============================================================
/***************************** Include Files *********************************/
#include "xdraw_speedometer.h"

/************************** Function Implementation *************************/
#ifndef __linux__
int XDraw_speedometer_CfgInitialize(XDraw_speedometer *InstancePtr, XDraw_speedometer_Config *ConfigPtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(ConfigPtr != NULL);

    InstancePtr->Axilites_BaseAddress = ConfigPtr->Axilites_BaseAddress;
    InstancePtr->IsReady = XIL_COMPONENT_IS_READY;

    return XST_SUCCESS;
}
#endif

void XDraw_speedometer_Set_io_frame(XDraw_speedometer *InstancePtr, u32 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XDraw_speedometer_WriteReg(InstancePtr->Axilites_BaseAddress, XDRAW_SPEEDOMETER_AXILITES_ADDR_IO_FRAME_DATA, Data);
}

u32 XDraw_speedometer_Get_io_frame(XDraw_speedometer *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XDraw_speedometer_ReadReg(InstancePtr->Axilites_BaseAddress, XDRAW_SPEEDOMETER_AXILITES_ADDR_IO_FRAME_DATA);
    return Data;
}

