\
\ L4-edge.f
\
\ EDGE rule for Layer 2 640x256 4bpp.  POINT returns a 4-bit colour
\ (0..15), so the comparison masks ATTRIB to its low nibble as well.
\ Used by PAINT to detect the boundary colour.
\
.( L4-EDGE )
\
NEEDS GRAPHICS-COMMON    \ ATTRIB

DECIMAL
: L4-EDGE  ( b -- f )
    ATTRIB 15 AND =
;
