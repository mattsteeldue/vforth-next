\
\ layer3.f
\ ______________________________________________________________________ 
\
\ v-Forth 1.8 - NextZXOS version - build 2026-04-19
\ MIT License (c) 1990-2026 Matteo Vitturi     
\ ______________________________________________________________________ 

\ Tilemode 80 
\
.( LAYER3 )
\

MARKER LAYER3

\ ______________________________
\

\ NextREG 0x68 (104) - ULA Control. disable ULA output
\ $80 $68 reg!
\
\ NextREG 0x6B (107) - Tilemap Control
\ %10100001 $6B reg!

\ 0x6B (107) Tilemap Control
\ bit 7 = 1 enable the tilemap
\ bit 6 = 0 for 40x32, 1 for 80x32
\ bit 5 = no attribute byte in tilemap (saves space)
\ bit 4 = select palette, 0 first, 1 second
\ bit 3 = set text mode, i.e. 1-bit B&W bitmaps
\ bit 2 = reserved, must be zero
\ bit 1 = activate 512 tile mode
\ bit 0 = force tilemap on top of ULA

\ -- PFA layout: 4 bytes --------------------------------------
\  byte 0  : value for NextREG $6B  (Tilemap Control)
\  byte 1  : value for NextREG $68  (ULA Control)
\  byte 2  : value for NextREG $6F  (Tile Definitions Base)
\  byte 3  : value for NextREG $6E  (Tilemap Base Address)
\ -------------------------------------------------------------
\ Creation syntax:  n6B n68 n6F n6E  TILE-MODE  <name>
\ BASE registers are only written when n68 is non-zero
\ (i.e. when ULA is suppressed = layer being enabled).
\ TILE-OFF passes $00 $00 for n6F/n6E and they are never written.

: TILE-MODE  ( n6B n68 n6F n6E -- )
    CREATE
        C,              \ byte 0 : $6B Tilemap Control
        C,              \ byte 1 : $68 ULA Control
        C,              \ byte 2 : $6F Tile Definitions Base
        C,              \ byte 3 : $6E Tilemap Base Address
    DOES>
        DUP C@          $6B REG!   \ Tilemap Control
        DUP 1+ C@  DUP  $68 REG!   \ ULA Control  ( 0 = layer off )
        IF                         \ only set base addresses when enabling
            DUP 2+ C@   $6F REG!   \ Tile Definitions Base
            DUP 3 + C@  $6E REG!   \ Tilemap Base Address
        THEN
        DROP
;


%00000000 $00 $00 $00  TILE-MODE  TILE-OFF  \ layer disabled, no base writes
%10000001 $80 $06 $00  TILE-MODE  TILE-40   \ 40 col, defs at $4A00
%11001001 $80 $13 $00  TILE-MODE  TILE-80   \ 80 col, defs at $5400
%11101001 $80 $13 $00  TILE-MODE  TILE-TXT  \ 80 col text mode, defs at $5400

\ ______________________________

\ NextREG 0x6C (108) - Tilemap Control
\ %10100001 $6B reg!
\ 7-4 Palette offset
\ 3 Set to mirror tiles in X direction
\ 2 Set to mirror tiles in Y direction
\ 1 Set rotate tiles 90oclockwise
\ 0 In 512 tile mode, bit 8 of tile index, 
\   set for ULA over tilemap, 
\   reset for tilemap over ULA

\ -- PFA layout --------------------------------------------------------
\  byte  0    : number of SET-PAL pairs  ( n )
\  byte  1    : extra-reg address for a trailing  0 REG!  ( 0 = none )
\  bytes 2..  : n pairs of  colour C,  index C,
\ ---------------------------------------------------------------------

\ Compile one  colour/index  pair into the current word's PFA.
\ Called immediately after  CREATE name  to fill the table.
: PAL,  ( colour index -- )  C, C, ;

\ NextREG 0x40 (64) - Palette Index Select
\ NextREG 0x41 (65) - 8-bit Palette Data
: SET-PAL ( c n -- ) $40 REG! $41 REG! ;
: GET-PAL ( n -- c ) $40 REG! $41 REG@ ;

\ Defining word.  
\ n:  number of couple  palette-index, colour
\ extra-reg: register address for a lone  0 REG!
\            0 if no extra write is needed.
: TILE-PALETTE  (  n  extra-reg -- )
    CREATE
        C,              \ byte 0 : extra-reg  ( 0 = none )
        C,              \ byte 1 : pair count
    DOES>
        \ -- preamble: select first tilemap palette in reg $43 --
        $43 REG@  %10001111 AND  %00110000 OR  $43 REG!
        \ -- loop through SET-PAL pairs --------------------------
        DUP  C@             \ a  extra-reg
        SWAP                \ extra-reg  a
        DUP 1+ C@           \ extra-reg  a n
        BOUNDS              \ extra-reg  a+n  a
        DO         \ loop  count  times
            I C@         \ colour
            I 1+ C@      \ index
            SET-PAL
        2 +LOOP
        ?DUP 
        IF  
            %00000000 SWAP REG!  \ optional lone REG!
        THEN  
;

\ TILE-40-PALETTE  —  8 pairs,  no extra reg
8 0 TILE-PALETTE  TILE-40-PALETTE
    %00000001 $01  PAL,    \ blue
    %11011000 $06  PAL,    \ yellow
    %00000001 $11  PAL,    \ blue
    %11000000 $16  PAL,    \ red
    %00000001 $21  PAL,    \ blue
    %11000001 $26  PAL,    \ magenta
    %00000001 $31  PAL,    \ blue
    %11011011 $36  PAL,    \ white

\ TILE-80-PALETTE  —  8 pairs,  no extra reg
8 0 TILE-PALETTE  TILE-80-PALETTE
    %00000001 $00  PAL,    \ on blue
    %11011000 $01  PAL,    \ yellow
    %00000001 $02  PAL,    \ on blue
    %11011011 $03  PAL,    \ white
    %00000001 $04  PAL,    \ on blue
    %11000000 $05  PAL,    \ red
    %00000001 $06  PAL,    \ on blue
    %11000001 $07  PAL,    \ magenta

\ TILE-TXT-PALETTE  —  2 pairs,  extra  0 $6C REG!  at end
2 $6C TILE-PALETTE  TILE-TXT-PALETTE
    %00000001 $00  PAL,    \ dark blue
    %11111001 $01  PAL,    \ light yellow


\ ______________________________
\
