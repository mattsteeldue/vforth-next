\
\ UNLINK.f
\
\ accept the following string as a filename and remove it from disk
\ and there is no way to recovery ...
\
\ Typical usage:   UNLINK <filename>
\ If no drive letter is given in <filename>, F_UNLINK falls back to
\ the current default drive ('*').
\

NEEDS F_UNLINK

BASE @

DECIMAL

: UNLINK ( -- )
    BL WORD COUNT 2DUP  \  a n a n
    OVER +              \  a n a a+n
    0 SWAP C!           \  a n a
    F_UNLINK            \  a n f
    IF 
        43 MESSAGE CR     
        ." Perhaps you meant c:" 
        TYPE SPACE
    ELSE
        2DROP
    THEN
;

BASE !
