\
\ layer3.f
\ ______________________________________________________________________ 
\
\ MIT License (c) 1990-2025 Matteo Vitturi     
\ ______________________________________________________________________ 

\ Tilemode 80 
\
.( LAYER3 )
\
\

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

\ 80 columns, grid at $4000, 80*32*2 = 5120 = $1400
\ definition 1bit per pixel at $4A00
: TILE-80-BASE  \ $14 (-1 to offset the first 32 chars)
  $13 $6F reg!  \ Tile Definitions Base Address $5400
  $00 $6E reg!  \ Tilemap Base Address at $4000
;

\ ______________________________

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
