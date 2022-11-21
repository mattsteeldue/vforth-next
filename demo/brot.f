\
\ brot.f
\

needs graphics
needs j
needs binary

layer2

\ table of color shades
BINARY
CREATE COLOR-TAB 
\   rrrgggbb
    00000000 C,   \ BLACK
    00000001 C,   \ BLUE
    00000010 C,
    00000110 C,
    00001010 C,
    00101010 C,
    01001110 C,
    01010010 C,
    01110010 C,
    01110110 C,
    10010110 C,
    10011010 C,
    10111010 C,
    00000000 C,  \ BLACK again


\ pick color element b from COLOR-TAB
: +COLOR ( b -- c )
  COLOR-TAB + C@
;


DECIMAL

VARIABLE ReZ
VARIABLE ImZ
VARIABLE ReZ^2
VARIABLE ImZ^2
VARIABLE ReC
VARIABLE ImC
VARIABLE IDX


\ H-RANGE and V-RANGE are defined from GRAPHICS.f

300 CONSTANT H-MULT
225 CONSTANT V-MULT

220 CONSTANT H-SHIFT
100 CONSTANT V-SHIFT

100     CONSTANT Scale
4 Scale * CONSTANT Mag-Lim
2 Scale * CONSTANT TWO
                                    
DECIMAL


: BROT  ( -- )
V-RANGE 0 DO    \  (Imaginary part of z)
  H-RANGE 0 DO  \  (Real part of z)
    \ prepare c part
    I  H-MULT UM* H-RANGE UM/MOD NIP H-SHIFT - ReC ! 
    J  V-MULT UM* V-RANGE UM/MOD NIP V-SHIFT - ImC ! 
    0 ReZ   !  0 ImZ   !
    14 0 DO 
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
  ?TERMINAL IF QUIT THEN
LOOP 
;

