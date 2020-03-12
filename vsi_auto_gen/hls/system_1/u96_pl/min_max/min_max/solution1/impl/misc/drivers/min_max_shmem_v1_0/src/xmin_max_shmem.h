// ==============================================================
// Vivado(TM) HLS - High-Level Synthesis from C, C++ and SystemC v2019.2 (64-bit)
// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// ==============================================================
#ifndef XMIN_MAX_SHMEM_H
#define XMIN_MAX_SHMEM_H

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
#include "xmin_max_shmem_hw.h"

/**************************** Type Definitions ******************************/
#ifdef __linux__
typedef uint8_t u8;
typedef uint16_t u16;
typedef uint32_t u32;
#else
typedef struct {
    u16 DeviceId;
    u32 Axilites_BaseAddress;
} XMin_max_shmem_Config;
#endif

typedef struct {
    u32 Axilites_BaseAddress;
    u32 IsReady;
} XMin_max_shmem;

/***************** Macros (Inline Functions) Definitions *********************/
#ifndef __linux__
#define XMin_max_shmem_WriteReg(BaseAddress, RegOffset, Data) \
    Xil_Out32((BaseAddress) + (RegOffset), (u32)(Data))
#define XMin_max_shmem_ReadReg(BaseAddress, RegOffset) \
    Xil_In32((BaseAddress) + (RegOffset))
#else
#define XMin_max_shmem_WriteReg(BaseAddress, RegOffset, Data) \
    *(volatile u32*)((BaseAddress) + (RegOffset)) = (u32)(Data)
#define XMin_max_shmem_ReadReg(BaseAddress, RegOffset) \
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
int XMin_max_shmem_Initialize(XMin_max_shmem *InstancePtr, u16 DeviceId);
XMin_max_shmem_Config* XMin_max_shmem_LookupConfig(u16 DeviceId);
int XMin_max_shmem_CfgInitialize(XMin_max_shmem *InstancePtr, XMin_max_shmem_Config *ConfigPtr);
#else
int XMin_max_shmem_Initialize(XMin_max_shmem *InstancePtr, const char* InstanceName);
int XMin_max_shmem_Release(XMin_max_shmem *InstancePtr);
#endif


void XMin_max_shmem_Set_io_frame(XMin_max_shmem *InstancePtr, u32 Data);
u32 XMin_max_shmem_Get_io_frame(XMin_max_shmem *InstancePtr);

#ifdef __cplusplus
}
#endif

#endif
