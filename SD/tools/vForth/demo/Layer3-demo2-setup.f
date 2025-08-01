\
\ TILE Demo charset setup
\
\ this script reads from ROM the standard character set and saves two files 
\ each containing the bitmap definition for 40 and 80 columns Layer3-tile-modes

\ Both modes keeps the grid at $4000 (Tilemap Base Address)

\ 40 columns grid is 40*32*2 = 2560 = $0A00 in size and the Definition uses 
\ 4-bit per color, put charset at $4A00-$5AFF in the middle of display-file
\ 1 bit is mapped as 4 bits. Max 136 chars available, we use the first 96.

\ 80 columns grid is 80*32*2 = 5120 = $1400 in size and the Definition uses
\ 1-bit color, put charset at $5400-$5AFF, 1 bit remains 1 bit
\ Max 224 char defs available, we use the first 96.
\ Control chars (<$20) aren't stored.

\ 80 columns text grid is 80*32*1 = 2560 = $A000 no attribute.

  MARKER FORGET-THIS-TASK

  NEEDS SPLIT
  NEEDS SAVE-BYTES
  NEEDS PAD"

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

: TILE-TXT-EXAMPLE
  $4000                  \ 4000-5400 grid
  #80 #32 *     ERASE    \ =80x32   =2560=$0A00
  #80 #32 *      0 DO
  \ choose an ascii code between $20 and $7F (-$20)
    I    #96 MOD  #32 +  I  $4000 + C!
  LOOP
;


\ ______________________________

\ Save 

CLS

TILE-TXT-EXAMPLE
PAD" ./demo/Layer3-example-txt.bin"
$4000 #2560 SAVE-BYTES

CLS

TILE-40-DEF
PAD" ./demo/Layer3-charset-40.bin"
$4A00 #4352 SAVE-BYTES

TILE-40-EXAMPLE
PAD" ./demo/Layer3-example-40.bin"
$4000 #2560 SAVE-BYTES

CLS 

TILE-80-DEF
PAD" ./demo/Layer3-charset-80.bin"
$5400 #1792 SAVE-BYTES

TILE-80-EXAMPLE
PAD" ./demo/Layer3-example-80.bin"
$4000 #5120 SAVE-BYTES

FORGET-THIS-TASK
