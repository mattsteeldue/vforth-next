\
\ source.f
\
.( SOURCE )

\ a is the address of, and u is the number of characters in, the input buffer.

: SOURCE ( -- a u )

  BLK @ IF
    >IN @ BLK @ B/SCR /MOD -ROT          \ scr  in  r
    B/BUF * + C/L / SWAP                 \ row  scr
    (LINE)                               \ a n
  ELSE
    TIB @ 24                             \ whatever...
  THEN
;

