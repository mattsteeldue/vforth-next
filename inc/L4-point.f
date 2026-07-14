\
\ L4-point.f
\
\ POINT for Layer 2 640x256 4bpp: return the 4-bit colour (0..15) of a
\ pixel, selecting the proper nibble from the parity of y.
\   y even -> high nibble (>> 4)
\   y odd  -> low  nibble
\ Out-of-range coordinates return -1 (0 is a valid colour: black).
\ COORD-CHECK and PIXELADD are vectored by the active layer (LAYER24).
\
.( L4-POINT )
\
NEEDS GRAPHICS-COMMON    \ COORD-CHECK/PIXELADD

DECIMAL
: L4-POINT  ( x y -- c )
    COORD-CHECK IF
        DUP 1 AND >R                \ parity of y
        PIXELADD C@                 \ byte
        R> IF
            15 AND                  \ odd  -> low nibble
        ELSE
            4 RSHIFT 15 AND         \ even -> high nibble
        THEN
    ELSE
        2DROP -1
    THEN
;
