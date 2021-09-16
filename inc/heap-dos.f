\
\ heap-dos.f
\
\ this is part of the HEAP memory management libary. See also:
\ FAR HP@ POINTER HEAP H" S" +C +" HEAP-INIT HEAP-DONE
\ See "Heap memory facility" in PDF documentation for details
\
.( HEAP-DOS )
\
\ allocate or free 8K-pages number $20 to $27.
\ This is 64K of ram avalable for Heap Management
\ passed parameter must be 2 for alloc, or 3 for free
\
HEX
: HEAP-DOS ( n -- )
    20 27               \ decimal 32-39 
    DO
        DUP             \  n1 = hl register parameter value 
        I              \  n2 = de register parameter value 
        0              \  n3 = bc register parameter value 
        0              \  n4 =  a register parameter value 
        01BD           \   a = routine address in ROM 3    
        M_P3DOS
        2C ?ERROR       \ error #44 NextZXOS DOS call error
        2DROP 2DROP
    LOOP DROP           \ consume n.
;
DECIMAL
