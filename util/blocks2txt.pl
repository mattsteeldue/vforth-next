#!/usr/bin/perl

=pod

 blocks2txt.pl

 Small utility to extract from a file (usually !Blocks.bin) 
 all "Screens" between 1 and N in a human readable Unix format.
 
 It needs the filename of binary file as first parameter.
 It produces a same filename with a ".txt" extension added.

 "N" is passed as second parameter.
  
 For example 
    perl  block!.pl 1000 !Blocks.bin 
 
 will produce !Blocks.bin.txt 
 
=cut

use strict ;

my $f = shift ;
die "Usage: $0 <file> [n]\n" if not $f ;
my $N = shift || 761 ;
open( B, '<', $f )|| die "$f not found.\n" ;
open( T, '>', "$f.txt" ) || die "Cannot create $f.txt\n" ;

my $buffer = '' ;
my $count  = 0 ;
my $screen = 1 ;

print T "File: $f\n" ;
print T "Created: " . localtime . "\n\n" ;
print T "Index:\n\n";

seek B, 512, 0 ;
while ( sysread( B, my $line, 64 ) ) {
    $line =~ s/\x00//g ;
    $line =~ s/\s+$// ;
    if ( 0 == $count ) {
        my @dump = sprintf( '%02X ' x 64 ,unpack( 'C32', $line ) ) ;
        my $l = length( $line ) ;
        if ( 1 ) {
            print T sprintf( "%5d %s\n", $screen, $line )
        }
    }
    if ( $count >= 15 ) {
        $count = -1 ;
        $screen ++ ;
        last if $screen >= $N ;
    }
    $count ++ ;
}

print T "\n\n";
$count  = 0 ;
$screen = 1 ;
seek B, 512, 0 ;
while ( sysread( B, my $line, 64 ) ) {
    # my @dump = sprintf( '%02X ' x 64 ,unpack( 'C32', $line ) ) ;
    $line =~ s/\x00/ /g ;
    $line =~ s/\s+$// ;
    $buffer .= sprintf( " %2d %s\n", $count, $line ) ;
    if ( $count >= 15 ) {
        print T "\nScr# $screen \n" ;
        print T "$buffer" ;
        $buffer = '' ;
        $count = -1 ;
        $screen ++ ;
        last if $screen >= $N ;
    }
    $count ++ ;
}
print T $buffer ;

close T ;
close B; 

print qq[File "$f.txt" created\n] ;
1;
