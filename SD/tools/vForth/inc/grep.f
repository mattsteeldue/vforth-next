\
\ grep.f
\
.( GREP )
\ search for text word inside the first 2000 screens.

NEEDS BSEARCH

: GREP       
    1 2000 BSEARCH 
;
