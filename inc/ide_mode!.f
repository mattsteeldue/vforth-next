\
\ ide_mode!.f
\
.( IDE_MODE! )
\
\ Set current NextBasic display mode
\

BASE @

: IDE_MODE! ( n -- )      
    >R 0 0 R> 1
    [ HEX ] 01D5 M_P3DOS [ DECIMAL ]
    44 ?ERROR
    2DROP 2DROP VIDEO
;

BASE !
