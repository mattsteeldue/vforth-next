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

: EVALUATE ( a u -- )

    \ .s 2dup type cr

    \ save current source status
    SOURCE-L    @  >R               \ a u   -  R: L
    SOURCE-P    @  >R               \ a u   -  R: L P
    BLK         @  >R               \ a u   -  R: L P blk
    >IN         @  >R               \ a u   -  R: L P blk >in
    SOURCE-ID   @  >R               \ a u   -  R: L P blk >in ptr src
    
    R@ 1+      \ so that -1 become 0
    IF 
        R@
        IF
            \ SOURCE-ID is >0 during an F_INCLUDE then
            \ save current position and close the file-handle for later
            \ ." source-id is greater than zero " CR
            R@ F_FGETPOS            \ a u pos
            [ 44 ] LITERAL ?ERROR 
            
            \ but must rewind to the beginning of the current line
            >IN @ 2-  SPAN @  -  S>D D+
        ELSE
            \ SOURCE-ID was zero, dummy handle-position
            \ ." source-id is zero " CR
            2DUP                    \ a u  a u
        THEN
    ELSE 
        \ SOURCE-ID is -1 during EVALUATE
        \ ." source-id is negative " CR
        2DUP                        \ a u  a u   
    THEN 
    
    \ cr .s ." >>> " 
    
    \ actual save 
    >R >R                           \ a u   -  R: L P blk >in ptr src pos

    2DUP SOURCE-L ! SOURCE-P !      \ a u   

    \ emulate EVALUATE via LOAD from BLOCK #1 which belongs to no BLOCK at all.
    1    BLK        !  
    0    >IN        !     
    -1   SOURCE-ID  !
    1    BLOCK                      \ a u a1 

    DUP  B/BUF BLANK                 
    SWAP B/BUF MIN                  \ a a1 u 
    CMOVE                           \ 

    INTERPRET           
    
    \ .s ." <<< " cr

    \ receive previous Handle-position if any
    R> R>                           \ pos   -  R: L P blk >in ptr src
    
    \ restore SOURCE-ID, SOURCE-ID-P, >IN, BLK
    R> DUP SOURCE-ID !              \ pos src   -  R: L P  blk >in ptr
    R> >IN !                        \ pos src   -  R: L P  blk 
    R> BLK !                        \ pos src   -  R: L P  
    R> SOURCE-P !                   \ pos src   -  R: L 
    R> SOURCE-L !                   \ pos src   -  R:
    
    1+      \ so that -1 become 0   \ pos src+1
    IF 
        SOURCE-ID @                 \ pos src
        IF
            SOURCE-ID @ F_SEEK      \ f
            [ 43 ] LITERAL ?ERROR   \
        ELSE
            \ ignore fake handle-position or string-data
            2DROP                   \
        THEN    
    ELSE 
        \ ignore string-spec parameter
        2DROP                       \ 
    THEN
; 

BASE !
\
