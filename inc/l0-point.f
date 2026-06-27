\
\ l0-point.f
\
\ POINT - fetch color/status of pixel x,y (Layer 0 / 1,1 / 1,2 / 1,3)
\
.( L0-POINT )

NEEDS GRAPHICS-COMMON    \ PIXELADD

BASE @
HEX
: L0-POINT  ( x y -- c )
    TUCK                        \ y x y
    PIXELADD C@                 \ y b
    SWAP 7 AND                  \ b y mod 7
    LSHIFT 80 AND               \ f
;
BASE !

