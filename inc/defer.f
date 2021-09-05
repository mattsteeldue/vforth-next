\
\ defer.f
\
.( DEFER included ) 6 EMIT
\
\ Tipical usage is
\   DEFER print
\   :NONAME . ;   IS print 
\ 
: DEFER ( -- cccc )
    [COMPILE] :
    ['] ABORT ,
; 


\ : DEFER ( -- cccc )
\     <BUILDS [ ' NOOP ] LITERAL ,
\     DOES> @ EXECUTE
\ ; IMMEDIATE

