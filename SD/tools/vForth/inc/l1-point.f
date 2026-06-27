\
\ l1-point.f
\
\ POINT (per-pixel attribute) for Layer 1,0 and Layer 2
\
.( L1-POINT )

NEEDS GRAPHICS-COMMON    \ PIXELADD/COORD-CHECK

\ out-of-range coordinates return -1 (and never map a wrong MMU7 page)
: L1-POINT  ( x y -- c )
    COORD-CHECK IF
        PIXELADD C@
    ELSE
        2DROP -1    \ because 0 is a valid color (black)
    THEN
;

