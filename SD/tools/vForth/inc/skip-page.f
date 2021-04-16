\
\ skip-page.f
\

NEEDS HP@

\ check if  n  more bytes are available in this 8K-page in Heap
\ otherwise skip HP to the beginning of next 8K-page
: SKIP-PAGE ( n -- )
    [ HEX 1FFF ] LITERAL >R
    HP@  CELL+  R  AND
    +  R  >
    IF
        HP@  R> OR 1+  HP !
    ELSE
        R> DROP
    THEN
    HP@  0=  [ DECIMAL 12 ] LITERAL  ?ERROR
;
\
