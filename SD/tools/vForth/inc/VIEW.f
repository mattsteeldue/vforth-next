\
\ view.f

.( VIEW )

\ Typical usage
\
\   VIEW filename
\
\ Parse filename from input, move it to PAD as z-string,
\ then display the file via VIEW-FILE-PAD.
\ If file not exists, report message 43 "File not found."
\
BASE @
DECIMAL

NEEDS >ZPAD
NEEDS VIEW-FILE-PAD

: VIEW ( -- cccc )
    BL WORD COUNT >ZPAD
    VIEW-FILE-PAD
;

BASE !

