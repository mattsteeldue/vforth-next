\
\ brot.f
\

needs graphics
needs j

\ table of color shades
HEX
CREATE COLOR-TAB 
00 C,   \ BLACK
01 C,   \ BLUE
21 C,
41 C,
61 C,
81 C,
A1 C,
A5 C,
A9 C, 
C9 C,
EC C,
F4 C,
FF C,
00 C,  \ BLACK again
DECIMAL

\ pick color element b from COLOR-TAB
: +COLOR ( b -- c )
  COLOR-TAB + C@
;

0 VARIABLE XX 
0 VARIABLE YY
0 VARIABLE X 
0 VARIABLE Y
0 VARIABLE XT 
0 VARIABLE XZ 
0 VARIABLE YZ
0 VARIABLE IDX


\ H-RANGE and V-RANGE are defined from GRAPHICS.f

350 CONSTANT H-MULT
260 CONSTANT V-MULT

250 CONSTANT H-SHIFT
100 CONSTANT V-SHIFT

100 CONSTANT FXP
400 CONSTANT MAG-LIM
200 CONSTANT TWO

DECIMAL
: BROT
V-RANGE 0 DO 
  H-RANGE 0 DO 
    I  H-MULT  H-RANGE */  H-SHIFT - XZ ! 
    J  V-MULT  V-RANGE */  V-SHIFT - YZ ! 
    0 X ! 0 Y !
    14 0 DO 
      I IDX ! 
      X  @ DUP FXP */ XX !
      Y  @ DUP FXP */ YY ! 
      YY @ XX @ + MAG-LIM > IF LEAVE THEN 
      XX @ YY @ - XZ @ + XT ! 
      TWO  
      X @ FXP */ 
      Y @ FXP */ 
      YZ @ + Y ! 
      XT @ X ! 
    LOOP
    IDX @ +COLOR TO ATTRIB
    J I  PLOT
  LOOP 
  ?TERMINAL IF QUIT THEN
LOOP 
;

