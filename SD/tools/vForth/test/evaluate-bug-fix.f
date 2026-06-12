\ evaluate-bug-fix.f -- proposed EVALUATE fix under test
\ See doc/EVALUATE-bug-analysis.md
\ Redefines EVALUATE shadowing inc/evaluate.f. Two changes, both in the
\ file-include branch:
\  1. save: seek target is the read-start of the current line (pos - SPAN)
\     instead of mid-line (pos + >IN - 2 - SPAN)
\  2. restore: re-read the line with the same call shape as the F_INCLUDE
\     loop (a+1, m-2) so the buffer layout matches the original exactly,
\     making the restored absolute >IN valid again
BASE @
DECIMAL
: EVALUATE ( a u -- )
    >IN @ >R                        \ a u       - R: in
    BLK @ >R                        \ a u       - R: in blk
    SOURCE-ID @ 0< IF               \ a u
        SOURCE-L @ >R               \ a u       - R: in blk len
        SOURCE-P @ >R               \ a u       - R: in blk len hp
    ELSE
        SOURCE-ID @ IF
            SOURCE-ID @ F_FGETPOS   \ a u d f
            [ 36 ] LITERAL ?ERROR   \ a u d
            \ rewind to the read-start of the current line
            SPAN @ NEGATE S>D D+    \ a u d'
            >R >R                   \ a u       - R: in blk d'
        THEN
    THEN
    SOURCE-ID @ >R                  \ a u       - R: in blk d' src
    2DUP                            \ a u a u
    SOURCE-L !                      \ a u a
    MMU7@ <FAR                      \ a u hp
    SOURCE-P !                      \ a u
    1    BLOCK                      \ a u a1
    DUP  B/BUF BLANK                \ a u a1
    SWAP B/BUF MIN 0 MAX            \ a a1 u
    CMOVE
    -1   SOURCE-ID  !
    1    BLK        !
    0    >IN        !
    INTERPRET
    R> SOURCE-ID !                  \           - R: in blk d'
    SOURCE-ID @ 0< IF
        R> >IN @ + SOURCE-P !       \           - R: in blk len
        R> >IN @ - SOURCE-L !       \           - R: in blk
    ELSE
        SOURCE-ID @ IF              \           - R: in blk d'
            R> R>                   \ d'        - R: in blk
            SOURCE-ID @             \ d' fh
            F_SEEK                  \ f
            [ 35 ] LITERAL ?ERROR
            \ re-read the whole line, same shape as the F_INCLUDE loop
            1 BLOCK B/BUF           \ a m
            2DUP BLANK              \ a m
            SWAP 1+ SWAP CELL-      \ a+1 m-2
            SOURCE-ID @ F_GETLINE   \ n
            DROP
        THEN
    THEN                            \           - R: in blk
    R> BLK !                        \           - R: in
    R> >IN !                        \           - R:
;
BASE !
