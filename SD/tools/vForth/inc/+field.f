\
\ +field.f
\
.( +FIELD )
\
: +FIELD  \ n <"name"> -- ; Exec: addr -- 'addr
    <BUILDS
        OVER , +
    DOES> 
        @ +
;

\ Tipical usage
\   0                         \ initial total byte count
\      1 CELLS +FIELD  p.x    \ A single cell filed named p.x
\      1 CELLS +FIELD  p.y    \ A single cell field named p.y
\   CONSTANT point-len        \ save structure size
