\
\ l1-edge.f
\
\ EDGE rule for Layer 1,0 and Layer 2 (per-pixel attribute compare)
\
.( L1-EDGE )

NEEDS GRAPHICS-COMMON    \ ATTRIB

: L1-EDGE  ( b -- f )
    ATTRIB =
;

