\
\ R.f
\
.( R obsolete: prefer R@ ) 6 EMIT
\
\ Return-Stack Top value - OLD VERSION
\
: R ( -- n )
    RP@ CELL+ @ 
;
