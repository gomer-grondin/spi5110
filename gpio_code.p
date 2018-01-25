// gpio code


//  macro mypin
//  needs work1 and work2 registers (ephemeral)
//

.macro  mypin
.mparam mode, bitmap
        MOV work1, mode
        MOV work2, bitmap
        SBBO work2, work1, 0, 4
.endm

OUTPUT_PINS:
	MOV work1, GPIO0_OE
        LBBO work2, work1, 0, 4
        CLR work2, P8_13                 // DC
        CLR work2, P8_14                 // MOSI
        CLR work2, P8_17                 // 
        CLR work2, P8_19		 // SS
        SBBO work2, work1, 0, 4
        
	MOV work1, GPIO1_OE
        LBBO work2, work1, 0, 4
        SET work2, P8_11                 // 
        CLR work2, P8_12                 // reset
        CLR work2, P8_15                 // 
        CLR work2, P8_16                 // spi clock
        CLR work2, P9_14                 // 
        SET work2, P9_15                 //
        CLR work2, P9_16                 // 
        CLR work2, P9_23                 //
        SBBO work2, work1, 0, 4
        RET

MOSI_HI:
	mypin GPIO0_hi, P8_14_bitmap
	RET

MOSI_LOW:
	mypin GPIO0_low, P8_14_bitmap
	RET

RESET_HI:
	mypin GPIO1_hi, P8_12_bitmap
	RET

RESET_LOW:
	mypin GPIO1_low, P8_12_bitmap
	RET

DC_DATA:
	mypin GPIO0_hi, P8_13_bitmap
	RET

DC_COMMAND:
	mypin GPIO0_low, P8_13_bitmap
	RET

SS_HI:
	mypin GPIO0_hi, P8_19_bitmap
	RET

SS_LOW:
	mypin GPIO0_low, P8_19_bitmap
	RET

SPI_CLOCK_HI:
	mypin GPIO1_hi, P8_16_bitmap
	RET

SPI_CLOCK_LOW:
	mypin GPIO1_low, P8_16_bitmap
	RET
	
