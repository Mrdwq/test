// ==============================================================
// Vivado(TM) HLS - High-Level Synthesis from C, C++ and SystemC v2019.2 (64-bit)
// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// ==============================================================
/***************************** Include Files *********************************/
#include "xmin_max_shmem.h"

/************************** Function Implementation *************************/
#ifndef __linux__
int XMin_max_shmem_CfgInitialize(XMin_max_shmem *InstancePtr, XMin_max_shmem_Config *ConfigPtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(ConfigPtr != NULL);

    InstancePtr->Axilites_BaseAddress = ConfigPtr->Axilites_BaseAddress;
    InstancePtr->IsReady = XIL_COMPONENT_IS_READY;

    return XST_SUCCESS;
}
#endif

void XMin_max_shmem_Set_io_frame(XMin_max_shmem *InstancePtr, u32 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XMin_max_shmem_WriteReg(InstancePtr->Axilites_BaseAddress, XMIN_MAX_SHMEM_AXILITES_ADDR_IO_FRAME_DATA, Data);
}

u32 XMin_max_shmem_Get_io_frame(XMin_max_shmem *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XMin_max_shmem_ReadReg(InstancePtr->Axilites_BaseAddress, XMIN_MAX_SHMEM_AXILITES_ADDR_IO_FRAME_DATA);
    return Data;
}

