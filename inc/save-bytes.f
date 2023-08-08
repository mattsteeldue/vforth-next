\
\ inc/save-bytes.f
\

.( SAVE-BYTES ) 

\ save n bytes at address a to file named in PAD
\ it creates a new file, error if it already exists
\ PAD content is volatile

\ Usage:
\ pad" test.bin"       \ the space is needed but is not part of filename
\ <address> <size> save-bytes

\ Example:
\ PAD" filename"  HEX 4000 1000 SAVE-BYTES

BASE @

DECIMAL

\ save n bytes at address a to file named in PAD
\ it creates a new file, error if it already exists
\ PAD content is volatile
: SAVE-BYTES ( a n -- )
    PAD DUP 10 - 06 F_OPEN      \ a n u f
    \ test for NextZXOS Open error
    41 ?ERROR                   \ a n u
    >R R@                       \ a n u     R: u    
    F_WRITE                     \ m f
    \ test for NextZXOS Read error
    47 ?ERROR                   \ m
    DROP                        \
    R> F_CLOSE                  \ f         R:
    \ test for NextZXOS Close error
    42 ?ERROR
;

BASE !
