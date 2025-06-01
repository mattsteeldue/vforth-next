\
\ invv.f
\
\ Inverse/True Video character sequence
\
.( INVV )

BASE @ \ save base status
\
\ INVV
: INVV ( -- )
  [ $14 ] LITERAL EMITC
  1 EMITC
;

BASE !
