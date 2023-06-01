\
\ load-bytes.f
\

.( LOAD-BYTES ) 

\ load bytes from filename held in PAD
\ PAD is volatile

\ Example:
\ PAD" filename"  HEX 4000 1000 LOAD-BYTES

BASE @

DECIMAL

\ a is destination address, better < $E000
\ n maximumb length in bytes
: LOAD-BYTES ( a n -- )
    PAD DUP 10 - 01 F_OPEN      \ a n u f
    \ test for NextZXOS Open error
    41 ?ERROR                   \ a n u
    >R R@                       \ a n u     R: u    
    F_READ                      \ m f
    \ test for NextZXOS Read error
    46 ?ERROR                   \ m
    DROP                        \
    R> F_CLOSE                  \ f         R:
    \ test for NextZXOS Close error
    42 ?ERROR                   
;

BASE !
