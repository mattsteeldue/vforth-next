\ 08-03.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/08-functions-03.txt
\ guide: doc/basic-to-vforth/08-functions.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 LET a$=STR$ 1984
\   20 PRINT LEN a$
\   30 PRINT VAL a$+16
\   40 PRINT VAL "2*3"
\   50 PRINT STR$ (255,16)

\ --- words defined earlier in the guide

\ 08-functions.md:161
: STR$  ( n -- a u )  DUP ABS 0 <# #S ROT SIGN #> ;
-123 STR$ TYPE                  \ => -123
100 STR$ NIP .                  \ => 3

\ 08-functions.md:182
: BASE$  ( u base -- a u )
    BASE @ >R  BASE !  0 <# #S #>  R> BASE ! ;
100 16 BASE$ TYPE               \ => 64
3 2 BASE$ TYPE                  \ => 11
35 36 BASE$ TYPE                \ => Z

\ 08-functions.md:200
NEEDS S"
NEEDS >NUMBER
: VAL  ( a u -- n )  0 0 2SWAP >NUMBER 2DROP DROP ;
: T1  S" 1984" VAL 16 + . ;
T1                              \ => 2000
: T2  S" 12AB" VAL . ;
T2                              \ => 12
: T3  S" -5" VAL . ;
T3                              \ => 0

\ --- the translation

\ 08-functions.md:339
1984 STR$ NIP .                 \ => 4
1984 STR$ VAL 16 + .            \ => 2000
S" 2 3 *" EVALUATE .            \ => 6
255 16 BASE$ TYPE               \ => FF
