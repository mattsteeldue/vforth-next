\ 12-03.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/12-03.txt
\ guide: doc/basic-to-vforth/12-conditions.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 INPUT "Net price? ";n
\   20 INPUT "Zero rated (y/n)? ";v$
\   30 PRINT n*(1.15 OR v$="y")

\ --- the translation

\ 12-conditions.md:223
: GROSS  ( net zero? -- gross )
    0= IF  115 100 */  THEN ;
200 0 GROSS .  200 -1 GROSS .                   \ => 230 200
: GROSS  ( net zero? -- gross )
    0=  OVER 15 100 */  AND  + ;
200 0 GROSS .  200 -1 GROSS .                   \ => 230 200
