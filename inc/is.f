\
\ is.f
\
.( IS )
\
\ Tipical usage is
\   DEFER print
\   :NONAME . ;   IS print 
\ or
\   : prn3 . . . ;
\   ' prn3 IS print
\ or 
\   : config 
\     ['] prn3 IS print ;
\
NEEDS [']
NEEDS DEFER!
\
: IS ( xt -- cccc )
    '
    STATE @ IF
        COMPILE LIT
        ,
        COMPILE DEFER!
    ELSE
        DEFER!
    THEN    
; IMMEDIATE

\ : IS ( -- cccc )
\     ' >BODY CELL+
\     STATE @ IF
\         COMPILE LIT , COMPILE !
\     ELSE
\         !
\     THEN
\ ; IMMEDIATE

