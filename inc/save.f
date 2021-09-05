\
\ save.f
\
.( SAVE included ) 6 EMIT
\
\ save
: SAVE ( -- ) \ save all modified screens flushing to disk
    UPDATE FLUSH 
;
\
