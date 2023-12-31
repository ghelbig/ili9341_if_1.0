// *
// * ili9341_if.h
// *
// *    BSP routines for using the interface
// *
// *  25-Aug, 2023 - Gary Helbig
// *

#ifndef ILI9341_IF_H
#define ILI9341_IF_H


/****************** Include Files ********************/
#include "xil_types.h"
#include "xstatus.h"

#define ILI9341_IF_S00_AXI_SLV_REG0_OFFSET 0
#define ILI9341_IF_S00_AXI_SLV_REG1_OFFSET 4
#define ILI9341_IF_S00_AXI_SLV_REG2_OFFSET 8
#define ILI9341_IF_S00_AXI_SLV_REG3_OFFSET 12

volatile u32 *tft_command;
volatile u32 *tft_data;
volatile u32 *tft_reset;
volatile u16 *tft_data16;
volatile u32 *tft_data32;

/************************** Function Definitions ***************************/

//  ili9341_if_init
//  - Set up the pointers (defined above)
//    to the tft register(s).
//
void ili9341_if_init(u32 BASEADDR);

//  ili9341_tft_reset
//  - Assert or de-assert the TFT reset.
//
void ili9341_tft_reset(_Bool assert);

//  Writing to the TFT.
//  - Use the names found in the GFX library.
//
void ili9341_writecommand8(u32 cmd);
void ili9341_writedata8(u32 data);
void ili9341_writedata16(u16 data);
void ili9341_writedata32(u32 data);

/**************************** Type Definitions *****************************/
/**
 *
 * Write a value to a ILI9341_IF register. A 32 bit write is performed.
 * If the component is implemented in a smaller width, only the least
 * significant data is written.
 *
 * @param   BaseAddress is the base address of the ILI9341_IFdevice.
 * @param   RegOffset is the register offset from the base to write to.
 * @param   Data is the data written to the register.
 *
 * @return  None.
 *
 * @note
 * C-style signature:
 * 	void ILI9341_IF_mWriteReg(u32 BaseAddress, unsigned RegOffset, u32 Data)
 *
 */
#define ILI9341_IF_mWriteReg(BaseAddress, RegOffset, Data) \
  	Xil_Out32((BaseAddress) + (RegOffset), (u32)(Data))

/**
 *
 * Read a value from a ILI9341_IF register. A 32 bit read is performed.
 * If the component is implemented in a smaller width, only the least
 * significant data is read from the register. The most significant data
 * will be read as 0.
 *
 * @param   BaseAddress is the base address of the ILI9341_IF device.
 * @param   RegOffset is the register offset from the base to write to.
 *
 * @return  Data is the data from the register.
 *
 * @note
 * C-style signature:
 * 	u32 ILI9341_IF_mReadReg(u32 BaseAddress, unsigned RegOffset)
 *
 */
#define ILI9341_IF_mReadReg(BaseAddress, RegOffset) \
    Xil_In32((BaseAddress) + (RegOffset))

/************************** Function Prototypes ****************************/
/**
 *
 * Run a self-test on the driver/device. Note this may be a destructive test if
 * resets of the device are performed.
 *
 * If the hardware system is not built correctly, this function may never
 * return to the caller.
 *
 * @param   baseaddr_p is the base address of the ILI9341_IF instance to be worked on.
 *
 * @return
 *
 *    - XST_SUCCESS   if all self-test code passed
 *    - XST_FAILURE   if any self-test code failed
 *
 * @note    Caching must be turned off for this function to work.
 * @note    Self test may fail if data memory and device are not on the same bus.
 *
 */
XStatus ILI9341_IF_Reg_SelfTest(void * baseaddr_p);

#endif // ILI9341_IF_H
