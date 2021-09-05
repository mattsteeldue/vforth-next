\
\ .word.f
\
.( .WORD included ) 6 EMIT
\
\ .word
\ given a cfa or an xt, it determines the name and shows it using ID.
: .WORD ( cfa -- ) 
    >BODY NFA ID. 
;
\
