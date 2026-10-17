\ 25-02.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/25-using-machine-code-02.txt
\ guide: doc/basic-to-vforth/25-using-machine-code.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 CLEAR USR "A"-81
\   20 LET addr=USR "A"-80
\   30 FOR N=0 TO 5: READ byte: POKE addr+N,byte: NEXT N
\   40 PRINT USR (addr,21)
\   50 DATA $60,$69,$29,$44,$4D,$C9

\ --- the translation

\ 25-using-machine-code.md:206
NEEDS CALL#
DECIMAL
CREATE TW
    $60 C,                      \ ld h,b
    $69 C,                      \ ld l,c
    $29 C,                      \ add hl,hl
    $44 C,                      \ ld b,h
    $4D C,                      \ ld c,l
    $C9 C,                      \ ret
21 TW CALL# .                   \ => 42
CODE TWICE  ( n -- 2n )
    $E1 C,                      \ pop hl
    $29 C,                      \ add hl,hl
    $E5 C,                      \ push hl
    $DD C, $E9 C,               \ jp (ix)
    SMUDGE
21 TWICE .                      \ => 42
