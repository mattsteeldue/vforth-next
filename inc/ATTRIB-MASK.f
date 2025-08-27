\
\ attrib-mask.f
\
.( ATTRIB-MASK )

NEEDS IDE_MODE@ 

CREATE ATTRIB-MASK-TABLE
    7  C,   \ LAYER0
   -1  C,   \ LAYER10
   -1  C,   \ LAYER2
    0  C,   
    0  C,   
    7  C,   \ LAYER11
    0  C,   
    0  C,   
    0  C,   
    7  C,   \ LAYER12
    0  C,   
    0  C,   
    0  C,   
    7  C,   \ LAYER13


\ returns 7 or -1 as mask to be applied to a byte attribute.o
: ATTRIB-MASK  ( b1 -- b2 )
    IDE_MODE@         \ b1 n 
    >R 2DROP DROP R>  \ b1 n
    ATTRIB-MASK-TABLE \ b1 n a
    + C@ AND          \ b2 
;
