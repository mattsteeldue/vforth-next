\
\ DEB.f
\
.( DEB )
\
NEEDS .S
\ debugging display
\ Show "Debug n" followed by Calc-Stack content and Return-Stack content
\
: DEB ( n -- )
    ." debug " . .S ."  -- "
    R0 @ RP@ 2+ ?DO
        I @ U.
    2 +LOOP ;
