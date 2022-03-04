\
\ brot.f
\


needs graphics


0 value XX 
0 value YY
0 value X 
0 value Y
0 value XT 
0 value XZ 
0 value YZ
0 value IDX

100 CONSTANT FXP

\
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
F8 C,
00 C,  \ BLACK again
DECIMAL


\ pick color element b from COLOR-TAB
: +COLOR ( b -- c )
  COLOR-TAB + C@
;


layer2
cls
DECIMAL

: BROT13
    192 0 DO \ vertical coord 
        256 0 DO \ horizontal coord 
            I 350 256 */ 250 - to XZ 
            J 200 192 */ 100 - to YZ 
            0 to X  0 to Y 
            
            14 0 DO \ in 14 steps everything is done
 
                X DUP FXP */ to XX 
                Y DUP FXP */ to YY 
                YY XX + 
                400 > IF I to IDX LEAVE THEN 
                XX YY - XZ + to XT 
                200 X FXP */ Y  FXP */ YZ + to Y 
                XT to X 
            LOOP 
            
            ?TERMINAL IF QUIT THEN
            
            \ J 32 * I + 22528 + IDX @ 8 * SWAP C!
            IDX +COLOR to ATTRIB
            J I PLOT
        
        LOOP 
    LOOP 
;

