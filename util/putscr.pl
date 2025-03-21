#!/usr/bin/perl

=pod

 putscr.pl

 Small utility to put into !Blocks-64.bin a specific 1K Screen 
 using a suitable text file (one Screen is two Blocks).
 
 This is the reverse operation performed by blocks2txt.pl script
 
 For example: 
 
    perl  putscr.pl  Messages.txt  !Blocks-64.bin  4
    
 restores the blocks that contain the standard messages.

=cut

use strict ;

my $source_filename  = shift ;
my $block_filename = shift ;
my $desc_screen_number = shift || 0 ;

die "Usage: $0 <source> <block-file> [n]\n" if not $block_filename;

my $screen_number = 0 ;
my @screen_data   = () ;
my $line_number   = 0 ;
my $binary_content ;

open( G, '<', $block_filename )|| die "$block_filename not found.\n" ;
sysread( G, $binary_content, 16 * 1024 * 1024 ) ;
close G ;

open( F, '<', $source_filename )|| die "$block_filename not found.\n" ;
while( my $line = <F> ) {
	set_screen_number( $desc_screen_number ) if ( 0 == $screen_number && $desc_screen_number != 0 && $line =~ /Screen#\s(\d{1,4})/ ); 		# :dbolli:20210414 17:21:21 Added to use $desc_screen_number param if specified
	set_screen_number( $desc_screen_number ) if ( 0 == $screen_number && $desc_screen_number != 0 && $line =~ /Scr#\s(\d{1,4})/ ); 		# :dbolli:20210414 17:21:21 Added to use $desc_screen_number param if specified
    set_screen_number( $1 ) if ( 0 == $screen_number && $line =~ /Screen#\s(\d{1,4})/ ) ;
    set_screen_number( $1 ) if ( 0 == $screen_number && $line =~ /Scr#\s(\d{1,4})/ ) ;
    if ( $line =~ /^\s{1,2}(\d{1,2})\s?(.{1,64})/ ){
        my $num = $1 ;
        my $str = $2 ;
        warn "Wrong line number $1\n" if $num != $line_number or $num > 15 or $num < 0 ;
        push @screen_data, $str ;
        $line_number++ ;
    }
    if ( 16 == $line_number ) {
        # put_screen( $screen_number ) ;
        set_screen_number( 0 ) if ( $desc_screen_number == 0 );		# :dbolli:20210414 17:21:21 Added if ( $desc_screen_number == 0 )
        set_screen_number( $screen_number + 1 ) if ( $desc_screen_number != 0 );		# :dbolli:20210414 17:21:21 Added
        $line_number = 0 ;
    }
}
put_screen( $screen_number ) if scalar @screen_data ;

close F ;

open( G, '>', $block_filename )|| die "cannot write $block_filename\n" ;
syswrite G, $binary_content ;
close G ;

sub set_screen_number {
    put_screen( $screen_number ) ;
    $screen_number = shift ;
    @screen_data = () ;
}


sub put_screen {
    my $num = shift || 0 ;
    return if $num < 1;
    my $init_len = length( $binary_content ) ;
    my $str = ' ' x 1024 ;
    for ( my $i = 0; $i < 16; $i++ ) {
        substr( $str, 64 * $i, length( $screen_data[$i] ) ) = $screen_data[$i] ;
    }
    substr( $binary_content, 1024 * $num - 512, 1024 ) = $str ;
    my $final_len = length( $binary_content ) ;
    if ( $final_len != $init_len ) {
        1;
    }
    print "Screen# $num\n" ;
    # print length( $binary_content ) . " , " . length( $str ) . "\n" ;
    1;
}




print qq[File "$block_filename" re-written\n] ;
1;

# c:\Zx\Forth\F15\version\20210228\chomp.f  c:\Zx\Forth\F15\version\20210228\!Blocks-64.bin



