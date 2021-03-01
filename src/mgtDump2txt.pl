#!/usr/bin/perl

=pod

 mgtDump2txt.pl

 Small utility to extract from a IMAGE file 
 all "Screens" human in readable Unix format.
 
 It needs the filename of TXT files as parameters.
 It produces filename mgtDump2txt.output.txt.
  
 For example 
    perl  mgtDump2txt.pl output.txt text1.txt [ text2.txt ... ]
 
 will produce !Blocks.bin.txt 
 
=cut

use strict ;

my $image  = '' ;

my $image_filename = shift ;
print "Using $image_filename\n" ;
open( B, '<', $image_filename ) || die "$image_filename not found.\n" ;
sysread( B, my $data, 2 * 80 * 10 * 512 ) ;
$image .= substr( $data, 4 * 10 * 512 ) ;

close B ;
print "\n" ;

die "Usage: $0 <mgt>\n" if not $image ;

print length( $image ) , "\n" ;

my $f = "${image_filename}.txt" ;

open( T, '>', "$f" ) || die "Cannot create output file $f.\n" ;
print T "File: $f\n" ;
print T "Created: " . localtime . "\n\n" ;
print T "Index:\n\n";

my $buffer = '' ;
my $index  = '' ;
my $total  = '' ;
my $count  = 0 ;
my $screen = 1 ;


while ( my $line = substr( $image, 0, 32 ) ) {
    # my @dump = sprintf( '%02X ' x 32 ,unpack( 'C32', $line ) ) ;
    $image = substr( $image, 32 ) ;
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



