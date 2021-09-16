\
\ .word.f
\
.( .WORD )
\
\ .word
\ given a cfa or an xt, it determines the name and shows it using ID.
: .WORD ( cfa -- ) 
    >BODY NFA ID. 
;
\
