\
\ >TYPE.f
\
.( >TYPE )

NEEDS EDITOR

BASE @ DECIMAL

\
\ Same as TYPE except that the output string is moved to the PAD 
\ prior to output.
\ Useful for HEAP string to be sure MMU7 won't page it away.
\
: >TYPE ( a u -- )
    >R
    PAD R@ CMOVE
    PAR R> TYPE    
;

BASE !
