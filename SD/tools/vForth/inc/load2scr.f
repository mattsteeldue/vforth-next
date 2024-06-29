\
\ load2scr.f
\

.( LOAD2SCR ) 

\ load up to 1024 bytes from filename held in PAD to specified Screen n
\ starting from line 1 while filename string itself is copied to line 0.
\ PAD is volatile.

\ Example:
\ PAD" /doc/895.f" 895 LOAD2SCR

NEEDS LOAD-BYTES

BASE @

DECIMAL

\ n Screen number
\ WARNING: In this implementation a Screen occupies two BLOCKs
\ WARNING: so for example Screen# 440 is BLOCK 880.
: LOAD2SCR ( n -- )
    PAD DUP 10 -                \ n a1 a2
    01 F_OPEN                   \ n fh f
    \ test for NextZXOS Open error
    41 ?ERROR                   \ n fh
    >R                          \ n         R: fh

    \ assign a BUFFER and load BLOCK n into it
    2* DUP BLOCK                \ n a
    B/BUF                       \ n a u
    \ load up to 512 bytes to BLOCK
    R@ F_READ                   \ n m f
    \ test for NextZXOS Read error
    46 ?ERROR                   \ n m
    DROP                        \
    \ mark the block for update
    UPDATE                      \ n

    \ assign a BUFFER and load BLOCK n into it
    1+ BLOCK                    \ a
    B/BUF                       \ a u
    \ load up to 512 bytes to BLOCK
    R@ F_READ                   \ m f
    \ test for NextZXOS Read error
    46 ?ERROR                   \ m
    DROP                        \
    \ mark the block for update
    UPDATE                      \

    R> F_CLOSE                  \ f         R:
    \ test for NextZXOS Close error
    42 ?ERROR                   
;

BASE !
