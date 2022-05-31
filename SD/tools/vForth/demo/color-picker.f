
( LAYER 2 palette picker )
\
\ These screens defines
\      COLOR-PICKER ( -- )
\ and  PICK-COLOR ( -- b )
\ They passes to Layer2 and let you choose a color
\
MARKER TASK
\
NEEDS INTERRUPT
NEEDS VALUE     
NEEDS TO      
NEEDS +TO
NEEDS CALL#     
NEEDS FLIP
NEEDS LAYER2    
NEEDS LAYER12
NEEDS CASE

DECIMAL
\ compose Layer2 BRG color given its component b g r
: BGR ( b g r -- n )
  8 * + 4 * + ;
\
0 0 5 BGR constant KRED
0 5 0 BGR constant KGRN
2 0 0 BGR constant KBLU
2 5 5 BGR constant KWHT
\
0 value RED   0 value GRN   0 value BLU
0 value dy    0 value dx    0 value COL
0 value x     0 value y
: RGB? RED . GRN . BLU . ;

\
\ array that keep track of color behind each cell
\
create ARY  22 22 * ALLOT
: ARY!  ( c x y -- )
  22 * + ARY + c! ;
: ARY@  ( x y -- c )
  22 * + ARY + c@ ;
\
\ to display big square
create h-bar ,"  ---- "
create v-bar ," |    |"

\
: condensed 30 emitc 4 emitc ;
: large     30 emitc 8 emitc ;
needs .border
needs .at
needs .paper
needs .ink
 
: scr-init
  LAYER2 large  7 .border 0 .ink KWHT .paper CLS
  22  0 .at ." Use CURSOR KEYS to move"
  23  0 .at ." ENTER stops and returns byte"
   3 22 .at KRED .ink ." 32 x RED"
   4 22 .at KGRN .ink ."  4 x GREEN"
   5 22 .at KBLU .ink ."  1 x BLUE"     0 .ink
   8 24 .at h-bar count type
  13 9 do i 24 .at v-bar count type loop
  13 24 .at h-bar count type
;
: scr-done
  1 .border LAYER12
;

\
\ to display and populate ARY
: set-block ( q -- )
  case
    0 of     red       grn    endof
    1 of  15 red -     grn    endof
    2 of  15 red -  15 grn -  endof
    3 of     red    15 grn -  endof
  endcase
  3 + to y
  3 + to x
  x y .at col .ink  143 emitc
  col x y ary!
;

\
\ display contour numeric frame
: draw-frame ( -- )
  GRN 0= if
    KRED .ink
    03 RED + 1 .at RED 1 .R  03 RED + 20 .at RED 1 .R
    18 RED - 1 .at RED 1 .R  18 RED - 20 .at RED 1 .R
  endif
  RED 0= if
    KGRN .ink
    20 y .at GRN 1 .R   1 y .at GRN 1 .R
  endif
;

\
\ to complete numeric frame
: draw-corner ( q -- )
  case
    0   of 01 01 endof
    1   of 20 01 endof
    3   of 01 20 endof
    2   of 20 20 endof
  endcase
  .at  KBLU .ink  BLU 1 .R
;

\
\ each single square: q is the quadrant
: draw-block ( q -- )
  BLU GRN RED BGR  TO COL
  dup set-block
  draw-corner
  draw-frame
;

: draw-grid
  8 0 do
    i to RED
    8 0 do
      i to GRN
      0 to BLU 0 draw-block
      1 to BLU 1 draw-block
      2 to BLU 2 draw-block
      3 to BLU 3 draw-block
    loop
  loop
;

\ display big squared-sample
: sample
  x y ary@ .ink
  13 09 DO
    i 25 .at 143 dup 2dup emitc emitc emitc emitc
  LOOP
;
: display-numbers
  0 .ink  [char] 0 to BL
  x y ary@  DUP DUP
  19 24 .at   2 base ! 8 .R
  15 24 .at   [char] $ emit  hex 2 .R
  17 24 .at   decimal  3 .R   32 to BL
;

 
( mouse interface )
HEX 0FFDF P@ FLIP VARIABLE mouse-x
    0FBDF P@ FLIP VARIABLE mouse-y
    0FADF P@      VARIABLE mouse-s
  0 VARIABLE mouse-dx 0 VARIABLE mouse-dy
  0 VARIABLE mouse-ds

: mouse-read ( -- ) \ interrupt-service-routine
  0FFDF P@ FLIP DUP mouse-x @ SWAP - mouse-dx ! mouse-x !
  0FBDF P@ FLIP DUP mouse-y @      - mouse-dy ! mouse-y !
  0FADF P@      DUP mouse-s @      - mouse-ds ! mouse-s !
  mouse-dy @ mouse-dx @ mouse-ds @ or or if
    5C3B C@ 20 OR 5C3B C! 0             \ set FLAGS sys-var
    mouse-ds @ 0> if 0D + then 5C08 C!  \ set LASTK sys-var
  endif
; ' mouse-read INT-W !

 
DECIMAL
\ decide cursor movement from character given
: direction ( c -- )
  case
  [char] 7 of x 1 -  3 max to x endof
  [char] 8 of y 1 + 18 min to y endof
  [char] 5 of y 1 -  3 max to y endof
  [char] 6 of x 1 + 18 min to x endof
        11 of x 1 -  3 max to x endof
         9 of y 1 + 18 min to y endof
         8 of y 1 -  3 max to y endof
        10 of x 1 + 18 min to x endof
  endcase
;

\ handle mouse movement
: mouse-dir
  mouse-dx @ ?dup if
    1 swap +- x + 3 max 18 min to x
  endif
  mouse-dy @ ?dup if
    1 swap +- y + 3 max 18 min to y
  endif
;
\
\ ' mouse-read INT-W !
\

: COLOR-PICKER
  int-on
  scr-init draw-grid  3 to x  3 to y
  begin
    sample display-numbers
    0 .ink  x y .at key
  dup 13 - while
    x y ary@ .ink x y .at 143 emitc
    direction mouse-dir
  repeat drop
  condensed scr-done int-off
;

: PICK-COLOR ( -- b )
  color-picker x y ary@
;


