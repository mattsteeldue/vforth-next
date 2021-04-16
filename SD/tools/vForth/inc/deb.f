\
\ DEB.f
\
.( DEB ) 
\
NEEDS .S
\ debugging display
\
: DEB ( n -- )
    ." debug " . .S ."  -- "
    R0 @ RP@ 2+ ?DO
        I @ U.
    2 +LOOP ;
