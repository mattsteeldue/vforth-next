\
\ evaluate.f
\
\ Interpret a text-string
\ In this implementation EVAULATE cannot be nested.
\ Maximum string length is 512.
\
.( EVALUATE included ) 6 EMIT
\
: EVALUATE ( a u -- )

    1 block b/buf erase
    1 block swap b/buf min 
    cmove

    blk        @  >r  
    >in        @  >r  
    source-id  @  >r 
    
    -1 source-id !
    1  blk       ! 
    0  >in       !     

    interpret    

    r>  source-id  !
    r>  >in        !  
    r>  blk        !
; 

