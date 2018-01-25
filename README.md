# spi5110
Beaglebone Black SPI master bitbanging with 1 pru to Nokia 5110 slave

quick start:
1)	physical wiring:
	        from gpio_code.p:
                CLR work2, P8_13                 // DC
                CLR work2, P8_14                 // MOSI
                CLR work2, P8_19                 // SS
                CLR work2, P8_12                 // reset
                CLR work2, P8_16                 // spi clock
                        these are the 5 gpio pins needed to connect to
                        the LCD5110.
		of course, you'll need GND and 3.3V (works from BBB)

2)	make clean ; make all ; make invoke


More details:
root@bbb27:~/BBB/beaglebotA/spi5110# uname -a
Linux bbb27 3.8.13-bone47 #1 SMP Fri Apr 11 01:36:09 UTC 2014 armv7l GNU/Linux

root@bbb27:~/BBB/beaglebotA/spi5110# cat /etc/dogtag
BeagleBoard.org BeagleBone Debian Image 2014-04-23


you will also need a working environment for Perl

questions about device tree overlays are beyond the scope of this project.  

you will need the PRUSS infrastructure for this release / kernel

Makefile needs $SLOTS .. set to 
root@bbb27:~/BBB/beaglebotA/spi5110# echo $SLOTS
/sys/devices/bone_capemgr.9/slots


-----------------

Background:  the Nokia 5110 is my first SPI device.  After spending way too 
	much time trying to get it to work with the BBB SPI device, I decided
	to write my own SPI master on the PRU.  Note that Adafruit has a
	python implementation that works with the SPI device on BBB 
	which I used as a reference implementation. 

	I wrote this mainly to learn SPI, and used the PRU scaffolding that
	i've developed for larger projects.  you might find interesting the
	stack processing code, IPC (inter process communications) scheme, 
	and the memory initialization scheme ( param.dat, .ini )

---------------

Notes:
*) The Nokia 5110 LCD uses a Data/Command input making it a nonstandard SPI 
	slave.  

*) the example image was created on /usr/bin/bitmap invoked this way:
	bitmap -size 88x48
	this closely matches the 5110 84x48 orientation, just dont
	use the rightmost 4 bits of the row

*) /usr/bin/bitmap outputs a bitmap that is one pixel high by 8 pixels wide.
*) the 5110 expects data that is 1 bit wide by 8 bits high
*) bitmap2LCD5110.pl transforms the bitmap output to 5110 input

*)  the device tree overlay is copied from a larger project, and is thus
	a superset of configured pins

*)  gpio.h, gpio_code.p are copied from a larger project and contain
	definitions not used here.  I dont know why gpio_code.p has 
	to be at the bottom of LCD5110.p .. it assembles without complaint
	when put with the others, but does not work

*) param.dat is input to ini.pl, which creates LCD5110.ini .. this is a 
	scheme copied from a larger project.  The idea, is to 
	initialize PRU memory from the invoking 'c' program.  Useful when
	the pacing resource is the 8K program space for the PRU.

*) flow control is achieved by polling, not interrupts.  
	*) the PRUSS interrupt system needs work
	*) Check ipc.dat for the 3 states for INPUT_READY_FLAG ..
		the values are from the .p perspective.  .c loads
		pru memory when this flag is set to NO_INPUT, and
		sets it to INPUT_READY at EOF (stdin) or when the
		configurable XMIT_BUFFER is full.  see notes in
		param.dat (IPC_MAXDATA) for sizing this buffer
	*) the high level flow control, is that .c reads from stdin, loads
		the transmit buffer in pru memory (12k shared).  .p polls
		the INPUT_READY_FLAG for ready status, processes the 
		buffer, then sets INPUT_READY_FLAG back to NO_INPUT ..
		this continues until EOF

*) SPI clock speed:
	*) check notes in param.dat for comments on IPC_CLOCK_DELAY 
	*) i was surprised at how flexible SPI is to varied clock speeds

*) no extra charge for LCD5110.pl which has some animation routines

*) found elsewhere, but applies here:
	*) if 5110 appears hung and not updating, unplug from input to reset

*) to abort process, open another window and create a panic file 'touch panic'.
	*) this is useful if you've slowed down the clock, and don't want 
		to wait for the process to finish.
	*) be aware, that the PRU continues to run until either halted,
		or disabled.  This panic scheme disables the PRU

*) one objective is to limit the resources used by the linux environment.  
	This is why .c takes lots of 100ms breaks while .p works.
	easily explained is that the faster the SPI clock is, the more
	resources will be used by .c (linux).






