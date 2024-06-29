\
\ USE.f
\
.( USE )

NEEDS F_FSTAT

BASE @ DECIMAL

\ 
\
: USE ( -- cccc )
  OPEN<                         \ fh
  BLK-FH @ F_CLOSE DROP         \ close previous file, ignore error
  DUP BLK-FH !                  \ 
  HERE SWAP F_FSTAT DROP
  HERE 7 + 2@ SWAP 
  512 UM/MOD NIP 1-
  [ ' #SEC >BODY ] LITERAL
  !
;

BASE !
