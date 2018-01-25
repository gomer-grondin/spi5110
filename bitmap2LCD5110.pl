#!/usr/bin/perl
#
#  bitmap2LCD5110.pl
#    modify orientation of bitmap to 5110 format
#
#

my @bitmap;
while( <STDIN> ) {
	chomp;
	@bitmap = split;
}

for my $r ( 0 .. 5 ) {
  for my $c ( 0 .. 83 ) {
    printf( "%u ", xform( $r, $c ) );
  }
}

sub xform {
    my( $row, $col, $rval ) = @_;
    my $mask = 1;
    $mask *= 2 for( 0 .. $col % 8 - 1 );
    my $hbyte = $row * 88 + int( $col / 8 );
    for( 1, 2, 4, 8, 16, 32, 64, 128 ) { 
      $rval += $_ if $bitmap[$hbyte] & $mask;
      $hbyte += 11;
    }
    $rval;
}

1;
