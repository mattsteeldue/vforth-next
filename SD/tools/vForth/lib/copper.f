\
\ copper.f
\
( ZX-Next Copper )
NEEDS FLIP
NEEDS SPLIT
\
MARKER NO-COPPER      \ then you can use NO-COPPER to "forget" all the following definitions

HEX 061 CONSTANT COP-CTRL-LO    \ Copper control Low byte
HEX 062 CONSTANT COP-CTRL-HI    \ Copper control High byte
HEX 063 CONSTANT COP-WRITE      \ Copper data 16-bit write
    VARIABLE COP-IDX            \ Used for debugging purposes

HEX
\ copy single instruction to copper memory
\ display to video what's being COP-UPLOADed
: COP-UPLOAD ( n -- )
    SPLIT   
\   COP-IDX @ . 3A EMIT SPACE 2DUP . . CR    \ for debugging 
    COP-WRITE REG!  
    COP-WRITE REG!   
    1 COP-IDX +! 
;

\ COP-STOP copper and set data COP-UPLOAD index to 0
: COP-STOP  ( -- )
    0 COP-CTRL-LO REG! 
    0 COP-CTRL-HI REG! 
    0 COP-IDX ! 
;

\ COP-START copper in mode %11 - reset on every vertical blank
: COP-START ( -- )
    0   COP-CTRL-LO REG! 
    0C0 COP-CTRL-HI REG! 
;

HEX
: COP-WAIT ( v h -- )       \ v-vertical (0-311) h-horizontal (0-55)
    3F AND 2* FLIP SWAP \ compose horizontal part
    1FF AND             \ compose vertical part
    OR                  \ merge
    8000 OR             \ set bit-15.
    COP-UPLOAD 
;
    

: COP-MOVE ( v r -- )       \ v-alue and r-egister (0-127)
    7F  AND  FLIP SWAP  \ force register 0-127
    0FF AND             \ force value 0-255
    OR                  \ merge
    COP-UPLOAD              
;

: COP-NOOP ( -- )           \ does nothing for one horizontal position.
  0     COP-UPLOAD ;        

: COP-HALT ( -- )           \ COP-STOP furhter copper processing
    0FFFF COP-UPLOAD
;

: COPPER ;
