#!/usr/bin/perl
#
#  LCD5110.pl -- create bytestream of data for Nokia 5110 displays
#
#

my @bitmap;
while( <STDIN> ) {
	chomp;
	@bitmap = split;
}

my $animate;
$animate = {
	fine      => sub { gen_animate_fine( @_ ); },
	course    => sub { gen_animate_course( @_, 8 ); },
	course4   => sub { gen_animate_course( @_, 16 ); },
	course9   => sub { gen_animate_course( @_, 24 ); },
	wiperight => sub { gen_animate_wiperight( @_ ); },
	wipeleft  => sub { gen_animate_wipeleft( @_ ); },
	curtains  => sub { gen_animate_curtains( @_ ); },
};

my $LCDout;
$LCDout = {
	black     => sub { 511; },
	clear     => sub { 256; },
	lookup    => sub { $bitmap[ $_[0] * 84 + $_[1] ] + 256; },
};

my $output = [];
for my $a ( keys %$animate ) {
  for my $s ( reverse sort keys %$LCDout ) {
    my $c = $s eq 'lookup' ? 2 : 1;
    my $r = $animate->{$a}( [], $s );
    for( 1 .. $c ) { push @$output, $r; }
  }
}

for( 0 .. 5 ) { for my $a ( @$output ) { print join( ' ', @$a ) . ' '; } }

sub gen_animate_curtains {
  my( $rval, $t ) = @_; 
  my $s = 41;
  for my $v( 0 .. 42 ) {
	$col = $s + $v;
        for( my $row = 0 ; $row <= 5 ; $row++ ) {
          render( $row, $col, $rval, $t, 1 );
        }
	$col = $s - $v;
        for( my $row = 5 ; $row >= 0 ; $row-- ) {
          render( $row, $col, $rval, $t, 1 );
        }
  }
  $rval;
}

sub gen_animate_wiperight {
  my( $rval, $t ) = @_; 
  for( my $col = 0 ; $col < 84 ; $col++ ) {
    for( my $row = 0 ; $row < 6 ; $row++ ) {
      render( $row, $col, $rval, $t, 1 );
    }
  }
  $rval;
}
      
sub gen_animate_wipeleft {
  my( $rval, $t ) = @_; 
  for( my $col = 83 ; $col >= 0 ; $col-- ) {
    for( my $row = 0 ; $row < 6 ; $row++ ) {
      render( $row, $col, $rval, $t, 1 );
    }
  }
  $rval;
}

sub gen_animate_fine {
  my( $rval, $t, $done ) = @_;
  $done->[504] = 1;
  my $notdone = 1;
  while( $notdone ) {
    $notdone = 0;
    for( my $i = 0 ; $i < 504 ; $i++ ) {
      unless( $done->[$i] ) {
        $notdone = 1;
        my $r = 504;
        while( $done->[$r] ) { $r = int(rand() * 504); }
        my $row = int( $r / 84 );
        my $col = int( $r % 84 );
	render( $row, $col, $rval, $t, 1, $done );
      }  
    } 
  }
  $rval;
}

sub gen_animate_course {
  my( $rval, $t, $cc, $done ) = @_;
  $done->[504] = 1;
  my $notdone = 1;
  while( $notdone ) {
    $notdone = 0;
    for( my $i = 0 ; $i < 504 ; $i++ ) {
      unless( $done->[$i] ) {
        $notdone = 1;
        my $r = 504;
        while( $done->[$r] ) { $r = int(rand() * 504); }
        my $row = int( $r / 84 );
	   $row = int( $row / ( $cc / 8 ) ) * ( $cc / 8 );
        my $col = int( $r % 84 );
           $col = int( $col / $cc ) * $cc;
	for( 1 .. $cc / 8 ) {
	  render( $row++, $col, $rval, $t, $cc, $done );
        }  
      }  
    } 
  }
  $rval;
}

sub render {
  my( $row, $col, $rval, $f, $cc, $done ) = @_;
  push @$rval, 64 + $row;
  push @$rval, 128 + $col;
  for( 1 .. $cc ) {
    $col < 84 or next;
    $col >= 0 or next;
    $done and $done->[( $row * 84 ) + $col] = 1;
    push @$rval, $LCDout->{ $f }( $row, $col++ ); 
  }
  1;
}

1;
