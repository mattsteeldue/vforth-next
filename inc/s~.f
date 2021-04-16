\
\ s~.f
\
.( S" ) 
\
NEEDS FAR
NEEDS H"

\
\
\ immutable  string on heap
: (S") R @ FAR COUNT R> CELL+ >R ;

: S"  ( -- a n )
    STATE @
    IF
        COMPILE (S") H" ,
    ELSE
        H" FAR COUNT
    ENDIF
; IMMEDIATE
\
\
\ : TEST_S"  S" HELLO WORLD" NOOP ;
\ CR TEST_S" TYPE CR S" HELLO WORLD" TYPE



