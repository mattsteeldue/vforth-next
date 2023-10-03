\
\ USE.f
\
.( USE )

BASE @ DECIMAL

\ 
\
: USE ( -- cccc )
  open<                         \ fh
  BLK-FH @ F_CLOSE DROP         \ close BLOCKs file and ignore any error
  blk-fh !
;

BASE !
