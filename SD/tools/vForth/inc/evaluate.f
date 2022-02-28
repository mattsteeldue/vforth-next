\
\ evaluate.f
\
\ Interpret a text-string
\ In this implementation EVAULATE cannot be nested.
\ Maximum string length is 512.
\
.( EVALUATE )
\
: EVALUATE ( a u -- )

    3 block b/buf erase
    3 block swap b/buf min 
    cmove

    blk        @  >r  
    >in        @  >r  
    source-id  @  >r 
    
    -1 source-id !
    3  blk       ! 
    0  >in       !     

    interpret    

    r>  source-id  !
    r>  >in        !  
    r>  blk        !
; 

