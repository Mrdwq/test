// ==============================================================
// Vivado(TM) HLS - High-Level Synthesis from C, C++ and SystemC v2019.2 (64-bit)
// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// ==============================================================
#ifndef XDRAW_SPEEDOMETER_H
#define XDRAW_SPEEDOMETER_H

#ifdef __cplusplus
extern "C" {
#endif

/***************************** Include Files *********************************/
#ifndef __linux__
#include "xil_types.h"
#include "xil_assert.h"
#include "xstatus.h"
#include "xil_io.h"
#else
#include <stdint.h>
#include <assert.h>
#include <dirent.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>
#include <stddef.h>
#endif
#include "xdraw_speedometer_hw.h"

/**************************** Type Definitions ******************************/
#ifdef __linux__
typedef uint8_t u8;
typedef uint16_t u16;
typedef uint32_t u32;
#else
typedef struct {
    u16 DeviceId;
    u32 Axilites_BaseAddress;
} XDraw_speedometer_Config;
#endif

typedef struct {
    u32 Axilites_BaseAddress;
    u32 IsReady;
} XDraw_speedometer;

/***************** Macros (Inline Functions) Definitions *********************/
#ifndef __linux__
#define XDraw_speedometer_WriteReg(BaseAddress, RegOffset, Data) \
    Xil_Out32((BaseAddress) + (RegOffset), (u32)(Data))
#define XDraw_speedometer_ReadReg(BaseAddress, RegOffset) \
    Xil_In32((BaseAddress) + (RegOffset))
#else
#define XDraw_speedometer_WriteReg(BaseAddress, RegOffset, Data) \
    *(volatile u32*)((BaseAddress) + (RegOffset)) = (u32)(Data)
#define XDraw_speedometer_ReadReg(BaseAddress, RegOffset) \
    *(volatile u32*)((BaseAddress) + (RegOffset))

#define Xil_AssertVoid(expr)    assert(expr)
#define Xil_AssertNonvoid(expr) assert(expr)

#define XST_SUCCESS             0
#define XST_DEVICE_NOT_FOUND    2
#define XST_OPEN_DEVICE_FAILED  3
#define XIL_COMPONENT_IS_READY  1
#endif

/************************** Function Prototypes *****************************/
#ifndef __linux__
int XDraw_speedometer_Initialize(XDraw_speedometer *InstancePtr, u16 DeviceId);
XDraw_speedometer_Config* XDraw_speedometer_LookupConfig(u16 DeviceId);
int XDraw_speedometer_CfgInitialize(XDraw_speedometer *InstancePtr, XDraw_speedometer_Config *ConfigPtr);
#else
int XDraw_speedometer_Initialize(XDraw_speedometer *InstancePtr, const char* InstanceName);
int XDraw_speedometer_Release(XDraw_speedometer *InstancePtr);
#endif


void XDraw_speedometer_Set_io_frame(XDraw_speedometer *InstancePtr, u32 Data);
u32 XDraw_speedometer_Get_io_frame(XDraw_speedometer *InstancePtr);

#ifdef __cplusplus
}
#endif

#endif
