#!/usr/bin/perl

=pod

 mdrDump2txt.pl

 Small utility to extract from a many MDR file 
 all "Screens" human in readable Unix format.
 
 It needs the filename of TXT files as parameters.
 It produces filename mdrDump2txt.output.txt.
  
 For example 
    perl  mdrDump2txt.pl output.txt text1.txt [ text2.txt ... ]
 
 will produce !Blocks.bin.txt 
 
=cut

use strict ;

my $cartridges  = '' ;

my $output_filename = shift ;
print "Creating $output_filename using " ;

while( my $f = shift ) {
    print "$f " ;
    open( B, '<', $f ) || die "$f not found.\n" ;
    sysread( B, my $data, 254 *512 ) ;
    $cartridges .= $data ;
}    
close B ;
print "\n" ;

die "Usage: $0 <output> <mdr1> [ mdr2 ... ]\n" if not $cartridges ;

print length( $cartridges ) , "\n" ;

my $f = $output_filename ;

open( T, '>', "$f" ) || die "Cannot create output file $f.\n" ;
print T "File: $f\n" ;
print T "Created: " . localtime . "\n\n" ;
print T "Index:\n\n";

my $buffer = '' ;
my $index  = '' ;
my $total  = '' ;
my $count  = 0 ;
my $screen = 1 ;


while ( my $line = substr( $cartridges, 0, 32 ) ) {
    # my @dump = sprintf( '%02X ' x 32 ,unpack( 'C32', $line ) ) ;
    $cartridges = substr( $cartridges, 32 ) ;
    $line =~ s/\x00/ /g ;
    $line =~ s/\s+$// ;
    $buffer .= sprintf( " %2d %s\n", $count, $line ) ;
    $index  .= sprintf( "%5d %s\n", $screen, $line ) if 0 == $count ;
    if ( $count >= 15 ) {
        $total .= "\nScr# $screen \n" ;
        $total .= "$buffer" ;
        $buffer = '' ;
        $count = -1 ;
        $screen ++ ;
        # last if $screen >= $N ;
    }
    $count ++ ;
}

print T $index ;
print "\n\n";
print T $total ;

close T ;

exit 1;



