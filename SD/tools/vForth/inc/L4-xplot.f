\
\ L4-xplot.f
\
\ XPLOT for Layer 2 640x256 4bpp: XOR-invert only the pixel's own nibble,
\ leaving the neighbouring pixel sharing the same byte untouched.
\   y even -> high nibble (mask 240)
\   y odd  -> low  nibble (mask 15)
\ COORD-CHECK and PIXELADD are vectored by the active layer (LAYER24).
\
.( L4-XPLOT )
\
NEEDS GRAPHICS-COMMON    \ COORD-CHECK/PIXELADD

DECIMAL
: L4-XPLOT  ( x y -- )
    COORD-CHECK IF
        DUP 1 AND >R                \ parity of y
        PIXELADD                    \ a
        R> IF 15 ELSE 240 THEN      \ nibble mask to invert
        OVER C@ XOR SWAP C!
    ELSE
        2DROP
    THEN
;
