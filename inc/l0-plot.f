\
\ l0-plot.f
\
\ PLOT - set pixel x,y to color/status kept by ATTRIB
\ COORD-CHECK, PIXELADD and PIXELATT are vectorized via DEFER..IS
\
.( L0-PLOT )

NEEDS GRAPHICS-COMMON    \ PIXELADD/PIXELATT/ATTRIB/COORD-CHECK
NEEDS PLOTOP

BASE @
HEX
: L0-PLOT       ( x y -- )
    COORD-CHECK                 \ x y f
    IF                          \ x y
        TUCK                    \ y x y
        PIXELADD >R             \ y         R: a
        7 AND                   \ n
        80 SWAP RSHIFT          \ 80>>n
        R@ C@                   \ b  80>>n
        PLOTOP
        R@ C!                   \
        ATTRIB R>               \ b a       R:
        PIXELATT                \
    ELSE
        2DROP
    THEN
;
BASE !

