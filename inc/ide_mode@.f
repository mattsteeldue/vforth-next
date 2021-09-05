\
\ ide_mode@.f
\
.( IDE_MODE@ included ) 6 EMIT
\
\ Set current NextBasic display mode
\
: IDE_MODE@ ( -- hl de bc a )      
    0 0 0 0
    [ HEX ] 01D5 M_P3DOS [ DECIMAL ]
    44 ?ERROR
;

DECIMAL
