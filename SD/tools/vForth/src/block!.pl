#!/usr/bin/perl

=pod

 Small utility to extract from a file (usually !Blocks-64.bin) 
 all "Screens" between 1 and 761 in a human readable format.
 
 Modify the limit 762 if you want to extract more Screens.
 
 It needs the filename of binary file as parameter.
 It produces a same filename with a ".txt" extension added.
 
 For example 
    perl  block!.pl  !Blocks-64.bin 
 
 will produce !Blocks-64.bin.txt 
 
=cut

use strict ;

my $f = shift ;
open B, '<', $f ;
open T, '>', "$f.txt" ;

my $buffer = '' ;
my $count  = 0 ;
my $screen = 1 ;

while ( sysread( B, my $line, 32 ) ) {
    my @dump = sprintf( '%02X ' x 32 ,unpack( 'C32', $line ) ) ;
    $line =~ s/\x00//g ;
    $line =~ s/\s+$// ;
    $buffer .= sprintf( " %2d %s\r", $count, $line ) ;
    if ( $count >= 15 ) {
        print T "\rScr# $screen \r" ;
        print T "$buffer" ;
        $buffer = '' ;
        $count = -1 ;
        $screen ++ ;
        last if $screen >= 762 ;
    }
    $count ++ ;
}
print T $buffer ;

close T ;
close B; 

