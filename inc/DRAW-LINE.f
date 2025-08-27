\
\ draw-line.f  
\
.( DRAW-LINE )
\
\ v-Forth 1.8 - NextZXOS version - build 2025-08-15
\ MIT License (c) 1990-2025 Matteo Vitturi     
\
NEEDS GRAPHICS
NEEDS FLIP

\ given two points (x1,y1) and (x0,y0) and ATTRIB preset to c
\ draw a line using Bresenham's line algorithm
\ Coordinates out-of-range are ignored without error.
\ 
: DRAW-LINE  ( x1 y1 x0 y0 -- )
    TO Y0
    TO X0
    TO Y1
    TO X1
    \ compute sign SX, delta DX, sign SY, delta DY and total DIFF
    1 X1 X0 - 
    DUP ABS         TO DX
    +-              TO SX
    1 Y1 Y0 - 
    DUP ABS NEGATE  TO DY
    +-              TO SY
    DX DY +         TO DIFF
    BEGIN
        ?TERMINAL IF EXIT THEN 
        X0 Y0 PLOT
        DIFF 2* TO ERR          \ take twice error and compare with deltas
        ERR DY < NOT IF         \ 
                X0 X1 = IF EXIT THEN
                DY +TO DIFF     \ decrement error by DY
                SX +TO X0 THEN
        ERR DX > NOT IF         \ 
                Y0 Y1 = IF EXIT THEN
                DX +TO DIFF     \ increment error by DX
                SY +TO Y0 THEN
    AGAIN
;
