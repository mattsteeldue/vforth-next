\
\ dosver.f
\
.( DOSVER )
\

BASE @

NEEDS M_DOSVERSION

\ Print the NextZXOS version and language code, eg "NextZXOS v2.08 en"
: DOSVER  ( -- )
    BASE @ 
    M_DOSVERSION 
    HEX 0 <# # # [CHAR] . HOLD # #> TYPE
    BASE !
;

BASE !
