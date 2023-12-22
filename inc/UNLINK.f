\
\ UNLINK.f
\
\ accept the following string as a filename and remove it from disk
\ and there is no way to recovery ...
\
\ Typical usage:   UNLINK <filename>
\ At this moment, you must specify the drive e.g.  unlink c:dummy.f
\ Despite it could be deemed a bug, I keep this behavior to
\ improve security and avoid unwanted destructive operations.
\
\

BASE @

CODE F_UNLINK ( a -- f )
HEX        
        DD C, E3 C,     \  ex (sp), ix
        D5 C,           \  push de
        C5 C,           \  push bc
        3E C, 43 C,     \  ld   a, "C"
        F3 C,           \  di
        CF C, AD C,     \  rst  8
        C1 C,           \  pop  bc
        D1 C,           \  pop  de
        DD C, E1 C,     \  pop  ix
        FB C,           \  ei
        ED C, 62 C,     \  sbc  hl,hl
        E5 C,           \  push hl
        DD C, E9 C,     \  jp (ix)
SMUDGE
DECIMAL

: UNLINK ( -- )
    BL WORD COUNT       \  a  n
    OVER + 0 SWAP !     \  a  
    F_UNLINK 44 ?ERROR
;

BASE !
