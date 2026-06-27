\
\ l1-plot.f
\
\ PLOT for one-colour-per-pixel modes (Layer 1,0 and Layer 2 320x256).
\ COORD-CHECK and PIXELADD are vectored via DEFER..IS by the active layer.
\
.( L1-PLOT )

NEEDS GRAPHICS-COMMON    \ COORD-CHECK/PIXELADD/ATTRIB

: L1-PLOT  ( x y -- )
    COORD-CHECK
    IF
        PIXELADD
        ATTRIB SWAP C!
    ELSE
        2DROP
    THEN
;
