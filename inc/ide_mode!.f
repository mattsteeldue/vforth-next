\
\ ide_mode!.f
\
.( IDE_MODE! included ) 6 EMIT
\
\ Set current NextBasic display mode
\
: IDE_MODE! ( hl de bc a -- )      
    >R 0 0 R> 1
    [ HEX ] 01D5 M_P3DOS [ DECIMAL ]
    44 ?ERROR
    2DROP 2DROP VIDEO
;
