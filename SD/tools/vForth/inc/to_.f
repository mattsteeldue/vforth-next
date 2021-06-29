\
\ to.f
\
.( TO )
\
\ Used in the form
\   n   TO  cccc 
\
\ If not compiling, set the value  n  to cccc  
\ At compile-time it compiles a literal pointer to cccc PFA 
\ followed by a store-command (!) so that later...
\ at run-time the literal is used by the ! word to alter cccc value
\ cccc was created via VALUE.
\
: TO ( n -- ccc )
    ' >BODY
    STATE @ IF
        COMPILE LIT
        , 
        COMPILE !
    ELSE
        !
    ENDIF
; IMMEDIATE
