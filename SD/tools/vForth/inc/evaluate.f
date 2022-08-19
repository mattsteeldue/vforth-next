\
\ evaluate.f
\
\ Interpret a text-string
\ In this implementation EVAULATE cannot be nested, for now.
\ Maximum string length is 512.
\
.( EVALUATE )
\
BASE @

DECIMAL

: EVALUATE ( a u -- )

    source-id  @ -1 = 34 ?error \ error if nesting EVALUATE.

    blk        @  >r  
    >in        @  >r  
    source-id  @  >r 
    
    \ if SOURCE-ID was non zero (i.e. we were during a F_INCLUDE)
    \ try to save its position and close the file-handle.
    r@ 
    If 
        r@ f_fgetpos [ 44 ] Literal ?error 
        \ must rewind to the beginning of the current line
        >in @ 2-  span @  -  s>d d+
    Else 
        0 0         \ 0 0 fake handle-position
    Then 
    >r >r           \ save previous (double) handle-position if any...
    
    -1 source-id !
    1  blk       ! 
    0  >in       !     


    1 block b/buf BLANK 
    1 block swap b/buf min   \ maximum string
    cmove
    interpret    

    \ restore previous Handle-position
    r> r> 
    \ restore SOURCE-ID
    r>   
    dup source-id !
    If 
        source-id @ f_seek [ 43 ] Literal ?error 
    Else 
        2drop       \ ignore 0 0 fake handle-position.
    Then
    \ restore >IN, BLK
    r> >in !  
    r> blk !
; 

BASE !
\
