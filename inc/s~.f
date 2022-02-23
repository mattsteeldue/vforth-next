\
\ s~.f
\
\ this is part of the HEAP memory management libary. See also:
\ FAR HP@ POINTER HEAP H" +C +" HEAP-INIT HEAP-DONE
\ See "Heap memory facility" in PDF documentation for details
\
.( S" )
\
NEEDS FAR
NEEDS H"
\
\ immutable  string on heap
: (S") R@ @ FAR COUNT R> CELL+ >R ;
\
: S"  ( -- a n )
    STATE @
    IF
        COMPILE (S") H" ,
    ELSE
        H" FAR COUNT
    THEN
; IMMEDIATE
\
\
\ : TEST_S"  S" HELLO WORLD" NOOP ;
\ CR TEST_S" TYPE CR S" HELLO WORLD" TYPE



