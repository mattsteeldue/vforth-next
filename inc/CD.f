\
\ cd.f
\
.( CD )
\
\ change current directory. Used in the form:
\
\   CD  "cccc"
\
\ example  CD C:/tools/vForth
\
\ Warning *** changing to a different directory impede any subsequent 
\ Warning *** use of NEEDS until current directory is restored to its default.

NEEDS IDE_PATH

BASE @

DECIMAL

: CD ( -- )
    BL WORD COUNT       \  a  n             -- append cccc
    OVER + 1+           \  a  a+n+1         
    $FF SWAP C!         \  a                -- append 0xFF
    0 IDE_PATH          \  f                -- change directory
    37 ?ERROR           \                   -- signal not found ?
;

BASE !
