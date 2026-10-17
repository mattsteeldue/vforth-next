\ 12-05.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/12-conditions-05.txt
\ guide: doc/basic-to-vforth/12-conditions.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 LET a$="pear": LET b$="apple"
\   20 IF b$<a$ THEN LET t$=a$: LET a$=b$: LET b$=t$
\   30 PRINT a$;" ";("<" AND a$<b$);("=" AND a$=b$);" ";b$

\ --- the translation

\ 12-conditions.md:254
NEEDS COMPARE
: ORDER  ( a1 u1 a2 u2 -- )
    2OVER 2OVER COMPARE 0> IF  2SWAP  THEN
    2OVER TYPE SPACE
    2OVER 2OVER COMPARE >R
    S" <" R@ 0< AND TYPE  S" =" R> 0= AND TYPE
    SPACE TYPE 2DROP ;
: T1  S" pear" S" apple" ORDER ;
: T2  S" fig" S" fig" ORDER ;
: T3  S" Pear" S" apple" ORDER ;
T1                              \ => apple < pear
T2                              \ => fig = fig
T3                              \ => apple < Pear
