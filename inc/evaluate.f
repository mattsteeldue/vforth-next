\
\ evaluate.f
\
\ Interpret a text-string
\ Maximum string length is 512
\
.( EVALUATE )

NEEDS SOURCE

\
BASE @

DECIMAL

\ Assumes a is an address in HEAP with MMU7 correctly in place
\ String cannot exceed 511 bytes

: EVALUATE ( a u -- )

    \ .s  ." >>> blk " BLK ? ." >in " >in ? ." src " source-id ?

    >IN @ >R                        \ a u       - R: in
    BLK @ >R                        \ a u       - R: in blk

    \ source-id is -1 during EVALUATE: we are in nested evaluation ! 
    SOURCE-ID @ 0< IF               \ a u  
        \ ." : I was evaluating " SOURCE-P @ far 16 type 
        \ save previous EVALUATE status
        SOURCE-L @ >R               \ a u       - R: in blk len
        SOURCE-P @ >R               \ a u       - R: in blk len hp
    ELSE 
        \ source-id is >0 during an F_INCLUDE 
        \ save current position (including current >IN)
        \ ." : I was loading " 
        SOURCE-ID @ IF
            \ ." ...from file !! " 
            SOURCE-ID @ F_FGETPOS   \ a u d f
            [ 36 ] LITERAL ?ERROR   \ a u d
            \ but must rewind to the beginning of the current line
            >IN @ 2-  SPAN @  -  S>D D+
            >R >R                   \ a u       - R: in blk d 
        THEN
    THEN 
    SOURCE-ID @ >R                  \ a u       - R: in blk d src
    
    \ save current string EVALUATE status assuming HEAP
    2DUP                            \ a u a u
    SOURCE-L !                      \ a u a
    MMU7@ <FAR                      \ a u hp
    SOURCE-P !                      \ a u

    \ .s  ." >>> going to <" over 15 type ." >" cr

    \ emulate EVALUATE via LOAD from BLOCK #1 which belongs to no Screen at all
    \ move string to block #1 and interpret 
    1    BLOCK                      \ a u a1 
    DUP  B/BUF BLANK                \ a u a1 
    SWAP B/BUF MIN 0 MAX            \ a a1 u 
    CMOVE 
    -1   SOURCE-ID  ! 
    1    BLK        ! 
    0    >IN        ! 
    INTERPRET

    \ .s  ." ||| blk " BLK ? ." >in " >in ? ." src " source-id ?

    \ at return, retrieve source
    R> SOURCE-ID !                  \           - R: in blk d

    SOURCE-ID @ 0< IF               
        \ save previous EVALUATE status         - R: in blk len hp
        R> >IN @ + SOURCE-P !       \           - R: in blk len 
        R> >IN @ - SOURCE-L !       \           - R: in blk
    ELSE 
        \ source-id is >0 during an F_INCLUDE 
        \ restore current position (including current >IN)
        SOURCE-ID @ IF              \           - R: in blk  d
            R> R>                   \ d         - R: in blk
            SOURCE-ID @             \ d fh
            F_SEEK                  \ f
            [ 35 ] LITERAL ?ERROR
            1 BLOCK B/BUF           \ a m
            2DUP BLANK              \ a m
            SOURCE-ID @ F_GETLINE   \ n
            DROP                    \     ignore bytes read
        THEN
    THEN                            \           - R: in blk
    R> BLK !                        \           - R: in 
    R> >IN !                        \           - R:

    \ .s   ." <<< blk " BLK ? ." >in " >in ? ." src " source-id ?
; 

BASE !

