\
\ brot.f
\
\ Mandelbrot set on Layer 2, computed entirely in 16-bit scaled (fixed
\ point) integers: the value n stands for n/Scale, with Scale = 256.
\ The arithmetic is explained step by step in tutorial 064.
\
\ Run it with:  DEMO      ( any key returns to the text screen )
\ Zoom with:    cx cy span WINDOW   ( hundredths ) then  DEMO
\               e.g.  -50 60 120 WINDOW  DEMO
\ Mind the iteration count: the loop below gives up after 15 rounds and
\ calls the point "inside", so a view aimed close to the boundary -- the
\ seahorse valley, say -75 10 60 WINDOW -- comes out almost entirely
\ black.  Deep views need more iterations, and more shades in COLOR-TAB.
\

needs value
needs to
needs j
needs graphics

\ table of color shades, one entry per possible iteration count.
\ Entry 0 is black (escaped at once) and so is the last one, reached
\ only by the points that never escape: the set itself.
CREATE COLOR-TAB
\    rrrgggbb
    %00000000 C,   \ BLACK
    %00000001 C,   \ BLUE
    %00000010 C,
    %00000110 C,
    %00001010 C,
    %00101010 C,
    %01001110 C,
    %01010010 C,
    %01110010 C,
    %01110110 C,
    %10010110 C,
    %10011010 C,
    %10111010 C,
    %11111111 C,
    %00000000 C,  \ BLACK again


\ pick color element b from COLOR-TAB
: +COLOR ( b -- c )
  COLOR-TAB + C@
;


VARIABLE ReZ
VARIABLE ImZ
VARIABLE ReZ^2
VARIABLE ImZ^2
VARIABLE ReC
VARIABLE ImC
VARIABLE IDX


\ H-RANGE and V-RANGE are defined from GRAPHICS.f

256 CONSTANT Scale

\ hundredths -> scaled units:  220 CENTI  is 2.20  is 563.
\ Mind the argument order of */ : it is n1*n2/n3, so Scale must come
\ second and 100 third.  The other way round quietly scales by 100/256
\ instead, which is what used to squeeze the whole view inside the
\ cardioid and paint a nearly black screen.
: CENTI ( n -- n' )
  Scale 100 */
;

4 Scale * VALUE Mag-Lim
2 Scale * VALUE TWO

\ view window: 3.00 wide, starting 2.20 left of the origin, and the same
\ span scaled to the 256x192 aspect ratio vertically.  Same thing as
\   -70 0 300 WINDOW
300 CENTI VALUE H-MULT
225 CENTI VALUE V-MULT

220 CENTI VALUE H-SHIFT
112 CENTI VALUE V-SHIFT


\ set the view from a centre and a width, all three in hundredths.
\ Call it after LAYER2: H-RANGE and V-RANGE follow the graphic mode.
: WINDOW ( cx cy span -- )
    DUP V-RANGE H-RANGE */      \ cx cy span vspan
    ROT SWAP                    \ cx span cy vspan
    DUP CENTI TO V-MULT         \ cx span cy vspan
    2/ SWAP -  CENTI TO V-SHIFT \ cx span         top edge = cy - vspan/2
    DUP CENTI TO H-MULT         \ cx span
    2/ SWAP -  CENTI TO H-SHIFT \                 left edge = cx - span/2
;




: BROT  ( -- )
V-RANGE 0 DO    \  (Imaginary part of z)
  H-RANGE 0 DO  \  (Real part of z)
    \ prepare c part
    I  H-MULT UM* H-RANGE UM/MOD NIP H-SHIFT - ReC !
    J  V-MULT UM* V-RANGE UM/MOD NIP V-SHIFT - ImC !
    0 ReZ   !  0 ImZ   !
    15 0 DO
      I IDX !
      ReZ  @ ABS DUP UM* Scale UM/MOD NIP  \ xx
      ImZ  @ ABS DUP UM* Scale UM/MOD NIP  \ xx yy
      2DUP + Mag-Lim > IF 2DROP LEAVE THEN \ verify if |z| > 2
      \ compute (x + yi)^2 := x^2 - y^2 + 2xyi
      -                                 \ n1    : real part (x^2-y^2)
      TWO ReZ @ Scale */ ImZ @ Scale */ \ n1 n2 : imaginary part (2xy)
      \ add c
      ImC @ + ImZ !                     \ n1
      ReC @ + ReZ !
    LOOP
    IDX @ +COLOR TO ATTRIB
    J I  PLOT
  LOOP
  ?TERMINAL IF LEAVE THEN
LOOP
;


\ switch in, draw, wait, restore the default text screen
: DEMO ( -- )
    LAYER2 CLS
    BROT
    KEY DROP
    LAYER12 1 .PAPER CLS
;
