\
\ l1-xplot.f
\
\ XPLOT for one-colour-per-pixel modes (Layer 1,0 and Layer 2 320x256):
\ invert the per-pixel colour byte.
\ COORD-CHECK and PIXELADD are vectored via DEFER..IS by the active layer.
\
.( L1-XPLOT )

NEEDS GRAPHICS-COMMON    \ COORD-CHECK/PIXELADD

DECIMAL
: L1-XPLOT  ( x y -- )
    COORD-CHECK
    IF
        PIXELADD
        DUP C@ 255 XOR SWAP C!
    ELSE
        2DROP
    THEN
;
