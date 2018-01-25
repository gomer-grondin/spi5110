#!/usr/bin/perl
#
#  ipc.pl
#   input ipc.dat
#   output ipc_c.h  ipc_p.h 
#
#

use strict;

my $input = 'ipc.dat';
open my $INPUT, '<', $input or die "unable to open $input : $!";

my $ch = 'ipc_c.h';
open my $CH, '>', $ch or die "unable to open $ch : $!";

my $ph = 'ipc_p.h';
open my $PH, '>', $ph or die "unable to open $ph : $!";

my $address = 0;
my $comment;
while( <$INPUT> ) {
  chomp;
  $_ or next;
  my ( $type, $field, $val, @desc ) = split;
  $type or next;
  $comment = join( ' ', @desc );
  if( $type eq 'enum' ) { 
    printf $CH "%s %s \t\t= %d;\n", "const unsigned int", $field, $val;
    printf $PH "%s %s \t\t%d\n", "#define", $field, $val;
  } 
  if( $type eq 'word' ) { 
    $comment and printf $CH "// %s\n", $comment;
    printf $CH "%s %s \t= %4d;\n", "const unsigned int", $field, $address;
    $comment and printf $PH "// %s\n", $comment;
    printf $PH "%s %s \t%d\n", "#define", $field, $address;
    $address += 4;
  } 
}

close $PH    or die "unable to close $ph : $!";
close $CH    or die "unable to close $ch : $!";
close $INPUT or die "unable to close $input : $!";
