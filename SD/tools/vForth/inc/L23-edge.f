\
\ L23-edge.f
\
\ EDGE rule for Layer 2 640x256 4bpp.  POINT returns a 4-bit colour
\ (0..15), so the comparison masks ATTRIB to its low nibble as well.
\ Used by PAINT to detect the boundary colour.
\
.( L23-EDGE )
\
NEEDS GRAPHICS-COMMON    \ ATTRIB

DECIMAL
: L23-EDGE ( b -- f )
    ATTRIB 15 AND =
;
