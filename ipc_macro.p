// ipc_macro.p
//  standardize ipc operations .. simplify?
//  operations for 4 byte words only
//  assumed that ipc is the 12K shared space defined by SHARED12K_ADDRESS
//
//  need registers defined as work1 and work2 .. ephemeral
//  need register named IPCRAM initialized to shared 12k sram
//

.macro  ipcput
.mparam src, pointer
	MOV work2, src
	MOV work3, pointer
	SBBO work2, IPCRAM, work3, 4
.endm

.macro  ipcfetch
.mparam dst, pointer
	MOV work2, pointer 
	LBBO dst, IPCRAM, work2, 4
.endm

.macro c24put
.mparam src, pointer
.mparam bites = 4
	MOV work2, src
	MOV work3, pointer
	SBCO work2, c24, work3, bites
.endm

.macro c24fetch
.mparam dst, pointer
.mparam bites = 4
	MOV work2, pointer 
	LBCO dst, c24, work2, bites
.endm

.macro c25put
.mparam src, pointer
.mparam bites = 4
	MOV work2, src
	MOV work3, pointer
	SBCO work2, c25, work3, bites
.endm

.macro c25fetch
.mparam dst, pointer
.mparam bites = 4
	MOV work2, pointer 
	LBCO dst, c25, work2, bites
.endm
