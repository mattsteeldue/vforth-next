\
\ inc/save-bytes.f
\

\ save n bytes at address a to file named in PAD
\ it creates a new file, error if it already exists
\ PAD content is volatile

\ Usage:
\ filename" test.bin"       \ the space is needed but is not part of filename
\ <address> <size> save-bytes

VARIABLE FH      

\ accept volatile filename at PAD
: FILENAME" ( -- )  \
    ?EXEC                           \ for now you cannot compile it.
    [CHAR] " WORD COUNT             \ a+1 n
    TUCK OVER + 0                   \ n a+1 a+n+1 0
    SWAP !                          \ n a+1
    PAD ROT 1+                      \ a+1 pad n+1
    CMOVE ;


\
\ SAVE-BYTES TEST
\ save n bytes at address a to file named in PAD
\ it creates a new file, error if it already exists
\ PAD content is volatile
: SAVE-BYTES ( a n -- )
    PAD DUP 10 - 06 F_OPEN          \ a n u f
    41 ?ERROR                       \ a n u
    DUP FH ! F_WRITE                \ m f
    47 ?ERROR                       \ m
    DROP FH @ F_CLOSE               \ f
    42 ?ERROR
;
