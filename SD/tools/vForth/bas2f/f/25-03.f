\ 25-03.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/25-using-machine-code-03.txt
\ guide: doc/basic-to-vforth/25-using-machine-code.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 CLEAR USR "A"-81
\   20 LET addr=USR "A"-80
\   30 FOR N=0 TO 6: READ byte: POKE addr+N,byte: NEXT N
\   40 PRINT USR (addr,$0C0B)
\   50 DATA $50,$59,$ED,$30,$42,$4B,$C9

\ --- the translation

\ 25-using-machine-code.md:66
NEEDS ASSEMBLER
CODE TIMES  ( u1 u2 -- u )
    exx
    pop hl|  ld e'| l|
    pop hl|  ld d'| l|
    mul
    push de|
    exx
    NEXT
C;
12 11 TIMES .                   \ => 132
