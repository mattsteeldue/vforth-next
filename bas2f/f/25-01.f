\ 25-01.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/25-01.txt
\ guide: doc/basic-to-vforth/25-using-machine-code.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 CLEAR USR "A"-81
\   20 LET addr=USR "A"-80
\   30 FOR N=0 TO 3: READ byte: POKE addr+N,byte: NEXT N
\   40 PRINT USR addr
\   50 DATA 1,80,0,$C9

\ --- the translation

\ 25-using-machine-code.md:100
NEEDS CALL#
DECIMAL
CREATE MC  1 C, 80 C, 0 C, $C9 C,     \ ld bc,80 : ret
0 MC CALL# .                    \ => 80
