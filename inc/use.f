\
\ USE.f
\
.( USE )

NEEDS F_FSTAT

BASE @ DECIMAL

\ 
\
: USE ( -- cccc )
  OPEN<                         \ open following filename giving fh
  BLK-FH @ F_CLOSE DROP         \ close previous file, ignore error
  BLK-FH !                      \ store fh
\ HERE BLK-FH @ F_FSTAT DROP    \ Get statistics, ignore error
\ HERE 7 + 2@ SWAP              \ swap two integers to get real length
\ B/BUF UM/MOD NIP 1-           \ compute how many blocks-unit
\ 1 MAX
\ $7FFF MIN                     \ cannot be larger than that
\ [ ' #SEC >BODY ] LITERAL      \ store in data address of #SEC
\ !
;

BASE !
