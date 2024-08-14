\
\ narrowchar.f
\
\ Layers 1 .. 2
\ set 4-bits narrow character set
\
.( NARROWCHAR )
\

BASE @

: NARROWCHAR

    $1E EMITC 4 EMITC

;

BASE !
