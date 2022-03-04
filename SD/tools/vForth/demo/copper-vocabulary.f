( ZX-Next Copper )
NEEDS FLIP
NEEDS SPLIT
\
MARKER NO-COPPER      \ then you can use NO-COPPER to "forget" all the following definitions

VOCABULARY COPPER IMMEDIATE   \ define a new Vocabulary
COPPER DEFINITIONS    \ new definitions are inside COPPER vocabulary
\
HEX 061 CONSTANT COP-CTRL-LO    \ Copper control Low byte
HEX 062 CONSTANT COP-CTRL-HI    \ Copper control High byte
HEX 063 CONSTANT COP-WRITE      \ Copper data 16-bit write
    VARIABLE COP-IDX            \ Used for debugging purposes

HEX
\ copy single instruction to copper memory
\ display to video what's being uploaded
: UPLOAD ( n -- )
    SPLIT   
    COP-IDX @ . 3A EMIT SPACE 2DUP . . CR    \ for debugging 
    COP-WRITE REG!  
    COP-WRITE REG!   
    1 COP-IDX +! 
;

\ stop copper and set data upload index to 0
: STOP  ( -- )
    0 COP-CTRL-LO REG! 
    0 COP-CTRL-HI REG! 
    0 COP-IDX ! 
;

\ start copper in mode %11 - reset on every vertical blank
: START ( -- )
    0   COP-CTRL-LO REG! 
    0C0 COP-CTRL-HI REG! 
;

HEX
: WAIT ( v h -- )       \ v-vertical (0-311) h-horizontal (0-55)
    3F AND 2* FLIP SWAP \ compose horizontal part
    1FF AND             \ compose vertical part
    OR                  \ merge
    8000 OR             \ set bit-15.
    UPLOAD 
;
    

: MOVE ( v r -- )       \ v-alue and r-egister (0-127)
    7F  AND  FLIP SWAP  \ force register 0-127
    0FF AND             \ force value 0-255
    OR                  \ merge
    UPLOAD              
;

: NOOP ( -- )           \ does nothing for one horizontal position.
  0     UPLOAD ;        

: HALT ( -- )           \ stop furhter copper processing
    0FFFF UPLOAD
    [COMPILE] FORTH     \ restore FORTH as CURRENT vocabulary    
;

FORTH DEFINITIONS DECIMAL

( ZX-Next Copper - Example )
NEEDS LAYERS
COPPER STOP
  HEX
  00   00    WAIT   \ Wait for scan-line 0, pos 0
  02   16    MOVE   \ Shift 2 pixel in Layer2 Horizontal Scroll (16h)
  60   00    WAIT   \ Wait for scan-line 96 = 60h
  00   16    MOVE   \ Shift 0 pixel in Layer2 Horizontal Scroll (16h)
             HALT

