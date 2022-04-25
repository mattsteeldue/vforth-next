\
\ .border.f
\
.( .BORDER )
\
NEEDS CALL#

BASE @ \ save base status

\
HEX
: .BORDER  ( b -- )
    7 AND
    2297
    CALL#
    DROP
;

BASE !
