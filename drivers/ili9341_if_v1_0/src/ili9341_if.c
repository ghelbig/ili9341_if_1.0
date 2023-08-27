// *
// *  ili9341_if.c
// *
// *    BSP routines for using the interface
// *
// *  25-Aug, 2023 - Gary Helbig
// *

/***************************** Include Files *******************************/
#include <stdbool.h>
#include "xil_types.h"
#include "ili9341_if.h"

/************************** Function Definitions ***************************/

//  ili9341_if_init
//  - Set up the pointers to the TFT register(s).
//
void ili9341_if_init(u32 BASEADDR) {
	tft_command = (u32 *)(BASEADDR + ILI9341_IF_S00_AXI_SLV_REG0_OFFSET);
	tft_data =    (u32 *)(BASEADDR + ILI9341_IF_S00_AXI_SLV_REG1_OFFSET);
	tft_reset =   (u32 *)(BASEADDR + ILI9341_IF_S00_AXI_SLV_REG2_OFFSET);
	tft_data16 =  (u16 *)(BASEADDR + ILI9341_IF_S00_AXI_SLV_REG3_OFFSET);
	tft_data32 =  (u32 *)(BASEADDR + ILI9341_IF_S00_AXI_SLV_REG3_OFFSET);
}

//  ili9341_tft_reset
//  - Assert or de-assert the TFT reset.
//
void ili9341_tft_reset(bool assert) {
	*tft_reset = (assert ? 0x00000001 : 0x00000000);
}

//  Writing to the TFT.  Use the names found in the GFX library.
//
void ili9341_writecommand8(u32 cmd) {
	*tft_command = cmd;
}

void ili9341_writedata8(u32 data) {
	*tft_data = data;
}

void ili9341_writedata16(u16 data) {
	*tft_data16 = data;
}

void ili9341_writedata32(u32 data) {
	*tft_data32 = data;
}
