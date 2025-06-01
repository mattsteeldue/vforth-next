\
\ TILE Demo 1
\

  NEEDS LAYERS
  NEEDS SPLIT
  MARKER TASK

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
: TILE-OFF %00000000 $6B reg! $00 $68 reg! ;
: TILE-40  %10000001 $6B reg! $80 $68 reg! ;
: TILE-80  %11001001 $6B reg! $80 $68 reg! ;

\ NextREG 0x40 (64) - Palette Index Select
\ NextREG 0x41 (65) - 8-bit Palette Data
: SET-PAL ( c n -- ) $40 REG! $41 REG! ;
: GET-PAL ( n -- c ) $40 REG! $41 REG@ ;


\ ______________________________

\ setup Tilemap and Definition  base addresses
\ 40 columns, grid at $4000, 40*32*2 = 2560 = $0A00
\ definition 4bit per pixel at $4A00
: TILE-40-BASE  \ $0A (-4 to offset the first 32 chars)
  $06 $6F reg!  \ Tile Definitions Base Address $4A00
  $00 $6E reg!  \ Tilemap Base Address at $4000
;
\ 80 columns, grid at $4000, 80*32*2 = 5120 = $1400
\ definition 1bit per pixel at $4A00
: TILE-80-BASE  \ $14 (-1 to offset the first 32 chars)
  $13 $6F reg!  \ Tile Definitions Base Address $5400
  $00 $6E reg!  \ Tilemap Base Address at $4000
;

\ ______________________________

\ expands byte b to 8 nibble or 4 bytes, for one tile-line
\ assign 6 for foreground ink and 1 for background paper
: TILE-40-BIT     ( b -- n1 n2 n3 n4 )
  7 LSHIFT          \ shift pattern
  0 0      
  8 0 DO
    2DUP D+ 2DUP D+ 2DUP D+ 2DUP D+  \ 4 lshift on 32bits
    ROT DUP + DUP   \ shift  n  bit14 on the sign-bit
    0< IF -ROT      \ operate on d accumulating
         06 0 D+    \ this is palette entry for ink
    ELSE  -ROT
         01 0 D+    \ this is palette entry for paper
    THEN
  LOOP 
  ROT DROP          \ discard original byte
  SPLIT   ROT       \     nHL nHH dL
  SPLIT   2SWAP ;   \     nLL nLH nHL nHH


\ 40 columns mode, 4-bit color
\ Copy charset to 4A00-5AFF, 1 bit becomes 4 bit
\ Max 136 char defs available, we use the first 96
: TILE-40-DEF    \ Tile definition
  $5C36 @ #256 + \ CHARS address
  $5600 $4A00 DO
    DUP C@      \ DUP 2/  OR
    TILE-40-BIT \ 8bits expanded to four bytes
    I       C!
    I 1+    C!
    I 2+    C!
    I 3 +   C!
    1+          \ next address
  4 +LOOP DROP
; 

\ ______________________________

\ 80 columns mode, 1-bit color
\ Copy charset to 5400-5AFF, 1 bit remains 1 bit
\ Max 224 char defs available, we use the first 96.
\ control chars aren't stored
\
: TILE-80-DEF
  $5C36 @ #256 +  \ printable only
  $5700  $5400 DO
    DUP C@        \ DUP 2/  OR
    I C!
    1+
  LOOP  DROP
;

\ ______________________________

: TILE-40-PALETTE
  $43 REG@        \ get current status of reg $43
  %10001111 AND
  %00110000 OR    \ .011.... is Tilemap 1st pal.
  $43 REG!
  \ 16 palette entries plus their shift
  %00000001 $01  set-pal   \ blue
  %11011000 $06  set-pal   \ yellow

  %00000001 $11  set-pal   \ blue
  %11000000 $16  set-pal   \ red

  %00000001 $21  set-pal   \ blue
  %11000001 $26  set-pal   \ magenta

  %00000001 $31  set-pal   \ blue
  %11011011 $36  set-pal   \ white
; 


: TILE-80-PALETTE
  $43 REG@        \ get current status of reg $43
  %10001111 AND
  %00110000 OR    \ .011.... is Tilemap 1st pal.
  $43 REG!
  \ palette entries are given in couple ink on paper
  %11011000 $01  set-pal   \ yellow
  %00000001 $00  set-pal   \ on blue
  %11011011 $03  set-pal   \ white
  %00000001 $02  set-pal   \ on blue
  %11000000 $05  set-pal   \ red
  %00000001 $04  set-pal   \ on blue
  %11000001 $07  set-pal   \ magenta
  %00000001 $06  set-pal   \ on blue
;

\ ______________________________

: TILE-40-EXAMPLE
  $4000                  \ 4000-4A00 grid
  #40 #32 * 2*  ERASE    \ =40x32x1 =2560=$0A00
  #40 #32 * 2*   0 DO
  \ choose an ascii code between $20 and $7F (-$20)
    I 2/ #96 MOD  #32 +  I  $4000 + C!
  \
  \ choose a palette entry  (0 or 1)
  \ uses 3 lshift instead of 4 because of 2 +loop.
    I 7 AND 3 LSHIFT     I  $4001 + C!
  \ I 0 AND              I  $4001 + C!
  2 +LOOP
;

: TILE-80-EXAMPLE
  $4000                  \ 4000-5400 grid
  #80 #32 *  2* ERASE    \ =80x32x2 =5120=$1400
  #80 #32 *  2*  0 DO
  \ choose an ascii code between $20 and $7F (-$20)
    I 2/ #96 MOD  #32 +  I  $4000 + C!
  \
  \ choose a palette entry  (0 or 1)
    I 7 AND              I  $4001 + C!
  \ I 0 AND              I  $4001 + C!
  2 +LOOP
;

\ ______________________________

  tile-40-palette
  tile-40-def
  tile-40-example
  tile-40-base
  tile-40
  key drop tile-off
  tile-80-palette
  tile-80-def
  tile-80-example
  tile-80-base
  tile-80
  key drop tile-off

