\
\ ide_path.f
\
.( IDE_PATH )
\
\ Path/directory management via the NextZXOS M_P3DOS service $01B1.
\
\ IDE_PATH ( a b -- f )
\   a : address of pathspec, terminated with $FF
\   b : 0 change path   1 get path   2 make path   3 delete path
\
\ (PARSE-PATH) ( -- a )
\   parse the next word from the input stream, in place, and append
\   a $FF terminator; returns its address, ready for   b IDE_PATH
\
\ Consumers: inc/CD.f inc/PWD.f inc/MAKEDIR.f inc/REMOVEDIR.f

MARKER NO-IDE_PATH

: IDE_PATH ( a b -- f )
    >R 0 0 R>
    $01B1 M_P3DOS
    >R 2DROP 2DROP R>
;


: (PARSE-PATH) ( -- a )
    BL WORD COUNT           \  a  n
    OVER +     $FF SWAP C!  \  a          -- append $FF terminator
;
