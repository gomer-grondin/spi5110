// stack_macro.p
//  standardize stack operations .. simplify?
//  stack operations for 4 byte words only
//  assumed that stack is on "local" data space c24
//    so .. each pru has own stack, which is what we want
//



.macro  mypush
.mparam src, pointer
	SUB pointer, pointer, 4
	MOV work1, src
	SBCO work1, c24, pointer, 4
.endm

.macro  mypop
.mparam dst, pointer
	LBCO dst, c24, pointer, 4
	ADD pointer, pointer, 4
.endm

