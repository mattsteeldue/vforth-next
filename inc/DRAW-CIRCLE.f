\
\ draw-circle.f  
\
.( DRAW-CIRCLE )
\
NEEDS GRAPHICS
NEEDS FLIP

\ ____________________________________________________________________
\

\ for each coordinate SX, SY draw all eight pixel around the circumference
\ using PLOT 
\ https://www.geeksforgeeks.org/bresenhams-circle-drawing-algorithm/

: CIRCLE-EIGHT
    DX SX XY-RATIO +  DY SY  +  PLOT
    DX SX XY-RATIO -  DY SY  +  PLOT
    DX SX XY-RATIO +  DY SY  -  PLOT
    DX SX XY-RATIO -  DY SY  -  PLOT
    DX SY XY-RATIO +  DY SX  +  PLOT
    DX SY XY-RATIO -  DY SX  +  PLOT
    DX SY XY-RATIO +  DY SX  -  PLOT
    DX SY XY-RATIO -  DY SX  -  PLOT
;

: DRAW-CIRCLE ( x y r -- )
    0 TO SX  
      TO SY  
      TO DY  
      TO DX
    SY IF
        3 SY 2* - TO DIFF   \ d := 3 - 2r
        CIRCLE-EIGHT
        BEGIN
            1 +TO SX
            DIFF 0< IF
                SX  2* 2*  6 + +TO DIFF   \ d += 4x + 6
            ELSE
                SX SY -  2* 2*  10 + +TO DIFF   \ d += 4(x-y) + 10
                -1 +TO SY
            THEN
            CIRCLE-EIGHT
        SY SX < UNTIL
    ELSE
        DX DY PLOT
    THEN
;
