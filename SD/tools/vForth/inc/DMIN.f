\ dmin.f
\
.( DMIN )

\
NEEDS 2OVER
NEEDS D<

: DMIN ( d1 d2 -- f )
  2OVER 2OVER  \ as 4DUP
  D< IF
    2DROP
  ELSE
    2SWAP 2DROP
  THEN
;
