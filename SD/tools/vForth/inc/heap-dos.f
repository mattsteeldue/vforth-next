\
\ heap-dos.f
\

.( HEAP-DOS )

\ allocate 8K-pages from $40 to $47.
\ This is 64K of ram avalable for Heap Management
HEX
: HEAP-DOS ( n -- )
    48 40 DO
        DUP  I  0  0  01BD  M_P3DOS
        2C ?ERROR
        2DROP 2DROP
    LOOP DROP 
;
DECIMAL

