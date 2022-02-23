\
\ defer.f
\
.( DEFER )
\
\ Tipical usage is
\   DEFER print
\ then
\   :NONAME . ;   IS print 
\ or similarly
\   : prn3 . . . ;
\   ' prn3 IS print
\ or compiling for later use
\   : config ['] prn3 IS print ;
\ 

NEEDS [']


: DEFER ( -- cccc )
    [COMPILE] :
    ['] NOOP  ,
    [COMPILE] ;
; 


\ : DEFER ( -- cccc )
\     <BUILDS [ ' NOOP ] LITERAL ,
\     DOES> @ EXECUTE
\ ; IMMEDIATE

