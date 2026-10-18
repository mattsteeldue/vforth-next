\ 12-02.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/12-02.txt
\ guide: doc/basic-to-vforth/12-conditions.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 INPUT a,b
\   20 PRINT (a AND NOT a<b)+(b AND a<b)

\ --- the translation

\ 12-conditions.md:195
: LARGER  ( a b -- n )
    2DUP <  >R R@ AND
    SWAP R> NOT AND + ;
3 8 LARGER .  8 3 LARGER .  5 5 LARGER .        \ => 8 8 5
