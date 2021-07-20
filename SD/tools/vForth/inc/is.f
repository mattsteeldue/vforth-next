\
\ is.f
\
.( IS )
\
: IS ( -- cccc )
    STATE @ IF
        [COMPILE] ['] [COMPILE] DEFER!
    ELSE
        ' DEFER!
    ENDIF    
; IMMEDIATE

