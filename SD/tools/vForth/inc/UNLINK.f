\
\ UNLINK.f
\
\ accept the following string as a filename and remove it from disk
\
\ Typical usage:   UNLINK <filename>
\
\

BASE @

CODE F_UNLINK ( a -- f )
HEX        
        DD C, E3 C,     \  ex (sp), ix
        D5 C,           \  push de
        C5 C,           \  push bc
        F3 C,           \  di
        CF C,           \  rst  8
        C1 C,           \  pop  bc
        D1 C,           \  pop  de
        DD C, E1 C,     \  pop  ix
        FB C,           \  ei
        ED C, 62 C,     \  sbc  hl,hl
        E3 C,           \  push hl
        DD C, E9 C,     \  jp (ix)
SMUDGE

: UNLINK ( -- cccc )
    BL WORD COUNT       \  a  n
    OVER + 0 SWAP !     \  a  
    F_UNLINK DROP
;

BASE !
