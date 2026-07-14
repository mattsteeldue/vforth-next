\
\ L4-plot.f
\
\ PLOT for Layer 2 640x256 4bpp (16 colours, 2 pixels per byte).
\ Read-modify-write of a single nibble so the neighbouring pixel sharing
\ the same byte is preserved.
\   y even -> left  pixel -> high nibble (bits 7..4)
\   y odd  -> right pixel -> low  nibble (bits 3..0)
\ COORD-CHECK and PIXELADD are vectored by the active layer (LAYER24).
\
.( L4-PLOT )
\
NEEDS GRAPHICS-COMMON    \ COORD-CHECK/PIXELADD/ATTRIB

DECIMAL
: L4-PLOT  ( x y -- )
    COORD-CHECK IF
        DUP 1 AND >R                \ parity of y: 0=even/high, 1=odd/low
        PIXELADD                    \ a
        ATTRIB 15 AND               \ colour 0..15
        R> IF                       \ odd -> low nibble
            SWAP DUP C@ 240 AND ROT OR SWAP C!
        ELSE                        \ even -> high nibble
            4 LSHIFT SWAP DUP C@ 15 AND ROT OR SWAP C!
        THEN
    ELSE
        2DROP
    THEN
;
