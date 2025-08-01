\
\ TILE80.f

\ v-Forth 1.8 - NextZXOS version - build 2025-07-19
\ MIT License (c) 1990-2025 Matteo Vitturi     

\ Tilemode 80 columns - 1 color
\
.( TILE80 )
\
\
MARKER TASK

NEEDS PAD"
NEEDS LOAD-BYTES
NEEDS [']
NEEDS CASE

\ ______________________________
\
\ NextREG 0x68 (104) - ULA Control. disable ULA output
\ $80 $68 reg!
\
\ NextREG 0x6B (107) - Tilemap Control
\ %10100001 $6B reg!

\ NextREG 0x6C (108) - Tilemap Control
\ %10100001 $6B reg!
\ 7-4 Palette offset
\ 3 Set to mirror tiles in X direction
\ 2 Set to mirror tiles in Y direction
\ 1 Set rotate tiles 90oclockwise
\ 0 In 512 tile mode, bit 8 of tile index, 
\   set for ULA over tilemap, 
\   reset for tilemap over ULA

\ 0x6B (107) Tilemap Control
\ bit 7 = 1 enable the tilemap
\ bit 6 = 0 for 40x32, 1 for 80x32
\ bit 5 = no attribute byte in tilemap (saves space)
\ bit 4 = select palette, 0 first, 1 second
\ bit 3 = set text mode, i.e. 1-bit B&W bitmaps
\ bit 2 = reserved, must be zero
\ bit 1 = activate 512 tile mode
\ bit 0 = force tilemap on top of ULA

: TILE-OFF %00000000 $6B reg! $00 $68 reg! ;
: TILE-40  %10000001 $6B reg! $80 $68 reg! ;
: TILE-80  %11001001 $6B reg! $80 $68 reg! ;
: TILE-TXT %11101001 $6B reg! $80 $68 reg! ;
\ ______________________________

\ NextREG 0x40 (64) - Palette Index Select
\ NextREG 0x41 (65) - 8-bit Palette Data
: SET-PAL ( c n -- ) $40 REG! $41 REG! ;
: GET-PAL ( n -- c ) $40 REG! $41 REG@ ;

\ ______________________________

\ 80 columns, grid at $4000, 80*32*1 = 2560 = $0A00
\ definition 1bit per pixel at $4A00
: TILE-TXT-BASE \ $14 (-1 to offset the first 32 chars)
    $13 $6F reg!  \ Tile Definitions Base Address $5400
    $00 $6E reg!  \ Tilemap Base Address at $4000
;

\ ______________________________

: TILE-TXT-PALETTE
    $43 REG@        \ get current status of reg $43
    %10001111 AND
    %00110000 OR    \ .011.... is Tilemap 1st pal.
    $43 REG!
    \ palette entries are given in couple ink on paper
    %11111001 $01  set-pal   \ light yellow
    %00000001 $00  set-pal   \ on dark blue
    %00000000 $6C reg!       \ globally first palette entry 
;

\ ______________________________

\ Address useful
$4000 CONSTANT DISPLAY-FILE

\ screen size, height and width
  #80 CONSTANT T-WIDTH
  #32 CONSTANT T-HEIGHT
T-WIDTH T-HEIGHT * 
      CONSTANT T-SIZE  
      
VARIABLE T-FLAGS
      
\ ______________________________

\ row and col where should go the next emitted character
VARIABLE T-POS
\ ______________________________

\ home
: T-HOME
    0 T-POS !
    0 T-FLAGS !
    PAD" ./LIB/TILE80-charset.bin"
    $5400 #1792 LOAD-BYTES
;

\ ______________________________

\ Scroll text screen one row up.
: T-SCROLL
  [ DISPLAY-FILE T-WIDTH + ]  LITERAL
    DISPLAY-FILE
  [ T-SIZE T-WIDTH - ]  LITERAL
    CMOVE

  [ DISPLAY-FILE T-SIZE + T-WIDTH - ] LITERAL
    T-WIDTH
    BLANK
    T-POS @ T-WIDTH - 0 MAX T-POS !
;

\ ______________________________

\ Clear screen by filling blanks
: T-CLS
    DISPLAY-FILE T-SIZE BLANK
    T-HOME
;

\ ______________________________

: T-XY ( -- a )
    T-POS @ 
    DISPLAY-FILE + 
    \ move cursor ahead
    1 T-POS +!
;

\ ______________________________
\
\ cr or lf
: T-CR
    T-POS @ 
    T-WIDTH /MOD NIP
    1+ T-WIDTH *
    T-POS !
    [ T-SIZE T-WIDTH - ]  LITERAL 
    T-POS @ < IF
        T-SCROLL
    THEN
;

\ ______________________________
\
\ Backspace
: T-BS
    T-POS @ 
    1- 0 MAX
    T-POS !
;

\ ______________________________

\ decode Emit
: T-DECODE ( c1 -- )
    T-FLAGS @ 2 = IF
        CASE
            2 OF  T-WIDTH * T-POS !  1 T-FLAGS !  ENDOF
            1 OF  T-POS +!           0 T-FLAGS !  ENDOF
        ENDCASE
    ELSE
        CASE
            $08 OF T-BS ENDOF
            $0A OF T-CR ENDOF
            $0D OF T-CR ENDOF
            $16 OF 2 T-FLAGS ! ENDOF
        ENDCASE
    THEN
;

\ ______________________________

\ vector for emit
: T-EMIT ( c -- 0 )
    DUP BL < 
    T-FLAGS @ OR
    IF
        T-DECODE
    ELSE
        \ First check if we must scroll one row
        T-SIZE T-POS @ < IF 
             T-SCROLL 
        THEN
        \ Put c at the right location
        T-XY !
        1 OUT +!
    THEN
    0
;

\ ______________________________
\ 
\ restore patch
\
: NO-TILE
    TILE-OFF  
    ['] (?EMIT)       ['] EMIT >BODY !
    ['] (CLS)         ['] CLS  >BODY !
    CLS
;

\ ______________________________
\
: TILE80
    CLS
    ['] T-EMIT        ['] EMIT >BODY !
    ['] T-CLS         ['] CLS  >BODY !
    TILE-TXT-PALETTE
    TILE-TXT-BASE
    TILE-TXT
    T-CLS 
    T-HOME  
\   PAD" ./demo/Layer3-example-txt.bin"
\   $4000 #2560 LOAD-BYTES
\   KEY
\   T-SCROLL
\   T-SCROLL
\   KEY
\   T-CLS
\   T-HOME
\   33 T-EMIT
\   33 T-EMIT
\   
\   
\   KEY
\   NO-TILE
;

