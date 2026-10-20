\ 03-06.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/03-06.txt
\ guide: doc/basic-to-vforth/03-looping.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 LET n=1000: LET c=0
\   20 REPEAT
\   30   LET n=INT (n/2): LET c=c+1
\   40 REPEAT UNTIL n=0
\   50 PRINT c

\ --- the translation

\ 03-looping.md:310
: HALVINGS  ( n -- count )
    0 SWAP              \ count, under n
    BEGIN
        2/  SWAP 1+ SWAP
        DUP 0=
    UNTIL
    DROP ;
1000 HALVINGS .         \ => 10
