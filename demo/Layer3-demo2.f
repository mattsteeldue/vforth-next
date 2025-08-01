\
\ TILE Demo 2
\ ______________________________________________________________________ 
\
\ MIT License (c) 1990-2025 Matteo Vitturi     
\ ______________________________________________________________________ 
\
\ This demo relyes on a previously created .bin file by
\ Layer3-demo2-setup.f available in this directory.
\ 

\ NEEDS LAYERS
  NEEDS LOAD-BYTES
  NEEDS PAD"
  
  MARKER TASK

\ ______________________________
\
\ NextREG 0x68 (104) - ULA Control. disable ULA output
\ $80 $68 reg!
\
\ NextREG 0x6B (107) - Tilemap Control
\ %10100001 $6B reg!

\ NextREG 0x6C (108) - Tilemap Control
\ %00010000 $6C reg!
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

\ 80 columns, grid at $4000, 80*32*1 = 2560 = $0A00
\ definition 1bit per pixel at $4A00
: TILE-TXT-BASE \ $14 (-1 to offset the first 32 chars)
  $13 $6F reg!  \ Tile Definitions Base Address $5400
  $00 $6E reg!  \ Tilemap Base Address at $4000
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

\ ______________________________

: TILE-80-PALETTE
  $43 REG@        \ get current status of reg $43
  %10001111 AND
  %00110000 OR    \ .011.... is Tilemap 1st pal.
  $43 REG!
  \ palette entries are given in couple ink on paper
  %11111001 $01  set-pal   \ light yellow
  %00000001 $00  set-pal   \ on blue
  %11011011 $03  set-pal   \ white
  %00000001 $02  set-pal   \ on blue
  %11000000 $05  set-pal   \ red
  %00000001 $04  set-pal   \ on blue
  %11000001 $07  set-pal   \ magenta
  %00000001 $06  set-pal   \ on blue
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

: layer3-demo-tile-40

  cls tile-off
  tile-40-base
  tile-40-palette

  tile-40

  PAD" ./demo/Layer3-charset-40.bin"
  $4A00 #4352 LOAD-BYTES

  PAD" ./demo/Layer3-example-40.bin"
  $4000 #2560 LOAD-BYTES

  key drop 
  cls tile-off
;

\ ______________________________

: layer3-demo-tile-80

  cls tile-off
  tile-80-base
  tile-80-palette

  tile-80

  PAD" ./demo/Layer3-charset-80.bin"
  $5400 #1792 LOAD-BYTES

  PAD" ./demo/Layer3-example-80.bin"
  $4000 #5120 LOAD-BYTES

  key drop 
  cls tile-off

;

\ ______________________________

: layer3-demo-tile-txt

  cls tile-off
  TILE-TXT-BASE
  TILE-TXT-PALETTE    
  %11111001 $01  set-pal   \ light yellow
  %00000001 $00  set-pal   \ on dark blue
  %00000000 $6C reg!       \ globally first palette entry 

  tile-txt
  
  PAD" ./demo/Layer3-charset-80.bin"
  $5400 #1792 LOAD-BYTES

  PAD" ./demo/Layer3-example-txt.bin"
  $4000 #2560 LOAD-BYTES

  key drop 
  cls tile-off
;

\ ______________________________

: LAYER3-DEMO
  LAYER3-DEMO-TILE-TXT
  LAYER3-DEMO-TILE-80
  LAYER3-DEMO-TILE-40
;

