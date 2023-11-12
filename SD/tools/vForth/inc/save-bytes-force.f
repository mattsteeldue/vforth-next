\
\ inc/save-bytes-force.f
\

.( SAVE-BYTES-FORCE ) 

\ save n bytes at address a to file named in PAD
\ it creates a new file, overwriting it if it already exists
\ PAD content is volatile

\ Usage:
\ pad" test.bin"       \ the space is needed but is not part of filename
\ <address> <size> save-bytes

\ Example:
\ PAD" filename"  $4000 4096 SAVE-BYTES-FORCE

BASE @

DECIMAL

\ save n bytes at address a to file named in PAD
\ it creates a new file, overwriting it if it already exists
\ PAD content is volatile
: SAVE-BYTES-FORCE ( a n -- )
    PAD DUP 10 - %1110 F_OPEN   \ a n u f
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
