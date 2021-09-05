\
\ room.f
\
.( ROOM included ) 6 EMIT
\
NEEDS UNUSED
\ room
: ROOM ( -- ) \ display room available in dictionary
    UNUSED U. ." bytes free." CR 
;
\
