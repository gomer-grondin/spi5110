#!/usr/bin/perl
#
#  ini.pl
#  build map from ipc_c.h
#  read param.dat file
#  write out LCD5110.ini file .. used in LCD5110.c

my $source = "./ipc_c.h";
open my $SOURCE, '<' . $source or die "unable to open $source for input : $!";
my $enum = {};
my $word;
while( <$SOURCE> ) {
  chomp;
  my( undef, undef, undef, $field, undef, $value ) = split;
  $value =~ s/;//g;
  $enum->{$field} = $value;
}
close $SOURCE or die "unable to close $source : $!";

my $param = "./param.dat";
my $out   = "./LCD5110.ini";
open my $SOURCE, '<' . $param or die "unable to open $param for input : $!";
open my $OUT,    '>' . $out   or die "unable to open $out   for output : $!";
while( <$SOURCE> ) {
  chomp;
  /^\s*#/ and next;
  my( $field, undef, $sym ) = split;
  my $v = exists $enum->{$sym} ? $enum->{$sym} : $sym;
  print $OUT $enum->{$field} . " $v\n";
}

close $SOURCE or die "unable to close $param  : $!";
close $OUT    or die "unable to close $out    : $!";

