\
\ l0-xplot.f
\
\ XPLOT - unset/invert pixel x,y
\ COORD-CHECK and PIXELADD are vectorized via DEFER..IS
\
.( L0-XPLOT )

NEEDS GRAPHICS-COMMON    \ PIXELADD/COORD-CHECK
NEEDS XPLOTOP

BASE @
HEX
: L0-XPLOT       ( x y -- )
    COORD-CHECK                 \ x y f
    IF
        TUCK                    \ y x y
        PIXELADD >R             \ y
        7 AND                   \ n
        80 SWAP RSHIFT
        R@ C@
        XPLOTOP
        R> C!
    ELSE
        2DROP
    THEN
;
BASE !

