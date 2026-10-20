\ 04-05.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/04-05.txt
\ guide: doc/basic-to-vforth/04-procedures-and-subroutines.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 PROC gcd(48,18) TO g
\   20 PRINT g
\   30 STOP
\   40 DEFPROC gcd(a,b)
\   50   LOCAL r
\   60   IF b=0 THEN ENDPROC =a
\   70   PROC gcd(b,a MOD b) TO r
\   80 ENDPROC =r

\ --- the translation

\ 04-procedures-and-subroutines.md:435
: GCD  ( a b -- gcd )
    ?DUP IF  SWAP OVER MOD  RECURSE  THEN ;
48 18 GCD .                     \ => 6
17 5 GCD .                      \ => 1
