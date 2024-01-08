\
\ -^EXECUTE.f
\ 
\ for -?EXECUTE
\
.( -?EXECUTE )
\
\

BASE @ HEX \ save base status

\ used in the form
\
\  -?EXECUTE cccc
\ 
\ search for cccc and execute it if exists.
\ do nothing when not found.
\
: -?EXECUTE  ( -- )
    -FIND 
    if 
        drop 
        execute 
    then ;

BASE !
