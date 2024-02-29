\
\ f_getfree.f
\

BASE @

NEEDS F_GETFREE

DECIMAL 

\ display free space on default drive

: .FREE-SIZE ( -- )
    [CHAR] * F_GETFREE \ d f \ d is the number of 512-bytes block free on drive
    NOT IF
        ?dup if
            dup 29 > if     nip 3 /        0   [char] G
                     else   200 um/mod nip 0   [char] M  then
        else
            5 um* over 9995 swap u<
                     if    1024 um/mod nip 0   [char] M
                     else                      [char] K  then
        then >R
        <# # [char] . hold #s #> type space R> emit
      
        ." bytes free on default drive." CR
    ELSE
        2DROP
    THEN
;

BASE !
