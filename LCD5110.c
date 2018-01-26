/*
	LCD5110.c -- read stream of byte data from stdin, and write it to
		pru 12K shared space.  In case of emergency, `touch panic`
		in this directory will dump out pru space, and end program
*/

#include <stdio.h>
#include <unistd.h>

#include <prussdrv.h>
#include <pruss_intc_mapping.h>
#include <time.h>
#include "ipc_c.h"

int dump( unsigned int * );
void slumber( int  );
int ready_status( unsigned int * );
int maxdata( unsigned int * );
void write_memory( int, const unsigned int * );
int event_loop( unsigned int *, int );
FILE *file;
unsigned int data;

int main(void) {

   
	/* Initialize the PRU */
	printf(">> Initializing PRU\n");
	tpruss_intc_initdata pruss_intc_initdata = PRUSS_INTC_INITDATA;
	prussdrv_init();

	if (prussdrv_open (PRU_EVTOUT_1)) {
		// Handle failure
		fprintf(stderr, ">> PRU1 open failed\n");
		return 1;
	}

	printf(">> PRU opened\n");
	/* Get the interrupt initialized */
	prussdrv_pruintc_init(&pruss_intc_initdata);

	/* Get pointers to PRU local memory */
	void *pruSharedDataMem;
	prussdrv_map_prumem(PRUSS0_SHARED_DATARAM, &pruSharedDataMem);
	unsigned int *pruSharedData = (unsigned int *) pruSharedDataMem;  

	/* initialize pru sram */

	int i;
	for( i = 0 ; i < 8 * 1024 / 4 ; i++ ) {
          prussdrv_pru_write_memory( PRUSS0_PRU1_DATARAM, i, &OFF, 4 );
          prussdrv_pru_write_memory( PRUSS0_SHARED_DATARAM, i, &OFF, 4 );
	}
	printf(">> PRU1 8K initialized\n");
	for( ; i < 12 * 1024 / 4 ; i++ ) {
          prussdrv_pru_write_memory( PRUSS0_SHARED_DATARAM, i, &OFF, 4 );
	}
	printf(">> Shared 12K initialized\n");

	unsigned int param = 0;
	unsigned int value = 0;
        if( ( file = fopen( "LCD5110.ini", "r" ) ) ) {
          while( ( fscanf( file, "%u %u", &param, &value ) ) != EOF ) {
            write_memory( param / 4, &value );
          }
          fclose(file);
        } 
	printf(">> param initialization complete\n");
        
	/* Execute code on PRU */

	printf(">> Executing SPI LCD5110 code\n");
	prussdrv_exec_program(1, "LCD5110.bin");

	write_memory( PANIC / 4, &CALM );
	printf(">> system calm \n");

	int notdone = 1;
	int p = 0;
	int datacount = 0;
	int eofcount = 0;
	int dc = maxdata( pruSharedData );
	dc = dc > 6 * 256 ? 6 * 256 : dc;  // 6k max out of 12k shared
	dc = dc < 1 * 256 ? 1 * 256 : dc;  // 1k min out of 12k shared
	while( notdone ) {
          while( ready_status( pruSharedData ) == NO_INPUT ) {
   	      fscanf( stdin, "%u", &data ); 
              datacount++;
              write_memory( XMIT_BUFFER / 4 + p++, &data );
              if( datacount > dc ) {
		data = 0;
		write_memory( XMIT_BUFFER / 4 + p++, &data );
		datacount = 0;
		p = 0;
              }  
              if( data ) { eofcount = 0; } else {
                write_memory( INPUT_READY_FLAG / 4, &INPUT_READY );
                while( ready_status( pruSharedData ) == INPUT_READY ) {
                  if(( notdone = event_loop( pruSharedData, 100000 )) == 0 ) {
                    break;
		  }
                }
		if( eofcount++ > 5 ) { notdone = 0; break; }
              } 
          }
	}
	/* Disable PRU and close memory mapping*/
 
	prussdrv_pru_disable(1);
	prussdrv_exit();
	printf(">> PRU Disabled.\r\n");
	
	return (0);
}

int dump( unsigned int *pruSharedData ) {

	int p, i, index;
	for( index = 0 ; index < 1024 * 3; index++ ) {
           i = index * 4;
           p = pruSharedData[index];
           printf( "IPC %.8d 0x%.8X 0x%.8X %u\n", i, i, p, p );
	}
	return 0;
}

void slumber( int d ) { usleep( d ); }

int ready_status( unsigned int *pruSharedData ) {
	int p = pruSharedData[INPUT_READY_FLAG / 4];
	return p; 
}

int maxdata( unsigned int *pruSharedData ) {
	int p = pruSharedData[IPC_MAXDATA / 4];
	return p; 
}

void write_memory( int where, const unsigned int *what ) {
  prussdrv_pru_write_memory( PRUSS0_SHARED_DATARAM, where, what, 4 ); 
}

int event_loop( unsigned int *pruSharedData, int delay ) {
	int notdone = 1;
	if( ( file = fopen( "panic", "r" ) ) ) {
		printf( "PANIC\n" );
		fclose(file);
		write_memory( PANIC / 4, &DISTRAUGHT );
		notdone = 0;
		slumber( 100000 ); // allow pru to halt
		dump( pruSharedData );
	} else {
		slumber( delay ); 
	}
	if( notdone && delay > 0 ) {
		notdone = event_loop( pruSharedData, 0 ); 
	}
	return notdone;
} 
