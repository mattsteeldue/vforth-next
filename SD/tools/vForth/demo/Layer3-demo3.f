\
\ TILE Demo 3
\ ______________________________________________________________________ 
\
\ MIT License (c) 1990-2026 Matteo Vitturi     
\ ______________________________________________________________________ 
\
\ This demo relyes on a previously created .bin file by
\ Layer3-demo2-setup.f available in this directory.
\ 

  NEEDS LAYER3
  NEEDS LOAD-BYTES
  NEEDS PAD"
  
  MARKER TASK

\ ______________________________

: layer3-demo-tile-40

  cls tile-off
\ tile-40-base
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
\ tile-80-base
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
\ TILE-TXT-BASE
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


