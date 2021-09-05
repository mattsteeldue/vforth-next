\
\ grep.f
\
.( GREP included ) 6 EMIT
\ search for text word inside the first 1000 screens.

NEEDS BSEARCH

: GREP       
    1 1000 BSEARCH 
;
