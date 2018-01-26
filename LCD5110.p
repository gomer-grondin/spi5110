// Define the entry point of the program
.origin 0
.entrypoint START

#include "gpio.h"
#include "pru.h"
#include "ipc_p.h"

#define IPCRAM        r25  //  SHARED 12k sram
#define DELAY         r20  //  
#define work1         r1   //  dont use, for library
#define work2         r2   //  dont use, for library
#define work3         r3   //  dont use, for library
#define stackptr      r4   //

#define STACKBOTTOM            0x2000      // bottom of data space

#include "stack_macro.p"
#include "ipc_macro.p"

START:
	MOV IPCRAM, SHARED12K_ADDRESS
	ipcfetch r0, PANIC
	QBNE START, r0, CALM  // wait for C program to initialize memory

	JAL r30.w0, INIT_INTC
	JAL r30.w0, OUTPUT_PINS

	MOV stackptr, STACKBOTTOM

	MOV DELAY, 20000  // hack just for initial display reset

        JAL r30.w0, RESET_LOW
        JAL r30.w0, SS_HI
	JAL r30.w0, CLOCK_DELAY
        JAL r30.w0, RESET_HI
	
	ipcfetch DELAY, IPC_CLOCK_DELAY

LCD5110_INIT:	
	ipcfetch r18, INPUT_READY_FLAG
	QBNE LCD5110_INIT, r18, INPUT_INIT
	MOV r6, LCD5110_INIT0
        JAL r30.w0, WRITE_BUFFER
	JMP RESETINPUT
	
CLOCK_DELAY:
	MOV r11, DELAY
CLOCK_DELAY_:
	SUB r11, r11, 1
	QBLT CLOCK_DELAY_, r11, 1
	RET
	
RESETINPUT:
	ipcput NO_INPUT, INPUT_READY_FLAG
        JAL r30.w0, SS_HI
        JAL r30.w0, MOSI_LOW
	JAL r30.w0, SPI_CLOCK_LOW
	JAL r30.w0, DC_COMMAND
	
CHECK4INPUT:
	ipcfetch r0, PANIC
	QBEQ FINIS, r0, DISTRAUGHT 
	ipcfetch r0, INPUT_READY_FLAG
	QBNE CHECK4INPUT, r0, INPUT_READY
	MOV r6, XMIT_BUFFER
        JAL r30.w0, WRITE_BUFFER
	JMP RESETINPUT

WRITE_BUFFER:
	mypush r30, stackptr
WRITE_BUFFER_:
	ipcfetch r0, PANIC
	QBEQ FINIS, r0, DISTRAUGHT 
	ipcfetch r7, r6    // r7 has xmit word   (9 bit)
	QBEQ WRITE_BUFFER_RET, r7, 0
        JAL r30.w0, XMIT_BYTE
	ADD r6, r6, 4
	JMP WRITE_BUFFER_
WRITE_BUFFER_RET:
	mypop r30, stackptr
	RET

FINIS:
	ipcput HALTED, PANIC 
	HALT

XMIT_BYTE:
	mypush r30, stackptr
	JAL r30.w0, DC_COMMAND
        JAL r30.w0, SS_LOW
	MOV r15, 256
	AND r8, r7, r15    // r8 contains C/D flag
	MOV r9, 128
XMIT_BYTE_:
	AND r10, r9, r7    // r10 has xmit bit
	JAL r30.w0, XMIT_BIT
	LSR r9, r9, 1
	QBLT XMIT_BYTE_, r9, 0
	JAL r30.w0, BYTE_BOUNDARY
	mypop r30, stackptr
	RET

XMIT_BIT:
	mypush r30, stackptr
	QBEQ XMIT_BIT_LOW, r10, 0
	JAL r30.w0, MOSI_HI
	JMP XMIT_BIT_
XMIT_BIT_LOW:
	JAL r30.w0, MOSI_LOW
XMIT_BIT_:
	QBLT XMIT_BIT__, r9, 1  // r9 has bit position
	QBEQ COMMAND, r8, 0
	JMP DATA
COMMAND:
	JAL r30.w0, DC_COMMAND
	JMP XMIT_BIT__
DATA:
	JAL r30.w0, DC_DATA
XMIT_BIT__:
	JAL r30.w0, BIT_BOUNDARY
	mypop r30, stackptr
	RET

BIT_BOUNDARY:
	mypush r30, stackptr
	JAL r30.w0, SPI_CLOCK_HI
	JAL r30.w0, CLOCK_DELAY
	JAL r30.w0, MOSI_LOW
	JAL r30.w0, DC_COMMAND
	JAL r30.w0, SPI_CLOCK_LOW
	JAL r30.w0, CLOCK_DELAY
	mypop r30, stackptr
	RET

BYTE_BOUNDARY:
	mypush r30, stackptr
	JAL r30.w0, SPI_CLOCK_LOW
	JAL r30.w0, MOSI_LOW
        JAL r30.w0, SS_HI
	JAL r30.w0, DC_COMMAND
	JAL r30.w0, CLOCK_DELAY
	mypop r30, stackptr
	RET

INIT_INTC:
	// Clear the STANDBY_INIT bit in the SYSCFG register
	// otherwise the PRU will not be able to write outside the PRU memory space
	// and to the Beaglebone pins
	LBCO r10, C4, 4, 4
	CLR r10, r10, 4
	SBCO r10, C4, 4, 4
	
	// Make constant 24 (c24) point to the beginning of PRU0 data ram
	MOV r10, 0x00000000
	MOV r11, 0x22020
	SBBO r10, r11, 0, 4
	RET

#include "gpio_code.p"

