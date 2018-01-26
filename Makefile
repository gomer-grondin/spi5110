# Makefile 
CC = gcc
CFLAGS = -Wall
PRU_ASM = pasm
DTC = dtc
SPIPRU = $(shell grep spipru $(SLOTS))

spipru-00A0.dtbo: spipru.dts 
	$(DTC) -O dtb -o spipru-00A0.dtbo -b 0 -@ spipru.dts
	cp spipru-00A0.dtbo /lib/firmware

LCD5110.bin : LCD5110.p stack_macro.p ipc_macro.p \
			gpio_code.p ipc_p.h gpio.h pru.h
	$(PRU_ASM) -V3 -b LCD5110.p

LCD5110 : LCD5110.o
	$(CC) -lpthread -lprussdrv -o LCD5110 LCD5110.o

LCD5110.o : ipc_c.h LCD5110.c
	$(CC) $(CFLAGS) -c -o LCD5110.o LCD5110.c

bitmapdump : bitmapdump.o
	$(CC) -lpthread -lprussdrv -o bitmapdump bitmapdump.o

bitmapdump.o : bitmapdump.c
	$(CC) $(CFLAGS) -c -o bitmapdump.o bitmapdump.c

bitmapdump.c : bitmap
	perl -pnle ' BEGIN { print "#include <stdio.h>" } s/char .+_bits/char bitmap/; END { print "\nint main() {"; print "\tint i = 0;"; print "\tfor( ; i < sizeof( bitmap ) ; i++ ) {"; print "\t\tprintf( \"%u \", bitmap[i] );"; print "\t}"; print "\treturn 0;"; print "}"; } ' bitmap > bitmapdump.c

ipc_c.h ipc_p.h : ./ipc.dat ./ipc.pl
	perl ./ipc.pl

LCD5110.ini : ini.pl ipc_c.h param.dat
	perl ./ini.pl

clean :
	rm -f ./bitmapdump.c ./bitmapdump.o ./bitmapdump 
	rm -f ./LCD5110.ini ./ipc_c.h ./ipc_p.h
	rm -f ./LCD5110.o ./LCD5110 ./LCD5110.bin
	rm -f ./spipru-00A0.dtbo
	rm -f panic

invoke : all 
	rm -f panic
	chmod 755 ./*.pl
	./bitmapdump | ./bitmap2LCD5110.pl | ./LCD5110.pl | ./LCD5110

device_tree : ./spipru-00A0.dtbo
ifeq ($(strip $(SPIPRU)),)
	cat $(SLOTS) 
	@echo 'DEVICE TREE IS not LOADED !!!'
	echo spipru > $(SLOTS) 2>/dev/null
endif

all : bitmapdump ipc_c.h ipc_p.h LCD5110.ini \
	./LCD5110 ./LCD5110.bin ./spipru-00A0.dtbo device_tree
