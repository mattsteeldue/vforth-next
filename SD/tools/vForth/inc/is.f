\
\ is.f
\
.( IS )
\
\ Tipical usage is
\   DEFER print
\   :NONAME . ;   IS print 
\
NEEDS [']
NEEDS DEFER!
\
: IS ( -- cccc )
    STATE @ IF
        [COMPILE] ['] [COMPILE] DEFER!
    ELSE
        ' DEFER!
    ENDIF    
; IMMEDIATE

\ : IS ( -- cccc )
\     ' >BODY CELL+
\     STATE @ IF
\         COMPILE LIT , COMPILE !
\     ELSE
\         !
\     THEN
\ ; IMMEDIATE

    