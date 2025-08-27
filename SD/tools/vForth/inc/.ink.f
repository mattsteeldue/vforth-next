\
\ .ink.f
\
.( .INK )
\

NEEDS ATTRIB-MASK 

: .INK  ( b -- )
    #16 EMITC 
    ATTRIB-MASK EMITC
;

