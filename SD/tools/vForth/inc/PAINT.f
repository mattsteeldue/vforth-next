\
\ paint.f  
\
.( PAINT )
\
NEEDS GRAPHICS
NEEDS FLIP

\ ____________________________________________________________________
\
\
HEX
: PAINT-HIT ( x y d -- )
    >R
    BEGIN
        2DUP PLOT
        R@ + 1FF AND
        2DUP POINT EDGE
    UNTIL
    R> DROP 2DROP
;

: PAINT-HIT2 ( x y -- )
    2DUP 1 PAINT-HIT 
        -1 PAINT-HIT
;

: PAINT-HITX ( x y d -- )
    >R
    BEGIN
        SWAP R@ + 0FF AND SWAP
        2DUP POINT EDGE NOT
        ?TERMINAL 0= AND
    WHILE
        2DUP PAINT-HIT2
    REPEAT
    R> DROP 2DROP
;    
        
: PAINT  ( x y -- )
    2DUP PAINT-HIT2
    2DUP 1 PAINT-HITX
        -1 PAINT-HITX
;
