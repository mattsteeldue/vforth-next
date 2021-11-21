\ dmax.f
\
.( DMAX )

\
NEEDS 2OVER
NEEDS D<

: DMAX ( d1 d2 -- f )
  2OVER 2OVER  \ as 4DUP
  D< IF
    2SWAP
  THEN
  2DROP
;
