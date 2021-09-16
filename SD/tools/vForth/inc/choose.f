\
\ choose.f
\
\ Leo Brodie - Starting Forth
\ generate random number u2 between 0 and u-1.
\
.( CHOOSE )
\
NEEDS RANDOM
\
: CHOOSE ( u -- u2 )
    RANDOM
    UM* 
    NIP
;
