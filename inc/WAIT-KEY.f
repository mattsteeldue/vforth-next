\
\ wait-key.f
\
.( WAIT-KEY )
\
\
NEEDS INVERT

BASE @ HEX \ save base status

: WAIT-KEY
    \ wait for no-key is pressed
    BEGIN
      0FE P@ 01F AND
    01F = UNTIL
    \ wait for a key is pressed
    BEGIN
      0FE P@ 01F AND
    01F - UNTIL
;

BASE !
