\ du{.f
\
.( DU< )
\
: DU< ( d1 d2 -- f )    \  l1 h1 l2 h2
    ROT                 \  l1 l2 h2 h1
    SWAP                \  l1 l2 h1 h2
    U<                  \  l1 l2 h1<h2
    -ROT                \  h1<h2 l1 l2 
    U<                  \  h1<h2 l1<l2 
    AND                 \  f
;
