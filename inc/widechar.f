\
\ widechar.f
\
\ Layers 1 .. 2
\ set 8-bits wide character set
\
.( WIDECHAR )
\

BASE @

: WIDECHAR

    $1E EMITC 8 EMITC
;

BASE !
